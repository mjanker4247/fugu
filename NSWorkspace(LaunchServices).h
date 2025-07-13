/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Cocoa/Cocoa.h>

@interface NSWorkspace(LaunchServices)

- (BOOL)launchServicesOpenURL:(NSURL *)fileURL
         withApplicationURL:(NSURL *)appURL
         passThruParams:(NSDictionary *)params
         launchFlags:(NSWorkspaceLaunchOptions)flags;
         
- (BOOL)launchServicesFindApplicationForCreatorType:(NSString *)creator
    bundleID:(NSString *)bundleID
    appName:(NSString *)appName
    foundAppURL:(NSURL **)appURL;
    
- (BOOL)launchServicesFindApplication:(NSString *)appName
    foundAppURL:(NSURL **)appURL;
        
- (BOOL)launchServicesFindApplicationWithCreatorType:(NSString *)creator
    foundAppURL:(NSURL **)appURL;
        
- (BOOL)launchServicesFindApplicationWithBundleID:(NSString *)bundleID
    foundAppURL:(NSURL **)appURL;

@end
