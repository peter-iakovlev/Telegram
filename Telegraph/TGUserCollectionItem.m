/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGUserCollectionItem.h"

#import "ASHandle.h"
#import "TGUser.h"

#import "TGUserCollectionItemView.h"

@interface TGUserCollectionItem () <TGUserCollectionItemViewDelegate>

@end

@implementation TGUserCollectionItem

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _deleteActionTitle = TGLocalized(@"BlockedUsers.Unblock");
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGUserCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, _showAvatar ? 58 : 44);
}

- (void)bindView:(TGCollectionItemView *)view
{
    [super bindView:view];
    
    ((TGUserCollectionItemView *)view).optionText = _deleteActionTitle;
    ((TGUserCollectionItemView *)view).delegate = self;
    [(TGUserCollectionItemView *)view setShowAvatar:_showAvatar];
    [(TGUserCollectionItemView *)view setFirstName:_user.firstName lastName:_user.lastName uidForPlaceholderCalculation:_user.uid avatarUri:_user.photoUrlSmall];
}

- (void)unbindView
{
    ((TGUserCollectionItemView *)[self boundView]).delegate = nil;
    
    [super unbindView];
}

- (void)itemSelected:(id)__unused actionTarget
{
    [_interfaceHandle requestAction:@"userItemSelected" options:@{@"uid": @(_user.uid)}];
}

- (void)userCollectionItemViewRequestedDeleteAction:(TGUserCollectionItemView *)userCollectionItemView
{
    if (userCollectionItemView == [self boundView] && _user != nil)
        [_interfaceHandle requestAction:@"userItemDeleteRequested" options:@{@"uid": @(_user.uid)}];
}

@end
