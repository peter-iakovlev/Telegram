#import "TGModernCheckButtonView.h"

#import <LegacyComponents/LegacyComponents.h>
#import <LegacyComponents/TGCheckButtonView.h>

@interface TGModernCheckButtonView ()
{
    TGCheckButtonView *_checkButton;
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGModernCheckButtonView

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
    
    _checkButton = [[TGCheckButtonView alloc] initWithStyle:TGCheckButtonStyleChat];
    _checkButton.frame = CGRectOffset(_checkButton.frame, -1.0f, -1.0f);
    [self addSubview:_checkButton];
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [_checkButton addTarget:target action:action forControlEvents:controlEvents];
}

- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [_checkButton removeTarget:target action:action forControlEvents:controlEvents];
}

- (void)willBecomeRecycled
{
}

- (void)setChecked:(bool)checked animated:(bool)animated
{
    [_checkButton setSelected:checked animated:animated];
}


@end
