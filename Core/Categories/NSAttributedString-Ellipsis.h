/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Cocoa/Cocoa.h>

@interface NSAttributedString(Ellipsis)

NS_ASSUME_NONNULL_BEGIN
- ( NSAttributedString * )ellipsisAbbreviatedStringForWidth: ( double )width;
NS_ASSUME_NONNULL_END
@end
