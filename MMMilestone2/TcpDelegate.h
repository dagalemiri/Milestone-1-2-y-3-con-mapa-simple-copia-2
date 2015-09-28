//
//  TcpDelegate.h
//  MMMilestone2
//
//  Created by David Galemiri on 10-06-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TcpDelegate <NSObject>

- (void)receivedNewLocationUpdate: (NSString*)locationString;
- (void)perdidaDeConeccion;

@end