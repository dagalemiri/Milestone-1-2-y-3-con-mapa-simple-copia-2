//
//  estaticos.swift
//  MMMilestone2
//
//  Created by David Galemiri on 12-05-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

import UIKit
import CoreData
import AddressBook

class estaticos: NSObject {
    //Variables
    class func moc() -> NSManagedObjectContext { return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!}
    class func formatoToken () -> String {return "Token token=Npz7IixsBERjCCjc2d5legtt"}
    class func token () -> String {return"Npz7IixsBERjCCjc2d5legtt"}
    class func nombreUsuario() -> String {return "David Galemiri"}
    class func numeroUsuario () -> String {return "56968799501"}
    static let puerto = "8000"
    static let adbk : ABAddressBook? = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
    static let addressBook : ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
    static var diccionarioNumeroPersonABRecord = Dictionary<String,ABRecord>()
    static var diccionarioNumeroNombre = Dictionary<String,String>()
    
    
    // Metodo que obtiene todas las ipAddress
    static func getIPAddresses() -> String {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
        if getifaddrs(&ifaddr) == 0 {
            
            // For each interface ...
            for (var ptr = ifaddr; ptr != nil; ptr = ptr.memory.ifa_next) {
                let flags = Int32(ptr.memory.ifa_flags)
                var addr = ptr.memory.ifa_addr.memory
                
                // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                                if let address = String.fromCString(hostname) {
                                    addresses.append(address)
                                }
                        }
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        if addresses.count>0 {
            return addresses[0]
        }
        else {
            return ""
        }
        
    }
    
    // Metodo que retorna las tuplas que se piden de una base de datos
    class func Fetch(entity:String) ->[NSObject] {
        let fetchRequest = NSFetchRequest(entityName: entity)
        if let fetchResults = (try? moc().executeFetchRequest(fetchRequest)) as? [NSObject] {
            return fetchResults
        }
        return []
    }
    
    // Metodo que guarda tuplas en la base de datos
    class func save() {
        do{
           try moc().save()
        }
        catch{print("error")}
    }
    
    // Dado un numero del address book, entrega un string sin elementos que no sean numeros.
    class func obtenerNumero(numero:String)->String {
        var aux = ""
        for letra in numero.characters {
            if (letra == "+" || letra == " "){}
            else{aux.append(letra)}
        }
        return aux
    }
    
    // Metodo que compara dos edades
    class func isDateGreaterThanDate(date1:NSDate, date2:NSDate) -> Bool {
        print(date1.compare(date2).rawValue == 1 ? true : false)
        return date1.compare(date2).rawValue == 1 ? true : false
    }

    //Metodo que parsea de string a date
    class func stringAFecha(fecha:String) -> NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat="yyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let date = formatter.dateFromString(fecha)
        return date!
    }

    // Metodo que crea un diccionario con numero de key y nombre de valor
    static func crearDiccionarioNumeroNombre() {
        let a = estaticos.diccionarioNumeroPersonABRecord.keys
        for key in a {
            print(key)
            estaticos.diccionarioNumeroNombre[key] = estaticos.getNameForContactNumber(key) as String
        }
    }
    
    // Metodo que obtiene los nombres del address book
    static func getAddressBookNames() {
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        if (authorizationStatus == ABAuthorizationStatus.NotDetermined) {
            ABAddressBookRequestAccessWithCompletion(estaticos.addressBook, { (granted : Bool, error: CFError!) -> Void in
                if granted == true {
                self.getContactNames()
                }
            })
        }
        else if (authorizationStatus == ABAuthorizationStatus.Denied || authorizationStatus == ABAuthorizationStatus.Restricted) {}
        else if (authorizationStatus == ABAuthorizationStatus.Authorized) {
            self.getContactNames()
        }
    }
    
    
    static func getContactNames() {
        var errorRef: Unmanaged<CFError>?
        let addressBook: ABAddressBookRef? = estaticos.extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        let contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
        for record:ABRecordRef in contactList {
            var contactName: String = ABRecordCopyCompositeName(record).takeRetainedValue() as String
        }
    }
    
    static func extractABAddressBookRef(abRef: Unmanaged<ABAddressBookRef>!) -> ABAddressBookRef? {
        if let ab = abRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    
    // Metodo que dado un numero, entrega un nombre
    static func getNameForContactNumber(number:String) -> String {
        let person: ABRecord? = estaticos.diccionarioNumeroPersonABRecord[number]
        var nombre = ""
        let nombreRaw = ABRecordCopyCompositeName(person)
        if nombreRaw != nil {
            nombre = ABRecordCopyCompositeName(person).takeRetainedValue() as String
        }
        nombre = nombre != "" ? nombre : number
        return nombre
    }
    
    ///Ordena los chats fijandose en el atributo updatedAt (los que no lo tienen quedan al final)
    static func createArrayNumberName() {
        estaticos.diccionarioNumeroPersonABRecord.removeAll(keepCapacity: false)
        let allPeople = ABAddressBookCopyArrayOfAllPeople(estaticos.adbk).takeRetainedValue() as NSArray
        for personRecord in allPeople {
            let phones : ABMultiValueRef = ABRecordCopyValue(personRecord, kABPersonPhoneProperty).takeRetainedValue()
            if ABMultiValueCopyArrayOfAllValues(phones) != nil {
                for numeroRaw in ABMultiValueCopyArrayOfAllValues(phones).takeRetainedValue() as NSArray {
                    let numero = estaticos.limpiarNumero(numeroRaw as! String)
                    if estaticos.diccionarioNumeroPersonABRecord.indexForKey(numero) != nil {
                        NSLog("Hay un numero duplicado (en dos contactos)\nNumero: " + numero)
                    }
                    else {
                        diccionarioNumeroPersonABRecord[numero] = personRecord as ABRecord
                    }
                }
            }
        }
    }
    
    // Metodo que dado un numero del address book, devuelve el numero limpio
    static func limpiarNumero(num:String) -> String {
        var numLimpio = ""
        for letra in num.characters {
            if letra == "(" || letra == ")" || letra == "+" || letra == "-" || letra == " "{ }
            else { numLimpio += String(letra) }}
        let components = numLimpio.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter({!$0.characters.isEmpty})
        return components.joinWithSeparator("")
    }
    
    // Metodo que crea un diccionario numero - nombre
    static func crearAgenda() {
        estaticos.getAddressBookNames()
        estaticos.createArrayNumberName()
        estaticos.crearDiccionarioNumeroNombre()
    }
 
    // Metodo que dado un diccionario de numeros y nombres, busca el nombre
    static func buscarNumeroEnAgenda(numero:String) -> String {
        let arregloLLaves = estaticos.diccionarioNumeroNombre.keys
        if arregloLLaves.contains(numero) {
            return estaticos.diccionarioNumeroNombre[numero]!
        }
        else {
            return numero
        }
    }
    
    // Metodo que obtiene la ip global
    static func getGlobalAddress() -> String {
        var ip = ""
        var i = 0
        let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: "http://ipof.in/txt")!) {(data, response, error) in
            ip = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String
        }
        task.resume()
        while ip == "" {
            if i > 50000000 { NSLog("Mas de 50000000 iteraciones"); return "-1"}
            i++
        }
        NSLog("Numero iteraciones: "+String(i))
        return ip
    }
}
