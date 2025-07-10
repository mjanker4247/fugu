/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import "SFTPService.h"
#import "SFTPServiceProtocol.h"
#import <sys/socket.h>
#import <sys/wait.h>
#import <util.h>

NSString * const SFTPServiceErrorDomain = @"SFTPServiceErrorDomain";

@interface SFTPService ()
@property (nonatomic, assign) pid_t sftpPid;
@property (nonatomic, assign) int masterFD;
@property (nonatomic, assign) BOOL atPrompt;
@property (nonatomic, strong) NSString *remoteDirBuf;
@property (nonatomic, strong) NSString *currentTransferName;
@property (nonatomic, strong) NSString *sftpRemoteObjectList;
@property (nonatomic, strong) NSFileHandle *masterFileHandle;
@end

@implementation SFTPService

- (instancetype)init {
    self = [super init];
    if (self) {
        _sftpPid = 0;
        _masterFD = -1;
        _atPrompt = NO;
        _remoteDirBuf = nil;
        _currentTransferName = nil;
        _sftpRemoteObjectList = nil;
        _masterFileHandle = nil;
    }
    return self;
}

- (void)connectToServerWithParams:(NSArray *)params 
                       completion:(void (^)(BOOL success, NSString *error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            // Extract parameters
            if (params.count < 4) {
                completion(NO, @"Insufficient parameters for connection");
                return;
            }
            
            NSString *host = params[0];
            NSString *username = params[1];
            NSString *port = params[2];
            NSString *additionalOptions = params.count > 3 ? params[3] : @"";
            
            // Create SSH/SFTP connection using forkpty
            char *sftpArgs[] = {
                "sftp",
                "-o", "StrictHostKeyChecking=ask",
                "-o", "NumberOfPasswordPrompts=3",
                "-P", (char *)[port UTF8String],
                NULL, // Will be filled with user@host
                NULL
            };
            
            // Create user@host string
            NSString *userHost = [NSString stringWithFormat:@"%@@%@", username, host];
            sftpArgs[6] = (char *)[userHost UTF8String];
            
            char ttyname[1024];
            pid_t pid = forkpty(&_masterFD, ttyname, NULL, NULL);
            
            if (pid == 0) {
                // Child process - exec sftp
                execvp("sftp", sftpArgs);
                perror("execvp failed");
                _exit(1);
            } else if (pid > 0) {
                // Parent process
                _sftpPid = pid;
                _masterFileHandle = [[NSFileHandle alloc] initWithFileDescriptor:_masterFD closeOnDealloc:YES];
                
                // Wait for initial connection
                NSData *initialData = [self readFromMasterWithTimeout:30.0];
                NSString *initialOutput = [[NSString alloc] initWithData:initialData encoding:NSUTF8StringEncoding];
                
                if ([initialOutput containsString:@"sftp>"]) {
                    _atPrompt = YES;
                    completion(YES, nil);
                } else if ([initialOutput containsString:@"Permission denied"] || 
                          [initialOutput containsString:@"Authentication failed"]) {
                    completion(NO, @"Authentication failed");
                } else {
                    completion(NO, @"Connection failed");
                }
            } else {
                // Fork failed
                completion(NO, [NSString stringWithFormat:@"Fork failed: %s", strerror(errno)]);
            }
        } @catch (NSException *exception) {
            completion(NO, [NSString stringWithFormat:@"Exception: %@", exception.reason]);
        }
    });
}

- (void)collectDirectoryListingWithCompletion:(void (^)(NSArray *listing, NSString *error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!_atPrompt || _masterFD < 0) {
            completion(nil, @"Not connected to SFTP server");
            return;
        }
        
        @try {
            // Send 'ls -la' command
            NSString *command = @"ls -la\n";
            NSData *commandData = [command dataUsingEncoding:NSUTF8StringEncoding];
            [_masterFileHandle writeData:commandData];
            
            // Read response
            NSData *responseData = [self readFromMasterWithTimeout:10.0];
            NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            
            // Parse listing
            NSArray *lines = [response componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            NSMutableArray *listing = [NSMutableArray array];
            
            for (NSString *line in lines) {
                if (line.length > 0 && ![line hasPrefix:@"sftp>"]) {
                    NSDictionary *fileInfo = [self parseDirectoryLine:line];
                    if (fileInfo) {
                        [listing addObject:fileInfo];
                    }
                }
            }
            
            completion([listing copy], nil);
        } @catch (NSException *exception) {
            completion(nil, [NSString stringWithFormat:@"Exception: %@", exception.reason]);
        }
    });
}

- (void)checkAtSftpPromptWithCompletion:(void (^)(BOOL atPrompt))completion {
    completion(_atPrompt);
}

- (void)getSftpPidWithCompletion:(void (^)(pid_t pid))completion {
    completion(_sftpPid);
}

- (void)executeSFTPCommand:(NSString *)command 
                completion:(void (^)(NSString *output, NSString *error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!_atPrompt || _masterFD < 0) {
            completion(nil, @"Not connected to SFTP server");
            return;
        }
        
        @try {
            // Send command
            NSString *fullCommand = [command stringByAppendingString:@"\n"];
            NSData *commandData = [fullCommand dataUsingEncoding:NSUTF8StringEncoding];
            [_masterFileHandle writeData:commandData];
            
            // Read response
            NSData *responseData = [self readFromMasterWithTimeout:10.0];
            NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            
            completion(response, nil);
        } @catch (NSException *exception) {
            completion(nil, [NSString stringWithFormat:@"Exception: %@", exception.reason]);
        }
    });
}

- (void)uploadFile:(NSString *)localPath 
        remotePath:(NSString *)remotePath 
        completion:(void (^)(BOOL success, NSString *error))completion {
    [self executeSFTPCommand:[NSString stringWithFormat:@"put \"%@\" \"%@\"", localPath, remotePath]
                  completion:^(NSString *output, NSString *error) {
        if (error) {
            completion(NO, error);
        } else if ([output containsString:@"100%"] || [output containsString:@"Uploading"]) {
            completion(YES, nil);
        } else {
            completion(NO, @"Upload failed");
        }
    }];
}

- (void)downloadFile:(NSString *)remotePath 
           localPath:(NSString *)localPath 
          completion:(void (^)(BOOL success, NSString *error))completion {
    [self executeSFTPCommand:[NSString stringWithFormat:@"get \"%@\" \"%@\"", remotePath, localPath]
                  completion:^(NSString *output, NSString *error) {
        if (error) {
            completion(NO, error);
        } else if ([output containsString:@"100%"] || [output containsString:@"Fetching"]) {
            completion(YES, nil);
        } else {
            completion(NO, @"Download failed");
        }
    }];
}

- (void)createRemoteDirectory:(NSString *)remotePath 
                   completion:(void (^)(BOOL success, NSString *error))completion {
    [self executeSFTPCommand:[NSString stringWithFormat:@"mkdir \"%@\"", remotePath]
                  completion:^(NSString *output, NSString *error) {
        if (error) {
            completion(NO, error);
        } else if (![output containsString:@"Couldn't"] && ![output containsString:@"Permission denied"]) {
            completion(YES, nil);
        } else {
            completion(NO, @"Failed to create directory");
        }
    }];
}

- (void)deleteRemoteItem:(NSString *)remotePath 
              completion:(void (^)(BOOL success, NSString *error))completion {
    // Try as file first, then as directory
    [self executeSFTPCommand:[NSString stringWithFormat:@"rm \"%@\"", remotePath]
                  completion:^(NSString *output, NSString *error) {
        if (error || [output containsString:@"Couldn't"]) {
            // Try as directory
            [self executeSFTPCommand:[NSString stringWithFormat:@"rmdir \"%@\"", remotePath]
                          completion:^(NSString *dirOutput, NSString *dirError) {
                if (dirError) {
                    completion(NO, dirError);
                } else if (![dirOutput containsString:@"Couldn't"]) {
                    completion(YES, nil);
                } else {
                    completion(NO, @"Failed to delete item");
                }
            }];
        } else {
            completion(YES, nil);
        }
    }];
}

- (void)getFileInfo:(NSString *)remotePath 
         completion:(void (^)(NSDictionary *info, NSString *error))completion {
    [self executeSFTPCommand:[NSString stringWithFormat:@"ls -la \"%@\"", remotePath]
                  completion:^(NSString *output, NSString *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        
        NSArray *lines = [output componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        for (NSString *line in lines) {
            if (line.length > 0 && ![line hasPrefix:@"sftp>"]) {
                NSDictionary *fileInfo = [self parseDirectoryLine:line];
                if (fileInfo) {
                    completion(fileInfo, nil);
                    return;
                }
            }
        }
        
        completion(nil, @"File information not found");
    }];
}

- (void)disconnectWithCompletion:(void (^)(void))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (_sftpPid > 0) {
            // Send quit command
            if (_masterFileHandle) {
                NSData *quitData = [@"quit\n" dataUsingEncoding:NSUTF8StringEncoding];
                [_masterFileHandle writeData:quitData];
                [_masterFileHandle closeFile];
                _masterFileHandle = nil;
            }
            
            // Wait for process to exit
            int status;
            waitpid(_sftpPid, &status, 0);
            _sftpPid = 0;
        }
        
        if (_masterFD >= 0) {
            close(_masterFD);
            _masterFD = -1;
        }
        
        _atPrompt = NO;
        completion();
    });
}

#pragma mark - Private Methods

- (NSData *)readFromMasterWithTimeout:(NSTimeInterval)timeout {
    NSMutableData *data = [NSMutableData data];
    NSDate *startTime = [NSDate date];
    
    while ([[NSDate date] timeIntervalSinceDate:startTime] < timeout) {
        if ([_masterFileHandle availableData].length > 0) {
            NSData *chunk = [_masterFileHandle availableData];
            [data appendData:chunk];
            
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ([dataString containsString:@"sftp>"]) {
                _atPrompt = YES;
                break;
            }
        }
        usleep(100000); // 100ms
    }
    
    return data;
}

- (NSDictionary *)parseDirectoryLine:(NSString *)line {
    // Parse ls -la output line
    // Format: drwxr-xr-x 2 user group 4096 Jan 1 12:00 filename
    
    NSArray *components = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableArray *nonEmptyComponents = [NSMutableArray array];
    
    for (NSString *component in components) {
        if (component.length > 0) {
            [nonEmptyComponents addObject:component];
        }
    }
    
    if (nonEmptyComponents.count < 9) {
        return nil;
    }
    
    NSString *permissions = nonEmptyComponents[0];
    NSString *links = nonEmptyComponents[1];
    NSString *owner = nonEmptyComponents[2];
    NSString *group = nonEmptyComponents[3];
    NSString *size = nonEmptyComponents[4];
    NSString *month = nonEmptyComponents[5];
    NSString *day = nonEmptyComponents[6];
    NSString *timeOrYear = nonEmptyComponents[7];
    NSString *name = [nonEmptyComponents subarrayWithRange:NSMakeRange(8, nonEmptyComponents.count - 8)].firstObject;
    
    // Determine file type
    NSString *type = @"file";
    if ([permissions hasPrefix:@"d"]) {
        type = @"directory";
    } else if ([permissions hasPrefix:@"l"]) {
        type = @"link";
    }
    
    return @{
        @"name": name ?: @"",
        @"type": type,
        @"size": size ?: @"0",
        @"owner": owner ?: @"",
        @"group": group ?: @"",
        @"perm": permissions ?: @"",
        @"date": [NSString stringWithFormat:@"%@ %@ %@", month, day, timeOrYear] ?: @""
    };
}

@end