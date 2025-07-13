/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <AppKit/AppKit.h>

@interface NSWorkspace(SystemVersionNumber)
+ (NSOperatingSystemVersion)systemVersion;
+ (NSInteger)majorSystemVersion;
@end
