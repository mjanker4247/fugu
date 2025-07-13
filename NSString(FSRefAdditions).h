/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Foundation/Foundation.h>

@interface NSString(FSRefAdditions)

+ (NSString *)stringWithURL:(NSURL *)url;
+ (NSString *)stringWithAliasData:(NSData *)aliasData;
- (NSURL *)URLRepresentation;
- (NSString *)stringByResolvingAliasInPath;
- (BOOL)isAliasFile;

@end
