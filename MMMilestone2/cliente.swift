//
//  cliente.swift
//  MMMilestone2
//
//  Created by David Galemiri on 17-06-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//



class cliente: NSObject, NSStreamDelegate {
    //Variables
    var opened = false
    var shouldKill = false
    var outputStream : NSOutputStream?;
    var inputStream : NSInputStream?;
    
    // Metodo que crea el cliente
    func crearCliente(ip:String, port:UInt32) {
        let host : CFString = ip;
        var readStream : Unmanaged<CFReadStream>? = nil;
        var writeStream : Unmanaged<CFWriteStream>? = nil;
        CFStreamCreatePairWithSocketToHost(nil, host, port, &readStream, &writeStream);
        inputStream = readStream!.takeRetainedValue();
        outputStream = writeStream!.takeRetainedValue();
        if inputStream != nil && outputStream != nil {
            inputStream!.delegate = self
            outputStream!.delegate = self
            inputStream!.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            outputStream!.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            inputStream!.open()
            outputStream!.open()
            NSLog("Cliente intento abrir streams")
        }
    }
    
    //Relacionado con el socket
    func SocketReadCallback(_: CFSocket!, _: CFSocketCallBackType, _: CFData!, _: UnsafePointer<Void>, _: UnsafeMutablePointer<Void>) {
        
    }
    
    // Metodo que da informacion si la comunicacion del socket se hizo bien
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        if aStream === inputStream {
            switch eventCode {
            case NSStreamEvent.ErrorOccurred:
                print("input: ErrorOccurred: \(aStream.streamError?.description)")
            case NSStreamEvent.OpenCompleted:
                print("input: OpenCompleted")
            case NSStreamEvent.HasBytesAvailable:
                print("input: HasBytesAvailable")
                
                // Here you can `read()` from `inputStream`
                
            default:
                NSLog("default input")
                break
            }
        }
        else if aStream === outputStream {
            switch eventCode {
            case NSStreamEvent.ErrorOccurred:
                print("output: ErrorOccurred: \(aStream.streamError?.description)")
                          shouldKill = true
            case NSStreamEvent.OpenCompleted:
                print("output: OpenCompleted")
                          opened = true
            case NSStreamEvent.HasSpaceAvailable:
                print("output: HasSpaceAvailable")
                
                // Here you can write() to `outputStream`
                
            default:
                NSLog("default output")
                break
            }
        }
    }
    
    //Metodo que mata la comunicacion
    func kill() {
        inputStream?.close()
        outputStream?.close()
    }
}
