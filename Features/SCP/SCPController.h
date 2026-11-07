/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Cocoa/Cocoa.h>

#import "SCPTransfer.h"
#import "UMDragDropImageView.h"
#import "UMTextField.h"

@class SCPTransfer;

@interface SCPController : NSObject
{
    IBOutlet NSTextField 	*_Nullable destPathField;
    IBOutlet NSTextField 	*_Nullable destPortField;
    IBOutlet NSComboBox 	*_Nullable destServerField;
    IBOutlet NSTextField	*_Nullable destUserNameField;
    IBOutlet UMTextField 	*_Nullable localFileField;
    IBOutlet UMDragDropImageView 	*_Nullable localFileImageView;
    IBOutlet NSPopUpButton	*_Nullable recentCopiesList;
    IBOutlet NSSegmentedControl	*_Nullable copyType;
    
    IBOutlet NSTextField 	*_Nullable passPromptField;
    IBOutlet NSView 		*_Nullable passpromptView;
    IBOutlet NSTextField 	*_Nullable passwordField;
    IBOutlet NSTextField	*_Nullable passErrorField;
    IBOutlet NSButton		*_Nullable addToKeychainSwitch;
    
    IBOutlet NSProgressIndicator *_Nullable progBar;
    IBOutlet NSTextField	*_Nullable percentDoneField;
    IBOutlet NSTextField	*_Nullable etaField;
    IBOutlet NSTextField	*_Nullable bytesCopiedField;
    IBOutlet NSTextField 	*_Nullable connectProgMsg;
    IBOutlet NSView 		*_Nullable connectProgView;
    
    IBOutlet NSView		*_Nullable unknownHostView;
    IBOutlet NSTextField	*_Nullable unknownHostMsgField;
    IBOutlet NSTextField	*_Nullable unknownHostKeyField;
    
    IBOutlet NSPanel 		*_Nullable scpSheet;
    IBOutlet NSWindow 		*_Nullable scpWindow;
    
    IBOutlet NSWindow		*_Nullable scpLogWindow;
    IBOutlet NSTextView		*_Nullable scpLogField;
    
    IBOutlet NSProgressIndicator *_Nullable authProgBar;
    
@private
    NSString			*scpFileName;
    SCPTransfer			*scp;
    double			bytescopied, scpFileSize;
    
    BOOL			_firstPasswordPrompt;
    BOOL			_gotPasswordFromKeychain;
    
    id				_scpDelegate;
    pid_t			scppid;
    int				masterfd;
}
NS_ASSUME_NONNULL_BEGIN

- ( void )authenticateWithPrompt: ( char * )prompt;
- ( IBAction )authenticate: ( id _Nullable )sender;
- ( void )write: ( char * )buf;
- ( void )passError;

- ( void )sessionError: ( NSString * )err;

- ( IBAction )beginSCP: ( id _Nullable )sender;
- ( IBAction )cancelSCP: ( id _Nullable )sender;
- ( IBAction )cancelSCPDialog: ( id _Nullable )sender;
- ( IBAction )chooseLocalFile: ( id _Nullable )sender;
- ( IBAction )toggleLogWindow: ( id _Nullable )sender;

- ( void )getSecureCopyWindowForFile: ( NSString * )filename
            scpType: ( int )scpType copyToPath: ( NSString * )destPath
            fromHost: ( NSString * )rhost userName: ( NSString * )user
            delegate: ( id )delegate;
- ( void )getContinueQueryWithString: ( NSString * )string;
- ( IBAction )acceptHost: ( id _Nullable )sender;
- ( IBAction )refuseHost: ( id _Nullable )sender;

- ( BOOL )firstPasswordPrompt;
- ( void )setFirstPasswordPrompt: ( BOOL )fp;
- ( BOOL )gotPasswordFromKeychain;
- ( void )setGotPasswordFromKeychain: ( BOOL )gp;
- ( BOOL )retrievePasswordFromKeychain;

- ( void )secureCopy;
- ( void )fileCopying: ( NSString * )fname
            updateWithPercentDone: ( char * )pc
            eta: ( char * )eta
            bytesCopied: ( char * )bytes;
- ( void )secureCopyFinishedWithStatus: ( int )status;
/* on completion, SCPController class calls delegate method -(void)scpFinished */

- ( void )clearLog;
- ( void )addToLog: ( NSString * )buf;

- ( void )setSCPPID: ( pid_t )pid;
- ( void )setMasterFD: ( int )fd;

- ( id )delegate;
- ( void )setDelegate: ( id )delegate;

NS_ASSUME_NONNULL_END
@end

/* delegate methods */
@interface NSObject(SCPControllerDelegate)
NS_ASSUME_NONNULL_BEGIN
- ( void )scpFinished;
NS_ASSUME_NONNULL_END
@end
