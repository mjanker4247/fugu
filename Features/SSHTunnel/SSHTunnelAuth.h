/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Cocoa/Cocoa.h>

@class SSHTunnel;

@protocol SSHTunnelAuthInterface

NS_ASSUME_NONNULL_BEGIN
- ( void )sshTunnelLocalPort: ( char * )lport remoteHost: ( char * )rhost
                remotePort: ( char * )rport tunnelUserAndHost: ( char * )userathost
                tunnelPort: ( char * )tport
                fromController: ( SSHTunnel * )controller;

- ( int )closeMasterFD;

NS_ASSUME_NONNULL_END
@end

@interface SSHTunnelAuth : NSObject <SSHTunnelAuthInterface>
{
@private
    pid_t	sshpid;
}
NS_ASSUME_NONNULL_BEGIN

- ( id )init;

NS_ASSUME_NONNULL_END
@end
