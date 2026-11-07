/*
 * Copyright (c) 2005 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Cocoa/Cocoa.h>

@interface UMDragDropImageView : NSImageView
{
    id		_umDragDropImageViewDelegate;
}
NS_ASSUME_NONNULL_BEGIN

- ( void )setDelegate: ( id )delegate;
- ( id )delegate;

NS_ASSUME_NONNULL_END
@end

/* delegate methods */
@interface NSObject(UMDragDropImageView)
NS_ASSUME_NONNULL_BEGIN
- ( void )dropImageViewChanged: ( NSDictionary * )changeDictionary;
NS_ASSUME_NONNULL_END
@end