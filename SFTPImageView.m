/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import "SFTPImageView.h"

@implementation NSImageCell(DraggableExtensions)

- ( NSImage * )scaledImage
{
    // Remove this method from NSImageCell, as it does not have access to [self bounds]
    return nil;
}

@end



@implementation SFTPImageView

- ( void )awakeFromNib
{
    _imageLocationPath_ = nil;
}

/* allow user to drag image out of image view */
- ( void )mouseDown: ( NSEvent * )theEvent
{
    NSSize		dragOffset = NSMakeSize( 0.0, 0.0 );
    NSPasteboard	*pboard;
    NSImage		*dragImage = nil;
    NSImage		*scaledImage = [[ self cell ] scaledImage ];
    NSPoint		point;
    NSArray		*paths = nil;
    
    point = NSMakePoint((( [ self bounds ].size.width - [ scaledImage size ].width ) / 2.0 ),
                        (( [ self bounds ].size.height - [ scaledImage size ].height ) / 2.0 ));

    pboard = [ NSPasteboard pasteboardWithName: NSDragPboard ];
    [ pboard declareTypes: [ NSArray arrayWithObjects: NSTIFFPboardType,
                                        NSFilenamesPboardType, nil ]
                owner: self ];
                
    [ pboard setData: [[ self image ] TIFFRepresentation ]
            forType: NSTIFFPboardType ];
    
    if ( [ self imageLocationPath ] != nil ) {
        paths = [ NSArray arrayWithObject: [ self imageLocationPath ]];
        [ pboard setPropertyList: paths forType: NSFilenamesPboardType ];
    }
    
    dragImage = [[ NSImage alloc ] initWithSize: [ scaledImage size ]];
    [ dragImage lockFocus ];
    [ scaledImage dissolveToPoint: NSMakePoint( 0.0, 0.0 )
                    fraction: 0.5 ];
    [ dragImage unlockFocus ];
    
    [ self dragImage: dragImage at: point
            offset: dragOffset event: theEvent pasteboard: pboard
            source: self slideBack: YES ];
    [ dragImage release ];
}

- ( BOOL )needsPanelToBecomeKey
{
    return( YES );
}

- ( BOOL )acceptsFirstResponder
{
    return( YES );
}

- ( NSDragOperation )draggingSourceOperationMaskForLocal: ( BOOL )isLocal
{
    if ( isLocal ) {
        return( NSDragOperationNone );
    }
    
    return( NSDragOperationGeneric | NSDragOperationCopy );
}

- ( void )setImageLocationPath: ( NSString * )path
{
    if ( _imageLocationPath_ != nil ) {
        [ _imageLocationPath_ release ];
        _imageLocationPath_ = nil;
    }
    
    if ( path == nil || [ path isEqualToString: @"" ] ) {
        return;
    }
    
    _imageLocationPath_ = [[ NSString alloc ] initWithString: path ];
}

- ( NSString * )imageLocationPath
{
    return( _imageLocationPath_ );
}

// Add the correct scaledImage implementation here
- (NSImage *)scaledImage
{
    NSImage *image = [self image];
    if (!image) {
        return nil;
    }
    
    NSSize imageSize = [image size];
    NSSize viewSize = [self bounds].size;
    
    // If the image fits within the view, return it as is
    if (imageSize.width <= viewSize.width && imageSize.height <= viewSize.height) {
        return image;
    }
    
    // Calculate the scaled size maintaining aspect ratio
    CGFloat scaleX = viewSize.width / imageSize.width;
    CGFloat scaleY = viewSize.height / imageSize.height;
    CGFloat scale = MIN(scaleX, scaleY);
    
    NSSize scaledSize = NSMakeSize(imageSize.width * scale, imageSize.height * scale);
    
    // Create a scaled copy of the image
    NSImage *scaledImage = [[NSImage alloc] initWithSize:scaledSize];
    [scaledImage lockFocus];
    [image drawInRect:NSMakeRect(0, 0, scaledSize.width, scaledSize.height)];
    [scaledImage unlockFocus];
    
    return [scaledImage autorelease];
}

@end