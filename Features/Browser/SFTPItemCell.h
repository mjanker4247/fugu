#import <Cocoa/Cocoa.h>

@interface SFTPItemCell : NSTextFieldCell {
@private
    NSImage	*image;

}
NS_ASSUME_NONNULL_BEGIN

- ( void )italicizeStringValue;
- ( void )setImage:( NSImage * _Nullable )anImage;
- ( NSImage * )image;

- ( void )drawWithFrame: ( NSRect )cellFrame inView: ( NSView * )controlView;
- ( NSSize )cellSize;

NS_ASSUME_NONNULL_END
@end
