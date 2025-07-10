/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Foundation/Foundation.h>

// XPC Service protocol for SCP operations
@protocol SCPServiceProtocol

// Connect and perform SCP operation
- (void)scpConnect:(NSString *)userAtHost 
            toPort:(NSString *)port
           forItem:(NSString *)item
           scpType:(NSInteger)scpType
        completion:(void (^)(BOOL success, NSString *error))completion;

// Get copy progress updates
- (void)getCopyProgressWithCompletion:(void (^)(NSString *fileName, NSString *percentDone, NSString *eta, NSString *bytesCopied))completion;

// Close master file descriptor
- (void)closeMasterFDWithCompletion:(void (^)(NSInteger result))completion;

// Cancel current operation
- (void)cancelOperationWithCompletion:(void (^)(void))completion;

@end

// Error domain for SCP service
extern NSString * const SCPServiceErrorDomain;

// Error codes
typedef NS_ENUM(NSInteger, SCPServiceError) {
    SCPServiceErrorConnectionFailed = 2000,
    SCPServiceErrorAuthenticationFailed,
    SCPServiceErrorTransferFailed,
    SCPServiceErrorFileNotFound,
    SCPServiceErrorPermissionDenied,
    SCPServiceErrorCancelled,
    SCPServiceErrorUnknown
};

// SCP Type constants
typedef NS_ENUM(NSInteger, SCPType) {
    SCPTypeUpload = 0,
    SCPTypeDownload = 1
};