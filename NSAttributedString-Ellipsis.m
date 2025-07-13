/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import "NSAttributedString-Ellipsis.h"

@implementation NSAttributedString(Ellipsis)

- (NSAttributedString *)ellipsisAbbreviatedStringForWidth:(double)width
{
    // If the string already fits within the width, return self
    NSSize boundingSize = [self boundingRectWithSize:NSMakeSize(width, CGFLOAT_MAX) 
                                            options:NSStringDrawingUsesLineFragmentOrigin 
                                            context:nil].size;
    
    if (boundingSize.width <= width) {
        return self;
    }
    
    // Calculate available width with some padding
    double paddedWidth = width - 24.0;
    if (paddedWidth <= 0) {
        return self;
    }
    
    NSString *originalString = [self string];
    NSMutableAttributedString *result = [self mutableCopy];
    
    // Try to find a good truncation point
    NSInteger start = 0;
    NSInteger end = [originalString length];
    NSInteger bestLength = 0;
    
    // Binary search for the best truncation point
    while (start <= end) {
        NSInteger mid = (start + end) / 2;
        
        // Create a truncated string with ellipsis in the middle
        NSString *truncatedString = nil;
        if (mid > 0) {
            NSInteger firstPartLength = mid / 2;
            NSInteger secondPartLength = mid - firstPartLength;
            
            if (firstPartLength > 0 && secondPartLength > 0) {
                NSString *firstPart = [originalString substringToIndex:firstPartLength];
                NSString *lastPart = [originalString substringFromIndex:[originalString length] - secondPartLength];
                truncatedString = [NSString stringWithFormat:@"%@...%@", firstPart, lastPart];
            } else {
                truncatedString = [originalString substringToIndex:mid];
            }
        } else {
            truncatedString = @"...";
        }
        
        // Create attributed string with same attributes as original
        NSMutableAttributedString *testString = [[NSMutableAttributedString alloc] initWithString:truncatedString];
        
        // Copy attributes from the original string
        [self enumerateAttributesInRange:NSMakeRange(0, MIN([self length], [testString length])) 
                                options:0 
                             usingBlock:^(NSDictionary<NSAttributedStringKey,id> *attrs, NSRange range, BOOL *stop) {
            [testString addAttributes:attrs range:range];
        }];
        
        // Check if it fits
        NSSize testSize = [testString boundingRectWithSize:NSMakeSize(paddedWidth, CGFLOAT_MAX) 
                                                   options:NSStringDrawingUsesLineFragmentOrigin 
                                                   context:nil].size;
        
        if (testSize.width <= paddedWidth) {
            bestLength = mid;
            start = mid + 1;
        } else {
            end = mid - 1;
        }
    }
    
    // Create the final truncated string
    NSString *finalString = nil;
    if (bestLength > 0) {
        NSInteger firstPartLength = bestLength / 2;
        NSInteger secondPartLength = bestLength - firstPartLength;
        
        if (firstPartLength > 0 && secondPartLength > 0) {
            NSString *firstPart = [originalString substringToIndex:firstPartLength];
            NSString *lastPart = [originalString substringFromIndex:[originalString length] - secondPartLength];
            finalString = [NSString stringWithFormat:@"%@...%@", firstPart, lastPart];
        } else {
            finalString = [originalString substringToIndex:bestLength];
        }
    } else {
        finalString = @"...";
    }
    
    // Create the result with preserved attributes
    NSMutableAttributedString *finalResult = [[NSMutableAttributedString alloc] initWithString:finalString];
    
    // Copy attributes from the original string
    [self enumerateAttributesInRange:NSMakeRange(0, MIN([self length], [finalResult length])) 
                            options:0 
                         usingBlock:^(NSDictionary<NSAttributedStringKey,id> *attrs, NSRange range, BOOL *stop) {
        [finalResult addAttributes:attrs range:range];
    }];
    
    return finalResult;
}

@end
