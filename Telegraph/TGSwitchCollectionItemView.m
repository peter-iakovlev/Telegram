/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGSwitchCollectionItemView.h"

#import "TGFont.h"

#import "TGIconSwitchView.h"

@interface TGSwitchCollectionItemView ()
{
    UILabel *_titleLabel;
    UISwitch *_switchView;
}

@end

@implementation TGSwitchCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {   
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TGSystemFontOfSize(17);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabel];
        
        if ([self isKindOfClass:[TGPermissionSwitchCollectionItemView class]] && iosMajorVersion() >= 8) {
            _switchView = [[TGIconSwitchView alloc] init];
            _switchView.layer.allowsGroupOpacity = true;
        } else {
            _switchView = [[UISwitch alloc] init];
        }
        [_switchView addTarget:self action:@selector(switchValueChanged) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:_switchView];
    }
    return self;
}

- (void)setFullSeparator:(bool)fullSeparator {
    self.separatorInset = fullSeparator ? 0.0f : 15.0f;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

- (void)setIsOn:(bool)isOn animated:(bool)animated
{
    [_switchView setOn:isOn animated:animated];
}

- (void)setIsEnabled:(bool)isEnabled {
    _titleLabel.alpha = isEnabled ? 1.0f : 0.5f;
    _switchView.userInteractionEnabled = isEnabled;
    _switchView.alpha = isEnabled ? 1.0f : 0.5f;
}

- (void)switchValueChanged
{
    id<TGSwitchCollectionItemViewDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(switchCollectionItemViewChangedValue:isOn:)])
        [delegate switchCollectionItemViewChangedValue:self isOn:_switchView.on];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGSize switchSize = _switchView.bounds.size;
    _switchView.frame = CGRectMake(bounds.size.width - switchSize.width - 15.0f, 6.0f, switchSize.width, switchSize.height);
    
    _titleLabel.frame = CGRectMake(15.0f, CGFloor((bounds.size.height - 26.0f) / 2.0f), bounds.size.width - 15.0f - 4.0f - switchSize.width - 6.0f, 26.0f);
}

@end

@implementation TGPermissionSwitchCollectionItemView

@end
