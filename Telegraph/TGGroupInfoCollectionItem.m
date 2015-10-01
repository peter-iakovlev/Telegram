/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGGroupInfoCollectionItem.h"

#import "TGGroupInfoCollectionItemView.h"

#import "TGConversation.h"
#import "ASHandle.h"

#import "TGRemoteImageView.h"

@interface TGGroupInfoCollectionItem () <TGGroupInfoCollectionItemViewDelegate>
{
    TGConversation *_conversation;
    NSString *_editingTitle;
    
    NSString *_updatingTitle;
    UIImage *_updatingAvatar;
    bool _hasUpdatingAvatar;
    
    UIImage *_staticAvatar;
    bool _hasStaticAvatar;
    
    bool _makeFieldFirstResponder;
}

@end

@implementation TGGroupInfoCollectionItem

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.selectable = false;
        self.highlightable = false;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGGroupInfoCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, (_isChannel && !_editing) ? 88.0f : 93.0f);
}

- (void)bindView:(TGGroupInfoCollectionItemView *)view
{
    [super bindView:view];
    
    view.delegate = self;
    
    view.isBroadcast = _isBroadcast;
    view.isChannel = _isChannel;
    view.isVerified = _conversation.isVerified;
    [view setGroupId:_conversation.conversationId];
    [view setUpdatingTitle:_updatingTitle != nil animated:false];
    if (_conversation.conversationId == 0) {
        [view setAvatarImage:_staticAvatar animated:false];
    } else {
        [view setUpdatingAvatar:_hasUpdatingAvatar animated:false];
        if (_updatingAvatar == nil)
            [view setAvatarUri:_conversation.chatPhotoSmall animated:false];
        else
            [view setAvatarImage:_updatingAvatar animated:false];
    }
    
    [view setTitle:_updatingTitle != nil ? _updatingTitle : _conversation.chatTitle];
    
    [view setEditing:_editing animated:false];
    
    if (_makeFieldFirstResponder)
    {
        _makeFieldFirstResponder = false;
        [view makeNameFieldFirstResponder];
    }
}

- (void)unbindView
{
    ((TGGroupInfoCollectionItemView *)[self boundView]).delegate = nil;
    
    [super unbindView];
}

- (void)setConversation:(TGConversation *)conversation
{
    _conversation = conversation;
    
    TGGroupInfoCollectionItemView *view = (TGGroupInfoCollectionItemView *)[self boundView];
    if (view != nil)
    {
        if (_conversation.conversationId == 0) {
            [view setAvatarImage:_staticAvatar animated:true];
        } else if (_updatingAvatar == nil)
            [view setAvatarUri:_conversation.chatPhotoSmall animated:true];
        else
            [view setAvatarImage:_updatingAvatar animated:true];
        
        [view setTitle:_updatingTitle != nil ? _updatingTitle : _conversation.chatTitle];
        
        view.isVerified = _conversation.isVerified;
    }
}

- (void)setUpdatingTitle:(NSString *)updatingTitle
{
    if (!TGStringCompare(_updatingTitle, updatingTitle))
    {
        _updatingTitle = updatingTitle;
        
        TGGroupInfoCollectionItemView *view = (TGGroupInfoCollectionItemView *)[self boundView];
        if (view != nil)
        {
            [view setUpdatingTitle:_updatingTitle != nil animated:true];
            [view setTitle:_updatingTitle != nil ? _updatingTitle : _conversation.chatTitle];
        }
    }
}

- (void)copyUpdatingAvatarToCacheWithUri:(NSString *)uri
{
    if ([self boundView] != nil && _updatingAvatar != nil && uri != nil)
    {
        [[TGRemoteImageView sharedCache] cacheImage:_updatingAvatar withData:nil url:[[NSString alloc] initWithFormat:@"{filter:circle:64x64}%@", uri] availability:TGCacheMemory];
    }
}

- (void)makeNameFieldFirstResponder
{
    if ([self boundView] == nil)
        _makeFieldFirstResponder = true;
    else
        [(TGGroupInfoCollectionItemView *)[self boundView] makeNameFieldFirstResponder];
}

- (void)setUpdatingAvatar:(UIImage *)updatingAvatar hasUpdatingAvatar:(bool)hasUpdatingAvatar
{
    if (_updatingAvatar != updatingAvatar || _hasUpdatingAvatar != hasUpdatingAvatar)
    {
        _updatingAvatar = updatingAvatar;
        _hasUpdatingAvatar = hasUpdatingAvatar;
        
        TGGroupInfoCollectionItemView *view = (TGGroupInfoCollectionItemView *)[self boundView];
        if (view != nil)
        {
            [view setUpdatingAvatar:_hasUpdatingAvatar animated:true];
            
            if (_updatingAvatar == nil)
                [view setAvatarUri:_conversation.chatPhotoSmall animated:false];
            else
                [view setAvatarImage:_updatingAvatar animated:false];
        }
    }
}

- (bool)hasUpdatingAvatar
{
    return _hasUpdatingAvatar;
}

- (void)setStaticAvatar:(UIImage *)staticAvatar {
    _staticAvatar = staticAvatar;
    
    TGGroupInfoCollectionItemView *view = (TGGroupInfoCollectionItemView *)[self boundView];
    if (view != nil) {
        if (_conversation.conversationId == 0) {
            [view setAvatarImage:staticAvatar animated:false];
        }
    }
}

- (UIImage *)staticAvatar {
    return _staticAvatar;
}

- (void)setEditing:(bool)editing animated:(bool)animated
{
    if (_editing != editing)
    {
        _editing = editing;
        
        [(TGGroupInfoCollectionItemView *)[self boundView] setEditing:_editing animated:animated];
    }
}

- (id)avatarView
{
    return [(TGGroupInfoCollectionItemView *)[self boundView] avatarView];
}

- (NSString *)editingTitle
{
    return _editing ? _editingTitle : nil;
}

- (void)groupInfoViewHasTappedAvatar:(TGGroupInfoCollectionItemView *)groupInfoView
{
    if (groupInfoView == [self boundView])
    {
        if (_hasUpdatingAvatar)
            [_interfaceHandle requestAction:@"showUpdatingAvatarOptions" options:nil];
        else
            [_interfaceHandle requestAction:@"openAvatar" options:nil];
    }
}

- (void)groupInfoViewHasChangedEditedTitle:(TGGroupInfoCollectionItemView *)groupInfoView title:(NSString *)title
{
    if (groupInfoView == [self boundView])
    {
        _editingTitle = title;
        [_interfaceHandle requestAction:@"editedTitleChanged" options:@{@"title": title == nil ? @"" : title}];
    }
}

@end
