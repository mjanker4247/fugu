/*
 * Copyright (c) 2004 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Foundation/Foundation.h>

@interface NSString(UnknownEncoding)

NS_ASSUME_NONNULL_BEGIN
+ ( NSString * )stringWithBytesOfUnknownEncoding: ( char * )bytes
                length: ( unsigned )len;

NS_ASSUME_NONNULL_END
@end
