//
//  ViewController.swift
//  MMMilestone2
//
//  Created by David Galemiri on 12-05-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI

class ViewController: UIViewController, ABPeoplePickerNavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate {
    // Outlets y variables
    @IBOutlet weak var controller: UIViewController!
    @IBOutlet weak var tableView: UITableView!
    
    var selected = NSIndexPath()
    var textField: UITextField!
    var adbk: ABAddressBook!
    var authDone = false
    var person: ABRecord!
    var numero: String!
    var conversaciones = [Conversacion]()
    
    // Baja las conversaciones del usuario desde el servidor
    func bajarConversacionesDelServidor() {
        interaccionServidor.obtenerConversacionesUsuario(estaticos.numeroUsuario())
        self.obtenerConversaciones()
    }
    
    // Refresca las conversaciones
    @IBAction func refresh(sender: AnyObject) {
        self.bajarConversacionesDelServidor()
    }
    
    // Metodo que revisa si se puede acceder al address book, en caso que no se pueda pregunta si quiere habilitarlo
    func revisarAutorizacionContactos() {
        if !self.authDone {
            self.authDone = true
            let stat = ABAddressBookGetAuthorizationStatus()
            switch stat {
            case .Denied, .Restricted:
                print("no access")
            case .Authorized, .NotDetermined:
                var err: Unmanaged<CFError>? = nil
                let adbk: ABAddressBook? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
                if adbk == nil {
                    print(err)
                    return
                }
                ABAddressBookRequestAccessWithCompletion(adbk) { (granted:Bool, err:CFError!) in
                   if granted {
                       self.adbk = adbk
                   }
                   else {
                       print(err)
                   }
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        controller = self
        revisarAutorizacionContactos()
        interaccionServidor.obtenerContactosServidor()
        bajarConversacionesDelServidor()
        estaticos.crearAgenda()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // Metodo que obtiene las conversaciones desde la base de datos
    func obtenerConversaciones() {
        self.conversaciones = estaticos.Fetch("Conversacion") as! [Conversacion]
        self.conversaciones.sortInPlace({ $1.id > $0.id })
        print(conversaciones.count)
        self.tableView.reloadData()
    }
    
    // Metodo que da los valores a los elementos de la celda
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("celdaViewController") as! cellViewController
        cell.id.text = (conversaciones[conversaciones.count-indexPath.row-1].id).stringValue
        cell.nombreContacto.text = estaticos.buscarNumeroEnAgenda(conversaciones[conversaciones.count-1-indexPath.row].numeroAdmin)
        cell.nombreChat.text = conversaciones[conversaciones.count-1-indexPath.row].titulo
        return cell
    }
    
    // Metodo que define el numero de filas en una seccion
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversaciones.count
    }
    
    // Metodo que se lanza al presionar una fila
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       selected = NSIndexPath(forRow: conversaciones.count-indexPath.row-1, inSection: 0)
       print(selected.row)
        
       //Este metodo hace el segue
       controller.performSegueWithIdentifier("salaDeChatDos", sender: controller)
    }
    
    // Este metodo se lanza antes de que cargue el View Controller generado por el segue
    // Con este metodo se pueden entregar valores al View Controller para que sean usados en el ViewDidLoad
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "salaDeChatDos" {
            let controller:salaDeChatDos = segue.destinationViewController as! salaDeChatDos
            controller.content = conversaciones[selected.row].titulo
            controller.id = conversaciones[selected.row].id.stringValue
        }
    }
}

