#import "TGStickerCollectionHeader.h"

#import "TGFont.h"

@interface TGStickerCollectionHeader ()
{
    UILabel *_titleLabel;
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
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    _titleLabel.text = [title uppercaseString];
}

- (void)layoutSubviews
{
    _titleLabel.frame = CGRectMake(13.0f, self.frame.size.height - 16.0f, self.bounds.size.width - 13.0f * 2.0f, 16.0f);
}

@end
