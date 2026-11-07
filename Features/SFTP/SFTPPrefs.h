/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Cocoa/Cocoa.h>

#define SFTPPrefsChangedNotification	@"SFTPPrefsChangedNotification"

@class SFTPPrefTableView;

@interface SFTPPrefs : NSObject <NSToolbarDelegate, NSTableViewDelegate, NSTableViewDataSource>
{
    IBOutlet NSComboBox 	*_Nullable prefDefaultHost;
    IBOutlet NSTextField	*_Nullable prefDefaultUser;
    IBOutlet NSTextField	*_Nullable prefDefaultLDir;
    IBOutlet NSTextField	*_Nullable prefDefaultRDir;
    IBOutlet NSTextField	*_Nullable prefDefaultPort;
    IBOutlet SFTPPrefTableView 	*_Nullable prefFavTable;
    IBOutlet NSPanel 		*_Nullable prefPanel;
    IBOutlet NSBox		*_Nullable prefViewBox;
    IBOutlet NSView		*_Nullable prefGeneralView;
    IBOutlet NSView		*_Nullable prefFavoritesView;
    IBOutlet NSView		*_Nullable prefKnownHostsView;
    IBOutlet SFTPPrefTableView	*_Nullable prefKnownHostsTable;
    
    IBOutlet NSView		*_Nullable prefFilesView;   
    IBOutlet NSPopUpButton	*_Nullable prefTextEditorPopUp;
    IBOutlet NSSegmentedControl	*_Nullable prefPostEditMatrix;
    IBOutlet NSSegmentedControl	*_Nullable prefSortingMatrix;
	IBOutlet NSComboBox		*_Nullable prefSSHPath;
    
    IBOutlet NSView		*_Nullable prefTransfersView;
    IBOutlet NSButton		*_Nullable prefRetainFileTimeSwitch;

@private
    NSMutableArray		*favs;
}
NS_ASSUME_NONNULL_BEGIN
- ( IBAction )addFavorite: ( id _Nullable )sender;
- ( IBAction )deleteFavorite: ( id _Nullable )sender;

- ( IBAction )setGeneralDefaults: ( id _Nullable )sender;
- ( IBAction )clearDefaults: ( id _Nullable )sender;

- ( IBAction )deleteKnownHost: ( id _Nullable )sender;
- ( IBAction )saveKnownHosts: ( id _Nullable )sender;

- ( IBAction )setODBTextEditor: ( id _Nullable )sender;

- ( IBAction )toggleRetainFileTime: ( id _Nullable )sender;

- ( IBAction )setPostEditBehaviour: ( id _Nullable )sender;

- ( IBAction )setSortingBehaviour: ( id _Nullable )sender;

- ( IBAction )setSSHPath: ( id _Nullable )sender;

- ( void )readGeneralPrefs;
- ( void )readFavorites;

- ( void )showGeneralPreferences: ( id _Nullable )sender;

- ( IBAction )chooseDefaultLocalDirectory: ( id _Nullable )sender;

- ( void )showPreferencePanel;

NS_ASSUME_NONNULL_END
@end
