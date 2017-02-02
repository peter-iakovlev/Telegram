#import "TGShareCollectionHeader.h"

#import "TGFont.h"

@interface TGShareCollectionHeader ()
{
    UILabel *_headerLabel;
}
@end

@implementation TGShareCollectionHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.backgroundColor = UIColorRGB(0xf7f7f7);
        
        _headerLabel = [[UILabel alloc] init];
        _headerLabel.backgroundColor = self.backgroundColor;
        _headerLabel.opaque = true;
        _headerLabel.textColor = UIColorRGB(0x8e8e93);
        _headerLabel.font = TGBoldSystemFontOfSize(12.0f);
        [self addSubview:_headerLabel];
    }
    return self;
}

- (void)setTitle:(NSString *)string
{
    _headerLabel.text = [string uppercaseString];
    [_headerLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    _headerLabel.frame = CGRectMake(14.0f, 6.0f, _headerLabel.frame.size.width, _headerLabel.frame.size.height);
}

@end
