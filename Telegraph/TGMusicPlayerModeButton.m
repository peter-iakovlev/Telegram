#import "TGMusicPlayerModeButton.h"
#import <LegacyComponents/LegacyComponents.h>

@implementation TGMusicPlayerModeButton

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    [super setImage:image forState:state];
    
    if (state == UIControlStateNormal)
    {
        UIImage *highlightedImage = TGTintedImage(image, TGAccentColor());
        [super setImage:highlightedImage forState:UIControlStateSelected];
        [super setImage:highlightedImage forState:UIControlStateSelected | UIControlStateHighlighted];
    }
}

//- (void)drawRect:(CGRect)rect
//{
//    if (self.selected)
//    {
//        static UIImage *selectionBackground = nil;
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^
//        {
//            UIGraphicsBeginImageContextWithOptions(CGSizeMake(12, 12), false, 0.0f);
//            CGContextRef context = UIGraphicsGetCurrentContext();
//            CGContextSetFillColorWithColor(context, UIColorRGB(0xd0d0d0).CGColor);
//
//            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 12, 12) cornerRadius:3.0f];
//            [path fill];
//
//            selectionBackground = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(12.0f / 4.0f, 12.0f / 4.0f, 12.0f / 4.0f, 12.0f / 4.0f)];
//            UIGraphicsEndImageContext();
//        });
//
//        [selectionBackground drawInRect:self.bounds];
//    }
//
//    [super drawRect:rect];
//}

@end
