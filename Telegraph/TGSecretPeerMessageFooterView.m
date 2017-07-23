#import "TGSecretPeerMessageFooterView.h"

#import "TGFont.h"

@interface TGSecretPeerMessageFooterView ()
{
    UILabel *_label;
}
@end

@implementation TGSecretPeerMessageFooterView

- (instancetype)initWithString:(NSString *)string
{
    self = [super init];
    if (self != nil)
    {
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = TGSystemFontOfSize(17.0f);
        _label.textAlignment = NSTextAlignmentCenter;
        _label.text = string;
        _label.textColor = [UIColor whiteColor];
        [_label sizeToFit];
        [self addSubview:_label];
    }
    return self;
}

- (void)setItem:(id<TGModernGalleryItem>)item
{
    NSLog(@"i");
}

- (void)layoutSubviews
{
    _label.frame = CGRectMake(round((self.frame.size.width - _label.frame.size.width) / 2.0f), round((self.frame.size.height - _label.frame.size.height) / 2.0f), _label.frame.size.width, _label.frame.size.height);
}

@end
