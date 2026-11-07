/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Cocoa/Cocoa.h>

@interface SFTPNode : NSObject {

}
NS_ASSUME_NONNULL_BEGIN
+ ( SFTPNode * )sharedInstance;
- ( NSMutableArray * )itemsAtPath: ( NSString * )path showHiddenFiles: ( BOOL )showHidden;
- ( BOOL )isDirectory: ( NSString * )path;
- ( NSDictionary * )statInformationForPath: ( NSString * )path;
- ( void )setUpNodeCell: ( NSString * )nodePath forCell: ( NSBrowserCell * )cell;
- ( NSSet * )invisibles;
- ( NSSet * )bundleExtensions;
NS_ASSUME_NONNULL_END
@end
