//
//  crearChatGrupal.swift
//  MMMilestone2
//
//  Created by David Galemiri on 17-05-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI

class crearChatGrupal: UIViewController,ABPeoplePickerNavigationControllerDelegate {

    // Outlets y variables
    @IBOutlet weak var titulo: UITextField!
    
    var adbk : ABAddressBook!
    var authDone = false
    var person: ABRecord!
    var actual = CGFloat(180)
    var usuariosNombre = [String]()
    var usuariosNumero = [String]()
    var labels = [UILabel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
         revisarAutorizacionContactos()
    }
    
    // Metodo que crea una etiqueta con el nombre de la persona que se agregara a la conversacion
    func crearEtiqueta(nombre:String) {
        let label = UILabel(frame: CGRectMake(0, 0, 200, 21))
        label.center = CGPointMake(180, actual)
        label.textAlignment = NSTextAlignment.Center
        usuariosNombre.append(nombre)
        label.text = nombre
        self.view.addSubview(label)
        actual+=50
        labels.append(label)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Metodo que revisa si se puede acceder al address book, en caso que no se pueda pregunta si quiere habilitarlo
    func revisarAutorizacionContactos() {
        if !self.authDone {
            self.authDone = true
            let stat = ABAddressBookGetAuthorizationStatus()
            switch stat {
            case .Denied, .Restricted:
                print("no access", terminator: "")
            case .Authorized, .NotDetermined:
                var err : Unmanaged<CFError>? = nil
                let adbk : ABAddressBook? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
                if adbk == nil {
                    print(err, terminator: "")
                    return
                }
                ABAddressBookRequestAccessWithCompletion(adbk) { (granted:Bool, err:CFError!) in
                        if granted {
                            self.adbk = adbk
                        }
                        else {
                            print(err, terminator: "")
                        }
                }
            }
        }
    }
    
    // Navegador para seleccionar un contacto del address book y obtener sus datos
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord, property: ABPropertyID, identifier: ABMultiValueIdentifier) {
        if property == kABPersonPhoneProperty {
            self.adbk = peoplePicker.addressBook
            let nameCFString : CFString = ABRecordCopyCompositeName(person).takeRetainedValue()
            let name : NSString = nameCFString as NSString
            self.crearEtiqueta(name as String)
            let numbersValueRef: ABMultiValueRef = ABRecordCopyValue(person, property).takeRetainedValue()
            let numberValueIndex = ABMultiValueGetIndexForIdentifier(numbersValueRef, identifier)
            let numberRaw = ABMultiValueCopyValueAtIndex(numbersValueRef, numberValueIndex).takeRetainedValue() as! String
            let numero = estaticos.obtenerNumero(numberRaw)
            usuariosNumero.append(numero)
            }
        }
    
    // Evento que se lanza al presionar el boton agregar personas a la conversacion
    @IBAction  func agregarPersonas(sender: AnyObject) {
        let picker: ABPeoplePickerNavigationController =  ABPeoplePickerNavigationController()
        picker.peoplePickerDelegate = self
        self.presentViewController(picker, animated: true, completion:nil)
            
    }
    
    // Evento que se lanza al presionar el boton para crear conversacion
    @IBAction func crearConversacion(sender: AnyObject) {
        interaccionServidor.crearChatGrupal(usuariosNumero,titulo:titulo.text!)
        print(usuariosNumero, terminator: "")
        print(usuariosNombre, terminator: "")
        usuariosNombre = [String]()
        usuariosNumero = [String]()
        actual = CGFloat(180)
        for label in labels {
             label.removeFromSuperview()
        }
        titulo.text = ""
    }
}
