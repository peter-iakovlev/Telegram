#import "TGUserInfoTextCollectionItemView.h"

#import "TGFont.h"
#import "TGImageUtils.h"

@interface TGUserInfoTextCollectionItemView ()
{
    UIView *_separatorView;
    
    UILabel *_labelView;
    UILabel *_textLabel;
}

@end

@implementation TGUserInfoTextCollectionItemView

+ (UIFont *)font
{
    return TGSystemFontOfSize(17.0f);
}

+ (CGFloat)heightForWidth:(CGFloat)width text:(NSString *)text
{
    CGFloat leftPadding = 35.0f + TGRetinaPixel;
    CGSize textSize = [text sizeWithFont:[self font] constrainedToSize:CGSizeMake(width - leftPadding - 10.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    textSize.width = CGCeil(textSize.width);
    textSize.height = CGCeil(textSize.height);
    
    return textSize.height + 44.0f;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.selectionInsets = UIEdgeInsetsMake(TGIsRetina() ? 0.5f : 1.0f, 0.0f, 0.0f, 0.0f);
        
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = TGSeparatorColor();
        [self.backgroundView addSubview:_separatorView];
        
        _labelView = [[UILabel alloc] init];
        _labelView.backgroundColor = [UIColor clearColor];
        _labelView.textColor = TGAccentColor();
        _labelView.font = TGSystemFontOfSize(14.0f);
        [self addSubview:_labelView];
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.font = [TGUserInfoTextCollectionItemView font];
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _textLabel.userInteractionEnabled = false;
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _labelView.text = title;
    [self setNeedsLayout];
}

- (void)setText:(NSString *)text
{
    _textLabel.text = text;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGFloat separatorHeight = TGIsRetina() ? 0.5f : 1.0f;
    _separatorView.frame = CGRectMake(35.0f, bounds.size.height - separatorHeight, bounds.size.width - 35.0f, separatorHeight);
    
    CGFloat leftPadding = 35.0f + TGRetinaPixel;
    
    CGSize labelSize = [_labelView.text sizeWithFont:_labelView.font constrainedToSize:CGSizeMake(bounds.size.width - leftPadding - 10.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    labelSize.width = CGCeil(labelSize.width);
    labelSize.height = CGCeil(labelSize.height);
    _labelView.frame = CGRectMake(leftPadding, 11.0f, labelSize.width, labelSize.height);
    
    CGSize textSize = [_textLabel.text sizeWithFont:_textLabel.font constrainedToSize:CGSizeMake(bounds.size.width - leftPadding - 10.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    textSize.width = CGCeil(textSize.width);
    textSize.height = CGCeil(textSize.height);
    _textLabel.frame = CGRectMake(leftPadding, 30.0f, textSize.width, textSize.height);
}

@end
