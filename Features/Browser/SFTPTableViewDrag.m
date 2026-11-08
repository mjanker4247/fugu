/*
 * Copyright (c) 2005 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import "Fugu-Swift.h"

/// Swift marks these NSDraggingSource methods unavailable. The selectors still run, so they stay in Objective-C.
@implementation SFTPTableView (LegacyDrag)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- ( void )dragImage: ( NSImage * )anImage at: ( NSPoint )imageLoc offset: ( NSSize )mouseOffset
        event: ( NSEvent * )theEvent pasteboard: ( NSPasteboard * )pboard
	source: ( id )sourceObject slideBack: ( BOOL )slideBack
{
    NSInteger           row = [ self rowAtPoint: imageLoc ];
    NSRect		imageframe = [ self frameOfCellAtColumn: 0 row: row ];
    NSRect		imageRect;
    float		width = NSWidth( imageframe );
    float		height = NSHeight( imageframe );
    NSSize		imagesize;
    NSImage		*image = nil;
    NSView		*view = nil;
    int			i;

    if ( self.dragPhase == 0 ) {
	/*
	 * phase 0: capture image and original pasteboard
	 * contents, then drag promised files if required
	 */
	if (( view = [[ self superview ] superview ] ) == nil ) {
	    view = self;
	}
	height = NSHeight( [ view frame ] );

	imagesize = NSMakeSize( width, height );
	image = [[ NSImage alloc ] initWithSize: imagesize ];

	/* only draw the portion from the filename column */
	[ image lockFocus ];
	[ anImage dissolveToPoint: NSZeroPoint fraction: 1.0 ];
	[ image unlockFocus ];

	if ( ! [ self dragPromisedFiles ] ) {
	    [ super dragImage: image at: imageLoc offset: mouseOffset
		event: theEvent pasteboard: pboard source: sourceObject
		slideBack: slideBack ];
	    return;
	}

	self.originalDragImage = image;
	self.originalPboardTypes = [[ pboard types ] copy ];

	NSMutableArray *plists = [[ NSMutableArray alloc ] init ];
	for ( i = 0; i < [ self.originalPboardTypes count ]; i++ ) {
	    [ plists addObject:
		    [ pboard propertyListForType:
			[ self.originalPboardTypes objectAtIndex: i ]]];
	}
	self.originalPboardPlists = plists;
	self.dragPhase = 1;

	imageRect.origin = imageLoc;
	imageRect.size = NSMakeSize( 0.0, 0.0 );

	[ self dragPromisedFilesOfTypes: [ NSArray arrayWithObject: @"'doc '" ]
		    fromRect: imageRect source: self slideBack: YES event: theEvent ];

    } else {
	/*
	 * phase 1: restore original image; add old pasteboard
	 * contents; and let super do all the rest
	 */
	NSArray		*types = self.originalPboardTypes;
	id		plist;

	[ pboard addTypes: types owner: [ self delegate ]];
	for ( i = 0; i < [ types count ]; i++ ) {
	    plist = [ self.originalPboardPlists objectAtIndex: i ];
	    [ pboard setPropertyList: plist forType: [ types objectAtIndex: i ]];
	}

	[ super dragImage: self.originalDragImage at: imageLoc offset: mouseOffset
		event: theEvent pasteboard: pboard source: sourceObject
		slideBack: slideBack ];

	self.originalDragImage = nil;
	self.originalPboardTypes = nil;

	self.dragPhase = 0;
    }
}

- ( NSDragOperation )draggingSourceOperationMaskForLocal: ( BOOL )isLocal
{
    return( NSDragOperationCopy );
}

- ( void )draggedImage: ( NSImage * )image endedAt: ( NSPoint )point
	    operation: ( NSDragOperation )operation
{
    /* work around a bug in Panther */
    [[ NSPasteboard pasteboardWithName: NSDragPboard ]
	    declareTypes: @[] owner: nil ];
}
#pragma clang diagnostic pop

@end
