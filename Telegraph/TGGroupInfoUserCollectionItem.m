/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGGroupInfoUserCollectionItem.h"

#import "TGGroupInfoUserCollectionItemView.h"

#import "TGDateUtils.h"
#import "TGUser.h"

#import "ASHandle.h"

@interface TGGroupInfoUserCollectionItem () <TGGroupInfoUserCollectionItemViewDelegate>
{
    bool _canEdit;
    bool _disabled;
}

@end

@implementation TGGroupInfoUserCollectionItem

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _canEdit = true;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGGroupInfoUserCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 48);
}

- (void)bindView:(TGGroupInfoUserCollectionItemView *)view
{
    [super bindView:view];
    
    view.delegate = self;
    
    [view setFirstName:_user.firstName lastName:_user.lastName uidForPlaceholderCalculation:_user.uid];
    bool active = false;
    NSString *status = [self _statusStringFromUserPresence:_user.presence active:&active];
    [view setStatus:status active:active];
    [view setAvatarUri:_user.photoUrlSmall];
    [view setEnableEditing:_canEdit animated:false];
    [(TGGroupInfoUserCollectionItemView *)[self boundView] setDisabled:_disabled animated:false];
}

- (void)unbindView
{
    ((TGGroupInfoUserCollectionItemView *)[self boundView]).delegate = nil;
    
    [super unbindView];
}

- (NSString *)_statusStringFromUserPresence:(TGUserPresence)presence active:(out bool *)active
{
    if (presence.online)
    {
        if (active != NULL)
            *active = true;
        return TGLocalizedStatic(@"Presence.online");
    }
    else if (presence.lastSeen < 0)
        return TGLocalizedStatic(@"Presence.invisible");
    else if (presence.lastSeen != 0)
        return [TGDateUtils stringForRelativeLastSeen:presence.lastSeen];
    
    return TGLocalized(@"Presence.offline");
}

- (void)setUser:(TGUser *)user
{
    _user = user;
    
    if ([self boundView] != nil)
    {
        TGGroupInfoUserCollectionItemView *view = (TGGroupInfoUserCollectionItemView *)[self boundView];
        [view setFirstName:user.firstName lastName:user.lastName uidForPlaceholderCalculation:_user.uid];
        bool active = false;
        NSString *status = [self _statusStringFromUserPresence:_user.presence active:&active];
        [view setStatus:status active:active];
        [view setAvatarUri:_user.photoUrlSmall];
    }
}

- (void)setCanEdit:(bool)canEdit
{
    [self setCanEdit:canEdit animated:false];
}

- (void)setCanEdit:(bool)canEdit animated:(bool)animated
{
    if (_canEdit != canEdit)
    {
        _canEdit = canEdit;
        [(TGGroupInfoUserCollectionItemView *)[self boundView] setEnableEditing:_canEdit animated:animated];
    }
}

- (void)setDisabled:(bool)disabled
{
    if (_disabled != disabled)
    {
        _disabled = disabled;
        [(TGGroupInfoUserCollectionItemView *)[self boundView] setDisabled:_disabled animated:true];
    }
}

- (void)updateTimestamp
{
    bool active = false;
    NSString *status = [self _statusStringFromUserPresence:_user.presence active:&active];
    [(TGGroupInfoUserCollectionItemView *)[self boundView] setStatus:status active:active];
}

- (void)itemSelected:(id)__unused actionTarget
{
    [_interfaceHandle requestAction:@"openUser" options:@{@"uid": @(_user.uid)}];
}

- (void)groupInfoUserItemViewRequestedDeleteAction:(TGGroupInfoUserCollectionItemView *)groupInfoUserItemView
{
    if (groupInfoUserItemView == [self boundView] && _user.uid != 0)
        [_interfaceHandle requestAction:@"deleteUser" options:@{@"uid": @(_user.uid)}];
}

@end
