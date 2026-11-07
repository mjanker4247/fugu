/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

/*
 * simple class to handle opening files and directories
 * from contextual menus.
 */

#import <Cocoa/Cocoa.h>

@interface UMFileLauncher : NSObject {

}
NS_ASSUME_NONNULL_BEGIN

- ( BOOL )openFile: ( NSString * )file withApplication: ( NSString * _Nullable )app;
- ( BOOL )externalEditFile: ( NSString * )path
            withCLIEditor: ( NSString * )editor
            contextInfo: ( void * )contextInfo;

NS_ASSUME_NONNULL_END
@end
