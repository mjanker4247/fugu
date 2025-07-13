/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import "NSString(FSRefAdditions).h"
#import <Foundation/Foundation.h>

@implementation NSString(FSRefAdditions)

+ (NSString *)stringWithURL:(NSURL *)url
{
    if (!url) {
        NSLog(@"stringWithURL: url is nil");
        return nil;
    }
    
    return [url path];
}

+ (NSString *)stringWithAliasData:(NSData *)aliasData
{
    if (!aliasData) {
        NSLog(@"stringWithAliasData: aliasData is nil");
        return nil;
    }
    
    // Use modern bookmark resolution
    NSURL *resolvedURL = nil;
    NSError *error = nil;
    BOOL stale = NO;
    
    resolvedURL = [NSURL URLByResolvingBookmarkData:aliasData
                                           options:NSURLBookmarkResolutionWithSecurityScope
                                     relativeToURL:nil
                               bookmarkDataIsStale:&stale
                                             error:&error];
    
    if (!resolvedURL) {
        NSLog(@"Failed to resolve alias data: %@", error);
        return nil;
    }
    
    return [resolvedURL path];
}

- (NSURL *)URLRepresentation
{
    return [NSURL fileURLWithPath:self];
}

- (NSString *)stringByResolvingAliasInPath
{
    NSURL *url = [NSURL fileURLWithPath:self];
    if (!url) {
        return self;
    }
    
    // Check if it's an alias
    NSNumber *isAlias = nil;
    NSError *error = nil;
    
    if ([url getResourceValue:&isAlias forKey:NSURLIsAliasFileKey error:&error]) {
        if ([isAlias boolValue]) {
            // Resolve the alias
            NSURL *resolvedURL = nil;
            if ([url getResourceValue:&resolvedURL forKey:NSURLOriginalURLKey error:&error]) {
                return [resolvedURL path];
            }
        }
    }
    
    return self;
}

- (BOOL)isAliasFile
{
    NSURL *url = [NSURL fileURLWithPath:self];
    if (!url) {
        return NO;
    }
    
    NSNumber *isAlias = nil;
    NSError *error = nil;
    
    if ([url getResourceValue:&isAlias forKey:NSURLIsAliasFileKey error:&error]) {
        return [isAlias boolValue];
    }
    
    return NO;
}

@end
