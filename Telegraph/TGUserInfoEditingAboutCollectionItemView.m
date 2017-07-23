#import "TGUserInfoEditingAboutCollectionItemView.h"

#import "TGImageUtils.h"

@interface TGUserInfoEditingAboutCollectionItemView ()
{
    CALayer *_separatorLayer;
}
@end

@implementation TGUserInfoEditingAboutCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _separatorLayer = [[CALayer alloc] init];
        _separatorLayer.backgroundColor = TGSeparatorColor().CGColor;
        [self.backgroundView.layer addSublayer:_separatorLayer];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGFloat separatorHeight = TGScreenPixel;
    _separatorLayer.frame = CGRectMake(15.0f, bounds.size.height - separatorHeight, bounds.size.width - 15.0f, separatorHeight);
}

@end
