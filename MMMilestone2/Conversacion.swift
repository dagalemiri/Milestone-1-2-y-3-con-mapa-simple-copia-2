//
//  Conversacion.swift
//  MMMilestone2
//
//  Created by David Galemiri on 12-05-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

import Foundation
import CoreData

class Conversacion: NSManagedObject {
    //Atributos de la tabla
    @NSManaged var id: NSNumber
    @NSManaged var titulo: String
    @NSManaged var numeroAdmin: String
    @NSManaged var mensajesChat: NSOrderedSet
    @NSManaged var usuarios: NSSet
    @NSManaged var ultimoVisto: NSDate
    @NSManaged var group: Bool

    // Metodo que crea una tupla en la base de datos y le asigna valores
    class func createInManagedObjectContext(moc: NSManagedObjectContext, id:NSNumber,titulo:String,numeroAdmin:String,group:Bool) {
        let nuevoElemento = NSEntityDescription.insertNewObjectForEntityForName("Conversacion", inManagedObjectContext: moc) as! Conversacion
        nuevoElemento.id = id
        nuevoElemento.titulo = titulo
        nuevoElemento.numeroAdmin = numeroAdmin
        nuevoElemento.group = group
        nuevoElemento.ultimoVisto = estaticos.stringAFecha("1999-04-12T22:13:20.210Z")
    }
    
    // Metodo que agrega/asocia mensajes a una conversacion y los guarda en la base de datos
    func agregarMensajes(mensajeServidor:Mensaje) {
        if(estaticos.isDateGreaterThanDate(mensajeServidor.fecha, date2:self.ultimoVisto) && verificarSiNoExisteMensajeEnConversacion(mensajeServidor)) {
            var mensajes = self.mensajesChat.array as! [Mensaje]
            mensajes.append(mensajeServidor)
            mensajesChat = NSOrderedSet(array: mensajes)
            estaticos.save()
        }
    }
    
    // Metodo que verifica si existe o no un mensaje (para asi saber si guardarlo y no repetirlo)
    func verificarSiNoExisteMensajeEnConversacion(mensajeServidor:Mensaje) ->Bool {
        let mensajes = self.mensajesChat.array as! [Mensaje]
        for mensaje in mensajes {
            if mensajeServidor.idMensaje == mensaje.idMensaje {
                return false
            }
        }
        return true
    }
}
