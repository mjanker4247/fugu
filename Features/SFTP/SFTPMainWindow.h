/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Cocoa/Cocoa.h>

/*
 * Override animationResizeTime of superclass (NSWindow)
 */

@interface SFTPMainWindow : NSWindow {

}
NS_ASSUME_NONNULL_BEGIN

- ( int )setTitleToLocalHostName;

NS_ASSUME_NONNULL_END
@end
