#import "TGSharedMediaCheckButton.h"
#import <LegacyComponents/TGCheckButtonView.h>

@interface TGSharedMediaCheckButton ()
{
    TGCheckButtonView *_checkButton;
}

@end

@implementation TGSharedMediaCheckButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit
{
    self.exclusiveTouch = true;
    
    _checkButton = [[TGCheckButtonView alloc] initWithStyle:TGCheckButtonStyleDefault];
    _checkButton.frame = CGRectOffset(_checkButton.frame, -4.0f, -4.0f);
    [self addSubview:_checkButton];
}

- (void)setChecked:(bool)checked animated:(bool)animated
{
    [_checkButton setSelected:checked animated:animated];
}

@end
