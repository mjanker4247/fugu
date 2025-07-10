/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Foundation/Foundation.h>
#import "SFTPService.h"
#import "SFTPServiceProtocol.h"

@interface SFTPServiceDelegate : NSObject <NSXPCListenerDelegate>
@end

@implementation SFTPServiceDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    // Configure the connection
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(SFTPServiceProtocol)];
    
    // Create and export the service object
    SFTPService *exportedObject = [[SFTPService alloc] init];
    newConnection.exportedObject = exportedObject;
    
    // Set up invalidation handler
    newConnection.invalidationHandler = ^{
        NSLog(@"SFTP XPC connection invalidated");
    };
    
    newConnection.interruptionHandler = ^{
        NSLog(@"SFTP XPC connection interrupted");
    };
    
    // Resume the connection
    [newConnection resume];
    
    return YES;
}

@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        SFTPServiceDelegate *delegate = [[SFTPServiceDelegate alloc] init];
        
        NSXPCListener *listener = [NSXPCListener serviceListener];
        listener.delegate = delegate;
        
        // Start the XPC service
        [listener resume];
        
        NSLog(@"SFTP XPC Service started");
        
        // Run the service
        [[NSRunLoop currentRunLoop] run];
    }
    
    return 0;
}