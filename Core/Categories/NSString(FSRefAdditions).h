/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Foundation/Foundation.h>

@interface NSString(FSRefAdditions)
NS_ASSUME_NONNULL_BEGIN
- ( NSString * )stringByResolvingAliasInPath;
- ( BOOL )isAliasFile;
NS_ASSUME_NONNULL_END
@end
