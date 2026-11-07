/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Cocoa/Cocoa.h>

@interface SFTPImageView : NSImageView <NSDraggingSource>
{
@private
    NSString		*_imageLocationPath_;
}
NS_ASSUME_NONNULL_BEGIN

- ( void )mouseDown: ( NSEvent * )theEvent;
- ( BOOL )needsPanelToBecomeKey;
- ( BOOL )acceptsFirstResponder;

- ( void )setImageLocationPath: ( NSString * )path;
- ( NSString * )imageLocationPath;

NS_ASSUME_NONNULL_END
@end