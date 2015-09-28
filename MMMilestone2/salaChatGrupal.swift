//
//  salaChatGrupal.swift
//  MMMilestone2
//
//  Created by David Galemiri on 19-05-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

import UIKit

class salaChatGrupal: UIViewController,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate {

    //Outlet y variables
    @IBOutlet weak var salaDeChat: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var escribirMensaje: UITextField!
    @IBOutlet weak var controller: UIViewController!
    
    var content: String!
    var id: String!
    var url :String!
    let imagePicker = UIImagePickerController()
    var mensajes = [Mensaje]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        salaDeChat.text = content
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "fondo2.jpg")!)
        self.tableView.backgroundColor = UIColor.clearColor()
        self.funcionRefresco()
        controller = self
        imagePicker.delegate = self
        self.escribirMensaje.delegate = self
        tableView.reloadData()
    }

    //Metodo que remueve las burbujas de las celdas que desaparecen de la pantalla
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        for v in cell.subviews {
            if v is UIImageView {
                v.removeFromSuperview()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Funcion que refresca los mensajes en el Table View
    func funcionRefresco() {
        interaccionServidor.obtenerMensajesConversacion(id)
        var conversaciones = estaticos.Fetch("ConversacionGrupal") as! [ConversacionGrupal]
        conversaciones.sortInPlace({ $1.id > $0.id })
        print(conversaciones.count)
        for conversacion in conversaciones {
            if (conversacion.id.stringValue == id) {
                self.mensajes = self.obtenerMensajesBD(conversacion)
                break
            }
        }
        tableView.reloadData()
    }
    
    // Evento que se activa al querer refrescar los mensajes
    @IBAction func refrescar(sender: AnyObject) {
        funcionRefresco()
        tableView.reloadData()
    }
    
    // Enento que envia mensajes al servidor
    @IBAction func enviarMensaje(sender: AnyObject) {
        interaccionServidor.enviarMensajesAConversacion(id,mensaje:escribirMensaje.text!)
        escribirMensaje.text = ""
    }
    
    // Metodo que hace aparecer las celdas en la tabla
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mensajeChatGrupal") as! mensajeChatGrupal
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
    
    //Numero de filas por seccion
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mensajes.count
    }

    //Metodo que obtiene los mensajes desde la base de datos
    func obtenerMensajesBD(conversacion:ConversacionGrupal) ->[Mensaje] {
        return conversacion.mensajesChatGrupal.array as! [Mensaje]
    }

    // Metodo que se activa cuando se selecciona una imagen
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            dismissViewControllerAnimated(true, completion: nil)
            let imageData = UIImageJPEGRepresentation(pickedImage , 1.0)
            SRWebClient.POST("http://guasapuc.herokuapp.com/api/v2/conversations/send_file_message")
                .data(imageData!, fieldName:"file",
                    data:["file_mime_type":"image/jpeg","conversation_id":id,"sender":estaticos.numeroUsuario()
                    ])
                .headers(["Authorization":estaticos.formatoToken()])
                .send({(response:AnyObject!, status:Int) -> Void in
                    NSLog(response.description)
                    },failure:{(error:NSError!) -> Void in NSLog(error.description)
                })
        }
    }
    
    //Funcion que se activa si se cancela el image picker
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Evento que se activa al presionar el boton enviar imagen
    @IBAction func EnviarImagen(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    //Metodo que se activa antes de crear el view controller dl segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "imagen" {
            let controller:MostrarImagenGrupalViewController = segue.destinationViewController as! MostrarImagenGrupalViewController
            controller.url = url
        }
    }
    
    //Metodo del delegado que se activa al seleccionar una celda
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if mensajes[mensajes.count-indexPath.row-1].foto {
            url = mensajes[mensajes.count-indexPath.row-1].mensaje
            print("si", terminator: "")
            controller.performSegueWithIdentifier("imagen", sender: controller)
        }
    }
    
    //Metodo que elimina el teclado al presionar el boton return
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Metodo que elimina el teclado presionando en algun lugar que no sea el teclado 
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}
