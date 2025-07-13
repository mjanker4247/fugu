/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import "aevent.h"
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

/* Modern file notification using NSWorkspace and NSNotificationCenter */
int notifyFileModified(NSString *path, NSString *senderToken)
{
    if (!path) {
        NSLog(@"notifyFileModified: path is nil");
        return -1;
    }
    
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    if (!fileURL) {
        NSLog(@"notifyFileModified: failed to create URL from path: %@", path);
        return -1;
    }
    
    // Post notification for file modification
    NSDictionary *userInfo = @{
        @"fileURL": fileURL,
        @"senderToken": senderToken ?: @"",
        @"eventType": @"modified"
    };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FileModifiedNotification" 
                                                      object:nil 
                                                    userInfo:userInfo];
    
    return 0;
}

void notifyFileSaved(NSString *path, NSString *senderToken)
{
    if (notifyFileModified(path, senderToken) < 0) {
        NSLog(@"Failed to send save notification for: %@", path);
    }
}

void notifyFileClosed(NSString *path)
{
    if (!path) {
        NSLog(@"notifyFileClosed: path is nil");
        return;
    }
    
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    if (!fileURL) {
        NSLog(@"notifyFileClosed: failed to create URL from path: %@", path);
        return;
    }
    
    // Post notification for file close
    NSDictionary *userInfo = @{
        @"fileURL": fileURL,
        @"eventType": @"closed"
    };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FileClosedNotification" 
                                                      object:nil 
                                                    userInfo:userInfo];
}
