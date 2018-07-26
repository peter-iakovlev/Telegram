#import "TGUserInfoPhoneCollectionItem.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGUserInfoPhoneCollectionItemView.h"

@interface TGUserInfoPhoneCollectionItem ()
{
    NSString *_label;
    NSString *_formattedPhone;
    SEL _action;
}

@end

@implementation TGUserInfoPhoneCollectionItem

- (instancetype)initWithLabel:(NSString *)label phone:(NSString *)phone phoneColor:(UIColor *)phoneColor action:(SEL)action
{
    return [self initWithLabel:label phone:phone formattedPhone:[TGPhoneUtils formatPhone:phone forceInternational:false] phoneColor:phoneColor action:action];
}

- (instancetype)initWithLabel:(NSString *)label phone:(NSString *)phone formattedPhone:(NSString *)formattedPhone phoneColor:(UIColor *)phoneColor action:(SEL)action
{
    self = [super init];
    if (self != nil)
    {
        self.transparent = true;
        self.deselectAutomatically = true;
        
        _label = label;
        _phone = phone;
        _phoneColor = phoneColor;
        _formattedPhone = formattedPhone;
        _action = action;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGUserInfoPhoneCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 60.0f);
}

- (void)itemSelected:(id)actionTarget
{
    if (self.checking)
    {
        self.isChecked = !self.isChecked;
        
        if (self.isCheckedChanged != nil)
            self.isCheckedChanged(self.isChecked);
        return;
    }
    
    if (_action != NULL && [actionTarget respondsToSelector:_action])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([NSStringFromSelector(_action) rangeOfString:@":"].location != NSNotFound)
            [actionTarget performSelector:_action withObject:self];
        else
            [actionTarget performSelector:_action];
#pragma clang diagnostic pop
    }
}

- (void)setChecking:(bool)checking {
    _checking = checking;
    self.highlightDisabled = checking;
}

- (void)setIsChecked:(bool)isChecked
{
    _isChecked = isChecked;
    
    if ([self boundView] != nil)
        [(TGUserInfoPhoneCollectionItemView *)[self boundView] setIsChecked:_isChecked animated:true];
}

- (void)bindView:(TGUserInfoPhoneCollectionItemView *)view
{
    [super bindView:view];
    
    [view setLabel:_label];
    [view setPhone:_formattedPhone];
    [view setPhoneColor:_phoneColor];
    [view setChecking:_checking];
    [view setIsChecked:_isChecked animated:false];
    
    [view setLastInList:_lastInList];
}

- (void)unbindView
{
    [super unbindView];
}

- (bool)itemWantsMenu
{
    return !_checking;
}

- (bool)itemCanPerformAction:(SEL)action
{
    if (!_checking && action == @selector(copy:))
        return true;
    
    return false;
}

- (void)itemPerformAction:(SEL)action
{
    if (action == @selector(copy:))
    {
        if (_phone.length != 0)
            [[UIPasteboard generalPasteboard] setString:_phone];
    }
}

@end
