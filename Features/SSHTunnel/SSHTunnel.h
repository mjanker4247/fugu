/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Cocoa/Cocoa.h>

@class SSHTunnelAuth;

@interface SSHTunnel : NSObject
{
    IBOutlet NSProgressIndicator *_Nullable authProgBar;
    IBOutlet NSTextField 	*_Nullable authProgMsg;
    IBOutlet NSTextField 	*_Nullable passErrorField;
    IBOutlet NSTextField 	*_Nullable passPromptField;
    IBOutlet NSButton		*_Nullable addToKeychainSwitch;
    IBOutlet NSView 		*_Nullable passpromptView;
    IBOutlet NSTextField 	*_Nullable passwordField;
    IBOutlet NSComboBox 	*_Nullable remoteHostField;
    IBOutlet NSComboBox 	*_Nullable remotePortField;
    IBOutlet NSTextField	*_Nullable localPortField;
    IBOutlet NSPanel 		*_Nullable sshtunnelSheet;
    IBOutlet NSTableView 	*_Nullable sshTunnelsTable;
    IBOutlet NSPanel 		*_Nullable sshtunnelWindow;
    IBOutlet NSView 		*_Nullable tunnelCreationView;
    IBOutlet NSComboBox		*_Nullable tunnelHostField;
    IBOutlet NSTextField 	*_Nullable unknownHostKeyField;
    IBOutlet NSTextField 	*_Nullable unknownHostMsgField;
    IBOutlet NSView 		*_Nullable unknownHostView;
    IBOutlet NSTextField 	*_Nullable usernameField;
    IBOutlet NSTextField	*_Nullable tunnelPortField;
    IBOutlet NSPopUpButton	*_Nullable serviceFavoritePopUp;
    
    /* add service sheet */
    IBOutlet NSPanel		*_Nullable addServiceSheet;
    IBOutlet NSTextField	*_Nullable newServicePort;
    IBOutlet NSTextField	*_Nullable newServiceName;
    
    IBOutlet NSPopUpButton	*_Nullable sshTunnelInfoButton;
    
    IBOutlet NSProgressIndicator *_Nullable connectProgBar;
    IBOutlet NSTextField	*_Nullable connectMsg;
    
@private
    SSHTunnelAuth		*ssh;
    BOOL			_firstPasswordPrompt;
    BOOL			_gotPasswordFromKeychain;
    pid_t			sshpid;
}
NS_ASSUME_NONNULL_BEGIN

- ( void )write: ( char * )buf;
- ( void )authenticateWithPrompt: ( char * )prompt;
- ( void )getContinueQueryWithString: ( NSString * )string;
- ( void )passError;
- ( void )connectionError: ( NSString * )errmsg;

- ( BOOL )firstPasswordPrompt;
- ( void )setFirstPasswordPrompt: ( BOOL )fp;
- ( BOOL )gotPasswordFromKeychain;
- ( void )setGotPasswordFromKeychain: ( BOOL )gp;
- ( BOOL )retrievePasswordFromKeychain;

- ( void )displayWindow;

- ( IBAction )authenticate: ( id _Nullable )sender;
- ( IBAction )acceptHost: ( id _Nullable )sender;
- ( IBAction )cancelTunnelCreation: ( id _Nullable )sender;
- ( IBAction )closeTunnel: ( id _Nullable )sender;
- ( IBAction )refuseHost: ( id _Nullable )sender;
- ( IBAction )startTunnel: ( id _Nullable )sender;

- ( void )setSSHPID: ( pid_t )pid;

- ( void )tunnelCreated;
- ( void )addTunneledHostToDefaults: ( NSString * )rHost;

#ifdef notdef
- ( IBAction )cancelServiceAdd: ( id _Nullable )sender;
- ( void )addService;
- ( IBAction )addService: ( id _Nullable )sender;
- ( void )reloadServiceFavorites;
#endif /* notdef */

//- ( IBAction )selectFromFavorites: ( id )sender;

NS_ASSUME_NONNULL_END
@end
