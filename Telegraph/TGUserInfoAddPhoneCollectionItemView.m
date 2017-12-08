#import "TGUserInfoAddPhoneCollectionItemView.h"

#import <LegacyComponents/LegacyComponents.h>

@interface TGUserInfoAddPhoneCollectionItemView ()
{
    CALayer *_separatorLayer;
    UILabel *_labelView;
    UIImageView *_addIconView;
}

@end

@implementation TGUserInfoAddPhoneCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _separatorLayer = [[CALayer alloc] init];
        _separatorLayer.backgroundColor = TGSeparatorColor().CGColor;
        [self.backgroundView.layer addSublayer:_separatorLayer];
        
        CGFloat separatorHeight = TGScreenPixel;
        self.selectionInsets = UIEdgeInsetsMake(separatorHeight, 0.0f, 0.0f, 0.0f);
        
        _addIconView = [[UIImageView alloc] initWithImage:TGImageNamed(@"ModernMenuAddIcon.png")];
        [self addSubview:_addIconView];
        
        _labelView = [[UILabel alloc] init];
        _labelView.backgroundColor = [UIColor clearColor];
        _labelView.textColor = TGAccentColor();
        _labelView.font = TGSystemFontOfSize(14.0f);
        _labelView.text = TGLocalized(@"UserInfo.AddPhone");
        [_labelView sizeToFit];
        [self addSubview:_labelView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGFloat separatorHeight = TGScreenPixel;
    CGFloat separatorInset = 15.0f + self.safeAreaInset.left;
    _separatorLayer.frame = CGRectMake(separatorInset, bounds.size.height - separatorHeight, bounds.size.width - separatorInset, separatorHeight);
    
    CGSize addIconSize = _addIconView.frame.size;
    _addIconView.frame = CGRectMake(12.0f + self.safeAreaInset.left, CGFloor((44.0f - addIconSize.height) / 2.0f) + 1.0f, addIconSize.width, addIconSize.height);
    
    CGSize labelSize = _labelView.frame.size;
    _labelView.frame = CGRectMake(46.0f + self.safeAreaInset.left, 13.0f, labelSize.width, labelSize.height);
}

@end
