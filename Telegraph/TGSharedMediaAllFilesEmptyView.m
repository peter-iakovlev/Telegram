#import "TGSharedMediaAllFilesEmptyView.h"

#import "TGFont.h"
#import "TGImageUtils.h"

@interface TGSharedMediaAllFilesEmptyView ()
{
    UIImageView *_iconView;
    UILabel *_titleLabel;
    UILabel *_textLabel;
}

@end

@implementation TGSharedMediaAllFilesEmptyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SharedMediaEmptyIcon.png"]];
        [self addSubview:_iconView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = UIColorRGB(0x999999);
        _titleLabel.font = TGMediumSystemFontOfSize(16.0f);
        _titleLabel.text = TGLocalized(@"SharedMedia.EmptyTitle");
        [self addSubview:_titleLabel];
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = UIColorRGB(0x999999);
        _textLabel.font = TGSystemFontOfSize(15.0f + TGRetinaPixel);
        _textLabel.text = TGLocalized(@"SharedMedia.EmptyText");
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
    CGSize titleSize = [_titleLabel sizeThatFits:boundsSize];
    CGSize textSize = [_textLabel sizeThatFits:boundsSize];
    
    _titleLabel.frame = CGRectMake(CGFloor((self.bounds.size.width - titleSize.width) / 2.0f), CGFloor((self.bounds.size.height - titleSize.height) / 2.0f) + (self.bounds.size.width < self.bounds.size.height ? 0.0f : 36.0f), titleSize.width, titleSize.height);
    _iconView.frame = CGRectMake(CGFloor((self.bounds.size.width - iconSize.width) / 2.0f), CGRectGetMinY(_titleLabel.frame) - iconSize.height - 28.0f, iconSize.width, iconSize.height);
    _textLabel.frame = CGRectMake(CGFloor((self.bounds.size.width - textSize.width) / 2.0f), CGRectGetMaxY(_titleLabel.frame) + 11.0f, textSize.width, textSize.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutItems];
}

@end
