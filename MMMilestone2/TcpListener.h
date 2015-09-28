//
//  TcpListener.h
//  MMMilestone2
//
//  Created by David Galemiri on 30-05-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TcpDelegate.h"



@interface TcpListener : NSObject<NSStreamDelegate>
@property (assign, nonatomic) UInt32 port;
// con esta property, se hace un puntero a un delegado
@property (assign, nonatomic) id<TcpDelegate> delegate;


- (void)configure;





@end
