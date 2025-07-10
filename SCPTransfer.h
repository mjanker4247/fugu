/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Cocoa/Cocoa.h>

@class SCPController;

@protocol SCPTransferInterface

- ( oneway void )scpConnect: ( char * )userathost toPort: ( char * )portnumber
                    forItem: ( char * )localfile
                    scpType: ( NSInteger )scpType
                    fromController: ( SCPController * )controller;

- ( NSInteger )closeMasterFD;

@end

@interface SCPTransfer : NSObject <SCPTransferInterface>
{
@private
    pid_t		scppid;
    NSInteger		masterfd;
}

+ ( void )connectWithPorts: ( NSArray * )ports;
- ( id )init;

@end
