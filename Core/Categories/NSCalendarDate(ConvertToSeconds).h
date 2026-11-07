/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Foundation/Foundation.h>

@interface NSDate(ConvertToSeconds)

NS_ASSUME_NONNULL_BEGIN
+ ( off_t )secondsFromFormattedDateString: ( NSString * )dString;

NS_ASSUME_NONNULL_END
@end
