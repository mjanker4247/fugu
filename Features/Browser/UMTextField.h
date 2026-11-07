/*
 * Copyright (c) 2005 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Cocoa/Cocoa.h>

@interface UMTextField : NSTextField
{
    id	    _umTextFieldDelegate;
}
NS_ASSUME_NONNULL_BEGIN

- ( void )setDelegate: ( id _Nullable )delegate;
- ( id )delegate;

NS_ASSUME_NONNULL_END
@end

/* delegate methods */
@interface NSObject(UMTextField)
NS_ASSUME_NONNULL_BEGIN
- ( void )umTextFieldContentsChanged: ( NSDictionary * )changeDictionary;
NS_ASSUME_NONNULL_END
@end