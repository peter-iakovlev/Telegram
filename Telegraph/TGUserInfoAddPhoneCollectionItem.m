/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGUserInfoAddPhoneCollectionItem.h"

#import "TGUserInfoAddPhoneCollectionItemView.h"

@interface TGUserInfoAddPhoneCollectionItem ()
{
    SEL _action;
}

@end

@implementation TGUserInfoAddPhoneCollectionItem

- (instancetype)initWithAction:(SEL)action
{
    self = [super init];
    if (self != nil)
    {
        _action = action;
        
        self.transparent = true;
        self.deselectAutomatically = true;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGUserInfoAddPhoneCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 44.0f);
}

- (void)itemSelected:(id)actionTarget
{
    if (_action != NULL && [actionTarget respondsToSelector:_action])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [actionTarget performSelector:_action];
#pragma clang diagnostic pop
    }
}

@end
