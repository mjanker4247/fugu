/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Foundation/Foundation.h>

@class SFTPController;

// XPC Service protocol for SFTP operations
@protocol SFTPServiceProtocol

// Connect to SFTP server with given parameters
- (void)connectToServerWithParams:(NSArray *)params 
                       completion:(void (^)(BOOL success, NSString *error))completion;

// Collect directory listing from SFTP connection
- (void)collectDirectoryListingWithCompletion:(void (^)(NSArray *listing, NSString *error))completion;

// Check if at SFTP prompt
- (void)checkAtSftpPromptWithCompletion:(void (^)(BOOL atPrompt))completion;

// Get SFTP process ID
- (void)getSftpPidWithCompletion:(void (^)(pid_t pid))completion;

// Execute SFTP command
- (void)executeSFTPCommand:(NSString *)command 
                completion:(void (^)(NSString *output, NSString *error))completion;

// Upload file to remote server
- (void)uploadFile:(NSString *)localPath 
        remotePath:(NSString *)remotePath 
        completion:(void (^)(BOOL success, NSString *error))completion;

// Download file from remote server  
- (void)downloadFile:(NSString *)remotePath 
           localPath:(NSString *)localPath 
          completion:(void (^)(BOOL success, NSString *error))completion;

// Create remote directory
- (void)createRemoteDirectory:(NSString *)remotePath 
                   completion:(void (^)(BOOL success, NSString *error))completion;

// Delete remote file or directory
- (void)deleteRemoteItem:(NSString *)remotePath 
              completion:(void (^)(BOOL success, NSString *error))completion;

// Get file information
- (void)getFileInfo:(NSString *)remotePath 
         completion:(void (^)(NSDictionary *info, NSString *error))completion;

// Disconnect from server
- (void)disconnectWithCompletion:(void (^)(void))completion;

@end

// Error domain for SFTP service
extern NSString * const SFTPServiceErrorDomain;

// Error codes
typedef NS_ENUM(NSInteger, SFTPServiceError) {
    SFTPServiceErrorConnectionFailed = 1000,
    SFTPServiceErrorAuthenticationFailed,
    SFTPServiceErrorCommandFailed,
    SFTPServiceErrorFileNotFound,
    SFTPServiceErrorPermissionDenied,
    SFTPServiceErrorUnknown
};