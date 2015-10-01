#import "TGSharedMediaLinksEmptyView.h"

#import "TGFont.h"
#import "TGImageUtils.h"

@interface TGSharedMediaLinksEmptyView ()
{
    UIImageView *_iconView;
    UILabel *_textLabel;
}

@end

@implementation TGSharedMediaLinksEmptyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SharedMediaEmptyLinks.png"]];
        [self addSubview:_iconView];
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = UIColorRGB(0x999999);
        _textLabel.font = TGSystemFontOfSize(16.0f);
        _textLabel.text = TGLocalized(@"SharedMedia.EmptyLinksText");
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)layoutItems
{
    CGSize boundsSize = CGSizeMake(self.bounds.size.width - 20.0f, CGFLOAT_MAX);
    
    CGSize iconSize = _iconView.image.size;
    CGSize textSize = [_textLabel sizeThatFits:boundsSize];
    
    CGFloat anchor = 3.0f + (self.bounds.size.width < self.bounds.size.height ? 0.0f : 50.0f);
    _iconView.frame = CGRectMake(CGFloor((self.bounds.size.width - iconSize.width) / 2.0f), CGFloor(self.bounds.size.height / 2.0f) + 3.0f + anchor + TGRetinaPixel - iconSize.height - 28.0f, iconSize.width, iconSize.height);
    _textLabel.frame = CGRectMake(CGFloor((self.bounds.size.width - textSize.width) / 2.0f), CGFloor(self.bounds.size.height / 2.0f) - 2.0f + anchor, textSize.width, textSize.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutItems];
}

@end
