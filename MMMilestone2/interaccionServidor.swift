//
//  interaccionServidor.swift
//  MMMilestone2
//
//  Created by David Galemiri on 12-05-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

import UIKit

class interaccionServidor: NSObject {
    //Variables
    weak var viewController : ViewController!
    
    //Metodo que obtiene los usuarios de una conversacion
    class func obtenerUsuariosConversacion(id:String) {
        let requestURL = NSURL(string:"http://guasapuc.herokuapp.com/api/v2/conversations/get_users?conversation_id="+id)!
        var request = NSMutableURLRequest(URL: requestURL)
        request.HTTPMethod = "GET"
        request.addValue(estaticos.formatoToken(),forHTTPHeaderField:"Authorization")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request){ data, response,error -> Void in
            var jsonSwift : AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            if let jsonArray = jsonSwift as? NSArray {
                for jsonContacto in jsonArray {
                    if let diccionarioContacto = jsonContacto as? Dictionary<String,NSObject> {
                        var idContacto = diccionarioContacto["id"] as! NSNumber
                        var nombreContacto = diccionarioContacto["name"] as! String
                        var numeroContacto = diccionarioContacto["phone_number"] as! String
                    }
                }
            }
        }
        task.resume()
    }
   
    // Metodo que crea una conversacion
    class func crearConversacion(titulo:String) {
        let request=NSMutableURLRequest(URL:NSURL(string:"http://guasapuc.herokuapp.com/api/v2/conversations")!)
        request.HTTPMethod="POST"
        request.addValue(estaticos.formatoToken(),forHTTPHeaderField:"Authorization")
        let postString="admin="+estaticos.numeroUsuario()+"&title="+titulo
        request.HTTPBody=postString.dataUsingEncoding(NSUTF8StringEncoding)
        var task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            var err: NSError?
            var json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as! NSDictionary
            var msg = "No message"
            if(err != nil) {
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
            }
            else {
                if let diccionarioContacto = json {
                    let idConversacion = diccionarioContacto["id"] as! NSNumber
                    let tituloConversacion = diccionarioContacto["title"] as! String
                    let numeroAdmin = diccionarioContacto["admin"] as! String
                    let group = diccionarioContacto["group"] as! Bool
                    if(!group){
                        Conversacion.createInManagedObjectContext(estaticos.moc(), id: idConversacion, titulo: tituloConversacion, numeroAdmin: numeroAdmin,group:false)
                        estaticos.save()}
                    return
                }
                else {
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        task.resume()
    }
    
    //Metodo que crea conversacion de dos
    class func crearConversacionDeADos(titulo:String,second:String) {
        let request=NSMutableURLRequest(URL:NSURL(string:"http://guasapuc.herokuapp.com/api/v2/conversations/create_two_conversation")!)
        request.HTTPMethod="POST"
        request.addValue(estaticos.formatoToken(),forHTTPHeaderField:"Authorization")
        let postString="first="+estaticos.numeroUsuario()+"&second="+second+"&title="+titulo
        request.HTTPBody=postString.dataUsingEncoding(NSUTF8StringEncoding)
        var task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            var err: NSError?
            var json :AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as!  NSDictionary
            var msg = "No message"
            if(err != nil) {
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                if let diccionarioContacto = json {
                    var idConversacion = diccionarioContacto["id"] as! NSNumber
                    var numeroAdmin = diccionarioContacto["admin"] as! String
                    var tituloConversacion = diccionarioContacto["title"] as! String
                    Conversacion.createInManagedObjectContext(estaticos.moc(), id: idConversacion, titulo: tituloConversacion, numeroAdmin: numeroAdmin, group:false)
                    estaticos.save()
                    return
                }
                else {
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        task.resume()
    }
    
    //Metodo que envia mensajes al servidor
    class func enviarMensajesAConversacion(id:String,mensaje:String) {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://guasapuc.herokuapp.com/api/v2/conversations/send_message")!)
        request.HTTPMethod = "POST"
        request.addValue(estaticos.formatoToken(),forHTTPHeaderField:"Authorization")
        let postString="conversation_id="+id+"&sender="+estaticos.numeroUsuario()+"&content="+mensaje
        request.HTTPBody=postString.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            var err: NSError?
            var json : AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as! NSArray
            if(err != nil) {
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
            }
            else {
                if let parseJSON = json as? NSDictionary{}
                else {
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        task.resume()
    }
    
    //Metodo que agrega usuarios al servidor
    class func agregarUsuariosAlServidor(numero:String,password:String,nombre:String) {
        let request = NSMutableURLRequest(URL:NSURL(string:"http://guasapuc.herokuapp.com/api/v2/users")!)
        request.HTTPMethod = "POST"
        request.addValue(estaticos.formatoToken(),forHTTPHeaderField:"Authorization")
        let postString="phone_number="+numero+"&password="+password+"&name="+nombre
        request.HTTPBody=postString.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            var err: NSError?
            var json :AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as! NSDictionary
            if(err != nil) {
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
            }
            else {
                if let parseJSON = json {}
                else {
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        task.resume()
    }

    // Metodo que descarga los mensajes de una conversacion
    class func obtenerMensajesConversacion(id:String) {
        let requestURL = NSURL(string:"http://guasapuc.herokuapp.com/api/v2/conversations/get_messages?conversation_id="+id)!
        var request = NSMutableURLRequest(URL: requestURL)
        request.HTTPMethod = "GET"
        request.addValue(estaticos.formatoToken(),forHTTPHeaderField:"Authorization")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request){ data, response,error -> Void in
            var jsonSwift : AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            if let jsonArray = jsonSwift as? NSArray {
                if jsonArray.count > 0 {
                    let a = jsonArray.count-1
                    let b = -1
                    for (var i = a ; i>b  ; i--) {
                        if let diccionarioContacto = jsonArray[i] as? Dictionary<String,NSObject> {
                            var idMensaje = diccionarioContacto["id"] as! NSNumber
                            var emisor = diccionarioContacto["sender"] as! String
                            var idConversacion = diccionarioContacto["conversation_id"] as! NSNumber
                            var fecha = diccionarioContacto["created_at"] as! String
                            if let mensaje = diccionarioContacto["content"] as? String {
                                let date = estaticos.stringAFecha(fecha)
                                var conversaciones = estaticos.Fetch("Conversacion") as! [Conversacion]
                                for conversacion in conversaciones {
                                    if (conversacion.id.stringValue == id ) {
                                        var m = Mensaje.createInManagedObjectContext(estaticos.moc(), fecha:date,idConversacion:idConversacion,idMensaje: idMensaje,mensaje: mensaje,sender: emisor,foto:false)
                                        conversacion.agregarMensajes(m)
                                    }
                                }
                                var conversacionesGrupales = estaticos.Fetch("ConversacionGrupal") as! [ConversacionGrupal]
                                for conversacion in conversacionesGrupales {
                                    if (conversacion.id.stringValue == id) {
                                        var m = Mensaje.createInManagedObjectContext(estaticos.moc(), fecha:date,idConversacion:idConversacion,idMensaje: idMensaje,mensaje: mensaje,sender: emisor,foto:false)
                                        conversacion.agregarMensajes(m)
                                    }
                                }
                            }
                            else {
                                    var file = diccionarioContacto["file"] as! Dictionary<String,NSObject>
                                    var url = file["url"] as! String
                                    let date = estaticos.stringAFecha(fecha)
                                    var conversaciones = estaticos.Fetch("Conversacion") as! [Conversacion]
                                    for conversacion in conversaciones {
                                        if (conversacion.id.stringValue == id ) {
                                            var m = Mensaje.createInManagedObjectContext(estaticos.moc(), fecha:date,idConversacion:idConversacion,idMensaje: idMensaje,mensaje: url,sender: emisor,foto:true)
                                            conversacion.agregarMensajes(m)
                                        }
                                    }
                                    var conversacionesGrupales = estaticos.Fetch("ConversacionGrupal") as! [ConversacionGrupal]
                                    for conversacion in conversacionesGrupales {
                                        if (conversacion.id.stringValue == id) {
                                            var m = Mensaje.createInManagedObjectContext(estaticos.moc(), fecha:date,idConversacion:idConversacion,idMensaje: idMensaje,mensaje:url,sender: emisor,foto:true)
                                            conversacion.agregarMensajes(m)
                                        }
                                    }
                                }
                            }
                     }
                }
           }
        }
        task.resume()
    }
    
    // Metodo que obtiene las conversaciones de un usuario
    class func obtenerConversacionesUsuario(telefono:String) {
        let requestURL = NSURL(string:"http://guasapuc.herokuapp.com/api/v2/users/get_conversations?phone_number="+telefono)!
        var request = NSMutableURLRequest(URL: requestURL)
        request.HTTPMethod = "GET"
        request.addValue(estaticos.formatoToken(),forHTTPHeaderField:"Authorization")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request){ data, response,error -> Void in
            if data != nil {
            var jsonSwift : AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            if let jsonArray = jsonSwift as? NSArray {
               for jsonContacto in jsonArray {
                   if let diccionarioContacto = jsonContacto as? Dictionary<String,NSObject> {
                      var idConversacion = diccionarioContacto["id"] as! NSNumber
                      var titulo = diccionarioContacto["title"] as! String
                      var numeroAdmin = diccionarioContacto["admin"] as! String
                      var group = diccionarioContacto["group"] as! Bool
                      if(!interaccionServidor.verificarSiExisteConversacion(idConversacion) && !group) {
                         Conversacion.createInManagedObjectContext(estaticos.moc(), id:idConversacion,titulo:titulo,numeroAdmin:numeroAdmin,group:false)
                         estaticos.save()
                      }
                      else if(!interaccionServidor.verificarSiExisteConversacionGrupal(idConversacion) && group) {
                          ConversacionGrupal.createInManagedObjectContext(estaticos.moc(), id:idConversacion,titulo:titulo,numeroAdmin:numeroAdmin,group:false)
                          estaticos.save()
                    }
                 }
            }
          }
        }
      }
     task.resume()
    }
    
    //Metodo que verifica si existe una conversacion guardada en la base de datos
    class func verificarSiExisteConversacion(id:NSNumber) -> Bool {
        let conversaciones = estaticos.Fetch("Conversacion") as! [Conversacion]
        for conversacion in conversaciones {
            if (conversacion.id == id) {
               return true
            }
        }
        return false
    }
    
    // Metodo que verifica si existe una conversacion grupal guardada en la base de datos
    class func verificarSiExisteConversacionGrupal(id:NSNumber) -> Bool {
        let conversaciones = estaticos.Fetch("ConversacionGrupal") as! [ConversacionGrupal]
        for conversacion in conversaciones {
            if (conversacion.id == id) {
                return true
            }
        }
        return false
    }
    
    //revisa si el contacto del celular esta registrado en el servidor
    class func obtenerContactosServidor() {
        let requestURL = NSURL(string:"http://guasapuc.herokuapp.com/users.json")!
        var request = NSMutableURLRequest(URL: requestURL)
        request.HTTPMethod = "GET"
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request){ data, response,error -> Void in
            if data != nil {
                var jsonSwift : AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                if let jsonArray = jsonSwift as? NSArray {
                    for jsonContacto in jsonArray {
                            if let diccionarioContacto = jsonContacto as? Dictionary<String,NSObject> {
                                var numero = diccionarioContacto["phone_number"] as! String
                                var nombre = diccionarioContacto["id"] as! NSNumber
                                if(!interaccionServidor.verificarSiExisteContacto(numero)) {
                                    Contacto.createInManagedObjectContext(estaticos.moc(),nombre:nombre.stringValue,numero: numero)
                                    estaticos.save()
                                }
                            }
                    }
                }
            }
        }
        task.resume()
    }
    
    //Verifica si existe un contacto en la base de datos
    class func verificarSiExisteContacto(numero:String) -> Bool {
        let contacto = estaticos.Fetch("Contacto") as! [Contacto]
        for c in contacto {
            if (c.numero == numero) {
                return true
            }
        }
        return false
    }
    
    //Metodo que crea un chat grupal
    static func crearChatGrupal(listaNumeros:[String],titulo:String) {
        let request = self.crearGrupoBody(listaNumeros,titulo:titulo)
        let session = NSURLSession.sharedSession()
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            var err: NSError?
            var json :AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as! NSDictionary
            if(err != nil) {
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
            }
            else {
                if let parseJSON = json {}
                else {
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        task.resume()
    }
    
    //Metodo que crea el body del chat grupal
    static func crearGrupoBody(usuarios:[String],titulo:String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL:NSURL(string:"http://guasapuc.herokuapp.com/api/v2/conversations/create_group_conversation")!)
        request.HTTPMethod="POST"
        request.addValue(estaticos.formatoToken(),forHTTPHeaderField:"Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let json = JSON(dictionaryLiteral: ("admin", estaticos.numeroUsuario()), ("users", usuarios), ("title",titulo))
        request.HTTPBody = json.rawString(NSUTF8StringEncoding)!.dataUsingEncoding(NSUTF8StringEncoding)
        return request

    }

    // Metodo que comparte la ubicacion
    static func requestCompartirUbicacion(usuarios:[String],puerto:String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL:NSURL(string:"http://guasapuc.herokuapp.com/api/v2/shared_locations")!)
        request.HTTPMethod="POST"
        request.addValue(estaticos.formatoToken(),forHTTPHeaderField:"Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let json = JSON(dictionaryLiteral: ("sender", estaticos.numeroUsuario()), ("ip", estaticos.getIPAddresses()), ("port", puerto), ("users", usuarios))
        request.HTTPBody = json.rawString(NSUTF8StringEncoding)!.dataUsingEncoding(NSUTF8StringEncoding)
        return request
    }
    
    // Metodo que comparte la ubicacion con contactos
    static func compartirUbicacion(listaNumeros:[String],puerto:String) {
        let request = self.requestCompartirUbicacion(listaNumeros,puerto:puerto)
        let session = NSURLSession.sharedSession()
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            var err: NSError?
            var json :AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as! NSDictionary
            if(err != nil) {
                print(err!.localizedDescription)
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                if let parseJSON = json {
                    print("Succes:")
                }
                else {
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        task.resume()
    }
    
    // Metodo que descarga las ubicaciones
    class func recibirUbicaciones() {
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
                    }
                }
            }
        }
        task.resume()
    }
}
