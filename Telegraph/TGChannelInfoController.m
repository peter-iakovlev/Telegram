/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGChannelInfoController.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGConversation.h"
#import "TGDatabase.h"

#import "TGHacks.h"
#import "TGFont.h"
#import "TGStringUtils.h"
#import "UIDevice+PlatformInfo.h"
#import "TGInterfaceAssets.h"

#import "TGAppDelegate.h"
#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"

#import "TGInterfaceManager.h"
#import "TGNavigationBar.h"
#import "TGTelegraphDialogListCompanion.h"
#import "TGConversationChangeTitleRequestActor.h"
#import "TGConversationChangePhotoActor.h"

#import "TGHeaderCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGVariantCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGGroupInfoCollectionItem.h"
#import "TGGroupInfoUserCollectionItem.h"

#import "TGTelegraphUserInfoController.h"
#import "TGGroupInfoSelectContactController.h"
#import "TGBotUserInfoController.h"
#import "TGAlertSoundController.h"

#import "TGRemoteImageView.h"
#import "TGLegacyCameraController.h"
#import "TGImagePickerController.h"

#import "TGOverlayFormsheetWindow.h"
#import "TGMediaFoldersController.h"
#import "TGModernMediaPickerController.h"
#import "TGWebSearchController.h"
#import "TGCameraController.h"

#import "TGImageUtils.h"

#import "TGAlertView.h"
#import "TGActionSheet.h"

#import "TGModernGalleryController.h"
#import "TGGroupAvatarGalleryItem.h"
#import "TGGroupAvatarGalleryModel.h"
#import "TGOverlayControllerWindow.h"

#import "TGUserInfoVariantCollectionItem.h"
#import "TGUserInfoTextCollectionItem.h"
#import "TGUserInfoUsernameCollectionItem.h"
#import "TGUserInfoButtonCollectionItem.h"

#import "TGAccessChecker.h"

#import "TGAttachmentSheetView.h"
#import "TGAttachmentSheetWindow.h"
#import "TGAttachmentSheetButtonItemView.h"
#import "TGAttachmentSheetRecentItemView.h"
#import "TGAttachmentSheetRecentCameraView.h"
#import "TGCameraPreviewView.h"

#import "TGSharedMediaController.h"

#import "TGTimerTarget.h"

#import "TGGroupManagementSignals.h"
#import "TGProgressWindow.h"

#import "TGGroupInfoShareLinkController.h"

#import "TGChannelLinkSetupController.h"
#import "TGChannelAboutSetupController.h"

#import "TGChannelManagementSignals.h"

#import "TGChannelMembersController.h"

@interface TGChannelInfoController () <TGGroupInfoSelectContactControllerDelegate, TGAlertSoundControllerDelegate, TGLegacyCameraControllerDelegate, TGImagePickerControllerDelegate, ASWatcher>
{
    bool _editing;
    
    int64_t _peerId;
    TGConversation *_conversation;
    
    TGCollectionMenuSection *_groupInfoSection;
    
    TGGroupInfoCollectionItem *_groupInfoItem;
    TGButtonCollectionItem *_setGroupPhotoItem;
    
    TGCollectionMenuSection *_infoSection;
    TGUserInfoTextCollectionItem *_aboutItem;
    TGUserInfoUsernameCollectionItem *_linkItem;
    
    TGCollectionMenuSection *_leaveSection;
    TGUserInfoButtonCollectionItem *_leaveItem;
    
    TGCollectionMenuSection *_adminInfoSection;
    TGUserInfoVariantCollectionItem *_infoManagementItem;
    TGUserInfoVariantCollectionItem *_infoBlacklistItem;
    TGUserInfoVariantCollectionItem *_infoMembersItem;
    
    TGCollectionMenuSection *_editingInfoSection;
    TGVariantCollectionItem *_channelAboutItem;
    TGVariantCollectionItem *_channelLinkItem;
    TGSwitchCollectionItem *_channelCommentsItem;
    
    TGCollectionMenuSection *_deleteChannelSection;
    
    TGCollectionMenuSection *_notificationsAndMediaSection;
    TGUserInfoVariantCollectionItem *_notificationsItem;
    TGUserInfoVariantCollectionItem *_soundItem;
    
    NSMutableDictionary *_groupNotificationSettings;
    NSInteger _sharedMediaCount;
    
    NSTimer *_muteExpirationTimer;
    
    TGAttachmentSheetWindow *_attachmentSheetWindow;
    
    id<SDisposable> _completeInfoDisposable;
    id<SDisposable> _cachedDataDisposable;
    
    NSString *_privateLink;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGChannelInfoController

- (instancetype)initWithPeerId:(int64_t)peerId
{
    self = [super init];
    if (self != nil)
    {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Back") style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _peerId = peerId;
        _groupNotificationSettings = [[NSMutableDictionary alloc] initWithDictionary:@{@"muteUntil": @(0), @"soundId": @(1)}];
        
        TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:_peerId];
        
        if (conversation.chatIsAdmin) {
            [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)] animated:false];
        } else {
        }
        
        [self setTitleText:TGLocalized(@"Channel.TitleInfo")];
        
        _groupInfoItem = [[TGGroupInfoCollectionItem alloc] init];
        _groupInfoItem.interfaceHandle = _actionHandle;
        _groupInfoItem.transparent = true;
        _groupInfoItem.isChannel = true;
        
        _setGroupPhotoItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.UpdatePhotoItem") action:@selector(setGroupPhotoPressed)];
        _setGroupPhotoItem.titleColor = TGAccentColor();
        _setGroupPhotoItem.deselectAutomatically = true;
        
        NSMutableArray *infoSectionItems = [[NSMutableArray alloc] init];
        [infoSectionItems addObject:_groupInfoItem];
        
        _groupInfoSection = [[TGCollectionMenuSection alloc] initWithItems:infoSectionItems];
        _groupInfoSection.insets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        
        NSString *linkText = _conversation.username.length == 0 ? @"" : [@"https://telegram.me/" stringByAppendingString:_conversation.username];
        _aboutItem = [[TGUserInfoTextCollectionItem alloc] init];
        _aboutItem.title = TGLocalized(@"Channel.Info.Description");
        _aboutItem.text = _conversation.about;
        _linkItem = [[TGUserInfoUsernameCollectionItem alloc] initWithLabel:TGLocalized(@"Channel.LinkItem") username:linkText];
        _linkItem.action = @selector(sharePressed);
        _infoSection = [[TGCollectionMenuSection alloc] initWithItems:@[_aboutItem, _linkItem]];
        _infoSection.insets = UIEdgeInsetsMake(1.0f, 0.0f, 22.0f, 0.0f);
        
        _leaveItem = [[TGUserInfoButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.LeaveChannel") action:@selector(leavePressed)];
        _leaveItem.titleColor = TGDestructiveAccentColor();
        _leaveItem.deselectAutomatically = true;
        _leaveSection = [[TGCollectionMenuSection alloc] initWithItems:@[_leaveItem]];

        TGButtonCollectionItem *deleteChannelItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"ChannelInfo.DeleteChannel") action:@selector(deleteChannelPressed)];
        deleteChannelItem.titleColor = TGDestructiveAccentColor();
        deleteChannelItem.deselectAutomatically = true;
        _deleteChannelSection = [[TGCollectionMenuSection alloc] initWithItems:@[deleteChannelItem]];
        
        _infoManagementItem = [[TGUserInfoVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Info.Management") variant:@"" action:@selector(infoManagementPressed)];
        _infoBlacklistItem = [[TGUserInfoVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Info.BlackList") variant:@"" action:@selector(infoBlacklistPressed)];
        _infoMembersItem = [[TGUserInfoVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Info.Members") variant:@"" action:@selector(infoMembersPressed)];
        _adminInfoSection = [[TGCollectionMenuSection alloc] initWithItems:@[_infoManagementItem, _infoMembersItem]];
        
        _channelAboutItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Edit.AboutItem") action:@selector(aboutPressed)];
        _channelAboutItem.variant = _conversation.about;
        _channelLinkItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Edit.LinkItem") action:@selector(linkPressed)];
        _channelLinkItem.variant = _conversation.username.length == 0 ? @"" : [@"/" stringByAppendingString:_conversation.username];
        _channelCommentsItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Edit.EnableComments") isOn:!_conversation.channelIsReadOnly];
        __weak TGChannelInfoController *weakSelf = self;
        _channelCommentsItem.toggled = ^(bool value){
            __strong TGChannelInfoController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf toggleCommentsEnabled:value];
            }
        };
        __unused TGCommentCollectionItem *commentsHelp = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Channel.Username.CreateCommentsHelp")];
        _editingInfoSection = [[TGCollectionMenuSection alloc] initWithItems:@[_channelAboutItem, _channelLinkItem]];
        
        _notificationsItem = [[TGUserInfoVariantCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.Notifications") variant:nil action:@selector(notificationsPressed)];
        _notificationsItem.deselectAutomatically = true;
        _soundItem = [[TGUserInfoVariantCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.Sound") variant:nil action:@selector(soundPressed)];
        _soundItem.deselectAutomatically = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
        
        TGUserInfoVariantCollectionItem *_sharedMediaItem = [[TGUserInfoVariantCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.SharedMedia") variant:@"" action:@selector(sharedMediaPressed)];
        
        _notificationsAndMediaSection = [[TGCollectionMenuSection alloc] initWithItems:@[_notificationsItem, _sharedMediaItem]];
        UIEdgeInsets notificationsAndMediaSectionInsets = _notificationsAndMediaSection.insets;
        notificationsAndMediaSectionInsets.bottom = 22.0f;
        _notificationsAndMediaSection.insets = notificationsAndMediaSectionInsets;
        
        [self _loadUsersAndUpdateConversation:conversation];
        
        [self _updateNotificationItems:false];
        [self _updateSharedMediaCount];
        
        int64_t accessHash = _conversation.accessHash;
        [ActionStageInstance() dispatchOnStageQueue:^
         {
             [ActionStageInstance() watchForPaths:@[
                                                    [[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _peerId],
                                                    //@"/tg/userdatachanges",
                                                    //@"/tg/userpresencechanges",
                                                    //@"/as/updateRelativeTimestamps",
                                                    //[[NSString alloc] initWithFormat:@"/tg/sharedMediaCount/(%" PRIx64 ")", (int64_t)_conversationId]
                                                    ] watcher:self];
             
             [ActionStageInstance() watchForPath:[NSString stringWithFormat:@"/tg/peerSettings/(%" PRId64 ")", _peerId] watcher:self];
             [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/peerSettings/(%" PRId64 ",cachedOnly)", _peerId] options:@{@"peerId": @(_peerId), @"accessHash": @(accessHash)} watcher:self];
             
             NSArray *changeTitleActions = [ActionStageInstance() rejoinActionsWithGenericPathNow:@"/tg/conversation/@/changeTitle/@" prefix:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")", _peerId] watcher:self];
             NSArray *changeAvatarActions = [ActionStageInstance() rejoinActionsWithGenericPathNow:@"/tg/conversation/@/updateAvatar/@" prefix:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")", _peerId] watcher:self];
             
             NSString *updatingTitle = nil;
             if (changeTitleActions.count != 0)
             {
                 NSString *action = [changeTitleActions lastObject];
                 TGConversationChangeTitleRequestActor *actor = (TGConversationChangeTitleRequestActor *)[ActionStageInstance() executingActorWithPath:action];
                 if (actor != nil)
                     updatingTitle = actor.currentTitle;
             }
             
             UIImage *updatingAvatar = nil;
             bool haveUpdatingAvatar = false;
             if (changeAvatarActions.count != 0)
             {
                 NSString *action = [changeAvatarActions lastObject];
                 TGConversationChangePhotoActor *actor = (TGConversationChangePhotoActor *)[ActionStageInstance() executingActorWithPath:action];
                 if (actor != nil)
                 {
                     updatingAvatar = actor.currentImage;
                     haveUpdatingAvatar = true;
                 }
             }
             
             if (changeTitleActions.count != 0 || changeAvatarActions.count != 0)
             {
                 TGDispatchOnMainThread(^ {
                     [_groupInfoItem setUpdatingTitle:updatingTitle];
                     
                     [_groupInfoItem setUpdatingAvatar:updatingAvatar hasUpdatingAvatar:haveUpdatingAvatar];
                     [_setGroupPhotoItem setEnabled:!haveUpdatingAvatar];
                     
                     [self _loadUsersAndUpdateConversation:_conversation];
                 });
             }
         }];
        
        _completeInfoDisposable = [[TGChannelManagementSignals updateChannelExtendedInfo:_conversation.conversationId accessHash:_conversation.accessHash updateUnread:true] startWithNext:nil];
        
        _cachedDataDisposable = [[[TGDatabaseInstance() channelCachedData:_conversation.conversationId] deliverOn:[SQueue mainQueue]] startWithNext:^(TGCachedConversationData *cachedData) {
            __strong TGChannelInfoController *strongSelf = weakSelf;
            if (strongSelf != nil && cachedData != nil) {
                [strongSelf->_infoManagementItem setVariant:[[NSString alloc] initWithFormat:@"%d", cachedData.managementCount]];
                [strongSelf->_infoBlacklistItem setVariant:[[NSString alloc] initWithFormat:@"%d", cachedData.blacklistCount]];
                [strongSelf->_infoMembersItem setVariant:[[NSString alloc] initWithFormat:@"%d", cachedData.memberCount]];
                strongSelf->_privateLink = cachedData.privateLink;
            }
        }];
        
        [self _setupSections:false];
    }
    return self;
}

- (void)_setupSections:(bool)editing {
    while (self.menuSections.sections.count != 0) {
        [self.menuSections deleteSection:0];
    }
    
    if (editing) {
        _groupInfoItem.transparent = false;
        if ([_groupInfoSection indexOfItem:_setGroupPhotoItem] == NSNotFound) {
            [_groupInfoSection insertItem:_setGroupPhotoItem atIndex:1];
        }
        _groupInfoSection.insets = UIEdgeInsetsMake(0.0f, 0.0f, 35.0f, 0.0f);
        
        [self.menuSections addSection:_groupInfoSection];
        [self.menuSections addSection:_editingInfoSection];
        
        if (_conversation.channelRole == TGChannelRoleCreator) {
            [self.menuSections addSection:_deleteChannelSection];
        }
        
        self.collectionView.backgroundColor = [TGInterfaceAssets listsBackgroundColor];
    } else {
        _groupInfoItem.transparent = true;
        [_groupInfoSection deleteItem:_setGroupPhotoItem];
        _groupInfoSection.insets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        
        [self.menuSections addSection:_groupInfoSection];
        [self.menuSections addSection:_infoSection];
        if (_conversation.channelRole == TGChannelRoleCreator || _conversation.channelRole == TGChannelRoleModerator || _conversation.channelRole == TGChannelRolePublisher) {
            [self.menuSections addSection:_adminInfoSection];
        }
        [self.menuSections addSection:_notificationsAndMediaSection];
        if (_conversation.kind == TGConversationKindPersistentChannel && _conversation.channelRole != TGChannelRoleCreator) {
            [self.menuSections addSection:_leaveSection];
        }
        self.collectionView.backgroundColor = [UIColor whiteColor];
    }
    
    [self.collectionView reloadData];
}

- (void)backPressed
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    
    [_completeInfoDisposable dispose];
    [_cachedDataDisposable dispose];
}

#pragma mark -

- (void)_resetCollectionView
{
    [super _resetCollectionView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView setAllowEditingCells:false animated:false];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark -

- (void)editPressed
{
    if (!_editing)
    {
        _editing = true;
        
        [_groupInfoItem setEditing:true animated:false];
        [self _setupSections:true];
        [self enterEditingMode:true];
    }
}

- (void)donePressed
{
    if (_editing)
    {
        _editing = false;
        
        if (!TGStringCompare(_conversation.chatTitle, [_groupInfoItem editingTitle]) && [_groupInfoItem editingTitle] != nil)
            [self _commitUpdateTitle:[_groupInfoItem editingTitle]];
        
        [_groupInfoItem setEditing:false animated:false];
        [self _setupSections:false];
        [self leaveEditingMode:true];
    }
    
    [self leaveEditingMode:true];
}

- (void)didEnterEditingMode:(bool)animated
{
    [super didEnterEditingMode:animated];
    
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)] animated:true];
}

- (void)didLeaveEditingMode:(bool)animated
{
    [super didLeaveEditingMode:animated];
    
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)] animated:animated];
}

- (void)setGroupPhotoPressed
{
    if (!_conversation.chatIsAdmin) {
        return;
    }
    
    if (false && iosMajorVersion() >= 7 && !TGIsPad())
    {
        __weak TGChannelInfoController *weakSelf = self;
        _attachmentSheetWindow = [[TGAttachmentSheetWindow alloc] init];
        _attachmentSheetWindow.dismissalBlock = ^
        {
            __strong TGChannelInfoController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            strongSelf->_attachmentSheetWindow.rootViewController = nil;
            strongSelf->_attachmentSheetWindow = nil;
        };
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        TGAttachmentSheetRecentItemView *recentView = [[TGAttachmentSheetRecentItemView alloc] initWithParentController:self mode:TGAttachmentSheetItemViewSetGroupPhotoMode];
        recentView.openCamera = ^(TGAttachmentSheetRecentCameraView *cameraView)
        {
            __strong TGChannelInfoController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf.view endEditing:true];
                [strongSelf _displayCameraWithView:cameraView];
            }
        };
        recentView.avatarCreated = ^(UIImage *resultImage)
        {
            __strong TGChannelInfoController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
                [strongSelf _updateGroupProfileImage:resultImage];
            }
        };
        [items addObject:recentView];
        
        [items addObject:[[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.ChoosePhoto") pressed:^
                          {
                              __strong TGChannelInfoController *strongSelf = weakSelf;
                              if (strongSelf != nil)
                              {
                                  [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
                                  [strongSelf _displayImagePicker:false];
                              }
                          }]];
        
        [items addObject:[[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Conversation.SearchWebImages") pressed:^
                          {
                              __strong TGChannelInfoController *strongSelf = weakSelf;
                              if (strongSelf != nil)
                              {
                                  [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
                                  [strongSelf _displayImagePicker:true];
                              }
                          }]];
        
        if (_conversation.chatPhotoSmall.length != 0)
        {
            TGAttachmentSheetButtonItemView *deleteItem = [[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"GroupInfo.SetGroupPhotoDelete") pressed:^
                                                           {
                                                               __strong TGChannelInfoController *strongSelf = weakSelf;
                                                               if (strongSelf != nil)
                                                               {
                                                                   [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
                                                                   [strongSelf _commitDeleteAvatar];
                                                               }
                                                           }];
            [deleteItem setDestructive:true];
            [items addObject:deleteItem];
        }
        
        TGAttachmentSheetButtonItemView *cancelItem =[[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") pressed:^
                                                      {
                                                          __strong TGChannelInfoController *strongSelf = weakSelf;
                                                          if (strongSelf != nil)
                                                              [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
                                                      }];
        [cancelItem setBold:true];
        [items addObject:cancelItem];
        
        _attachmentSheetWindow.view.items = items;
        [_attachmentSheetWindow showAnimated:true completion:nil];
    }
    else
    {
        NSMutableArray *actions = [[NSMutableArray alloc] init];
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.TakePhoto") action:@"camera"]];
        
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.ChoosePhoto") action:@"choosePhoto"]];
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.SearchWebImages") action:@"searchWeb"]];
        
        if (_conversation.chatPhotoSmall.length != 0)
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"GroupInfo.SetGroupPhotoDelete") action:@"delete" type:TGActionSheetActionTypeDestructive]];
        
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
        
        [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(TGChannelInfoController *controller, NSString *action)
          {
              if ([action isEqualToString:@"camera"])
                  [controller _displayCameraWithView:nil];
              else if ([action isEqualToString:@"choosePhoto"])
                  [controller _displayImagePicker:false];
              else if ([action isEqualToString:@"searchWeb"])
                  [controller _displayImagePicker:true];
              else if ([action isEqualToString:@"delete"])
                  [controller _commitDeleteAvatar];
          } target:self] showInView:self.view];
    }
}

- (void)_displayCameraWithView:(TGAttachmentSheetRecentCameraView *)cameraView
{
    if (![TGAccessChecker checkCameraAuthorizationStatusWithAlertDismissComlpetion:nil])
        return;
    
    if (iosMajorVersion() < 7 || [UIDevice currentDevice].platformType == UIDevice4iPhone || [UIDevice currentDevice].platformType == UIDevice4GiPod)
    {
        [self _displayLegacyCamera];
        [_attachmentSheetWindow dismissAnimated:true completion:nil];
        return;
    }
    
    TGCameraController *controller = nil;
    CGSize screenSize = TGScreenSize();
    
    if (cameraView.previewView != nil)
        controller = [[TGCameraController alloc] initWithCamera:cameraView.previewView.camera previewView:cameraView.previewView intent:TGCameraControllerAvatarIntent];
    else
        controller = [[TGCameraController alloc] initWithIntent:TGCameraControllerAvatarIntent];
    
    controller.shouldStoreCapturedAssets = true;
    
    TGCameraControllerWindow *controllerWindow = [[TGCameraControllerWindow alloc] initWithParentController:self contentController:controller];
    if (_attachmentSheetWindow != nil)
        controllerWindow.windowLevel = _attachmentSheetWindow.windowLevel + 0.0001f;
    controllerWindow.hidden = false;
    controllerWindow.clipsToBounds = true;
    controllerWindow.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    
    bool standalone = true;
    CGRect startFrame = CGRectMake(0, screenSize.height, screenSize.width, screenSize.height);
    if (cameraView != nil)
    {
        standalone = false;
        startFrame = [controller.view convertRect:cameraView.previewView.frame fromView:cameraView];
    }
    
    [cameraView detachPreviewView];
    [controller beginTransitionInFromRect:startFrame];
    
    __weak TGChannelInfoController *weakSelf = self;
    __weak TGCameraController *weakCameraController = controller;
    __weak TGAttachmentSheetRecentCameraView *weakCameraView = cameraView;
    
    controller.beginTransitionOut = ^CGRect
    {
        __strong TGCameraController *strongCameraController = weakCameraController;
        if (strongCameraController == nil)
            return CGRectZero;
        
        if (!standalone)
        {
            __strong TGAttachmentSheetRecentCameraView *strongCameraView = weakCameraView;
            if (strongCameraView != nil)
                return [strongCameraController.view convertRect:strongCameraView.frame fromView:strongCameraView.superview];
        }
        
        return CGRectZero;
    };
    
    controller.finishedTransitionOut = ^
    {
        __strong TGAttachmentSheetRecentCameraView *strongCameraView = weakCameraView;
        if (strongCameraView == nil)
            return;
        
        [strongCameraView attachPreviewViewAnimated:true];
    };
    
    controller.finishedWithPhoto = ^(UIImage *resultImage, __unused NSString *caption)
    {
        __strong TGChannelInfoController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf _updateGroupProfileImage:resultImage];
        [strongSelf->_attachmentSheetWindow dismissAnimated:false completion:nil];
    };
}

- (void)_displayLegacyCamera
{
    TGLegacyCameraController *legacyCameraController = [[TGLegacyCameraController alloc] init];
    legacyCameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    legacyCameraController.avatarMode = true;
    
    legacyCameraController.completionDelegate = self;
    
    [self presentViewController:legacyCameraController animated:true completion:nil];
}

- (void)_displayImagePicker:(bool)openWebSearch
{
    __weak TGChannelInfoController *weakSelf = self;
    
    TGNavigationController *navigationController = nil;
    
    if (openWebSearch)
    {
        TGWebSearchController *controller = [[TGWebSearchController alloc] initForAvatarSelection:true];
        __weak TGWebSearchController *weakController = controller;
        controller.avatarCreated = ^(UIImage *image)
        {
            __strong TGChannelInfoController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf _updateGroupProfileImage:image];
            
            __strong TGWebSearchController *strongController = weakController;
            if (strongController != nil && strongController.dismiss != nil)
                strongController.dismiss();
        };
        
        navigationController = [TGNavigationController navigationControllerWithControllers:@[controller]];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            void (^dismiss)(void) = ^
            {
                __strong TGChannelInfoController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                [strongSelf dismissViewControllerAnimated:true completion:nil];
            };
            
            [self presentViewController:navigationController animated:true completion:nil];
            
            controller.dismiss = dismiss;
        }
        else
        {
            navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
            navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            
            TGOverlayFormsheetWindow *formSheetWindow = [[TGOverlayFormsheetWindow alloc] initWithParentController:self contentController:navigationController];
            [formSheetWindow showAnimated:true];
            
            __weak TGOverlayFormsheetWindow *weakFormSheetWindow = formSheetWindow;
            void (^dismiss)(void) = ^
            {
                __strong TGOverlayFormsheetWindow *strongFormSheetWindow = weakFormSheetWindow;
                if (strongFormSheetWindow == nil)
                    return;
                
                [strongFormSheetWindow dismissAnimated:true];
            };
            
            controller.dismiss = dismiss;
        }
    }
    else
    {
        TGMediaFoldersController *mediaFoldersController = [[TGMediaFoldersController alloc] initWithIntent:TGModernMediaPickerControllerSetProfilePhotoIntent];
        TGModernMediaPickerController *mediaPickerController = [[TGModernMediaPickerController alloc] initWithAssetsGroup:nil intent:TGModernMediaPickerControllerSetProfilePhotoIntent];
        
        navigationController = [TGNavigationController navigationControllerWithControllers:@[ mediaFoldersController, mediaPickerController ]];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            void (^dismiss)(void) = ^
            {
                __strong TGChannelInfoController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                [strongSelf dismissViewControllerAnimated:true completion:nil];
            };
            
            mediaFoldersController.dismiss = dismiss;
            mediaPickerController.dismiss = dismiss;
            
            [self presentViewController:navigationController animated:true completion:nil];
        }
        else
        {
            navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
            navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            
            TGOverlayFormsheetWindow *formSheetWindow = [[TGOverlayFormsheetWindow alloc] initWithParentController:self contentController:navigationController];
            [formSheetWindow showAnimated:true];
            
            __weak TGOverlayFormsheetWindow *weakFormSheetWindow = formSheetWindow;
            void (^dismiss)(void) = ^
            {
                __strong TGOverlayFormsheetWindow *strongFormSheetWindow = weakFormSheetWindow;
                if (strongFormSheetWindow == nil)
                    return;
                
                [strongFormSheetWindow dismissAnimated:true];
            };
            
            mediaFoldersController.dismiss = dismiss;
            mediaPickerController.dismiss = dismiss;
        }
        
        __weak TGMediaFoldersController *weakMediaFoldersController = mediaFoldersController;
        void(^avatarCreated)(UIImage *) = ^(UIImage *image)
        {
            __strong TGChannelInfoController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf _updateGroupProfileImage:image];
            
            __strong TGMediaFoldersController *strongMediaFoldersController = weakMediaFoldersController;
            if (strongMediaFoldersController != nil && strongMediaFoldersController.dismiss != nil)
                strongMediaFoldersController.dismiss();
        };
        
        mediaFoldersController.avatarCreated = avatarCreated;
        mediaPickerController.avatarCreated = avatarCreated;
    }
}

- (void)imagePickerController:(TGImagePickerController *)__unused imagePicker didFinishPickingWithAssets:(NSArray *)assets
{
    UIImage *image = nil;
    
    if (assets.count != 0)
    {
        if ([assets[0] isKindOfClass:[UIImage class]])
            image = assets[0];
    }
    
    [self _updateGroupProfileImage:image];
    
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)_updateGroupProfileImage:(UIImage *)image
{
    if (image == nil)
        return;
    
    if (MIN(image.size.width, image.size.height) < 160.0f)
        image = TGScaleImageToPixelSize(image, CGSizeMake(160, 160));
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6f);
    if (imageData == nil)
        return;
    
    TGImageProcessor filter = [TGRemoteImageView imageProcessorForName:@"circle:64x64"];
    UIImage *avatarImage = filter(image);
    
    [_groupInfoItem setUpdatingAvatar:avatarImage hasUpdatingAvatar:true];
    [_setGroupPhotoItem setEnabled:false];
    
    NSMutableDictionary *uploadOptions = [[NSMutableDictionary alloc] init];
    [uploadOptions setObject:imageData forKey:@"imageData"];
    [uploadOptions setObject:[NSNumber numberWithLongLong:_conversation.conversationId] forKey:@"conversationId"];
    [uploadOptions setObject:avatarImage forKey:@"currentImage"];
    uploadOptions[@"accessHash"] = @(_conversation.accessHash);
    
    [ActionStageInstance() dispatchOnStageQueue:^
     {
         static int actionId = 0;
         [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")/updateAvatar/(updateAvatar%d)", _peerId, actionId] options:uploadOptions watcher:self];
         [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")/updateAvatar/(updateAvatar%d)", _peerId, actionId++] options:uploadOptions watcher:TGTelegraphInstance];
     }];
}

- (void)_commitDeleteAvatar
{
    [_groupInfoItem setUpdatingAvatar:nil hasUpdatingAvatar:true];
    [_setGroupPhotoItem setEnabled:false];
    
    NSMutableDictionary *uploadOptions = [[NSMutableDictionary alloc] init];
    [uploadOptions setObject:[NSNumber numberWithLongLong:_conversation.conversationId] forKey:@"conversationId"];
    uploadOptions[@"accessHash"] = @(_conversation.accessHash);
    
    [ActionStageInstance() dispatchOnStageQueue:^
     {
         static int actionId = 0;
         [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")/updateAvatar/(deleteAvatar%d)", _peerId, actionId] options:uploadOptions watcher:self];
         [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")/updateAvatar/(deleteAvatar%d)", _peerId, actionId++] options:uploadOptions watcher:TGTelegraphInstance];
     }];
}

- (void)_commitCancelAvatarUpdate
{
    [_groupInfoItem setUpdatingAvatar:nil hasUpdatingAvatar:false];
    [_setGroupPhotoItem setEnabled:true];
    
    [ActionStageInstance() dispatchOnStageQueue:^
     {
         NSArray *actors = [ActionStageInstance() executingActorsWithPathPrefix:[NSString stringWithFormat:@"/tg/conversation/(%lld)/updateAvatar/", _peerId]];
         for (ASActor *actor in actors)
         {
             [ActionStageInstance() removeAllWatchersFromPath:actor.path];
         }
     }];
}

- (void)legacyCameraControllerCompletedWithNoResult
{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)notificationsPressed
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"UserInfo.NotificationsEnable") action:@"enable"]];
    
    NSArray *muteIntervals = @[
                               @(1 * 60 * 60),
                               @(8 * 60 * 60),
                               @(2 * 24 * 60 * 60),
                               ];
    
    for (NSNumber *nMuteInterval in muteIntervals)
    {
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:[TGStringUtils stringForMuteInterval:[nMuteInterval intValue]] action:[[NSString alloc] initWithFormat:@"%@", nMuteInterval]]];
    }
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"UserInfo.NotificationsDisable") action:@"disable"]];
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
    
    [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(TGChannelInfoController *controller, NSString *action)
      {
          if ([action isEqualToString:@"enable"])
              [controller _commitEnableNotifications:true orMuteFor:0];
          else if ([action isEqualToString:@"disable"])
              [controller _commitEnableNotifications:false orMuteFor:0];
          else if (![action isEqualToString:@"cancel"])
          {
              [controller _commitEnableNotifications:false orMuteFor:[action intValue]];
          }
      } target:self] showInView:self.view];
}

- (void)_commitEnableNotifications:(bool)enable orMuteFor:(int)muteFor
{
    int muteUntil = 0;
    if (muteFor == 0)
    {
        if (enable)
            muteUntil = 0;
        else
            muteUntil = INT_MAX;
    }
    else
    {
        muteUntil = (int)([[TGTelegramNetworking instance] approximateRemoteTime] + muteFor);
    }
    
    if (muteUntil != [_groupNotificationSettings[@"muteUntil"] intValue])
    {
        _groupNotificationSettings[@"muteUntil"] = @(muteUntil);
        static int actionId = 0;
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%" PRId64 ")/(userInfoControllerMute%d)", _peerId, actionId++] options:@{@"peerId": @(_peerId), @"accessHash": @(_conversation.accessHash), @"muteUntil": @(muteUntil)} watcher:TGTelegraphInstance];
        [self _updateNotificationItems:false];
    }
}
- (void)_commitUpdateTitle:(NSString *)title
{
    [_groupInfoItem setUpdatingTitle:title];
    
    [ActionStageInstance() dispatchOnStageQueue:^
     {
         static int actionId = 0;
         NSString *path = [[NSString alloc] initWithFormat:@"/tg/conversation/(%" PRId64 ")/changeTitle/(groupInfoController%d)", _conversation.conversationId, actionId++];
         NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithDictionary:@{@"conversationId": @(_peerId), @"title": title == nil ? @"" : title}];
         options[@"accessHash"] = @(_conversation.accessHash);
         
         [ActionStageInstance() requestActor:path options:options watcher:self];
         [ActionStageInstance() requestActor:path options:options watcher:TGTelegraphInstance];
     }];
}

- (void)leaveGroupPressed
{
    __weak typeof(self) weakSelf = self;
    
    [[[TGActionSheet alloc] initWithTitle:TGLocalized(@"GroupInfo.DeleteAndExitConfirmation") actions:@[
                                                                                                        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"GroupInfo.DeleteAndExit") action:@"leave" type:TGActionSheetActionTypeDestructive],
                                                                                                        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
                                                                                                        ] actionBlock:^(__unused id target, NSString *action)
      {
          if ([action isEqualToString:@"leave"])
          {
              TGChannelInfoController *strongSelf = weakSelf;
              [strongSelf _commitLeaveGroup];
          }
      } target:self] showInView:self.view];
}

- (void)_commitLeaveGroup
{
    [TGAppDelegateInstance.rootController.dialogListController.dialogListCompanion deleteItem:[[TGConversation alloc] initWithConversationId:_peerId unreadCount:0 serviceUnreadCount:0] animated:false];
    
    if (self.popoverController != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self.popoverController dismissPopoverAnimated:true];
                       });
    }
    else
        [self.navigationController popToRootViewControllerAnimated:true];
}

- (void)_changeNotificationSettings:(bool)enableNotifications
{
    _groupNotificationSettings[@"muteUntil"] = @(!enableNotifications ? INT_MAX : 0);
    
    static int actionId = 0;
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%" PRId64 ")/(groupInfoController%d)", _conversation.conversationId, actionId++] options:@{@"peerId": @(_peerId), @"accessHash": @(_conversation.accessHash), @"muteUntil": @(!enableNotifications ? INT_MAX : 0)} watcher:TGTelegraphInstance];
}

- (void)soundPressed
{
    TGAlertSoundController *alertSoundController = [[TGAlertSoundController alloc] initWithTitle:TGLocalized(@"GroupInfo.Sound") soundInfoList:[self _soundInfoListForSelectedSoundId:[_groupNotificationSettings[@"soundId"] intValue]]];
    alertSoundController.delegate = self;
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[alertSoundController] navigationBarClass:[TGWhiteNavigationBar class]];
    if ([self inPopover])
    {
        navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleChildInPopover;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)alertSoundController:(TGAlertSoundController *)__unused alertSoundController didFinishPickingWithSoundInfo:(NSDictionary *)soundInfo
{
    if (soundInfo[@"soundId"] != nil && [soundInfo[@"soundId"] intValue] >= 0 && [soundInfo[@"soundId"] intValue] != [_groupNotificationSettings[@"soundId"] intValue])
    {
        int soundId = [soundInfo[@"soundId"] intValue];
        _groupNotificationSettings[@"soundId"] = @(soundId);
        [self _updateNotificationItems:false];
        
        static int actionId = 0;
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%" PRId64 ")/(groupInfoController%d)", _peerId, actionId++] options:@{@"peerId": @(_peerId), @"accessHash": @(_conversation.accessHash), @"soundId": @(soundId)} watcher:TGTelegraphInstance];
    }
}

- (NSString *)soundNameFromId:(int)soundId
{
    if (soundId == 0 || soundId == 1)
        return [TGAppDelegateInstance modernAlertSoundTitles][soundId];
    
    if (soundId >= 2 && soundId <= 9)
        return [TGAppDelegateInstance classicAlertSoundTitles][MAX(0, soundId - 2)];
    
    if (soundId >= 100 && soundId <= 111)
        return [TGAppDelegateInstance modernAlertSoundTitles][soundId - 100 + 2];
    return @"";
}

- (NSArray *)_soundInfoListForSelectedSoundId:(int)selectedSoundId
{
    NSMutableArray *infoList = [[NSMutableArray alloc] init];
    
    int defaultSoundId = 1;
    [TGDatabaseInstance() loadPeerNotificationSettings:INT_MAX - 2 soundId:&defaultSoundId muteUntil:NULL previewText:NULL photoNotificationsEnabled:NULL notFound:NULL];
    NSString *defaultSoundTitle = [self soundNameFromId:defaultSoundId];
    
    int index = -1;
    for (NSString *soundName in [TGAppDelegateInstance modernAlertSoundTitles])
    {
        index++;
        
        int soundId = 0;
        bool isDefault = false;
        
        if (index == 1)
        {
            soundId = 1;
            isDefault = true;
        }
        else if (index == 0)
            soundId = 0;
        else
            soundId = index + 100 - 2;
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[@"title"] = isDefault ? [[NSString alloc] initWithFormat:@"%@ (%@)", soundName, defaultSoundTitle] : soundName;
        dict[@"selected"] = @(selectedSoundId == soundId);
        dict[@"soundName"] = [[NSString alloc] initWithFormat:@"%d", isDefault ? defaultSoundId : soundId];
        dict[@"soundId"] = @(soundId);
        dict[@"groupId"] = @(0);
        [infoList addObject:dict];
    }
    
    index = -1;
    for (NSString *soundName in [TGAppDelegateInstance classicAlertSoundTitles])
    {
        index++;
        
        int soundId = index + 2;
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[@"title"] = soundName;
        dict[@"selected"] = @(selectedSoundId == soundId);
        dict[@"soundName"] =  [[NSString alloc] initWithFormat:@"%d", soundId];
        dict[@"soundId"] = @(soundId);
        dict[@"groupId"] = @(1);
        [infoList addObject:dict];
    }
    
    return infoList;
}

#pragma mark -

- (void)_updateNotificationItems:(bool)__unused animated
{
    [_muteExpirationTimer invalidate];
    _muteExpirationTimer = nil;
    
    NSString *variant = TGLocalized(@"UserInfo.NotificationsEnabled");
    int muteUntil = [_groupNotificationSettings[@"muteUntil"] intValue];
    if (muteUntil <= [[TGTelegramNetworking instance] approximateRemoteTime])
    {
        variant = TGLocalized(@"UserInfo.NotificationsEnabled");
    }
    else
    {
        int muteExpiration = muteUntil - (int)[[TGTelegramNetworking instance] approximateRemoteTime];
        if (muteExpiration >= 7 * 24 * 60 * 60)
            variant = TGLocalized(@"UserInfo.NotificationsDisabled");
        else
        {
            variant = [TGStringUtils stringForRemainingMuteInterval:muteExpiration];
            
            _muteExpirationTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(updateMuteExpiration) interval:2.0 repeat:true];
        }
    }
    
    [_notificationsItem setVariant:variant];
    
    int groupSoundId = [[_groupNotificationSettings objectForKey:@"soundId"] intValue];
    _soundItem.variant = [self soundNameFromId:groupSoundId];
}

- (void)updateMuteExpiration
{
    NSString *variant = TGLocalized(@"UserInfo.NotificationsEnabled");
    int muteUntil = [_groupNotificationSettings[@"muteUntil"] intValue];
    if (muteUntil <= [[TGTelegramNetworking instance] approximateRemoteTime])
    {
        variant = TGLocalized(@"UserInfo.NotificationsEnabled");
    }
    else
    {
        int muteExpiration = muteUntil - (int)[[TGTelegramNetworking instance] approximateRemoteTime];
        variant = [TGStringUtils stringForRemainingMuteInterval:muteExpiration];
    }
    
    if (!TGStringCompare(_notificationsItem.variant, variant))
    {
        [_notificationsItem setVariant:variant];
    }
}

- (void)_updateSharedMediaCount
{
}

- (void)_loadUsersAndUpdateConversation:(TGConversation *)conversation
{
    TGDispatchOnMainThread(^
    {
        bool reloadData = false;
        
        if (_conversation.channelRole != conversation.channelRole) {
            reloadData = true;
        }
        
        _conversation = conversation;
        [_groupInfoItem setConversation:_conversation];
        
        NSString *linkText = _conversation.username.length == 0 ? @"" : [@"https://telegram.me/" stringByAppendingString:_conversation.username];
        
        if (!TGStringCompare(_aboutItem.text, _conversation.about)) {
            reloadData = true;
        }
        
        _aboutItem.text = _conversation.about;
        _linkItem.username = linkText;
        
        if (_aboutItem.text.length == 0) {
            if ([_infoSection deleteItem:_aboutItem]) {
                reloadData = true;
            }
        } else {
            NSUInteger aboutIndex = [_infoSection indexOfItem:_aboutItem];
            if (aboutIndex == NSNotFound) {
                reloadData = true;
                [_infoSection insertItem:_aboutItem atIndex:0];
            }
        }
        
        if (_linkItem.username.length == 0) {
            if ([_infoSection deleteItem:_linkItem]) {
                reloadData = true;
            }
        } else {
            NSUInteger linkIndex = [_infoSection indexOfItem:_linkItem];
            if (linkIndex == NSNotFound) {
                reloadData = true;
                [_infoSection addItem:_linkItem];
            }
        }
        
        if (_channelCommentsItem.isOn != !conversation.channelIsReadOnly) {
            [_channelCommentsItem setIsOn:!conversation.channelIsReadOnly animated:true];
        }
        
        _channelAboutItem.variant = conversation.about;
        _channelLinkItem.variant = conversation.username.length == 0 ? @"" : [@"/" stringByAppendingString:conversation.username];
        
        bool forceReload = false;
        
        [self _updateConversationWithLoadedUsers:nil forceReload:forceReload];
        
        if (reloadData) {
            [self _setupSections:_editing];
        }
    });
}

- (void)_updateConversationWithLoadedUsers:(NSArray *)__unused participantUsers forceReload:(bool)__unused forceReload
{
}

- (void)_updateRelativeTimestamps
{
}

#pragma mark -

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"openUser"])
    {
        int32_t uid = [options[@"uid"] int32Value];
        if (uid != 0)
        {
            TGUser *user = [TGDatabaseInstance() loadUser:uid];
            if (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot)
            {
                TGBotUserInfoController *userInfoController = [[TGBotUserInfoController alloc] initWithUid:uid sendCommand:nil];
                [self.navigationController pushViewController:userInfoController animated:true];
            }
            else
            {
                TGTelegraphUserInfoController *userInfoController = [[TGTelegraphUserInfoController alloc] initWithUid:uid];
                [self.navigationController pushViewController:userInfoController animated:true];
            }
        }
    }
    else if ([action isEqualToString:@"editedTitleChanged"])
    {
        NSString *title = options[@"title"];
        
        if (_editing)
            self.navigationItem.rightBarButtonItem.enabled = title.length != 0;
    }
    else if ([action isEqualToString:@"openAvatar"])
    {
        if (_conversation.chatPhotoSmall.length == 0)
        {
            if (_setGroupPhotoItem.enabled)
                [self setGroupPhotoPressed];
        }
        else
        {
            TGRemoteImageView *avatarView = [_groupInfoItem avatarView];
            
            if (avatarView != nil && avatarView.image != nil)
            {
                TGModernGalleryController *modernGallery = [[TGModernGalleryController alloc] init];
                
                modernGallery.model = [[TGGroupAvatarGalleryModel alloc] initWithMessageId:0 legacyThumbnailUrl:_conversation.chatPhotoSmall legacyUrl:_conversation.chatPhotoBig imageSize:CGSizeMake(640.0f, 640.0f)];
                
                __weak TGChannelInfoController *weakSelf = self;
                
                modernGallery.itemFocused = ^(id<TGModernGalleryItem> item)
                {
                    __strong TGChannelInfoController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        if ([item isKindOfClass:[TGGroupAvatarGalleryItem class]])
                        {
                            ((UIView *)strongSelf->_groupInfoItem.avatarView).hidden = true;
                        }
                    }
                };
                
                modernGallery.beginTransitionIn = ^UIView *(id<TGModernGalleryItem> item, __unused TGModernGalleryItemView *itemView)
                {
                    __strong TGChannelInfoController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        if ([item isKindOfClass:[TGGroupAvatarGalleryItem class]])
                        {
                            return strongSelf->_groupInfoItem.avatarView;
                        }
                    }
                    
                    return nil;
                };
                
                modernGallery.beginTransitionOut = ^UIView *(id<TGModernGalleryItem> item)
                {
                    __strong TGChannelInfoController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        if ([item isKindOfClass:[TGGroupAvatarGalleryItem class]])
                        {
                            return strongSelf->_groupInfoItem.avatarView;
                        }
                    }
                    
                    return nil;
                };
                
                modernGallery.completedTransitionOut = ^
                {
                    __strong TGChannelInfoController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        ((UIView *)strongSelf->_groupInfoItem.avatarView).hidden = false;
                    }
                };
                
                TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithParentController:self contentController:modernGallery];
                controllerWindow.hidden = false;
            }
        }
    }
    else if ([action isEqualToString:@"showUpdatingAvatarOptions"])
    {
        [[[TGActionSheet alloc] initWithTitle:nil actions:@[
                                                            [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"GroupInfo.SetGroupPhotoStop") action:@"stop" type:TGActionSheetActionTypeDestructive],
                                                            [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
                                                            ] actionBlock:^(TGChannelInfoController *controller, NSString *action)
          {
              if ([action isEqualToString:@"stop"])
                  [controller _commitCancelAvatarUpdate];
          } target:self] showInView:self.view];
    }
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _peerId]])
    {
        TGConversation *conversation = ((SGraphObjectNode *)resource).object;
        
        if (conversation != nil) {
            [self _loadUsersAndUpdateConversation:conversation];
        }
    }
    else if ([path hasPrefix:@"/tg/peerSettings/"])
    {
        [self actorCompleted:ASStatusSuccess path:path result:resource];
    }
    else if ([path isEqualToString:@"/as/updateRelativeTimestamps"])
    {
        TGDispatchOnMainThread(^
                               {
                                   [self _updateRelativeTimestamps];
                               });
    }
    else if ([path isEqualToString:@"/tg/userdatachanges"] || [path isEqualToString:@"/tg/userpresencechanges"])
    {
        //NSArray *users = ((SGraphObjectNode *)resource).object;
        
        TGDispatchOnMainThread(^
                               {
                                   //[self _updateUsers:users];
                               });
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/sharedMediaCount/(%" PRIx64 ")", (int64_t)_peerId]])
    {
        TGDispatchOnMainThread(^
                               {
                                   _sharedMediaCount = [resource intValue];
                                   [self _updateSharedMediaCount];
                               });
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/tg/peerSettings/"])
    {
        if (status == ASStatusSuccess)
        {
            NSDictionary *notificationSettings = ((SGraphObjectNode *)result).object;
            
            TGDispatchOnMainThread(^
                                   {
                                       _groupNotificationSettings = [notificationSettings mutableCopy];
                                       [self _updateNotificationItems:false];
                                   });
        }
    }
    else if ([path hasPrefix:[[NSString alloc] initWithFormat:@"/tg/conversation/(%" PRId64 ")/changeTitle/", _conversation.conversationId]])
    {
        TGDispatchOnMainThread(^
                               {
                                   [_groupInfoItem setUpdatingTitle:nil];
                                   
                                   if (status == ASStatusSuccess)
                                   {
                                       TGConversation *resultConversation = ((SGraphObjectNode *)result).object;
                                       
                                       TGConversation *updatedConversation = [_conversation copy];
                                       updatedConversation.chatTitle = resultConversation.chatTitle;
                                       _conversation = updatedConversation;
                                       
                                       [_groupInfoItem setConversation:_conversation];
                                   }
                               });
    }
    else if ([path hasPrefix:[[NSString alloc] initWithFormat:@"/tg/conversation/(%" PRId64 ")/updateAvatar/", _conversation.conversationId]])
    {
        TGDispatchOnMainThread(^
                               {
                                   if (status == ASStatusSuccess)
                                   {
                                       TGConversation *resultConversation = ((SGraphObjectNode *)result).object;
                                       
                                       TGConversation *updatedConversation = [_conversation copy];
                                       updatedConversation.chatPhotoSmall = resultConversation.chatPhotoSmall;
                                       updatedConversation.chatPhotoMedium = resultConversation.chatPhotoMedium;
                                       updatedConversation.chatPhotoBig = resultConversation.chatPhotoBig;
                                       _conversation = updatedConversation;
                                       
                                       [_groupInfoItem copyUpdatingAvatarToCacheWithUri:_conversation.chatPhotoSmall];
                                       [_groupInfoItem setConversation:_conversation];
                                       
                                       [_groupInfoItem setUpdatingAvatar:nil hasUpdatingAvatar:false];
                                       [_setGroupPhotoItem setEnabled:true];
                                   }
                                   else
                                   {
                                       [_groupInfoItem setUpdatingAvatar:nil hasUpdatingAvatar:false];
                                       [_setGroupPhotoItem setEnabled:true];
                                   }
                               });
    }
}

- (void)aboutPressed {
    TGChannelAboutSetupController *aboutController = [[TGChannelAboutSetupController alloc] initWithConversation:_conversation];
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[aboutController]];
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)linkPressed {
    TGChannelLinkSetupController *linkController = [[TGChannelLinkSetupController alloc] initWithConversation:_conversation];
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[linkController]];
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)sharePressed {
    if (_conversation.username.length != 0) {
        NSArray *dataToShare = @[[NSURL URLWithString:[@"https://telegram.me/" stringByAppendingString:_conversation.username]]];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
        [self presentViewController:activityViewController animated:YES completion:nil];
    } else {
        __weak TGChannelInfoController *weakSelf = self;
        [[[TGAlertView alloc] initWithTitle:TGLocalized(@"Channel.ShareNoLink") message:nil cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:^(__unused bool okButtonPressed) {
            __strong TGChannelInfoController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf linkPressed];
            }
        }] show];
    }
}

- (void)leavePressed {
    __weak typeof(self) weakSelf = self;
    
    [[[TGActionSheet alloc] initWithTitle:nil actions:@[
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"ChannelInfo.ConfirmLeave") action:@"leave" type:TGActionSheetActionTypeDestructive],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
        ] actionBlock:^(__unused id target, NSString *action)
    {
        if ([action isEqualToString:@"leave"])
        {
            TGChannelInfoController *strongSelf = weakSelf;
            [strongSelf _commitLeaveChannel];
        }
    } target:self] showInView:self.view];
}

- (void)_commitLeaveChannel
{
    [TGAppDelegateInstance.rootController.dialogListController.dialogListCompanion deleteItem:[[TGConversation alloc] initWithConversationId:_peerId unreadCount:0 serviceUnreadCount:0] animated:false];
    
    if (self.popoverController != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self.popoverController dismissPopoverAnimated:true];
        });
    }
    else
        [self.navigationController popToRootViewControllerAnimated:true];
}

- (void)_commitDeleteChannel
{
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow show:true];
    
    [[[[TGChannelManagementSignals deleteChannel:_conversation.conversationId accessHash:_conversation.accessHash] deliverOn:[SQueue mainQueue]] onDispose:^{
        TGDispatchOnMainThread(^{
            [progressWindow dismiss:true];
        });
    }] startWithNext:nil completed:^{
        [TGAppDelegateInstance.rootController.dialogListController.dialogListCompanion deleteItem:[[TGConversation alloc] initWithConversationId:_peerId unreadCount:0 serviceUnreadCount:0] animated:false];
        
        if (self.popoverController != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self.popoverController dismissPopoverAnimated:true];
            });
        }
        else
            [self.navigationController popToRootViewControllerAnimated:true];
    }];
}

- (void)toggleCommentsEnabled:(bool)value {
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow show:true];
    
    __weak TGChannelInfoController *weakSelf = self;
    [[[[TGChannelManagementSignals toggleChannelCommentsEnabled:_conversation.conversationId accessHash:_conversation.accessHash enabled:value] deliverOn:[SQueue mainQueue]] onDispose:^{
        TGDispatchOnMainThread(^{
            [progressWindow dismiss:true];
        });
    }] startWithNext:nil error:^(__unused id error) {
        __strong TGChannelInfoController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf->_channelCommentsItem setIsOn:!value animated:true];
        }
    } completed:^{
        __strong TGChannelInfoController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf->_channelCommentsItem setIsOn:value animated:true];
        }
    }];
}

- (void)infoManagementPressed {
    [self.navigationController pushViewController:[[TGChannelMembersController alloc] initWithConversation:_conversation mode:TGChannelMembersModeAdmins] animated:true];
}

- (void)infoBlacklistPressed {
    [self.navigationController pushViewController:[[TGChannelMembersController alloc] initWithConversation:_conversation mode:TGChannelMembersModeBlacklist] animated:true];
}

- (void)infoMembersPressed {
    [self.navigationController pushViewController:[[TGChannelMembersController alloc] initWithConversation:_conversation mode:TGChannelMembersModeMembers] animated:true];
}

- (void)sharedMediaPressed {
    [self.navigationController pushViewController:[[TGSharedMediaController alloc] initWithPeerId:_peerId accessHash:_conversation.accessHash important:true] animated:true];
}

- (void)deleteChannelPressed {
    __weak typeof(self) weakSelf = self;
    
    [[[TGActionSheet alloc] initWithTitle:TGLocalized(@"ChannelInfo.DeleteChannelConfirmation") actions:@[
                                                        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"ChannelInfo.DeleteChannel") action:@"leave" type:TGActionSheetActionTypeDestructive],
                                                        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
                                                        ] actionBlock:^(__unused id target, NSString *action)
    {
        if ([action isEqualToString:@"leave"])
        {
            TGChannelInfoController *strongSelf = weakSelf;
            [strongSelf _commitDeleteChannel];
        }
    } target:self] showInView:self.view];
}

@end
