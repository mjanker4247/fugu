/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Cocoa/Cocoa.h>

@class SFTPController;

@protocol SFTPTServerInterface

NS_ASSUME_NONNULL_BEGIN
- ( void )connectToServerWithParams: ( NSArray * )params
                    fromController: ( SFTPController * )controller;

- ( void )collectListingFromMaster: ( int )master fileStream: ( FILE * )mf
            forController: ( SFTPController * )controller;
- ( int )atSftpPrompt;
- ( pid_t )getSftpPid;

NS_ASSUME_NONNULL_END
@end

@interface SFTPTServer : NSObject <SFTPTServerInterface> {
@private
    int			atprompt;
    NSString		*remoteDirBuf;
    NSString		*_currentTransferName;
    NSString            *_sftpRemoteObjectList;
}
NS_ASSUME_NONNULL_BEGIN

- ( id )init;
- ( NSString * )retrieveUnknownHostKeyFromStream: ( FILE * )stream;
- ( NSMutableDictionary * _Nullable )remoteObjectFromSFTPLine: ( char * )line;
- ( BOOL )checkForPasswordPromptInBuffer: ( char * )buf;
- ( BOOL )hasDirectoryListingFormInBuffer: ( char * )buf;

NS_ASSUME_NONNULL_END
@end
