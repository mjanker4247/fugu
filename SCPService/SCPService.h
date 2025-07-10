/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Foundation/Foundation.h>
#import "SCPServiceProtocol.h"

@interface SCPService : NSObject <SCPServiceProtocol>

// SCP operation state
@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, assign) BOOL isTransferring;
@property (nonatomic, strong) NSString *currentOperation;
@property (nonatomic, strong) NSString *currentFile;

// Process management
@property (nonatomic, assign) pid_t scpPid;
@property (nonatomic, strong) NSTask *scpTask;
@property (nonatomic, strong) NSPipe *inputPipe;
@property (nonatomic, strong) NSPipe *outputPipe;
@property (nonatomic, strong) NSPipe *errorPipe;

// Progress tracking
@property (nonatomic, strong) NSMutableString *progressBuffer;
@property (nonatomic, strong) NSTimer *progressTimer;

// Initialization
- (instancetype)init;

// Internal methods for SCP operations
- (void)setupSCPConnection:(NSString *)userAtHost 
                      port:(NSString *)port 
                      item:(NSString *)item 
                   scpType:(NSInteger)scpType 
                completion:(void (^)(BOOL success, NSString *error))completion;

- (void)monitorSCPProgress;
- (void)parseProgressOutput:(NSString *)output;
- (void)cleanupSCPConnection;

@end

// Error domain for SCP service
extern NSString * const SCPServiceErrorDomain; 