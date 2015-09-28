//
//  Contacto.swift
//  MMMilestone2
//
//  Created by David Galemiri on 12-05-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

import Foundation
import CoreData

class Contacto: NSManagedObject {
    //Atributos de la tabla
    @NSManaged var nombre: String
    @NSManaged var numero: String
    @NSManaged var chatsParticipante: NSSet
    @NSManaged var chatsParticipanteGrupal: NSSet
    
    // Metodo que crea una tupla en la base de datos y le asigna valores
    class func createInManagedObjectContext(moc: NSManagedObjectContext, nombre:String,numero: String) {
        let nuevoElemento = NSEntityDescription.insertNewObjectForEntityForName("Contacto", inManagedObjectContext: moc) as! Contacto
        nuevoElemento.nombre = nombre
        nuevoElemento.numero = numero
    }
}
