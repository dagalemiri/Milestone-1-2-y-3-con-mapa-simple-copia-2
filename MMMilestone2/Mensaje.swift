//
//  Mensaje.swift
//  MMMilestone2
//
//  Created by David Galemiri on 12-05-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

import Foundation
import CoreData

class Mensaje: NSManagedObject {
    //Atributos de la tabla
    @NSManaged var fecha: NSDate
    @NSManaged var idConversacion: NSNumber
    @NSManaged var idMensaje: NSNumber
    @NSManaged var mensaje: String
    @NSManaged var sender: String
    @NSManaged var salaChat: NSManagedObject
    @NSManaged var salaChatGrupal: NSManagedObject
    @NSManaged var foto: Bool
    
    // Metodo que crea una tupla en la base de datos y le asigna valores
    class func createInManagedObjectContext(moc: NSManagedObjectContext, fecha:NSDate,idConversacion:NSNumber,idMensaje: NSNumber,mensaje: String,sender: String) -> Mensaje {
        let nuevoElemento = NSEntityDescription.insertNewObjectForEntityForName("Mensaje", inManagedObjectContext: moc) as! Mensaje
        nuevoElemento.fecha = fecha
        nuevoElemento.idConversacion = idConversacion
        nuevoElemento.idMensaje = idMensaje
        nuevoElemento.mensaje = mensaje
        nuevoElemento.sender = sender
        print(mensaje, terminator: "")
        return nuevoElemento
    }
    // Metodo que crea una tupla en la base de datos y le asigna valores (Sobrecargado)
    class func createInManagedObjectContext(moc: NSManagedObjectContext, fecha:NSDate,idConversacion:NSNumber,idMensaje: NSNumber,mensaje: String,sender: String,foto:Bool) -> Mensaje {
        let nuevoElemento = NSEntityDescription.insertNewObjectForEntityForName("Mensaje", inManagedObjectContext: moc) as! Mensaje
        nuevoElemento.fecha = fecha
        nuevoElemento.idConversacion = idConversacion
        nuevoElemento.idMensaje = idMensaje
        nuevoElemento.mensaje = mensaje
        nuevoElemento.sender = sender
        nuevoElemento.foto = foto
        print(mensaje, terminator: "")
        return nuevoElemento
    }
}
