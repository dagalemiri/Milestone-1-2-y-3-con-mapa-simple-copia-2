//
//  mapa.swift
//  MMMilestone2
//
//  Created by David Galemiri on 26-05-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import AddressBook
import AddressBookUI

class mapa: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate, NSStreamDelegate,TcpDelegate {
    
    //Outlets y variables
    @IBOutlet weak var mapView: MKMapView!
    
    private var server : TcpListener?
    private var outputStream : NSOutputStream?
    private var inputStream : NSInputStream?
    var anotacion:MKPointAnnotation? =  MKPointAnnotation()
    var puertoServidor = UInt32()
    var ipServidor = ""
    var servidor : TcpListener!
    var verificadorCliente = false
    var diccionarioNumeroAnnotation = Dictionary<String, MKAnnotation>()
    var clientes = [cliente]()
    let locationManager = CLLocationManager()
    let total:CLLocationDistance = 50.0
    
    // Evento que se lanza al presionar el boton para compartir la ubicacion con contactos
    @IBAction func compartirUbicacion(sender: AnyObject) {
        interaccionServidor.compartirUbicacion(["56962448489","56961567267","56981362982"],puerto:String(puertoServidor))
    }

    // Funcion que recibe los ip y puertos desde el servidor
    func recibirUbicaciones() {
        clientes = [cliente]()
        let request = NSMutableURLRequest(URL: NSURL(string: "http://guasapuc.herokuapp.com/api/v2/shared_locations?phone_number="+estaticos.numeroUsuario())!)
        request.HTTPMethod = "GET"
        request.addValue(estaticos.formatoToken(), forHTTPHeaderField: "Authorization")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            if error != nil {
                print("ERROR compartiendo ubicación: \(error)")
                return
            }
            let jsonSwift: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
            if let jsonArray = jsonSwift as? NSArray {
                print(jsonArray.count)
                for jsonMensaje in jsonArray {
                    if let jsonDictionary = jsonMensaje as? Dictionary<String, NSObject> {
                        let ip = jsonDictionary["ip"] as! String
                        let port = jsonDictionary["port"] as! String
                        print(ip)
                        print(port)
                        if ip != self.ipServidor {
                            let c = cliente()
                            c.crearCliente(ip, port: UInt32(Int(port)!))
                            self.clientes.append(c)
                        }
                    }
                }
            }
            if self.clientes.count == 0 {
                let alert = UIAlertView()
                alert.title = "No hay personas compartiendo su ubicacion :("
                alert.message = "Intenta en un rato!"
                alert.addButtonWithTitle("OK")
                alert.show()
            }
        }
        task.resume()
    }

    // Evento que se activa al presionar el UISwitch
    @IBAction func enviarUbicacion(sender: AnyObject) {
        let s = sender as! UISwitch
        if s.on {
          print("on")
          self.recibirUbicaciones()
        }
        else {
            print("off")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ipServidor = estaticos.getIPAddresses()
        if ipServidor != "" {
            print(ipServidor)
            print("hay")
            if (server == nil) {
                server = TcpListener()
            }
            if let tcp = server {
                tcp.configure()
                servidor = tcp
                print(server?.port)
                puertoServidor = tcp.port
                tcp.delegate = self
            }
            mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
        }
        else {
            let alert = UIAlertView()
            alert.title = "No se ha podido crear el servidor"
            alert.message = "Conectate a internet"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Metodo que actualiza la posicion y la envia como Json a los clientes.
    func actualizarPosicion(lat:Double,lon:Double) {
        let obj = [ "lat":Double(lat),"lng":Double(lon),"phone":estaticos.numeroUsuario()]
        let jsonData = try? NSJSONSerialization.dataWithJSONObject(obj, options: [])
        let jsonString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding) as! String
        let messageData = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        if clientes.count > 0 {
            for (var i = 0; i<clientes.count ; i++) {
                if i==(clientes.count)-1 {
                    clientes[i].outputStream!.write(UnsafePointer<UInt8>(messageData.bytes), maxLength: messageData.length)
                }
            }
        }
    }

    // Metodo que indica el valor de la posicion si se actualizaron la coordenadas
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        print("OldLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude)
        let lat = Double(newLocation.coordinate.latitude)
        let lon = Double(newLocation.coordinate.longitude)
        if clientes.count > 0 {
            self.actualizarPosicion(lat,lon:lon)
        }
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
        self.locationManager.stopUpdatingLocation()
        print(placemark.locality)
        print(placemark.postalCode)
        print(placemark.administrativeArea)
        print(placemark.country)
    }
    
    //Metodo que se lanza si hay errores al momento de actualizar la posicion
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription)
    }
    
    // Metodo asociado al socket
    func SocketReadCallback(_: CFSocket!, _: CFSocketCallBackType, _: CFData!, _: UnsafePointer<Void>, _: UnsafeMutablePointer<Void>) {
    }

    // Metodo que recibe ubicaciones de los contactos y las actualiza
    func receivedNewLocationUpdate(locationString: String!) {
        print("Llego una nueva localizacion"+locationString)
        let data = locationString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        let jsonSwift: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
        let jsonDictionary = jsonSwift as! Dictionary<String,NSObject>
        NSLog("Recibiendo localizacion: "+String(stringInterpolationSegment: jsonDictionary))
        let lat = jsonDictionary["lat"] as! Double
        let lon = jsonDictionary["lng"] as! Double
        let phone = jsonDictionary["phone"] as! String
        print(lat)
        print(lon)
        print(phone)
        self.actualizarPosicion(CLLocationDegrees(lon), lat: CLLocationDegrees(lat), numeroUsuario: phone)
    }
    
    // Se envia una alerta si se perdio la conexion y se pregunta si desea restablecerla
    func perdidaDeConeccion() {
        let refreshAlert = UIAlertController(title: "Se ha perdido la coneccion cliente-servidor", message: "Desea intentar restablecer la conexion?", preferredStyle: UIAlertControllerStyle.Alert)
        refreshAlert.addAction(UIAlertAction(title: "Si", style: .Default, handler: { (action: UIAlertAction) in self.recibirUbicaciones()}))
        refreshAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction) in print("Handle Cancel Logic here") }))
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    //Metodo que actaliza mi posicion en el mapa
    func actualizarPosicion(lon:CLLocationDegrees ,lat:CLLocationDegrees ,numeroUsuario:String) {
        if let aux = anotacion {
            mapView.removeAnnotation(aux)
        }
        let latitude:CLLocationDegrees = lat
        let longitude:CLLocationDegrees =  lon
        let churchLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let punto = MKPointAnnotation()
        punto.title = estaticos.buscarNumeroEnAgenda(numeroUsuario)
        punto.coordinate = churchLocation
        mapView.addAnnotation(punto)
        anotacion = punto
    }
}
