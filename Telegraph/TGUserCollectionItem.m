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
        
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGUserCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 44);
}

- (void)bindView:(TGCollectionItemView *)view
{
    [super bindView:view];
    
    ((TGUserCollectionItemView *)view).optionText = TGLocalized(@"BlockedUsers.Unblock");
    ((TGUserCollectionItemView *)view).delegate = self;
    [(TGUserCollectionItemView *)view setTitle:_user.displayName];
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
