/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import "NSWorkspace(SystemVersionNumber).h"

@implementation NSWorkspace(SystemVersionNumber)

+ (NSOperatingSystemVersion)systemVersion
{
    return [[NSProcessInfo processInfo] operatingSystemVersion];
}

+ (NSInteger)majorSystemVersion
{
    return [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion;
}

@end
