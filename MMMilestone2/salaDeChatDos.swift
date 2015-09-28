//
//  salaDeChatDos.swift
//  MMMilestone2
//
//  Created by David Galemiri on 12-05-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

import UIKit

class salaDeChatDos: UIViewController,UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    //Outlets y variables
    @IBOutlet weak var controller: UIViewController!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var salaDeChat: UILabel!
    @IBOutlet weak var escribirMensaje: UITextField!
    var content : String!
    var id : String!
    var mensajes = [Mensaje]()
    var url:String!
    var a = false
    let imagePicker = UIImagePickerController()
    
    //Metodo que refresca los mensajes
    func funcionRefresco() {
        interaccionServidor.obtenerMensajesConversacion(id)
        let conversaciones = estaticos.Fetch("Conversacion") as! [Conversacion]
        for conversacion in conversaciones {
            if (conversacion.id.stringValue == id) {
                self.mensajes = self.obtenerMensajesBD(conversacion)
                self.viewDidAppear(false)
                break
            }
        }
        tableView.reloadData()
    }

    //Evento que activa el refresco
    @IBAction func refrescar(sender: AnyObject) {
        self.funcionRefresco()
    }

    // Funcion que refresca el table view
    func q() {
          self.tableView.reloadData()
    }
    
    //  Metodo que envia mensajes si el mensaje no es vacio
    @IBAction func enviarMensaje(sender: AnyObject) {
        if escribirMensaje.text == "" {}
        else {
        interaccionServidor.enviarMensajesAConversacion(id,mensaje:escribirMensaje.text!)
        escribirMensaje.text = ""
        }
    }
    
    //Elimina el teclaod al presionar el boton return
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Elimina el teclado al tocar en cualquier parte
   override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Metodo del delegado que elimina los globos cuando las celdas desaparecen
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        for v in cell.subviews{
            if v is UIImageView{
                v.removeFromSuperview()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
         self.escribirMensaje.delegate = self;
        salaDeChat.text = content
        print(id)
        self.funcionRefresco()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "fondo1.jpg")!)
        self.tableView.backgroundColor = UIColor.clearColor()
        imagePicker.delegate = self
        tableView.reloadData()
        controller = self
        a = false
    }
    
    // Metodo que se invoca cuando se selecciona una imagen
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            dismissViewControllerAnimated(true, completion: nil)
            let imageData = UIImageJPEGRepresentation(pickedImage , 1.0)
            SRWebClient.POST("http://guasapuc.herokuapp.com/api/v2/conversations/send_file_message")
                .data(imageData!, fieldName:"file",
                    data:[
                        "file_mime_type":"image/jpeg",
                        "conversation_id":id,
                        "sender":estaticos.numeroUsuario()
                    ])
                .headers(["Authorization":estaticos.formatoToken()])
                .send({(response:AnyObject!, status:Int) -> Void in
                    NSLog(response.description)
                    },failure:{(error:NSError!) -> Void in
                        NSLog(error.description)
                })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Metodo que se lanza cuando se presiona cancelar en el image picker controller
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Evento que se activa al presionar el boton enviar imagen
    @IBAction func EnviarImagen(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // Metodo que crea las celdas
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mensajeChatDos") as! mensajeChatDos
        cell.backgroundColor = UIColor.clearColor()
        cell.enviadoPor.text = estaticos.getNameForContactNumber(mensajes[mensajes.count-indexPath.row-1].sender)
        if !mensajes[mensajes.count-indexPath.row-1].foto {
        cell.mensaje.text = mensajes[mensajes.count-indexPath.row-1].mensaje
        }
        else {
            cell.mensaje.text = "[DISPONIBLE IMAGEN]"
        }
        cell.mensaje.frame = CGRectMake(0, 0, cell.mensaje.intrinsicContentSize().width, CGFloat(10))
        var imageView:UIImageView!
        if cell.mensaje.intrinsicContentSize().width < cell.enviadoPor.intrinsicContentSize().width {
              imageView = UIImageView(frame:  CGRectMake(25, 0, cell.enviadoPor.intrinsicContentSize().width*CGFloat(1.2), CGFloat(50)))
        }
        else {
            imageView = UIImageView(frame:  CGRectMake(25, 0, cell.mensaje.intrinsicContentSize().width*CGFloat(1.2), CGFloat(50)))
        }
        imageView.image = UIImage (named : "ChatBubble")
        let myInsets : UIEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 20)
        imageView.image = imageView.image!.resizableImageWithCapInsets(myInsets)
        cell.mensaje.addSubview(imageView)
        cell.addSubview(imageView)
        cell.insertSubview(imageView, atIndex : 0 )
        return cell
    }
    
    //Metodo del delegado que se activa al presionar las celdas
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if mensajes[mensajes.count-indexPath.row-1].foto {
            url = mensajes[mensajes.count-indexPath.row-1].mensaje
            print("si", terminator: "")
            controller.performSegueWithIdentifier("imagen", sender: controller)
        }
    }
    
    //Metodo que se lanza antes de crear el view controller del segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "imagen" {
            let controller:MostrarImagenViewController = segue.destinationViewController as! MostrarImagenViewController
            controller.url = url
        }
    }
    
    //Numero de filas en las secciones
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mensajes.count
    }
    
    //Metodo que obtiene los mensajes de la base de datos
    func obtenerMensajesBD(conversacion:Conversacion) ->[Mensaje] {
        let a = conversacion.mensajesChat.array as! [Mensaje]
        print(a.count)
        for x in a {
            print(x.mensaje)
        }
        self.tableView.reloadData()
        return conversacion.mensajesChat.array as! [Mensaje]
    }
}
