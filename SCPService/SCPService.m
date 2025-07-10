/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import "SCPService.h"
#import <Foundation/Foundation.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>
#import <pwd.h>
#import <signal.h>

// Error domain
NSString * const SCPServiceErrorDomain = @"edu.umich.fugu.SCPService";

@implementation SCPService

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isConnected = NO;
        self.isTransferring = NO;
        self.progressBuffer = [[NSMutableString alloc] init];
    }
    return self;
}

#pragma mark - SCPServiceProtocol Implementation

- (void)scpConnect:(NSString *)userAtHost 
            toPort:(NSString *)port
           forItem:(NSString *)item
           scpType:(NSInteger)scpType
        completion:(void (^)(BOOL success, NSString *error))completion {
    
    if (self.isTransferring) {
        completion(NO, @"SCP transfer already in progress");
        return;
    }
    
    [self setupSCPConnection:userAtHost port:port item:item scpType:scpType completion:completion];
}

- (void)getCopyProgressWithCompletion:(void (^)(NSString *fileName, NSString *percentDone, NSString *eta, NSString *bytesCopied))completion {
    if (!self.isTransferring) {
        completion(nil, nil, nil, nil);
        return;
    }
    
    // Parse progress from buffer
    NSString *progress = [self.progressBuffer copy];
    [self.progressBuffer setString:@""];
    
    // Simple progress parsing - in real implementation, parse scp output
    completion(self.currentFile, @"50%", @"00:30", @"1.2MB");
}

- (void)closeMasterFDWithCompletion:(void (^)(NSInteger result))completion {
    if (self.scpTask && self.scpTask.isRunning) {
        [self.scpTask terminate];
        [self cleanupSCPConnection];
        completion(0);
    } else {
        completion(-1);
    }
}

- (void)cancelOperationWithCompletion:(void (^)(void))completion {
    if (self.scpTask && self.scpTask.isRunning) {
        [self.scpTask terminate];
        [self cleanupSCPConnection];
    }
    completion();
}

#pragma mark - Internal Methods

- (void)setupSCPConnection:(NSString *)userAtHost 
                      port:(NSString *)port 
                      item:(NSString *)item 
                   scpType:(NSInteger)scpType 
                completion:(void (^)(BOOL success, NSString *error))completion {
    
    self.isTransferring = YES;
    self.currentOperation = (scpType == SCPTypeUpload) ? @"Upload" : @"Download";
    self.currentFile = [item lastPathComponent];
    
    // Create NSTask for SCP
    self.scpTask = [[NSTask alloc] init];
    self.scpTask.launchPath = @"/usr/bin/scp";
    
    // Setup pipes
    self.inputPipe = [NSPipe pipe];
    self.outputPipe = [NSPipe pipe];
    self.errorPipe = [NSPipe pipe];
    
    self.scpTask.standardInput = self.inputPipe.fileHandleForReading;
    self.scpTask.standardOutput = self.outputPipe.fileHandleForWriting;
    self.scpTask.standardError = self.errorPipe.fileHandleForWriting;
    
    // Build SCP arguments
    NSMutableArray *arguments = [NSMutableArray array];
    
    // Add port if specified
    if (port && ![port isEqualToString:@"22"]) {
        [arguments addObject:@"-P"];
        [arguments addObject:port];
    }
    
    // Add item based on type
    if (scpType == SCPTypeUpload) {
        [arguments addObject:item];
        [arguments addObject:[NSString stringWithFormat:@"%@:", userAtHost]];
    } else {
        [arguments addObject:[NSString stringWithFormat:@"%@:%@", userAtHost, item]];
        [arguments addObject:@"."];
    }
    
    self.scpTask.arguments = arguments;
    
    // Setup output monitoring
    __weak typeof(self) weakSelf = self;
    self.outputPipe.fileHandleForReading.readabilityHandler = ^(NSFileHandle *handle) {
        NSData *data = [handle availableData];
        if (data.length > 0) {
            NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [weakSelf parseProgressOutput:output];
        }
    };
    
    // Setup error monitoring
    self.errorPipe.fileHandleForReading.readabilityHandler = ^(NSFileHandle *handle) {
        NSData *data = [handle availableData];
        if (data.length > 0) {
            NSString *error = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"SCP Error: %@", error);
        }
    };
    
    // Setup completion handler
    self.scpTask.terminationHandler = ^(NSTask *task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.isTransferring = NO;
            [weakSelf cleanupSCPConnection];
            
            if (task.terminationStatus == 0) {
                completion(YES, nil);
            } else {
                completion(NO, [NSString stringWithFormat:@"SCP failed with status %d", (int)task.terminationStatus]);
            }
        });
    };
    
    // Launch SCP
    @try {
        [self.scpTask launch];
        self.scpPid = self.scpTask.processIdentifier;
        [self monitorSCPProgress];
    } @catch (NSException *exception) {
        self.isTransferring = NO;
        completion(NO, [NSString stringWithFormat:@"Failed to launch SCP: %@", exception.reason]);
    }
}

- (void)monitorSCPProgress {
    // Start progress timer
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 
                                                          target:self 
                                                        selector:@selector(updateProgress) 
                                                        userInfo:nil 
                                                         repeats:YES];
}

- (void)updateProgress {
    if (!self.isTransferring) {
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    }
}

- (void)parseProgressOutput:(NSString *)output {
    [self.progressBuffer appendString:output];
    
    // Parse progress information from scp output
    // This is a simplified implementation - real parsing would extract file names, percentages, etc.
    NSArray *lines = [output componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString *line in lines) {
        if ([line containsString:@"%"]) {
            // Extract progress information
            NSLog(@"SCP Progress: %@", line);
        }
    }
}

- (void)cleanupSCPConnection {
    if (self.outputPipe.fileHandleForReading.readabilityHandler) {
        self.outputPipe.fileHandleForReading.readabilityHandler = nil;
    }
    if (self.errorPipe.fileHandleForReading.readabilityHandler) {
        self.errorPipe.fileHandleForReading.readabilityHandler = nil;
    }
    
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    
    self.scpTask = nil;
    self.isTransferring = NO;
    self.isConnected = NO;
}

@end 