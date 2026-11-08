/*
 * Copyright (c) 2005 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Cocoa/Cocoa.h>

@interface SFTPTableView : NSTableView
{
@private
    NSInteger	    rightClickedRow;
    int		    _sftpDragPhase;
    NSTimer	    *springLoadedTimer;
    NSImage	    *_sftpOriginalDragImage;
    NSArray	    *_sftpOriginalPboardTypes;
    NSMutableArray  *_sftpOriginalPboardPlists;
    BOOL	    _sftpDragPromisedFiles;
}
NS_ASSUME_NONNULL_BEGIN

- ( void )keyDown: ( NSEvent * )theEvent;
- ( NSInteger )rightClickedRow;

- ( NSPoint )originOfSelectedCell;

- ( void )addTableColumnWithIdentifier: ( id )identifier
            columnTitle: ( NSString * )title width: ( float )width;
	    
- ( BOOL )dragPromisedFiles;
- ( void )setDragPromisedFiles: ( BOOL )promised;

NS_ASSUME_NONNULL_END
@end

/* to assist column creation in delegate */
NS_ASSUME_NONNULL_BEGIN
NSString 	*ColumnTitleFromIdentifier( NSString *identifier );
float		WidthForColumnWithIdentifier( NSString *identifier );
NS_ASSUME_NONNULL_END


/* additional delegate methods */
@interface NSObject(SFTPTableViewEventDelegate)

NS_ASSUME_NONNULL_BEGIN
- ( BOOL )handleEvent: ( NSEvent * )theEvent fromTable: ( SFTPTableView * )table;
- ( BOOL )handleChangedText: ( NSString * )newstring forTable: ( SFTPTableView * )table
            column: ( NSInteger )column;
- ( NSMenu * )menuForTable: ( SFTPTableView * )table
            column: ( NSInteger )column
            row: ( NSInteger )row;
- ( void )performSpringLoadedActionInTable: ( SFTPTableView * )table;
- ( void )springLoadedActionCancelledInTable: ( SFTPTableView * )table;

NS_ASSUME_NONNULL_END
@end

/* additional dataSource methods */
@interface NSObject(SFTPTableViewDataSource)
NS_ASSUME_NONNULL_BEGIN
- ( NSArray * )promisedNamesFromPlists: ( id )plist;
- ( BOOL )handleDroppedPromisedFiles: ( NSArray * )promisedFiles
	    destination: ( NSString * )dropDestination;
NS_ASSUME_NONNULL_END
@end