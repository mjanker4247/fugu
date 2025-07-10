/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Foundation/Foundation.h>
#import "SCPService.h"
#import "SCPServiceProtocol.h"

@interface SCPServiceListener : NSObject <NSXPCListenerDelegate>
@property (nonatomic, strong) NSXPCListener *listener;
@end

@implementation SCPServiceListener

- (instancetype)init {
    self = [super init];
    if (self) {
        // Create the XPC listener
        self.listener = [[NSXPCListener alloc] initWithMachServiceName:@"edu.umich.fugu.SCPService"];
        self.listener.delegate = self;
    }
    return self;
}

- (void)start {
    NSLog(@"SCPService: Starting XPC service");
    [self.listener resume];
    
    // Keep the service running
    [[NSRunLoop currentRunLoop] run];
}

#pragma mark - NSXPCListenerDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    NSLog(@"SCPService: New connection request");
    
    // Set the exported object interface
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(SCPServiceProtocol)];
    
    // Create and set the exported object
    SCPService *scpService = [[SCPService alloc] init];
    newConnection.exportedObject = scpService;
    
    // Set up invalidation handler
    __weak typeof(newConnection) weakConnection = newConnection;
    newConnection.invalidationHandler = ^{
        NSLog(@"SCPService: Connection invalidated");
    };
    
    // Set up interruption handler
    newConnection.interruptionHandler = ^{
        NSLog(@"SCPService: Connection interrupted");
    };
    
    // Resume the connection
    [newConnection resume];
    
    return YES;
}

@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSLog(@"SCPService: Starting SCP XPC Service");
        
        // Create and start the service listener
        SCPServiceListener *listener = [[SCPServiceListener alloc] init];
        [listener start];
        
        return 0;
    }
} 