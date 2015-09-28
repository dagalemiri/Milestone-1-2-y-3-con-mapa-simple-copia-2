//
//  crearChatDeDos.swift
//  MMMilestone2
//
//  Created by David Galemiri on 31-08-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI

class crearChatDeDos: UIViewController, ABPeoplePickerNavigationControllerDelegate {
    //Outlets y variables
    var textField : UITextField!
    var adbk : ABAddressBook!
    var authDone = false
    var person: ABRecord!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Metodo que se activa justo despues que se cargo el view controller (no se pueden agregar alertas en
    // el viewDidLoad
    override func viewDidAppear(animated: Bool) {
        let alert = UIAlertController(title: "Ingrese el nombre de la conversacion", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler:cancelar))
        alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default, handler: crearConversacion))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // Configura el text field en la alerta
    func configurationTextField(textField: UITextField!) {
        self.textField = textField!
        self.textField.placeholder = "Ingrese nombre"
    }
    
    //Metodo que crea la conversacion
    func crearConversacion(alerta:UIAlertAction!) {
        print("hola", terminator: "")
        let picker: ABPeoplePickerNavigationController =  ABPeoplePickerNavigationController()
        picker.peoplePickerDelegate = self
        self.presentViewController(picker, animated: true, completion:nil)
    }
    
    //Funcion que se activa si se quiere cancelar la creacion de la conversacion
    func cancelar(alerta:UIAlertAction!) {
        print("hola", terminator: "")
        navigationController?.popToRootViewControllerAnimated(false)
    }
    
    //Metodo que pregunta si se tiene acceso al address book
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
                ABAddressBookRequestAccessWithCompletion(adbk)
                    {
                        (granted:Bool, err:CFError!) in
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
    
    // Metodo que se activa si se selecciono una imagen en el address book
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord, property: ABPropertyID, identifier: ABMultiValueIdentifier) {
        if property == kABPersonPhoneProperty {
            self.adbk = peoplePicker.addressBook
            let numbersValueRef: ABMultiValueRef = ABRecordCopyValue(person, property).takeRetainedValue()
            let numberValueIndex = ABMultiValueGetIndexForIdentifier(numbersValueRef, identifier)
            let numberRaw = ABMultiValueCopyValueAtIndex(numbersValueRef, numberValueIndex).takeRetainedValue() as! String
            let numero = estaticos.obtenerNumero(numberRaw)
            let nameCFString : CFString = ABRecordCopyCompositeName(person).takeRetainedValue()
            let name : NSString = nameCFString as NSString
            print(name)
            interaccionServidor.crearConversacionDeADos(self.textField.text!,second:numero)
            navigationController?.popToRootViewControllerAnimated(false)
        }
    }
}
