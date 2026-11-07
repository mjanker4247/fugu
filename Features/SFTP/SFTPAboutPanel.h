/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Cocoa/Cocoa.h>

@interface SFTPAboutPanel : NSObject
{
    IBOutlet NSButton		*_Nullable emailButton;
    IBOutlet NSTextView 	*_Nullable creditsTextField;
    IBOutlet NSButton 		*_Nullable homepageButton;
    IBOutlet NSImageView 	*_Nullable pufferIconField;
    IBOutlet NSButton 		*_Nullable readMeButton;
}
NS_ASSUME_NONNULL_BEGIN

- ( IBAction )viewReadMe: ( id _Nullable )sender;
- ( IBAction )visitHomePage: ( id _Nullable )sender;
- ( IBAction )emailAuthor: ( id _Nullable )sender;

- ( void )awakeFromNib;

NS_ASSUME_NONNULL_END
@end
