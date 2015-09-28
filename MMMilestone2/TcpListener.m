//
//  TcpListener.m
//  MMMilestone2
//
//  Created by David Galemiri on 30-05-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

#import "TcpListener.h"
#include <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>



static TcpListener *selfReference;
static NSRunLoop *loop;

static NSInputStream *inStream;
static NSOutputStream *outStream;

static void callback(CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info) {
    NSLog(@"Callback");
    CFSocketNativeHandle nativeSocketHandle = * (CFSocketNativeHandle *) data;
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    CFStreamCreatePairWithSocket(nil, nativeSocketHandle, &readStream, &writeStream);
    
    inStream = (__bridge NSInputStream *)readStream;
    outStream = (__bridge NSOutputStream*)writeStream;
    
    inStream.delegate = selfReference;
    outStream.delegate = selfReference;
    
    [inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inStream open];
    [outStream open];
}

@interface TcpListener ()




@end

@implementation TcpListener



- (void)configure {
    loop = [NSRunLoop currentRunLoop];
    selfReference = self;
    
    CFSocketRef listeningSocket = CFSocketCreate(
                                                 kCFAllocatorDefault,
                                                 PF_INET,
                                                 SOCK_STREAM,
                                                 IPPROTO_TCP,
                                                 kCFSocketAcceptCallBack,
                                                 callback, NULL);
    
    // getsockopt will return existing socket option value via this variable
    int existingValue = 1;
    
    // Make sure that same listening socket address gets reused after every connection
    setsockopt( CFSocketGetNative(listeningSocket),
               SOL_SOCKET, SO_REUSEADDR, (void *)&existingValue,
               sizeof(existingValue));
    
    
    //// PART 2: Bind our socket to an endpoint.
    // We will be listening on all available interfaces/addresses.
    // Port will be assigned automatically by kernel.
    struct sockaddr_in socketAddress;
    memset(&socketAddress, 0, sizeof(socketAddress));
    socketAddress.sin_len = sizeof(socketAddress);
    socketAddress.sin_family = AF_INET;   // Address family (IPv4 vs IPv6)
    //socketAddress.sin_port = 0;           // Actual port will get assigned automatically by kernel
     socketAddress.sin_port = 0;
    socketAddress.sin_addr.s_addr = htonl(INADDR_ANY);    // We must use "network byte order" format (big-endian) for the value here
   // inet_pton(AF_INET, "10.0.0.1", &ip4addr.sin_addr);
    
    // Convert the endpoint data structure into something that CFSocket can use
    NSData *socketAddressData =
    [NSData dataWithBytes:&socketAddress length:sizeof(socketAddress)];
    
    // Bind our socket to the endpoint. Check if successful.
    if ( CFSocketSetAddress(listeningSocket, (CFDataRef)socketAddressData) != kCFSocketSuccess ) {
        // Cleanup
        if ( listeningSocket != NULL ) {
            CFRelease(listeningSocket);
            listeningSocket = NULL;
        }
    }
    
    
    //// PART 3: Find out what port kernel assigned to our socket
    // We need it to advertise our service via Bonjour
    NSData *socketAddressActualData = (NSData *)CFBridgingRelease(CFSocketCopyAddress(listeningSocket));
    
    // Convert socket data into a usable structure
    struct sockaddr_in socketAddressActual;
    memcpy(&socketAddressActual, [socketAddressActualData bytes],
           [socketAddressActualData length]);
    
    _port = ntohs(socketAddressActual.sin_port);
  //  _port = 8000;
   // _a = ntohs(socketAddressActual.sin_port);
    
    //// PART 4: Hook up our socket to the current run loop
    CFRunLoopRef currentRunLoop = CFRunLoopGetCurrent();
    CFRunLoopSourceRef runLoopSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, listeningSocket, 0);
    CFRunLoopAddSource(currentRunLoop, runLoopSource, kCFRunLoopCommonModes);
    CFRelease(runLoopSource);
    
    NSLog(@"Servidor creador");
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
            
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            break;
            
        case NSStreamEventHasBytesAvailable:
            [self readStream:aStream];
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"Can not connect to the host!");
            [_delegate perdidaDeConeccion];
            
            break;
            
        case NSStreamEventEndEncountered:
            break;
            
        default:
            NSLog(@"Unknown event");
    }
    
}



- (void)readStream:(NSStream *)stream {
    if (stream == inStream) {
        
        uint8_t buffer[1024];
        int len;
        
        while ([inStream hasBytesAvailable]) {
            len = [inStream read:buffer maxLength:sizeof(buffer)];
            if (len > 0) {
                
                NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                
                if (output != nil) {
                    [_delegate receivedNewLocationUpdate:output];
                    NSLog(@"Received message: %@", output);
                }
            }
        }
    }
}


@end