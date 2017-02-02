#import "TGShareToolbarButton.h"
#import "TGShareButton.h"

#import <LegacyDatabase/LegacyDatabase.h>

#import "UIControl+HitTestEdgeInsets.h"

@interface TGShareToolbarButton ()
{
    TGShareButton *_button;
    
    UIImage *_activeIconImage;
}
@end

@implementation TGShareToolbarButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.hitTestEdgeInsets = UIEdgeInsetsMake(-16, -16, -16, -16);
        
        _button = [[TGShareButton alloc] initWithFrame:self.bounds];
        _button.hitTestEdgeInsets = self.hitTestEdgeInsets;
        _button.tintColor = TGColorWithHex(0x007ee5);
        [_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
    }
    return self;
}

- (void)setIconImage:(UIImage *)image
{
    _iconImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _activeIconImage = nil;
    [self setActive:_active];
    
//    UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0f);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
//    CGContextSetBlendMode (context, kCGBlendModeSourceAtop);
//    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
//    CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height));
//    
//    UIImage *selectedImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    [_button setImage:selectedImage forState:UIControlStateSelected];
//    [_button setImage:selectedImage forState:UIControlStateSelected | UIControlStateHighlighted];
}

- (void)setActive:(bool)active
{
    [_button setImage:(active ? [self _activeIconImage] : _iconImage) forState:UIControlStateNormal];
}

- (UIImage *)_activeIconImage
{
    if (_activeIconImage == nil)
    {
        UIGraphicsBeginImageContextWithOptions(_iconImage.size, false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [_iconImage drawInRect:CGRectMake(0, 0, _iconImage.size.width, _iconImage.size.height)];
        CGContextSetBlendMode (context, kCGBlendModeSourceAtop);
        CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
        CGContextFillRect(context, CGRectMake(0, 0, _iconImage.size.width, _iconImage.size.height));
        
        _activeIconImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return _activeIconImage;
}

- (void)buttonPressed
{
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

@end
