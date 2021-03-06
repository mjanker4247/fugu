/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Foundation/Foundation.h>

@interface NSMutableDictionary(Fugu)
+ ( NSMutableDictionary * )favoriteDictionaryFromHostname: ( NSString * )hostname;
- ( NSComparisonResult )cacheDateCompare: ( NSDictionary * )dict;
@end
