#import "TGStickerGroupPackCell.h"

#import <LegacyComponents/TGFont.h>
#import <LegacyComponents/TGModernButton.h>

@interface TGStickerGroupPackCell ()
{
    UILabel *_label;
    TGModernButton *_button;
}
@end

@implementation TGStickerGroupPackCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _label = [[UILabel alloc] init];
        _label.font = TGSystemFontOfSize(14.0f);
        _label.text = TGLocalized(@"Stickers.GroupStickersHelp");
        _label.numberOfLines = 0;
        _label.textColor = UIColorRGB(0x8d8e93);
        [self addSubview:_label];
        
        static UIImage *buttonImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            {
                CGSize size = CGSizeMake(12.0f, 12.0f);
                UIGraphicsBeginImageContextWithOptions(size, false, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetStrokeColorWithColor(context, TGAccentColor().CGColor);
                CGContextSetLineWidth(context, 1.0f);
                CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, size.width - 1.0f, size.height - 1.0f));
                buttonImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)(size.width / 2.0f) topCapHeight:(NSInteger)(size.height / 2.0f)];
                UIGraphicsEndImageContext();
            }
        });
        
        _button = [[TGModernButton alloc] init];
        _button.adjustsImageWhenHighlighted = false;
        [_button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        _button.modernHighlight = true;
        [_button setTitle:TGLocalized(@"Stickers.GroupChooseStickerPack") forState:UIControlStateNormal];
        [_button setTitleColor:TGAccentColor()];
        _button.titleLabel.font = TGMediumSystemFontOfSize(13.0f);
        _button.contentEdgeInsets = UIEdgeInsetsMake(5.0f, 10.0f, 5.0f, 10.0f);
        [_button sizeToFit];
        [self.contentView addSubview:_button];
        
        [_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)buttonPressed
{
    if (self.pressed)
        self.pressed();
}

- (void)layoutSubviews
{
    _label.frame = CGRectMake(13.0f, 0.0f, self.frame.size.width - 13.0f * 2.0f, self.frame.size.height - 33.0f - 14.0f);
    _button.frame = CGRectMake(13.0f, self.frame.size.height - _button.frame.size.height - 13.0f, _button.frame.size.width, 33.0f);
}

@end
