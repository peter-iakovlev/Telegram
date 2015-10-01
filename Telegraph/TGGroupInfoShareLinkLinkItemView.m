#import "TGGroupInfoShareLinkLinkItemView.h"

#import "TGFont.h"

@interface TGGroupInfoShareLinkLinkItemView ()
{
    UILabel *_label;
}

@end

@implementation TGGroupInfoShareLinkLinkItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _label = [[UILabel alloc] init];
        _label.numberOfLines = 0;
        _label.font = TGSystemFontOfSize(16.0f);
        _label.textColor = [UIColor blackColor];
        _label.backgroundColor = [UIColor clearColor];
        _label.lineBreakMode = NSLineBreakByCharWrapping;
        [self.contentView addSubview:_label];
    }
    return self;
}

- (void)setText:(NSString *)text
{
    _label.text = text;
    [self setNeedsLayout];
}

+ (UIEdgeInsets)insets
{
    return UIEdgeInsetsMake(14.0f, 16.0f, 14.0f, 16.0f);
}

+ (CGSize)itemSizeForText:(NSString *)text maxWidth:(CGFloat)maxWidth
{
    UIFont *font = TGSystemFontOfSize(16.0f);
    UIEdgeInsets insets = [self insets];
    CGSize textSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(maxWidth - insets.left - insets.right, CGFLOAT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    return CGSizeMake(maxWidth, textSize.height + insets.top + insets.bottom);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIEdgeInsets insets = [TGGroupInfoShareLinkLinkItemView insets];
    _label.frame = CGRectMake(insets.left, insets.top, self.frame.size.width - insets.left - insets.right, self.frame.size.height - insets.top - insets.bottom);
}

@end
