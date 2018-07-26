#import "TGAppearanceColorCollectionItemView.h"

#import <LegacyComponents/TGImageUtils.h>

@interface TGAppearanceColorCollectionItemView ()
{
    UIView *_colorView;
}
@end

@implementation TGAppearanceColorCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _colorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 17.0f, 17.0f)];
        _colorView.clipsToBounds = true;
        _colorView.layer.cornerRadius = _colorView.frame.size.width / 2.0f;
        [self addSubview:_colorView];
    }
    return self;
}

- (void)setColor:(UIColor *)color
{
    _colorView.backgroundColor = color;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _colorView.frame = CGRectMake(self.frame.size.width - self.safeAreaInset.right - _colorView.frame.size.width - 32.0f, TGScreenPixelFloor((self.frame.size.height - _colorView.frame.size.height) / 2.0f), _colorView.frame.size.width, _colorView.frame.size.height);
}

@end
