/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGNotificationSettingsController.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGAppDelegate.h"
#import "TGTelegraph.h"

#import "TGHeaderCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGVariantCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGActionSheet.h"

#import "TGAlertSoundController.h"

@interface TGNotificationSettingsController () <TGAlertSoundControllerDelegate>
{
    TGSwitchCollectionItem *_privateAlert;
    TGSwitchCollectionItem *_privatePreview;
    TGVariantCollectionItem *_privateSound;
    
    TGSwitchCollectionItem *_groupAlert;
    TGSwitchCollectionItem *_groupPreview;
    TGVariantCollectionItem *_groupSound;
    
    TGSwitchCollectionItem *_inAppSounds;
    TGSwitchCollectionItem *_inAppVibrate;
    TGSwitchCollectionItem *_inAppPreview;
    
    NSMutableDictionary *_privateNotificationSettings;
    NSMutableDictionary *_groupNotificationSettings;
    
    bool _selectingPrivateSound;
}

@end

@implementation TGNotificationSettingsController

- (id)init
{
    self = [super init];
    if (self)
    {
        _privateNotificationSettings = [[NSMutableDictionary alloc] initWithDictionary:@{@"muteUntil": @(0), @"soundId": @(1), @"previewText": @(true)}];
        _groupNotificationSettings = [[NSMutableDictionary alloc] initWithDictionary:@{@"muteUntil": @(0), @"soundId": @(1), @"previewText": @(true)}];
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        [self setTitleText:TGLocalized(@"Notifications.Title")];
        
        _privateAlert = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Notifications.MessageNotificationsAlert") isOn:true];
        _privateAlert.interfaceHandle = _actionHandle;
        _privatePreview = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Notifications.MessageNotificationsPreview") isOn:true];
        _privatePreview.interfaceHandle = _actionHandle;
        
        NSString *currentPrivateSound = [TGAppDelegateInstance modernAlertSoundTitles][1];
        NSString *currentGroupSound = [TGAppDelegateInstance modernAlertSoundTitles][1];
        
        _privateSound = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Notifications.MessageNotificationsSound") variant:currentPrivateSound action:@selector(privateSoundPressed)];
        _privateSound.deselectAutomatically = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
        
        TGCollectionMenuSection *messageNotificationsSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Notifications.MessageNotifications")],
            _privateAlert,
            _privatePreview,
            _privateSound,
            [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"Notifications.MessageNotificationsHelp")]
        ]];
        UIEdgeInsets topSectionInsets = messageNotificationsSection.insets;
        topSectionInsets.top = 32.0f;
        messageNotificationsSection.insets = topSectionInsets;
        [self.menuSections addSection:messageNotificationsSection];
        
        _groupSound = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Notifications.MessageNotificationsSound") variant:currentGroupSound action:@selector(groupSoundPressed)];
        _groupSound.deselectAutomatically = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
        
        _groupAlert = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Notifications.GroupNotificationsAlert") isOn:true];
        _groupAlert.interfaceHandle = _actionHandle;
        _groupPreview = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Notifications.GroupNotificationsPreview") isOn:true];
        _groupPreview.interfaceHandle = _actionHandle;
        
        TGCollectionMenuSection *groupNotificationsSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Notifications.GroupNotifications")],
            _groupAlert,
            _groupPreview,
            _groupSound,
            [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"Notifications.GroupNotificationsHelp")]
        ]];
        [self.menuSections addSection:groupNotificationsSection];
        
        _inAppSounds = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Notifications.InAppNotificationsSounds") isOn:TGAppDelegateInstance.soundEnabled];
        _inAppSounds.interfaceHandle = _actionHandle;
        _inAppVibrate = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Notifications.InAppNotificationsVibrate") isOn:TGAppDelegateInstance.vibrationEnabled];
        _inAppVibrate.interfaceHandle = _actionHandle;
        _inAppPreview = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Notifications.InAppNotificationsPreview") isOn:TGAppDelegateInstance.bannerEnabled];
        _inAppPreview.interfaceHandle = _actionHandle;
        
        NSMutableArray *inAppNotificationsSectionItems = [[NSMutableArray alloc] init];
        
        [inAppNotificationsSectionItems addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Notifications.InAppNotifications")]];
        [inAppNotificationsSectionItems addObject:_inAppSounds];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            [inAppNotificationsSectionItems addObject:_inAppVibrate];
            [inAppNotificationsSectionItems addObject:_inAppPreview];
        }
        
        TGCollectionMenuSection *inAppNotificationsSection = [[TGCollectionMenuSection alloc] initWithItems:inAppNotificationsSectionItems];
        [self.menuSections addSection:inAppNotificationsSection];

        TGButtonCollectionItem *resetItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Notifications.ResetAllNotifications") action:@selector(resetAllNotifications)];
        resetItem.titleColor = TGDestructiveAccentColor();
        resetItem.deselectAutomatically = true;
        TGCollectionMenuSection *resetSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            resetItem,
            [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"Notifications.ResetAllNotificationsHelp")],
        ]];
        [self.menuSections addSection:resetSection];
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            [ActionStageInstance() watchForPaths:@[
                [NSString stringWithFormat:@"/tg/peerSettings/(%d)", INT_MAX - 1],
                [NSString stringWithFormat:@"/tg/peerSettings/(%d)", INT_MAX - 2]
            ] watcher:self];
            
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/peerSettings/(%d,cached)", INT_MAX - 1] options:[NSDictionary dictionaryWithObject:[NSNumber numberWithLongLong:INT_MAX - 1] forKey:@"peerId"] watcher:self];
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/peerSettings/(%d,cached)", INT_MAX - 2] options:[NSDictionary dictionaryWithObject:[NSNumber numberWithLongLong:INT_MAX - 2] forKey:@"peerId"] watcher:self];
        }];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

#pragma mark -

- (void)resetAllNotifications
{
    [[[TGActionSheet alloc] initWithTitle:TGLocalized(@"Notifications.ResetAllNotificationsHelp") actions:@[
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Notifications.Reset") action:@"reset" type:TGActionSheetActionTypeDestructive],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
    ] actionBlock:^(TGNotificationSettingsController *controller, NSString *action)
    {
        if ([action isEqualToString:@"reset"])
        {
            [controller _commitResetAllNotitications];
        }
    } target:self] showInView:self.view];
}

- (void)_commitResetAllNotitications
{
    TGAppDelegateInstance.soundEnabled = true;
    TGAppDelegateInstance.vibrationEnabled = false;
    TGAppDelegateInstance.bannerEnabled = true;
    [TGAppDelegateInstance saveSettings];
    
    _privateNotificationSettings = [[NSMutableDictionary alloc] initWithDictionary:@{@"muteUntil": @(0), @"soundId": @(1), @"previewText": @(true)}];
    _groupNotificationSettings = [[NSMutableDictionary alloc] initWithDictionary:@{@"muteUntil": @(0), @"soundId": @(1), @"previewText": @(true)}];
    
    [self _updateItems:true];
    
    [ActionStageInstance() requestActor:@"/tg/resetPeerSettings" options:nil watcher:TGTelegraphInstance];
}

- (NSArray *)_soundInfoListForSelectedSoundId:(int)selectedSoundId
{
    NSMutableArray *infoList = [[NSMutableArray alloc] init];
    
    int index = -1;
    for (NSString *soundName in [TGAppDelegateInstance modernAlertSoundTitles])
    {
        index++;
        
        if (index == 1)
            continue;
        
        int soundId = 0;
        if (index == 0)
            soundId = 0;
        else
            soundId = index + 100 - 2;
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[@"title"] = soundName;
        dict[@"selected"] = @(selectedSoundId == soundId);
        dict[@"soundName"] =  [[NSString alloc] initWithFormat:@"%d", soundId];
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

- (void)privateSoundPressed
{
    _selectingPrivateSound = true;
    TGAlertSoundController *alertSoundController = [[TGAlertSoundController alloc] initWithTitle:TGLocalized(@"Notifications.TextTone") soundInfoList:[self _soundInfoListForSelectedSoundId:[_privateNotificationSettings[@"soundId"] intValue]]];
    alertSoundController.delegate = self;
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[alertSoundController]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)groupSoundPressed
{
    _selectingPrivateSound = false;
    TGAlertSoundController *alertSoundController = [[TGAlertSoundController alloc] initWithTitle:TGLocalized(@"Notifications.TextTone") soundInfoList:[self _soundInfoListForSelectedSoundId:[_groupNotificationSettings[@"soundId"] intValue]]];
    alertSoundController.delegate = self;
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[alertSoundController]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)alertSoundController:(TGAlertSoundController *)__unused alertSoundController didFinishPickingWithSoundInfo:(NSDictionary *)soundInfo
{
    int soundId = [soundInfo[@"soundId"] intValue];
    
    if (soundId >= 0)
    {
        if ((_selectingPrivateSound && [_privateNotificationSettings[@"soundId"] intValue] != soundId) || (!_selectingPrivateSound && [_groupNotificationSettings[@"soundId"] intValue] != soundId))
        {
            int64_t peerId = 0;
            
            if (_selectingPrivateSound)
            {
                peerId = INT_MAX - 1;
                _privateNotificationSettings[@"soundId"] = @(soundId);
            }
            else
            {
                peerId = INT_MAX - 2;
                _groupNotificationSettings[@"soundId"] = @(soundId);
            }
            
            [self _updateItems:false];
            
            static int actionId = 0;
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%" PRId64 ")/(pc%d)", peerId, actionId++] options:@{
                @"peerId": @(peerId),
                @"soundId": @(soundId)
            } watcher:TGTelegraphInstance];
        }
    }
}

#pragma mark -

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

- (void)_updateItems:(bool)animated
{
    [_privateAlert setIsOn:[[_privateNotificationSettings objectForKey:@"muteUntil"] intValue] == 0 animated:animated];
    [_privatePreview setIsOn:[[_privateNotificationSettings objectForKey:@"previewText"] boolValue] animated:animated];
    
    int privateSoundId = [[_privateNotificationSettings objectForKey:@"soundId"] intValue];
    if (privateSoundId == 1)
        privateSoundId = 100;
    
    _privateSound.variant = [self soundNameFromId:privateSoundId];
    
    [_groupAlert setIsOn:[[_groupNotificationSettings objectForKey:@"muteUntil"] intValue] == 0 animated:animated];
    [_groupPreview setIsOn:[[_groupNotificationSettings objectForKey:@"previewText"] boolValue] animated:animated];
    
    int groupSoundId = [[_groupNotificationSettings objectForKey:@"soundId"] intValue];
    if (groupSoundId == 1)
        groupSoundId = 100;
    
    _groupSound.variant = [self soundNameFromId:groupSoundId];
    
    [_inAppSounds setIsOn:TGAppDelegateInstance.soundEnabled animated:animated];
    [_inAppVibrate setIsOn:TGAppDelegateInstance.vibrationEnabled animated:animated];
    [_inAppPreview setIsOn:TGAppDelegateInstance.bannerEnabled animated:animated];
}

#pragma mark -

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"switchItemChanged"])
    {
        TGSwitchCollectionItem *switchItem = options[@"item"];
        
        if (switchItem == _privateAlert)
        {
            int muteUntil = switchItem.isOn ? 0 : INT_MAX;
            _privateNotificationSettings[@"muteUntil"] = @(muteUntil);
            
            static int actionId = 0;
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%d)/(pc%d)", INT_MAX - 1, actionId++] options:@{
                @"peerId": @(INT_MAX - 1),
                @"muteUntil": @(muteUntil)
            } watcher:TGTelegraphInstance];
        }
        else if (switchItem == _privatePreview)
        {
            bool previewText = switchItem.isOn;
            _privateNotificationSettings[@"previewText"] = @(previewText);
            
            static int actionId = 0;
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%d)/(pc%d)", INT_MAX - 1, actionId++] options:@{
                @"peerId": @(INT_MAX - 1),
                @"previewText": @(previewText)
            } watcher:TGTelegraphInstance];
        }
        else if (switchItem == _groupAlert)
        {
            int muteUntil = switchItem.isOn ? 0 : INT_MAX;
            _groupNotificationSettings[@"muteUntil"] = @(muteUntil);

            static int actionId = 0;
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%d)/(pc%d)", INT_MAX - 2, actionId++] options:@{
                @"peerId": @(INT_MAX - 2),
                @"muteUntil": @(muteUntil)
            } watcher:TGTelegraphInstance];
        }
        else if (switchItem == _groupPreview)
        {
            bool previewText = switchItem.isOn;
            _groupNotificationSettings[@"previewText"] = @(previewText);

            static int actionId = 0;
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%d)/(pc%d)", INT_MAX - 2, actionId++] options:@{
                @"peerId": @(INT_MAX - 2),
                @"previewText": @(previewText)
            } watcher:TGTelegraphInstance];
        }
        else if (switchItem == _inAppSounds)
        {
            TGAppDelegateInstance.soundEnabled = switchItem.isOn;
            [TGAppDelegateInstance saveSettings];
        }
        else if (switchItem == _inAppVibrate)
        {
            TGAppDelegateInstance.vibrationEnabled = switchItem.isOn;
            [TGAppDelegateInstance saveSettings];
        }
        if (switchItem == _inAppPreview)
        {
            TGAppDelegateInstance.bannerEnabled = switchItem.isOn;
            [TGAppDelegateInstance saveSettings];
        }
    }
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path hasPrefix:@"/tg/peerSettings"])
    {
        [self actorCompleted:ASStatusSuccess path:path result:resource];
    }
}

- (void)actorCompleted:(int)resultCode path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/tg/peerSettings/"])
    {
        if (resultCode == ASStatusSuccess)
        {
            NSDictionary *notificationSettings = ((SGraphObjectNode *)result).object;
            
            TGDispatchOnMainThread(^
            {
                if ([path hasPrefix:[NSString stringWithFormat:@"/tg/peerSettings/(%d", INT_MAX - 1]])
                {
                    _privateNotificationSettings = [notificationSettings mutableCopy];
                    [self _updateItems:false];
                }
                else if ([path hasPrefix:[NSString stringWithFormat:@"/tg/peerSettings/(%d", INT_MAX - 2]])
                {
                    _groupNotificationSettings = [notificationSettings mutableCopy];
                    [self _updateItems:false];
                }
            });
        }
    }
}

@end
