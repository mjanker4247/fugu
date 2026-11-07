/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Foundation/Foundation.h>

@interface NSArray(CreateArgv)
NS_ASSUME_NONNULL_BEGIN
- ( int )createArgv: ( char * _Nullable * _Nullable * _Nonnull )argv;
NS_ASSUME_NONNULL_END
@end
