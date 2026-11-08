/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Cocoa/Cocoa.h>

#import "SFTPMainWindow.h"
#import "SFTPPrefs.h"
@class SFTPTableView;
@class SFTPImagePreviewPanel;
@class SFTPImageView;

@class 		SFTPTServer;
@class		SCPController;

@interface 	SFTPController : NSObject <NSApplicationDelegate, NSToolbarDelegate, NSTableViewDataSource, NSTableViewDelegate, NSTabViewDelegate, NSMenuItemValidation, NSToolbarItemValidation>
{
    /* console panel outlets */
    IBOutlet NSPanel			*_Nullable logPanel;
    IBOutlet NSTextView			*_Nullable logField;
    IBOutlet NSButton			*_Nullable commandButton;
    IBOutlet NSTextField 		*_Nullable manualComField;
    
    /* new dir panel outlets */
    IBOutlet NSPanel			*_Nullable newDirPanel;
    IBOutlet NSTextField		*_Nullable newDirNameField;
    IBOutlet NSButton			*_Nullable newDirCreateButton;
    IBOutlet NSButton			*_Nullable localDirCreateButton;
    IBOutlet NSButton			*_Nullable remoteDirCreateButton;
    
    /* go to dir panel outlets */
    IBOutlet NSPanel			*_Nullable gotoDirPanel;
    IBOutlet NSComboBox			*_Nullable gotoDirNameField;
    IBOutlet NSButton			*_Nullable gotoButton;
    IBOutlet NSButton			*_Nullable localGotoButton;
    IBOutlet NSButton			*_Nullable remoteGotoButton;
    
    /* upload progress panel outlets */
    IBOutlet NSPanel			*_Nullable uploadProgPanel;
    IBOutlet NSTextField		*_Nullable uploadProgName;
    IBOutlet NSTextField		*_Nullable uploadProgItemsLeft;
    IBOutlet NSTextField		*_Nullable uploadTimeField;
    IBOutlet NSProgressIndicator	*_Nullable uploadProgBar;
    IBOutlet NSTextField		*_Nullable uploadProgInfo;
    
    /* download progress panel outlets */
    IBOutlet NSPanel			*_Nullable downloadSheet;
    IBOutlet NSTextField		*_Nullable downloadTextField;
    IBOutlet NSTextField		*_Nullable downloadTimeField;
    IBOutlet NSProgressIndicator	*_Nullable downloadProgBar;
    IBOutlet NSTextField		*_Nullable downloadProgInfo;
    IBOutlet NSTextField		*_Nullable downloadProgPercentDone;
    
    /* preview panel outlets */
    IBOutlet SFTPImagePreviewPanel	*_Nullable imagePreviewPanel;
    IBOutlet NSBox			*_Nullable imagePreviewBox;
    IBOutlet NSView			*_Nullable imagePreviewView;
    IBOutlet SFTPImageView		*_Nullable imagePreview;
    IBOutlet NSTextField		*_Nullable imagePreviewTextField;
    
    /* info panel outlets */
    IBOutlet NSPanel			*_Nullable infoPanel;
    IBOutlet NSTabView			*_Nullable infoTabView;
        // local info fields
    IBOutlet NSImageView		*_Nullable largeIcon;
    IBOutlet NSTextField		*_Nullable modDateField;
    IBOutlet NSTextField	 	*_Nullable groupField;
    IBOutlet NSTextField 		*_Nullable ownerField;
    IBOutlet NSTextField 		*_Nullable sizeField;
    IBOutlet NSTextField 		*_Nullable typeField;
    IBOutlet NSTextField 		*_Nullable permField;
    IBOutlet NSTextField 		*_Nullable infoPathField;
    IBOutlet NSTextField		*_Nullable whereField;
    IBOutlet NSButton 			*_Nullable loReadSwitch;
    IBOutlet NSButton 			*_Nullable loWriteSwitch;
    IBOutlet NSButton 			*_Nullable loExecSwitch;
    IBOutlet NSButton 			*_Nullable lgReadSwitch;
    IBOutlet NSButton 			*_Nullable lgWriteSwitch;
    IBOutlet NSButton 			*_Nullable lgExecSwitch;
    IBOutlet NSButton 			*_Nullable laReadSwitch;
    IBOutlet NSButton 			*_Nullable laWriteSwitch;
    IBOutlet NSButton 			*_Nullable laExecSwitch;
        // remote info fields
    IBOutlet NSImageView		*_Nullable rIcon;
    IBOutlet NSTextField		*_Nullable rModDateField;
    IBOutlet NSTextField	 	*_Nullable rGroupField;
    IBOutlet NSTextField 		*_Nullable rOwnerField;
    IBOutlet NSTextField 		*_Nullable rSizeField;
    IBOutlet NSTextField 		*_Nullable rTypeField;
    IBOutlet NSTextField 		*_Nullable rPermField;
    IBOutlet NSTextField 		*_Nullable rInfoPathField;
    IBOutlet NSTextField		*_Nullable rWhereField;
    IBOutlet NSButton			*_Nullable roReadSwitch;
    IBOutlet NSButton			*_Nullable roWriteSwitch;
    IBOutlet NSButton			*_Nullable roExecSwitch;
    IBOutlet NSButton			*_Nullable rgReadSwitch;
    IBOutlet NSButton			*_Nullable rgWriteSwitch;
    IBOutlet NSButton			*_Nullable rgExecSwitch;
    IBOutlet NSButton			*_Nullable raReadSwitch;
    IBOutlet NSButton			*_Nullable raWriteSwitch;
    IBOutlet NSButton			*_Nullable raExecSwitch;
    
    /* main ui elements */
    //IBOutlet NSTextField		*remoteDirPath;
    IBOutlet NSProgressIndicator	*_Nullable remoteProgBar;
    IBOutlet NSTextField		*_Nullable remoteMsgField;
    IBOutlet NSBox			*_Nullable localBox;
    IBOutlet NSBox			*_Nullable remoteBox;
    
    /* local and remote views */
    IBOutlet NSView			*_Nullable localView;
    IBOutlet NSView			*_Nullable remoteView;
    IBOutlet NSPopUpButton		*_Nullable rPathPopUp;
    IBOutlet NSPopUpButton		*_Nullable lPathPopUp;
    IBOutlet NSTextField		*_Nullable remoteColumnFooter;
    IBOutlet SFTPTableView 		*_Nullable localBrowser;
    IBOutlet NSMenu			*_Nullable localTableMenu;
    IBOutlet SFTPTableView	 	*_Nullable remoteBrowser;
    IBOutlet NSMenu			*_Nullable remoteTableMenu;
    
    IBOutlet id _Nullable hostKeyUnauth;
    IBOutlet id _Nullable unauthHostInfo;
    IBOutlet id _Nullable dotMenuItem;
    IBOutlet id _Nullable infoMenuItem;
    IBOutlet id _Nullable addToFavButton;
    IBOutlet id _Nullable verifyConnectSheet;
    
    /* connecting view outlets */
    IBOutlet NSView			*_Nullable connectingView;
    IBOutlet NSProgressIndicator	*_Nullable connectingProgress;
    IBOutlet NSTextField		*_Nullable connectingToField;
    
    IBOutlet SFTPMainWindow		*_Nullable mainWindow;
    
    /* password prompt outlets */
    IBOutlet NSTextField 		*_Nullable passErrorField;
    IBOutlet NSView	 		*_Nullable passView;
    IBOutlet NSTextField		*_Nullable passWord;
    IBOutlet NSTextField		*_Nullable passHeader;
    IBOutlet NSProgressIndicator	*_Nullable authProgBar;
    IBOutlet NSButton			*_Nullable passAuthButton;
    IBOutlet NSButton			*_Nullable passCancelButton;
    IBOutlet NSButton			*_Nullable addToKeychainSwitch;
    
    /* login view outlets */
    IBOutlet NSView			*_Nullable loginView;
    IBOutlet NSPopUpButton 		*_Nullable popUpFavs;
    IBOutlet id _Nullable remoteHost;
    IBOutlet id _Nullable dotSwitch;
    IBOutlet id _Nullable userName;
    IBOutlet NSTextField 		*_Nullable portField;
    IBOutlet NSTextField		*_Nullable loginDirField;
    IBOutlet NSButton			*_Nullable connectButton;
    IBOutlet NSPopUpButton		*_Nullable rendezvousPopUp;
    
    /* advanced connection outlets */
    IBOutlet NSView			*_Nullable advConnectionView;
    IBOutlet NSBox			*_Nullable advConnectionBox;
    IBOutlet NSTextField		*_Nullable advAdditionalOptionsField;
    IBOutlet NSButton			*_Nullable advForceSSH1Switch;
    IBOutlet NSButton			*_Nullable advEnableCompressionSwitch;
    
    /* view information menu items */
    IBOutlet NSMenuItem			*_Nullable viewGroupMenuItem;
    IBOutlet NSMenuItem			*_Nullable viewModDateMenuItem;
    IBOutlet NSMenuItem			*_Nullable viewModeMenuItem;
    IBOutlet NSMenuItem			*_Nullable viewOwnerMenuItem;
    IBOutlet NSMenuItem			*_Nullable viewSizeMenuItem;
    
@private
    /*
     * used to tell if the password in the keychain was wrong.
     * if so, don't keep turning to the keychain for the password.
     * prompt the user as usual, instead.
     */
    BOOL			firstPasswordPrompt;
    BOOL			gotPasswordFromKeychain;
    
    int				dotflag;

    SFTPTServer			*tServer;
    
    SFTPPrefs			*prefs;
    
    SCPController		*scp;
    
    NSMutableDictionary		*userParameters;
    NSMutableDictionary 	*remoteFileInfo;
    NSString	 		*remoteDirBuf;
    NSString			*remoteHome;
    
    NSMutableArray		*remoteDirContents;
    NSMutableArray		*dotlessRDir;
    NSArray			*rSwitchArray;
    NSString			*remoteDirPath;
    NSMutableArray		*localDirContents;
    NSMutableArray		*dotlessLDir;
    NSString			*localDirPath;
    
    /* rendezvous */
    id				sshServiceBrowser;
    NSMutableArray		*services;
    
    /* documents being edited from the server */
    NSMutableArray		*editedDocuments;
    
    /* images being previewed from the server */
    NSString			*previewedImage;
    NSMutableArray		*cachedPreviews;
    
    /* menus for history */
    NSMenu			*localHistoryMenu;
    NSMenu			*remoteHistoryMenu;
    
    /* queues from which to dispatch items to the session */
    NSMutableArray		*uploadQueue;
    NSMutableArray		*downloadQueue;
    NSMutableArray		*removeQueue;
    
    /* images for display in browsers */
    NSImage			*dirImage;
    NSImage			*fileImage;
    NSImage			*linkImage;
    
    /* spring-loaded root path */
    NSString                    *_springLoadedRootPath;
    
    /* command queue */
    NSMutableArray              *_sftpCommandQueue;
}
NS_ASSUME_NONNULL_BEGIN

- ( void )showUploadProgress;
- ( void )updateUploadProgress: ( int )endflag;
- ( void )removeFirstItemFromUploadQ;
- ( NSMutableArray * )uploadQ;
- ( void )prepareDirUpload: ( NSString * )dir;
- ( void )updateUploadProgressBarWithValue: ( double )value
	    amountTransfered: ( NSString * )amount
	    transferRate: ( NSString * )rate
	    ETA: ( NSString * )eta;

- ( void )removeFirstItemFromDownloadQ;
- ( NSMutableArray * )downloadQ;

- ( IBAction )sendPassword: ( id _Nullable )sender;
- ( void )addPasswordToKeychain;
- ( BOOL )retrievePasswordFromKeychain;
- ( BOOL )firstPasswordPrompt;
- ( void )setFirstPasswordPrompt: ( BOOL )first;
- ( void )setGotPasswordFromKeychain: ( BOOL )rp;
- ( BOOL )gotPasswordFromKeychain;
- ( IBAction )cancelConnection: ( id _Nullable )sender;
- ( IBAction )continueConnecting: ( id _Nullable )sender;
- ( void )connectionError: ( NSString * )errmsg;
- ( void )sessionError: ( NSString * )errmsg;
- ( IBAction )toggleDots: ( id _Nullable )sender;

- ( IBAction )toggleAdvConnectionView: ( id _Nullable )sender;

- ( void )showConnectingInterface: ( id _Nullable )sender;

- ( IBAction )toggleGoToButtons: ( id _Nullable )sender;
- ( IBAction )getGotoDirPanel: ( id _Nullable )sender;
- ( IBAction )gotoLocalDirectory: ( id _Nullable )sender;
- ( IBAction )gotoRemoteDirectory: ( id _Nullable )sender;
- ( IBAction )dismissGotoDirPanel: ( id _Nullable )sender;

- ( IBAction )selectFromFavorites: ( id _Nullable )sender;
- ( IBAction )addToFavorites: ( id _Nullable )sender;

- ( IBAction )sftpConnect: ( id _Nullable )sender;

- ( void )showDownloadProgressWithMessage: ( char * )msg;
- ( void )updateDownloadProgressBarWithValue: ( double )value
	    amountTransfered: ( NSString * )amount
	    transferRate: ( NSString * )rate
	    ETA: ( NSString * )eta;
- ( void )finishedDownload;

- ( IBAction )showItemFromHelpMenu: ( id _Nullable )sender;

/* interaction related methods */
- ( void )uploadFiles: ( NSArray * )lfiles toDirectory: ( NSString * )rpath;
- ( void )downloadFiles: ( NSArray * )rpaths toDirectory: ( NSString * )lpath;
- ( IBAction )createNewDirectory: ( id _Nullable )sender;
- ( IBAction )toggleDirCreationButtons: ( id _Nullable )sender;
- ( IBAction )dismissNewDirPanel: ( id _Nullable )sender;

/* spring-loaded folders */
- ( void )performSpringLoadedActionInTable: ( NSTableView * )table;
- ( void )setSpringLoadedRootPathInTable: ( NSTableView * )table;
- ( NSString * )springLoadedRootPath;

/* accessor methods for sftp command queue */
- ( void )queueSFTPCommand: ( const char * )fmt, ...;
- ( NSMutableArray * )SFTPCommandQueue;
- ( id )nextSFTPCommandFromQueue;

/* methods related to deleting items */
- ( IBAction )delete: ( id _Nullable )sender;
- ( IBAction )deleteLocalFile: ( id _Nullable )sender;
- ( IBAction )deleteRemoteFile: ( id _Nullable )sender;
- ( void )deleteFirstItemFromRemoveQueue;
- ( NSMutableArray * )removeQ;

- ( IBAction )focusOnLocalPane: ( id _Nullable )sender;
- ( IBAction )focusOnRemotePane: ( id _Nullable )sender;

- ( IBAction )localBrowserSingleClick: ( id _Nullable )browser;
- ( IBAction )localBrowserDoubleClick: ( id _Nullable )browser;
- ( IBAction )uploadButtonClick: ( id _Nullable )sender;
- ( IBAction )remoteBrowserSingleClick: ( id _Nullable )browser;
- ( IBAction )remoteBrowserDoubleClick: ( id _Nullable )browser;
- ( IBAction )downloadButtonClick: ( id _Nullable )sender;
- ( IBAction )cdRemoteHome: ( id _Nullable )sender;
- ( IBAction )cdLocalHome: ( id _Nullable )sender;
- ( IBAction )remoteCdDotDot: ( id _Nullable )sender;
- ( IBAction )localCdDotDot: ( id _Nullable )sender;
- ( IBAction )cdFromLPathPopUp: ( id _Nullable )sender;
- ( IBAction )cdFromRPathPopUp: ( id _Nullable )sender;
- ( IBAction )refreshBrowsers: ( id _Nullable )sender;

- ( void )changeToRemoteDirectory: ( NSString * )remotePath;
- ( void )changeDirectory: ( id _Nullable )sender;
- ( void )dotdot: ( id _Nullable )sender;

- ( IBAction )changeROwner: ( id _Nullable )sender;
- ( IBAction )changeRGroup: ( id _Nullable )sender;
- ( IBAction )changeRemoteMode: ( id _Nullable )sender;

- ( IBAction )changeLOwnerAndGroup: ( id _Nullable )sender;
- ( IBAction )changeLocalMode: ( id _Nullable )sender;

- ( IBAction )renameLocalItem: ( id _Nullable )sender;
- ( IBAction )renameRemoteItem: ( id _Nullable )sender;

- ( void )getListing;
- ( void )setBusyStatusWithMessage: ( NSString * )message;
- ( void )finishedCommand;
- ( void )writeCommand: ( void * )cmd;
- ( IBAction )sendManualCommand: ( id _Nullable )sender;

- ( IBAction )showLogPanel: ( id _Nullable )sender;
- ( void )clearLog;
- ( void )addToLog: ( NSString * )text;
- ( void )updateHostList;
- ( void )reloadDefaults;

- ( void )passError;
- ( void )setConnectedWindowTitle;
- ( IBAction )disconnect: ( id _Nullable )sender;
- ( void )cleanUp;
- ( id )init;
//- ( void )mouseDown: ( NSEvent * )theEvent;

- ( void )localBrowserReloadForPath: ( NSString * )path;

- ( IBAction )toggleGroupColumn: ( id _Nullable )sender;
- ( IBAction )toggleModDateColumn: ( id _Nullable )sender;
- ( IBAction )toggleModeColumn: ( id _Nullable )sender;
- ( IBAction )toggleOwnerColumn: ( id _Nullable )sender;
- ( IBAction )toggleSizeColumn: ( id _Nullable )sender;

- ( void )setRemotePathPopUp: ( NSString * )pwd;
- ( void )showRemoteFiles;
- ( void )loadRemoteBrowserWithItems: ( NSArray * )items;
- ( IBAction )getInfo: ( id _Nullable )sender;
- ( void )remoteCheckSetup: ( NSString * )permissions;
- ( void )localCheckSetup: ( NSString * )octalmode;
- ( void )getContinueQueryForUnknownHost: ( NSDictionary * )hostInfo;
- ( void )requestPasswordWithPrompt: ( char * )header;
- ( void )enableFavButton: ( NSNotification * )aNotification;
- ( void )awakeFromNib;

- ( IBAction )showPrefs: ( id _Nullable )sender;

- ( int )matchingIndexForString: ( NSString * )string inTable: ( SFTPTableView * )table;
                
- ( IBAction )checkForUpdates: ( id _Nullable )sender;

- ( void )scanForSSHServers: ( id _Nullable )sender;
- ( IBAction )selectRendezvousServer: ( id _Nullable )sender;

- ( IBAction )previewItem: ( id _Nullable )sender;
- ( IBAction )previewLocalItem: ( id _Nullable )sender;
- ( IBAction )previewRemoteItem: ( id _Nullable )sender;
- ( void )setPreviewedImage: ( NSString * _Nullable )imagepath;
- ( NSString * )previewedImage;
- ( void )displayPreview;
- ( void )addToCachedPreviews: ( NSDictionary *)cachedData;
- ( NSArray * )cachedPreviews;

- ( IBAction )editFile: ( id _Nullable )sender;
- ( IBAction )openLocalFileInEditor: ( id _Nullable )sender;
- ( IBAction )openRemoteFileInEditor: ( id _Nullable )sender;
- ( void )ODBEditFile: ( NSString * )filepath remotePath: ( NSString * )remotepath;
- ( void )uploadSettledEditAtLocalPath: ( NSString * )localPath remotePath: ( NSString * )remotePath;

- ( NSArray * )editedDocuments;
- ( void )addToEditedDocuments: ( NSString * )docpath remotePath: ( NSString * )rpath;
- ( void )removeFromEditedDocuments: ( NSString * )docpath;

/* other ssh related tools */
- ( IBAction )newSSHTunnel: ( id _Nullable )sender;
- ( IBAction )secureCopy: ( id _Nullable )sender;
- ( IBAction )scp: ( id _Nullable )sender;
- ( void )scpLocalItem: ( NSString * )item toHost: ( NSString * )rhost
        userName: ( NSString * )user;
- ( void )scpRemoteItem: ( NSString * )rdir fromHost: ( NSString * )rhost
        toLocalPath: ( NSString * )ldir userName: ( NSString * )user;
- ( void )scpFinished; /* SCPController delegate method */

NS_ASSUME_NONNULL_END
@end
