#import "TGEmbedPIPPlaceholderView.h"
#import "TGFont.h"

@interface TGEmbedPIPPlaceholderView ()
{
    UIImageView *_imageView;
    UILabel *_label;
}
@end

@implementation TGEmbedPIPPlaceholderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.backgroundColor = UIColorRGB(0x333335);
        
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PictureInPictureIndicator"]];
        _imageView.backgroundColor = self.backgroundColor;
        
        [self addSubview:_imageView];
        
        _label = [[UILabel alloc] init];
        _label.backgroundColor = self.backgroundColor;
        _label.font = TGSystemFontOfSize(16.0f);
        _label.text = TGLocalized(@"Embed.PlayingInPIP");
        _label.textColor = UIColorRGB(0x8e8e93);
        [self addSubview:_label];
    }
    return self;
}

- (void)_willReattach
{
    if (self.onWillReattach != nil)
        self.onWillReattach();
}

- (void)setSolidColor
{
    _imageView.hidden = true;
    _label.hidden = true;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:_label.text attributes:@{ NSFontAttributeName: _label.font }];
    CGSize textSize = [string boundingRectWithSize:CGSizeMake(self.frame.size.width - 20.0f * 2.0f, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    CGFloat totalHeight = _imageView.frame.size.height + 10 + textSize.height;
    
    _imageView.frame = CGRectMake(floor((self.frame.size.width - _imageView.frame.size.width) / 2.0f), floor((self.frame.size.height - totalHeight) / 2.0f), _imageView.frame.size.width, _imageView.frame.size.height);
    
    _label.frame = CGRectMake(floor((self.frame.size.width - textSize.width) / 2.0f), CGRectGetMaxY(_imageView.frame) + 10.0f, ceil(textSize.width), ceil(textSize.height));
}

@end
