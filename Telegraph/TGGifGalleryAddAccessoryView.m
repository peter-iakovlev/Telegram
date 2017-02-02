#import "TGGifGalleryAddAccessoryView.h"

#import "TGModernGalleryItem.h"

#import "TGModernButton.h"

@interface TGGifGalleryAddAccessoryView ()
{
    TGModernButton *_button;
    id<TGModernGalleryItem> _item;
}
@end

@implementation TGGifGalleryAddAccessoryView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        UIImage *actionImage = [UIImage imageNamed:@"AddWhiteIcon.png"];
        _button = [[TGModernButton alloc] init];
        _button.modernHighlight = true;
        _button.exclusiveTouch = true;
        [_button setImage:actionImage forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _button.frame = (CGRect){CGPointZero, frame.size};
}

- (void)setItem:(id<TGModernGalleryItem>)item
{
    _item = item;
}

- (void)buttonPressed
{
    if (_item != nil && _action)
        _action(_item, self);
}

@end
