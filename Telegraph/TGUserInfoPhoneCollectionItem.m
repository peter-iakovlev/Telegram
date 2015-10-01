/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGUserInfoPhoneCollectionItem.h"

#import "TGUserInfoPhoneCollectionItemView.h"

#import "TGPhoneUtils.h"

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
    self = [super init];
    if (self != nil)
    {
        self.transparent = true;
        self.deselectAutomatically = true;
        
        _label = label;
        _phone = phone;
        _phoneColor = phoneColor;
        _formattedPhone = [TGPhoneUtils formatPhone:phone forceInternational:false];
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

- (void)bindView:(TGUserInfoPhoneCollectionItemView *)view
{
    [super bindView:view];
    
    [view setLabel:_label];
    [view setPhone:_formattedPhone];
    [view setPhoneColor:_phoneColor];
    
    [view setLastInList:_lastInList];
}

- (void)unbindView
{
    [super unbindView];
}

- (bool)itemWantsMenu
{
    return true;
}

- (bool)itemCanPerformAction:(SEL)action
{
    if (action == @selector(copy:))
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
