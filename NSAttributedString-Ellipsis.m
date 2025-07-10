/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import "NSAttributedString-Ellipsis.h"
// Remove Carbon include as it's no longer needed
// #include <Carbon/Carbon.h>
#include <CoreFoundation/CoreFoundation.h>

@implementation NSAttributedString(Ellipsis)

- ( NSAttributedString * )ellipsisAbbreviatedStringForWidth: ( CGFloat )width
{
    NSAttributedString          *attrString = nil;
    NSMutableString             *string = [[[ self string ] mutableCopy ] autorelease ];
    CGFloat                     paddedWidth = ( width - 24.0 );
    
    // Modern Cocoa approach to text truncation
    NSRect boundingRect = [self boundingRectWithSize:NSMakeSize(paddedWidth, CGFLOAT_MAX) 
                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading];
    
    if (boundingRect.size.width <= paddedWidth) {
        // Text fits within the width, no truncation needed
        return self;
    }
    
    // Calculate how many characters we can fit
    NSString *originalString = [self string];
    NSFont *font = [self attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    if (!font) {
        font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
    }
    
    // Start with a reasonable guess and adjust
    NSInteger maxLength = [originalString length];
    NSInteger minLength = 0;
    NSInteger currentLength = maxLength / 2;
    
    while (minLength < maxLength) {
        NSString *testString = [originalString substringToIndex:currentLength];
        if (currentLength < [originalString length]) {
            testString = [testString stringByAppendingString:@"..."];
        }
        
        NSAttributedString *testAttrString = [[NSAttributedString alloc] initWithString:testString attributes:[self attributesAtIndex:0 effectiveRange:NULL]];
        NSRect testRect = [testAttrString boundingRectWithSize:NSMakeSize(paddedWidth, CGFLOAT_MAX) 
                                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading];
        
        if (testRect.size.width <= paddedWidth) {
            minLength = currentLength + 1;
        } else {
            maxLength = currentLength;
        }
        
        currentLength = (minLength + maxLength) / 2;
        [testAttrString release];
    }
    
    // Use the calculated length to create the truncated string
    NSString *truncatedString = [originalString substringToIndex:maxLength];
    if (maxLength < [originalString length]) {
        truncatedString = [truncatedString stringByAppendingString:@"…"];
    }
    
    attrString = [[ NSAttributedString alloc ] initWithString: truncatedString attributes:[self attributesAtIndex:0 effectiveRange:NULL]];
    
    return( [ attrString autorelease ] );
}

@end
