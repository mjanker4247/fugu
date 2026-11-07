/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Cocoa/Cocoa.h>

@class SCPController;

@protocol SCPTransferInterface

NS_ASSUME_NONNULL_BEGIN
- ( void )scpConnect: ( char * )userathost toPort: ( char * )portnumber
                    forItem: ( char * )localfile
                    scpType: ( int )scpType
                    fromController: ( SCPController * )controller;

- ( int )closeMasterFD;

NS_ASSUME_NONNULL_END
@end

@interface SCPTransfer : NSObject <SCPTransferInterface>
{
@private
    pid_t		scppid;
    int			masterfd;
}
NS_ASSUME_NONNULL_BEGIN

- ( id )init;

NS_ASSUME_NONNULL_END
@end
