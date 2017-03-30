/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGUserInfoAddPhoneCollectionItemView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

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
        
        _addIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernMenuAddIcon.png"]];
        CGSize addIconSize = _addIconView.frame.size;
        _addIconView.frame = CGRectMake(12.0f, CGFloor((44.0f - addIconSize.height) / 2.0f) + 1.0f, addIconSize.width, addIconSize.height);
        [self addSubview:_addIconView];
        
        _labelView = [[UILabel alloc] init];
        _labelView.backgroundColor = [UIColor clearColor];
        _labelView.textColor = TGAccentColor();
        _labelView.font = TGSystemFontOfSize(14.0f);
        _labelView.text = TGLocalized(@"UserInfo.AddPhone");
        [_labelView sizeToFit];
        CGSize labelSize = _labelView.frame.size;
        _labelView.frame = CGRectMake(46.0f, 13.0f, labelSize.width, labelSize.height);
        [self addSubview:_labelView];
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
