#import "TGStickerCollectionHeader.h"

#import <LegacyComponents/LegacyComponents.h>

@interface TGStickerCollectionHeader ()
{
    UILabel *_titleLabel;
    TGModernButton *_button;
}
@end

@implementation TGStickerCollectionHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = UIColorRGB(0x949599);
        _titleLabel.font = TGBoldSystemFontOfSize(12.0f);
        [self addSubview:_titleLabel];
        
        _button = [[TGModernButton alloc] init];
        _button.adjustsImageWhenHighlighted = false;
        [_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        _button.userInteractionEnabled = false;
        [self addSubview:_button];
    }
    return self;
}

- (void)buttonPressed
{
    if (self.accessoryPressed)
        self.accessoryPressed();
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    _titleLabel.text = [title uppercaseString];
}

- (UIImage *)icon
{
    return [_button imageForState:UIControlStateNormal];
}

- (void)setIcon:(UIImage *)icon
{
    _button.userInteractionEnabled = icon != nil;
    [_button setImage:icon forState:UIControlStateNormal];
}

- (void)layoutSubviews
{
    _titleLabel.frame = CGRectMake(13.0f, self.frame.size.height - 16.0f, self.bounds.size.width - 13.0 - self.frame.size.height - 10.0f, 16.0f);
    _button.frame = CGRectMake(self.frame.size.width - self.frame.size.height - 9.0f, 3.0f + TGScreenPixel, self.frame.size.height, self.frame.size.height);
}

@end
