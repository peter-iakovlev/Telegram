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
#import "TGConversation.h"

#import "ASHandle.h"

#import "TGStringUtils.h"

#import "TGTelegraph.h"

#import "TGLocalization.h"

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
    
    [view setFirstName:_user.firstName lastName:_user.lastName uidForPlaceholderCalculation:_user.uid canPromote:_canPromote canRestrict:_canRestrict canBan:_canBan canDelete:_canDelete];
    if (_customStatus != nil) {
        [view setStatus:_customStatus active:false];
    } else {
        if (_user.kind == TGUserKindBot || _user.kind == TGUserKindSmartBot)
        {
            NSString *botStatus = nil;
            if (_user.kind == TGUserKindBot && _customLabel.length == 0)
                botStatus = TGLocalized(@"Bot.GroupStatusDoesNotReadHistory");
            else
                botStatus = TGLocalized(@"Bot.GroupStatusReadsHistory");
            [view setStatus:botStatus active:false];
        }
        else
        {
            bool active = false;
            NSString *status = [self _statusStringFromUserPresence:_user.presence active:&active];
            [view setStatus:status active:active];
        }
    }
    [view setAvatarUri:_user.photoUrlSmall];
    [view setEnableEditing:_canEdit animated:false];
    
    if (_conversation == nil)
    {
        [view setIsSecretChat:false];
    }
    else
    {
        [view setIsSecretChat:_conversation.isEncrypted];
        
        if (_user == nil)
        {
            [view setFirstName:_conversation.chatTitle lastName:@"" uidForPlaceholderCalculation:(int32_t)_conversation.conversationId canPromote:_canPromote canRestrict:_canRestrict canBan:_canBan canDelete:_canDelete];
            [view setStatus:[self stringForMemberCount:_conversation.chatParticipantCount] active:false];
            [view setAvatarUri:_conversation.chatPhotoSmall];
        }
    }
    
    if (_optionTitle != nil) {
        //view.optionText = _optionTitle;
    }
    
    [view setCustomLabel:_customLabel];
    
    [view setRequiresFullSeparator:_requiresFullSeparator];
    [view setDisplaySwitch:_displaySwitch];
    [view setDisplayCheck:_displayCheck];
    [view setEnableSwitch:_enableSwitch animated:false];
    [view setSwitchIsOn:_switchIsOn animated:false];
    [view setCheckIsOn:_checkIsOn];
    
    __weak TGGroupInfoUserCollectionItem *weakSelf = self;
    view.requestDelete = ^{
        __strong TGGroupInfoUserCollectionItem *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (strongSelf->_requestDelete) {
                strongSelf->_requestDelete();
            }
            
            [strongSelf groupInfoUserItemViewRequestedDeleteAction:(TGGroupInfoUserCollectionItemView *)[strongSelf boundView]];
        }
    };
    view.requestPromote = ^{
        __strong TGGroupInfoUserCollectionItem *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf->_requestPromote) {
            strongSelf->_requestPromote();
        }
    };
    view.requestRestrict = ^{
        __strong TGGroupInfoUserCollectionItem *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf->_requestRestrict) {
            strongSelf->_requestRestrict();
        }
    };
    
    [(TGGroupInfoUserCollectionItemView *)[self boundView] setDisabled:_disabled animated:false];
}

- (void)unbindView
{
    ((TGGroupInfoUserCollectionItemView *)[self boundView]).delegate = nil;
    
    [super unbindView];
}

- (void)setDisplaySwitch:(bool)displaySwitch {
    _displaySwitch = displaySwitch;
    
    [(TGGroupInfoUserCollectionItemView *)[self boundView] setDisplaySwitch:_displaySwitch];
}

- (void)setEnableSwitch:(bool)enableSwitch {
    _enableSwitch = enableSwitch;
    
    [(TGGroupInfoUserCollectionItemView *)[self boundView] setEnableSwitch:_enableSwitch animated:true];
}

- (void)setSwitchIsOn:(bool)switchIsOn {
    [self setSwitchIsOn:switchIsOn animated:true];
}

- (void)setDisplayCheck:(bool)displayCheck {
    _displayCheck = displayCheck;
    [(TGGroupInfoUserCollectionItemView *)[self boundView] setDisplayCheck:_displayCheck];
}

- (void)setCheckIsOn:(bool)checkIsOn {
    _checkIsOn = checkIsOn;
    [(TGGroupInfoUserCollectionItemView *)[self boundView] setCheckIsOn:_checkIsOn];
}

- (void)setSwitchIsOn:(bool)switchIsOn animated:(bool)animated {
    _switchIsOn = switchIsOn;
    
    [(TGGroupInfoUserCollectionItemView *)[self boundView] setSwitchIsOn:_switchIsOn animated:animated];
}

- (void)setCustomStatus:(NSString *)customStatus {
    _customStatus = customStatus;
    
    TGGroupInfoUserCollectionItemView *view = (TGGroupInfoUserCollectionItemView *)[self boundView];
    
    if (_customStatus != nil) {
        [view setStatus:_customStatus active:false];
    } else {
        if (_user.kind == TGUserKindBot || _user.kind == TGUserKindSmartBot)
        {
            NSString *botStatus = nil;
            if (_user.kind == TGUserKindBot && _customLabel.length == 0)
                botStatus = TGLocalized(@"Bot.GroupStatusDoesNotReadHistory");
            else
                botStatus = TGLocalized(@"Bot.GroupStatusReadsHistory");
            [view setStatus:botStatus active:false];
        }
        else
        {
            bool active = false;
            NSString *status = [self _statusStringFromUserPresence:_user.presence active:&active];
            [view setStatus:status active:active];
        }
    }
}

- (NSString *)_statusStringFromUserPresence:(TGUserPresence)presence active:(out bool *)active
{
    if (presence.online)
    {
        if (active != NULL)
            *active = true;
        return TGLocalized(@"Presence.online");
    }
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
        [view setFirstName:user.firstName lastName:user.lastName uidForPlaceholderCalculation:_user.uid canPromote:_canPromote canRestrict:_canRestrict canBan:_canBan canDelete:_canDelete];
        if (_customStatus != nil) {
            [view setStatus:_customStatus active:false];
        } else {
            if (_user.kind == TGUserKindBot || _user.kind == TGUserKindSmartBot)
            {
                NSString *botStatus = nil;
                if (_user.kind == TGUserKindBot && _customLabel.length == 0)
                    botStatus = TGLocalized(@"Bot.GroupStatusDoesNotReadHistory");
                else
                    botStatus = TGLocalized(@"Bot.GroupStatusReadsHistory");
                [view setStatus:botStatus active:false];
            }
            else
            {
                if (_user.uid == TGTelegraphInstance.clientUserId) {
                    bool active = false;
                    TGUserPresence presence;
                    presence.online = true;
                    NSString *status = [self _statusStringFromUserPresence:presence active:&active];
                    [view setStatus:status active:active];
                } else {
                    bool active = false;
                    NSString *status = [self _statusStringFromUserPresence:_user.presence active:&active];
                    [view setStatus:status active:active];
                }
            }
        }
        [view setAvatarUri:_user.photoUrlSmall];
    }
}

- (NSString *)stringForMemberCount:(int)memberCount
{
    return [effectiveLocalization() getPluralized:@"Conversation.StatusMembers" count:(int32_t)memberCount];
}

- (void)setConversation:(TGConversation *)conversation
{
    _conversation = conversation;
    
    if ([self boundView] != nil)
    {
        TGGroupInfoUserCollectionItemView *view = (TGGroupInfoUserCollectionItemView *)[self boundView];
        
        if (_conversation == nil)
        {
            [view setIsSecretChat:false];
        }
        else
        {
            [view setIsSecretChat:_conversation.isEncrypted];
        }
        
        if (_user == nil)
        {
            [view setFirstName:_conversation.chatTitle lastName:@"" uidForPlaceholderCalculation:(int32_t)_conversation.conversationId canPromote:_canBan canRestrict:_canRestrict canBan:_canBan canDelete:_canDelete];
            [view setStatus:[self stringForMemberCount:_conversation.chatParticipantCount] active:false];
            [view setAvatarUri:_conversation.chatPhotoSmall];
        }
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
    if (_user != nil && _user.kind == TGUserKindGeneric && _customStatus == nil)
    {
        bool active = false;
        NSString *status = [self _statusStringFromUserPresence:_user.presence active:&active];
        [(TGGroupInfoUserCollectionItemView *)[self boundView] setStatus:status active:active];
    }
}

- (void)itemSelected:(id)__unused actionTarget
{
    if (_pressed) {
        _pressed();
    }
    
    if (_conversation == nil)
        [_interfaceHandle requestAction:@"openUser" options:@{@"uid": @(_user.uid), @"force": @true}];
    else
        [_interfaceHandle requestAction:@"openConversation" options:@{@"conversationId": @(_conversation.conversationId)}];
}

- (void)groupInfoUserItemViewRequestedDeleteAction:(TGGroupInfoUserCollectionItemView *)groupInfoUserItemView
{
    if (groupInfoUserItemView == [self boundView] && (_user.uid != 0 || _conversation.conversationId != 0))
    {
        if (_conversation == nil)
            [_interfaceHandle requestAction:@"deleteUser" options:@{@"uid": @(_user.uid)}];
        else
            [_interfaceHandle requestAction:@"deleteConversation" options:@{@"conversationId": @(_conversation.conversationId)}];
    }
}

- (void)switchValueChanged:(bool)switchValue {
    if (_toggled) {
        _toggled(switchValue);
    }
}

- (void)setCustomLabel:(NSString *)customLabel {
    _customLabel = customLabel;
    
    [(TGGroupInfoUserCollectionItemView *)[self boundView] setCustomLabel:_customLabel];
}

@end
