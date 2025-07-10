/*
 * Copyright (c) 2005 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Cocoa/Cocoa.h>

/* column minimum widths */
#define DATE_COLUMN_WIDTH	100.0
#define GROUP_COLUMN_WIDTH	70.0
#define MODE_COLUMN_WIDTH	80.0
#define OWNER_COLUMN_WIDTH	70.0
#define SIZE_COLUMN_WIDTH	70.0

@interface SFTPTableView : NSTableView
{
@private
    NSInteger	    rightClickedRow;
    NSInteger	    _sftpDragPhase;
    NSTimer	    *springLoadedTimer;
    NSImage	    *_sftpOriginalDragImage;
    NSArray	    *_sftpOriginalPboardTypes;
    NSMutableArray  *_sftpOriginalPboardPlists;
    BOOL	    _sftpDragPromisedFiles;
}

- ( void )keyDown: ( NSEvent * )theEvent;
- ( NSInteger )rightClickedRow;

- ( NSPoint )originOfSelectedCell;

- ( void )addTableColumnWithIdentifier: ( id )identifier
            columnTitle: ( NSString * )title width: ( CGFloat )width;
	    
- ( BOOL )dragPromisedFiles;
- ( void )setDragPromisedFiles: ( BOOL )promised;

@end

/* to assist column creation in delegate */
NSString 	*ColumnTitleFromIdentifier( NSString *identifier );
CGFloat		WidthForColumnWithIdentifier( NSString *identifier );


/* additional delegate methods */
@interface NSObject(SFTPTableViewEventDelegate)

- ( BOOL )handleEvent: ( NSEvent * )theEvent fromTable: ( SFTPTableView * )table;
- ( BOOL )handleChangedText: ( NSString * )newstring forTable: ( SFTPTableView * )table
            column: ( int )column;
- ( NSMenu * )menuForTable: ( SFTPTableView * )table
            column: ( int )column
            row: ( int )row;

@end

/* additional dataSource methods */
@interface NSObject(SFTPTableViewDataSource)
- ( NSArray * )promisedNamesFromPlists: ( id )plist;
- ( BOOL )handleDroppedPromisedFiles: ( NSArray * )promisedFiles
	    destination: ( NSString * )dropDestination;
@end