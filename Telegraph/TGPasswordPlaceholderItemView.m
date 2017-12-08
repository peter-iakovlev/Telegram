#import "TGPasswordPlaceholderItemView.h"

#import <LegacyComponents/LegacyComponents.h>

@interface TGPasswordPlaceholderItemView ()
{
    UIImageView *_iconView;
    UILabel *_titleLabel;
    UILabel *_textLabel;
}

@end

@implementation TGPasswordPlaceholderItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.clipsToBounds = [TGViewController isWidescreen];
        
        _iconView = [[UIImageView alloc] init];
        [self addSubview:_iconView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = UIColorRGB(0x6d6d72);
        _titleLabel.font = TGBoldSystemFontOfSize(17.0f);
        [self addSubview:_titleLabel];
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.textAlignment = NSTextAlignmentLeft;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = UIColorRGB(0x6d6d72);
        _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _textLabel.numberOfLines = 0;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = TGSystemFontOfSize(14.0f);
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)setIcon:(UIImage *)icon title:(NSString *)title text:(NSString *)text
{
    _iconView.image = icon;
    [_iconView sizeToFit];
    _iconView.contentMode = UIViewContentModeScaleAspectFit;
    
    if (![TGViewController isWidescreen])
        _iconView.frame = CGRectMake(0.0f, 0.0f, _iconView.frame.size.width * 0.8f, _iconView.frame.size.height * 0.8f);
    
    _titleLabel.text = title;
    
    _textLabel.attributedText = [text attributedFormattedStringWithRegularFont:TGSystemFontOfSize(14.0f) boldFont:TGBoldSystemFontOfSize(14.0f) lineSpacing:2.0f paragraphSpacing:0.0f alignment:NSTextAlignmentCenter];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
    titleSize.width = CGCeil(titleSize.width);
    titleSize.height = CGCeil(titleSize.height);
    
    CGFloat inset = ![TGViewController hasLargeScreen] ? 30.0f : 60.0f;
    CGSize textSize = [_textLabel.attributedText boundingRectWithSize:CGSizeMake(self.frame.size.width - inset, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:NULL].size;
    textSize.width = CGCeil(textSize.width);
    textSize.height = CGCeil(textSize.height);
    
    CGFloat offset = [TGViewController isWidescreen] ? 30.0f : 38.0f;
    if ([TGViewController hasTallScreen])
        offset = 6.0f;
    CGFloat iconTitleSpacing = [TGViewController isWidescreen] ? -12.0f : -26.0f;
    CGFloat titleTextSpacing = [TGViewController isWidescreen] ? 8.0f : 6.0f;
    
    CGFloat contentHeight = _iconView.frame.size.height + iconTitleSpacing + titleSize.height + titleTextSpacing + textSize.height;
    CGFloat contentOrigin = CGFloor((self.frame.size.height - contentHeight) / 2.0f) - offset;
    _iconView.frame = CGRectMake(CGFloor((self.frame.size.width - _iconView.frame.size.width) / 2.0f), contentOrigin, _iconView.frame.size.width, _iconView.frame.size.height);
    
    _titleLabel.frame = CGRectMake(CGFloor((self.frame.size.width - titleSize.width) / 2.0f), contentOrigin + _iconView.frame.size.height + iconTitleSpacing, titleSize.width, titleSize.height);
    
    _textLabel.frame = CGRectMake(CGFloor((self.frame.size.width - textSize.width) / 2.0f), contentOrigin + _iconView.frame.size.height + iconTitleSpacing + titleSize.height + titleTextSpacing, textSize.width, textSize.height);
    
    CGFloat alpha = self.frame.size.height < 1.0f ? 0.0f : 1.0f;
    _iconView.alpha = alpha;
    _titleLabel.alpha = alpha;
    _textLabel.alpha = alpha;
}

@end
