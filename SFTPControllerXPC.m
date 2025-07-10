/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import "SFTPControllerXPC.h"

@implementation SFTPControllerXPC

- (instancetype)init {
    self = [super init];
    if (self) {
        [self establishSFTPConnection];
        [self establishSCPConnection];
    }
    return self;
}

- (void)dealloc {
    [self invalidateConnections];
}

#pragma mark - Service Management

- (void)establishSFTPConnection {
    // Create XPC connection to SFTP service
    self.sftpConnection = [[NSXPCConnection alloc] initWithServiceName:@"edu.umich.fugu.SFTPService"];
    
    // Set the remote object interface
    self.sftpConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(SFTPServiceProtocol)];
    
    // Set up invalidation and interruption handlers
    __weak typeof(self) weakSelf = self;
    self.sftpConnection.invalidationHandler = ^{
        NSLog(@"SFTP XPC connection invalidated");
        weakSelf.sftpConnection = nil;
        weakSelf.sftpService = nil;
    };
    
    self.sftpConnection.interruptionHandler = ^{
        NSLog(@"SFTP XPC connection interrupted");
        // Attempt to reconnect
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf establishSFTPConnection];
        });
    };
    
    // Resume the connection
    [self.sftpConnection resume];
    
    // Get the remote object proxy
    self.sftpService = [self.sftpConnection remoteObjectProxyWithErrorHandler:^(NSError *error) {
        NSLog(@"SFTP XPC error: %@", error.localizedDescription);
    }];
}

- (void)establishSCPConnection {
    // Create XPC connection to SCP service  
    self.scpConnection = [[NSXPCConnection alloc] initWithServiceName:@"edu.umich.fugu.SCPService"];
    
    // Set the remote object interface
    self.scpConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(SCPServiceProtocol)];
    
    // Set up invalidation and interruption handlers
    __weak typeof(self) weakSelf = self;
    self.scpConnection.invalidationHandler = ^{
        NSLog(@"SCP XPC connection invalidated");
        weakSelf.scpConnection = nil;
        weakSelf.scpService = nil;
    };
    
    self.scpConnection.interruptionHandler = ^{
        NSLog(@"SCP XPC connection interrupted");
        // Attempt to reconnect
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf establishSCPConnection];
        });
    };
    
    // Resume the connection
    [self.scpConnection resume];
    
    // Get the remote object proxy
    self.scpService = [self.scpConnection remoteObjectProxyWithErrorHandler:^(NSError *error) {
        NSLog(@"SCP XPC error: %@", error.localizedDescription);
    }];
}

- (void)invalidateConnections {
    if (self.sftpConnection) {
        [self.sftpConnection invalidate];
        self.sftpConnection = nil;
        self.sftpService = nil;
    }
    
    if (self.scpConnection) {
        [self.scpConnection invalidate];
        self.scpConnection = nil;
        self.scpService = nil;
    }
}

#pragma mark - SFTP Operations

- (void)connectToServer:(NSString *)host 
               username:(NSString *)username 
                   port:(NSString *)port 
             completion:(void (^)(BOOL success, NSString *error))completion {
    
    if (!self.sftpService) {
        completion(NO, @"SFTP service not available");
        return;
    }
    
    NSArray *params = @[host, username, port, @""];
    
    [self.sftpService connectToServerWithParams:params completion:^(BOOL success, NSString *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(success, error);
        });
    }];
}

- (void)getDirectoryListingWithCompletion:(void (^)(NSArray *listing, NSString *error))completion {
    if (!self.sftpService) {
        completion(nil, @"SFTP service not available");
        return;
    }
    
    [self.sftpService collectDirectoryListingWithCompletion:^(NSArray *listing, NSString *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(listing, error);
        });
    }];
}

- (void)uploadFile:(NSString *)localPath 
        remotePath:(NSString *)remotePath 
        completion:(void (^)(BOOL success, NSString *error))completion {
    
    if (!self.sftpService) {
        completion(NO, @"SFTP service not available");
        return;
    }
    
    [self.sftpService uploadFile:localPath remotePath:remotePath completion:^(BOOL success, NSString *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(success, error);
        });
    }];
}

- (void)downloadFile:(NSString *)remotePath 
           localPath:(NSString *)localPath 
          completion:(void (^)(BOOL success, NSString *error))completion {
    
    if (!self.sftpService) {
        completion(NO, @"SFTP service not available");
        return;
    }
    
    [self.sftpService downloadFile:remotePath localPath:localPath completion:^(BOOL success, NSString *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(success, error);
        });
    }];
}

- (void)createDirectory:(NSString *)remotePath 
             completion:(void (^)(BOOL success, NSString *error))completion {
    
    if (!self.sftpService) {
        completion(NO, @"SFTP service not available");
        return;
    }
    
    [self.sftpService createRemoteDirectory:remotePath completion:^(BOOL success, NSString *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(success, error);
        });
    }];
}

- (void)deleteItem:(NSString *)remotePath 
        completion:(void (^)(BOOL success, NSString *error))completion {
    
    if (!self.sftpService) {
        completion(NO, @"SFTP service not available");
        return;
    }
    
    [self.sftpService deleteRemoteItem:remotePath completion:^(BOOL success, NSString *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(success, error);
        });
    }];
}

- (void)getFileInfo:(NSString *)remotePath 
         completion:(void (^)(NSDictionary *info, NSString *error))completion {
    
    if (!self.sftpService) {
        completion(nil, @"SFTP service not available");
        return;
    }
    
    [self.sftpService getFileInfo:remotePath completion:^(NSDictionary *info, NSString *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(info, error);
        });
    }];
}

- (void)disconnectSFTPWithCompletion:(void (^)(void))completion {
    if (!self.sftpService) {
        completion();
        return;
    }
    
    [self.sftpService disconnectWithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    }];
}

#pragma mark - SCP Operations

- (void)performSCP:(NSString *)userAtHost 
              port:(NSString *)port 
              item:(NSString *)item 
           scpType:(NSInteger)scpType 
        completion:(void (^)(BOOL success, NSString *error))completion {
    
    if (!self.scpService) {
        completion(NO, @"SCP service not available");
        return;
    }
    
    [self.scpService scpConnect:userAtHost 
                         toPort:port 
                        forItem:item 
                        scpType:scpType 
                     completion:^(BOOL success, NSString *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(success, error);
        });
    }];
}

- (void)cancelSCPWithCompletion:(void (^)(void))completion {
    if (!self.scpService) {
        completion();
        return;
    }
    
    [self.scpService cancelOperationWithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    }];
}

@end