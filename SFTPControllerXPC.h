/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Foundation/Foundation.h>
#import "SFTPServiceProtocol.h"
#import "SCPServiceProtocol.h"

@interface SFTPControllerXPC : NSObject

// SFTP Service Connection
@property (nonatomic, strong) NSXPCConnection *sftpConnection;
@property (nonatomic, strong) id<SFTPServiceProtocol> sftpService;

// SCP Service Connection  
@property (nonatomic, strong) NSXPCConnection *scpConnection;
@property (nonatomic, strong) id<SCPServiceProtocol> scpService;

// Service Management
- (void)establishSFTPConnection;
- (void)establishSCPConnection;
- (void)invalidateConnections;

// SFTP Operations (replaces old SFTPTServer methods)
- (void)connectToServer:(NSString *)host 
               username:(NSString *)username 
                   port:(NSString *)port 
             completion:(void (^)(BOOL success, NSString *error))completion;

- (void)getDirectoryListingWithCompletion:(void (^)(NSArray *listing, NSString *error))completion;

- (void)uploadFile:(NSString *)localPath 
        remotePath:(NSString *)remotePath 
        completion:(void (^)(BOOL success, NSString *error))completion;

- (void)downloadFile:(NSString *)remotePath 
           localPath:(NSString *)localPath 
          completion:(void (^)(BOOL success, NSString *error))completion;

- (void)createDirectory:(NSString *)remotePath 
             completion:(void (^)(BOOL success, NSString *error))completion;

- (void)deleteItem:(NSString *)remotePath 
        completion:(void (^)(BOOL success, NSString *error))completion;

- (void)getFileInfo:(NSString *)remotePath 
         completion:(void (^)(NSDictionary *info, NSString *error))completion;

- (void)disconnectSFTPWithCompletion:(void (^)(void))completion;

// SCP Operations (replaces old SCPTransfer methods)
- (void)performSCP:(NSString *)userAtHost 
              port:(NSString *)port 
              item:(NSString *)item 
           scpType:(NSInteger)scpType 
        completion:(void (^)(BOOL success, NSString *error))completion;

- (void)cancelSCPWithCompletion:(void (^)(void))completion;

@end