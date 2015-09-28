//
//  agregarUsuarioAlServidor.swift
//  MMMilestone2
//
//  Created by David Galemiri on 19-05-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI

class agregarUsuarioAlServidor: UIViewController,ABPeoplePickerNavigationControllerDelegate,ABNewPersonViewControllerDelegate {
    //Outlets y variables
    @IBOutlet weak var tableView: UITableView!
    var adbk : ABAddressBook!
    var authDone = false
    var person: ABRecord!
    var contactos =  [Contacto]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        revisarAutorizacionContactos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Evento que se activa para agregar un contacto al address book
    @IBAction func AddNewContact(sender: AnyObject) {
        let controller = ABNewPersonViewController()
        controller.newPersonViewDelegate = self
        let navigationController = UINavigationController(rootViewController: controller)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    //Metodo que se despliega  el controllador para agregar gente al address book
    func newPersonViewController(newPersonView: ABNewPersonViewController, didCompleteWithNewPerson person: ABRecord?) {
        newPersonView.navigationController?.dismissViewControllerAnimated(true, completion: nil);
    }
    
    //Metodo que revisa si tengo permiso par acceder al address book, en caso contrario pregunta si lo desea
    func revisarAutorizacionContactos() {
            if !self.authDone {
                self.authDone = true
                let stat = ABAddressBookGetAuthorizationStatus()
                switch stat {
                case .Denied, .Restricted:
                    print("no access")
                case .Authorized, .NotDetermined:
                    var err : Unmanaged<CFError>? = nil
                    let adbk : ABAddressBook? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
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
    
    //Metodo que despliega el address book
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord, property: ABPropertyID, identifier: ABMultiValueIdentifier) {
            if property == kABPersonPhoneProperty {
                self.adbk = peoplePicker.addressBook
                let nameCFString : CFString = ABRecordCopyCompositeName(person).takeRetainedValue()
                let name : NSString = nameCFString as NSString
                let numbersValueRef: ABMultiValueRef = ABRecordCopyValue(person, property).takeRetainedValue()
                let numberValueIndex = ABMultiValueGetIndexForIdentifier(numbersValueRef, identifier)
                let numberRaw = ABMultiValueCopyValueAtIndex(numbersValueRef, numberValueIndex).takeRetainedValue() as! String
                let numero = estaticos.obtenerNumero(numberRaw)
                print(numero)
                contactos = estaticos.Fetch("Contacto") as! [Contacto]
                var aux = true
                for contacto in contactos {
                    if contacto.numero == numero {
                        aux = false
                        break
                    }
                }
                if aux {
                    interaccionServidor.agregarUsuariosAlServidor(numero,password:numero,nombre:name as String)
                }
            }
    }
    
    //Metodo que se lanza si ya existe el usuario en el servidor
    func activar() {
        let refreshAlert = UIAlertController(title: "Error", message: "El numero de este usuario ya esta registrado en el servidor", preferredStyle: UIAlertControllerStyle.Alert)
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) in
            print("Handle Ok logic here") }))
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    //Evento que se despliega para agregar personas al servidor
    @IBAction  func agregarPersonas(sender: AnyObject) {
            let picker: ABPeoplePickerNavigationController =  ABPeoplePickerNavigationController()
            picker.peoplePickerDelegate = self
            self.presentViewController(picker, animated: true, completion:nil)
    }
}
