/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Cocoa/Cocoa.h>

@interface NSWorkspace(LaunchServices)

NS_ASSUME_NONNULL_BEGIN
- ( NSURL * _Nullable )findApplicationNamed: ( NSString * _Nullable )name
                         bundleID: ( NSString * _Nullable )bundleID;

- ( void )openFileURL: ( NSURL * )fileURL
   withApplicationURL: ( NSURL * _Nullable )appURL
            odbParams: ( NSAppleEventDescriptor * _Nullable )params
    completionHandler: ( void (^ _Nullable)( NSError * _Nullable ) )handler;

NS_ASSUME_NONNULL_END
@end
