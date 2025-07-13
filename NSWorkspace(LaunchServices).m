/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import "NSWorkspace(LaunchServices).h"

@implementation NSWorkspace(LaunchServices)

- (BOOL)launchServicesOpenURL:(NSURL *)fileURL
         withApplicationURL:(NSURL *)appURL
         passThruParams:(NSDictionary *)params
         launchFlags:(NSWorkspaceLaunchOptions)flags
{
    if (!fileURL) {
        NSLog(@"launchServicesOpenURL: fileURL is nil");
        return NO;
    }
    
    NSWorkspaceLaunchOptions launchOptions = flags;
    if (appURL) {
        // Use the specified application
        return [[NSWorkspace sharedWorkspace] openURLs:@[fileURL]
                                 withApplicationAtURL:appURL
                                            options:launchOptions
                              additionalEventParamDescriptor:nil
                                           launchIdentifier:nil];
    } else {
        // Use default application
        return [[NSWorkspace sharedWorkspace] openURL:fileURL];
    }
}

- (BOOL)launchServicesFindApplicationForCreatorType:(NSString *)creator
    bundleID:(NSString *)bundleID
    appName:(NSString *)appName
    foundAppURL:(NSURL **)appURL
{
    if (appURL) {
        *appURL = nil;
    }
    
    // Try bundle ID first
    if (bundleID) {
        NSURL *url = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:bundleID];
        if (url && appURL) {
            *appURL = url;
            return YES;
        }
    }
    
    // Try app name
    if (appName) {
        NSURL *url = [[NSWorkspace sharedWorkspace] URLForApplicationToOpenURL:[NSURL fileURLWithPath:@"/"]];
        if (url && appURL) {
            *appURL = url;
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)launchServicesFindApplication:(NSString *)appName
    foundAppURL:(NSURL **)appURL
{
    return [self launchServicesFindApplicationForCreatorType:nil
                                                   bundleID:nil
                                                   appName:appName
                                               foundAppURL:appURL];
}

- (BOOL)launchServicesFindApplicationWithCreatorType:(NSString *)creator
    foundAppURL:(NSURL **)appURL
{
    return [self launchServicesFindApplicationForCreatorType:creator
                                                   bundleID:nil
                                                   appName:nil
                                               foundAppURL:appURL];
}

- (BOOL)launchServicesFindApplicationWithBundleID:(NSString *)bundleID
    foundAppURL:(NSURL **)appURL
{
    return [self launchServicesFindApplicationForCreatorType:nil
                                                   bundleID:bundleID
                                                   appName:nil
                                               foundAppURL:appURL];
}

@end
