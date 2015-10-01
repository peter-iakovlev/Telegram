#import "TGPhotoEditorButton.h"

#import "UIControl+HitTestEdgeInsets.h"

#import "TGModernButton.h"
#import "TGPhotoEditorInterfaceAssets.h"

@interface TGPhotoEditorButton ()
{
    TGModernButton *_button;
    UIImageView *_selectionView;
    
    UIImage *_activeIconImage;
}
@end

@implementation TGPhotoEditorButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        static UIImage *selectionBackground = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(frame.size.width, frame.size.height), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [TGPhotoEditorInterfaceAssets editorButtonSelectionBackgroundColor].CGColor);
            
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, frame.size.width, frame.size.height)
                                                            cornerRadius:2];
            
            [path fill];
            
            selectionBackground = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(frame.size.height / 4.0f, frame.size.height / 4.0f, frame.size.height / 4.0f, frame.size.height / 4.0f)];
            UIGraphicsEndImageContext();
        });

        self.hitTestEdgeInsets = UIEdgeInsetsMake(-16, -16, -16, -16);
        
        _selectionView = [[UIImageView alloc] initWithFrame:self.bounds];
        _selectionView.hidden = YES;
        _selectionView.image = selectionBackground;
        [self addSubview:_selectionView];
        
        _button = [[TGModernButton alloc] initWithFrame:self.bounds];
        _button.hitTestEdgeInsets = self.hitTestEdgeInsets;
        _button.exclusiveTouch = YES;
        [_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];        
        [self addSubview:_button];
    }
    return self;
}

- (void)buttonPressed
{
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)setIconImage:(UIImage *)image
{
    _iconImage = image;
    _activeIconImage = nil;
    [self setActive:_active];
    
    UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    CGContextSetBlendMode (context, kCGBlendModeSourceAtop);
    CGContextSetFillColorWithColor(context, [TGPhotoEditorInterfaceAssets toolbarSelectedIconColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height));
    
    UIImage *selectedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [_button setImage:selectedImage forState:UIControlStateSelected];
    [_button setImage:selectedImage forState:UIControlStateSelected | UIControlStateHighlighted];
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
        CGContextSetFillColorWithColor(context, [TGPhotoEditorInterfaceAssets toolbarAppliedIconColor].CGColor);
        CGContextFillRect(context, CGRectMake(0, 0, _iconImage.size.width, _iconImage.size.height));
        
        _activeIconImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    return _activeIconImage;
}

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected];
    if (self.dontHighlightOnSelection)
        return;
    
    _button.selected = self.selected;
    _button.modernHighlight = !self.selected;
    
    if (animated)
    {
        if (selected) {
            _selectionView.hidden = false;
            _selectionView.alpha = 0.0f;
            [UIView animateWithDuration:0.15f
                             animations:^
            {
                _selectionView.alpha = 1.0f;
            } completion:nil];
        }
        else
        {
            _selectionView.hidden = true;
        }
    }
    else
    {
        _selectionView.hidden = !self.selected;
    }
}

@end
