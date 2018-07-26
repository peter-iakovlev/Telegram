/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGChatSettingsController.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGHeaderCollectionItem.h"
#import "TGVariantCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGDisclosureActionCollectionItem.h"

#import "TGTextSizeController.h"

#import "TGTelegraphConversationMessageAssetsSource.h"
#import "TGAppDelegate.h"
#import <LegacyComponents/ActionStage.h>

#import <LegacyComponents/TGProgressWindow.h>
#import "TGLegacyComponentsContext.h"
#import "TGAlertView.h"

#import "TGCacheController.h"

#import "TGStickerPacksSettingsController.h"

#import "TGNetworkUsageController.h"
#import "TGCallDataSettingsController.h"

#import "TGUsernameCollectionItem.h"

#import "TGProxySetupController.h"
#import "TGAutoDownloadSettingsController.h"

#import <MTProtoKit/MTProtoKit.h>
#import "TGTelegramNetworking.h"

#import "TGCustomActionSheet.h"

#import "TGDatabase.h"

@interface TGChatSettingsController () <TGTextSizeControllerDelegate>
{
    TGVariantCollectionItem *_textSizeItem;
    
    TGSwitchCollectionItem *_autoDownloadEnabledItem;
    TGVariantCollectionItem *_autoDownloadPhotosItem;
    TGVariantCollectionItem *_autoDownloadVideosItem;
    TGVariantCollectionItem *_autoDownloadDocumentsItem;
    TGVariantCollectionItem *_autoDownloadVoiceMessagesItem;
    TGVariantCollectionItem *_autoDownloadVideoMessagesItem;
    TGButtonCollectionItem *_autoDownloadResetItem;
    
    TGVariantCollectionItem *_autosavePhotosItem;
    TGSwitchCollectionItem *_saveEditedPhotosItem;
    TGSwitchCollectionItem *_autoPlayAnimationsItem;
    TGVariantCollectionItem *_useLessDataItem;
    
    TGVariantCollectionItem *_useProxyItem;
    
    TGProgressWindow *_progressWindow;
    
    MTSocksProxySettings *_proxySettings;
}

@end

@implementation TGChatSettingsController

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        [self setTitleText:TGLocalized(@"ChatSettings.Title")];
        
        _textSizeItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.TextSize") variant:[[NSString alloc] initWithFormat:@"%d%@", TGBaseFontSize, TGLocalized(@"ChatSettings.TextSizeUnits")] action:@selector(textSizePressed)];
        
        _autosavePhotosItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.SaveIncomingPhotos") action:@selector(autosavePhotosPressed)];
        
        _saveEditedPhotosItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.SaveEditedPhotos") isOn:TGAppDelegateInstance.saveEditedPhotos];
        _saveEditedPhotosItem.interfaceHandle = _actionHandle;
        
        _autoPlayAnimationsItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.AutoPlayAnimations") isOn:TGAppDelegateInstance.autoPlayAnimations];
        _autoPlayAnimationsItem.interfaceHandle = _actionHandle;
        
        TGDisclosureActionCollectionItem *cacheItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Cache.Title") action:@selector(cachePressed)];
        
        TGDisclosureActionCollectionItem *networkItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.Title") action:@selector(networkPressed)];
        
        TGCollectionMenuSection *usageSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            cacheItem,
            networkItem
        ]];
        if (iosMajorVersion() >= 7 || [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            UIEdgeInsets topSectionInsets = usageSection.insets;
            topSectionInsets.top = 32.0f;
            usageSection.insets = topSectionInsets;
        }
        [self.menuSections addSection:usageSection];
        
        _autoDownloadEnabledItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.AutoDownloadEnabled") isOn:!TGAppDelegateInstance.autoDownloadPreferences.disabled];
        _autoDownloadEnabledItem.interfaceHandle = _actionHandle;
        
        _autoDownloadPhotosItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.AutoDownloadPhotos") action:@selector(autoDownloadPhotosPressed)];
        _autoDownloadPhotosItem.enabled = _autoDownloadEnabledItem.isOn;
        _autoDownloadVideosItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.AutoDownloadVideos") action:@selector(autoDownloadVideosPressed)];
        _autoDownloadVideosItem.enabled = _autoDownloadEnabledItem.isOn;
        _autoDownloadDocumentsItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.AutoDownloadDocuments") action:@selector(autoDownloadDocumentsPressed)];
        _autoDownloadDocumentsItem.enabled = _autoDownloadEnabledItem.isOn;
        _autoDownloadVoiceMessagesItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.AutoDownloadVoiceMessages") action:@selector(autoDownloadVoiceMessagesPressed)];
        _autoDownloadVoiceMessagesItem.enabled = _autoDownloadEnabledItem.isOn;
        _autoDownloadVideoMessagesItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.AutoDownloadVideoMessages") action:@selector(autoDownloadVideoMessagesPressed)];
        _autoDownloadVideoMessagesItem.enabled = _autoDownloadEnabledItem.isOn;
        _autoDownloadResetItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.AutoDownloadReset") action:@selector(autoDownloadResetPressed)];
        _autoDownloadResetItem.enabled = !TGAppDelegateInstance.autoDownloadPreferences.isDefaultPreferences;
        _autoDownloadResetItem.deselectAutomatically = true;
        
        TGCollectionMenuSection *autoDownloadSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.AutoDownloadTitle")],
            _autoDownloadEnabledItem,
            _autoDownloadPhotosItem,
            _autoDownloadVideosItem,
            _autoDownloadDocumentsItem,
            _autoDownloadVoiceMessagesItem,
            _autoDownloadVideoMessagesItem,
            _autoDownloadResetItem
        ]];
        [self.menuSections addSection:autoDownloadSection];
        
        _useLessDataItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"CallSettings.UseLessData") action:@selector(useLessDataPressed)];
        _useLessDataItem.variant = [self labelForCallDataMode:TGAppDelegateInstance.callsDataUsageMode];
        
        TGCollectionMenuSection *callsSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:[TGLocalized(@"Settings.CallSettings") uppercaseString]],
            _useLessDataItem
        ]];
        [self.menuSections addSection:callsSection];
        
        TGCollectionMenuSection *otherSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.Other")],
            _autosavePhotosItem,
            _saveEditedPhotosItem,
            _autoPlayAnimationsItem
        ]];
        [self.menuSections addSection:otherSection];
        
        _proxySettings = [[TGTelegramNetworking instance] context].apiEnvironment.socksProxySettings;
        NSString *proxyType = TGLocalized(@"GroupInfo.SharedMediaNone");
        if (_proxySettings != nil)
        {
            if (_proxySettings.secret != nil)
                proxyType = TGLocalized(@"SocksProxySetup.ProxyTelegram");
            else
                proxyType = TGLocalized(@"SocksProxySetup.ProxySocks5");
        }
        _useProxyItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.ConnectionType.UseProxy") variant:proxyType action:@selector(useProxyPressed)];
        _useProxyItem.deselectAutomatically = true;
        TGCollectionMenuSection *proxySection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.ConnectionType.Title")],
            _useProxyItem
        ]];
        [self.menuSections addSection:proxySection];
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Back") style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

#pragma mark -

- (void)backPressed
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)textSizePressed
{
    TGTextSizeController *textSizeController = [[TGTextSizeController alloc] initWithTextSize:(int)TGBaseFontSize];
    textSizeController.delegate = self;
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[textSizeController]];
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)textSizeController:(TGTextSizeController *)__unused textSizeController didFinishPickingWithTextSize:(int)textSize
{
    TGBaseFontSize = textSize;
    _textSizeItem.variant = [[NSString alloc] initWithFormat:@"%d%@", TGBaseFontSize, TGLocalized(@"ChatSettings.TextSizeUnits")];
    [TGAppDelegateInstance saveSettings];
}

#pragma mark -

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"switchItemChanged"])
    {
        TGSwitchCollectionItem *switchItem = options[@"item"];
        
        if (switchItem == _saveEditedPhotosItem)
        {
            TGAppDelegateInstance.saveEditedPhotos = switchItem.isOn;
            [TGAppDelegateInstance saveSettings];
        }
        else if (switchItem == _autoPlayAnimationsItem)
        {
            TGAppDelegateInstance.autoPlayAnimations = switchItem.isOn;
            [TGAppDelegateInstance saveSettings];
        }
        else if (switchItem == _autoDownloadEnabledItem)
        {
            TGAppDelegateInstance.autoDownloadPreferences = [TGAppDelegateInstance.autoDownloadPreferences updateDisabled:!_autoDownloadEnabledItem.isOn];
            _autoDownloadPhotosItem.enabled = _autoDownloadEnabledItem.isOn;
            _autoDownloadVideosItem.enabled = _autoDownloadEnabledItem.isOn;
            _autoDownloadDocumentsItem.enabled = _autoDownloadEnabledItem.isOn;
            _autoDownloadVoiceMessagesItem.enabled = _autoDownloadEnabledItem.isOn;
            _autoDownloadVideoMessagesItem.enabled = _autoDownloadEnabledItem.isOn;
            
            _autoDownloadResetItem.enabled = !TGAppDelegateInstance.autoDownloadPreferences.isDefaultPreferences;
        }
    }
}

- (void)actorCompleted:(int)__unused status path:(NSString *)__unused path result:(id)__unused result
{
}

- (void)stickersPressed
{
    TGStickerPacksSettingsController *controller = [[TGStickerPacksSettingsController alloc] init];
    [self.navigationController pushViewController:controller animated:true];
}

- (void)cachePressed
{
    TGCacheController *cacheController = [[TGCacheController alloc] init];
    [self.navigationController pushViewController:cacheController animated:true];
}

- (void)networkPressed {
    [self.navigationController pushViewController:[[TGNetworkUsageController alloc] init] animated:true];
}

- (void)useLessDataPressed
{
    __weak TGChatSettingsController *weakSelf = self;
    TGCallDataSettingsController *controller = [[TGCallDataSettingsController alloc] init];
    controller.onModeChanged = ^(int mode)
    {
        __strong TGChatSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil)
            strongSelf->_useLessDataItem.variant = [strongSelf labelForCallDataMode:mode];
    };
    [self.navigationController pushViewController:controller animated:true];
}

- (NSString *)labelForCallDataMode:(int)dataMode
{
    switch (dataMode)
    {
        case 1:
            return TGLocalized(@"CallSettings.OnMobile");
            
        case 2:
            return TGLocalized(@"CallSettings.Always");
            
        default:
            return TGLocalized(@"CallSettings.Never");
    }
}

- (void)autoDownloadPhotosPressed {
    TGAutoDownloadSettingsController *controller = [[TGAutoDownloadSettingsController alloc] initWithMode:TGAutoDownloadSettingsModePhotos];
    __weak TGChatSettingsController *weakSelf = self;
    controller.settingsUpdated = ^{
        __strong TGChatSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf updateAutoDownloadReset];
    };
    [self.navigationController pushViewController:controller animated:true];
}

- (void)autoDownloadVideosPressed {
    TGAutoDownloadSettingsController *controller = [[TGAutoDownloadSettingsController alloc] initWithMode:TGAutoDownloadSettingsModeVideos];
    __weak TGChatSettingsController *weakSelf = self;
    controller.settingsUpdated = ^{
        __strong TGChatSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf updateAutoDownloadReset];
    };
    [self.navigationController pushViewController:controller animated:true];
}

- (void)autoDownloadDocumentsPressed {
    TGAutoDownloadSettingsController *controller = [[TGAutoDownloadSettingsController alloc] initWithMode:TGAutoDownloadSettingsModeDocuments];
    __weak TGChatSettingsController *weakSelf = self;
    controller.settingsUpdated = ^{
        __strong TGChatSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf updateAutoDownloadReset];
    };
    [self.navigationController pushViewController:controller animated:true];
}

- (void)autoDownloadVoiceMessagesPressed {
    TGAutoDownloadSettingsController *controller = [[TGAutoDownloadSettingsController alloc] initWithMode:TGAutoDownloadSettingsModeVoiceMessages];
    __weak TGChatSettingsController *weakSelf = self;
    controller.settingsUpdated = ^{
        __strong TGChatSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf updateAutoDownloadReset];
    };
    [self.navigationController pushViewController:controller animated:true];
}

- (void)autoDownloadVideoMessagesPressed {
    TGAutoDownloadSettingsController *controller = [[TGAutoDownloadSettingsController alloc] initWithMode:TGAutoDownloadSettingsModeVideoMessages];
    __weak TGChatSettingsController *weakSelf = self;
    controller.settingsUpdated = ^{
        __strong TGChatSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf updateAutoDownloadReset];
    };
    [self.navigationController pushViewController:controller animated:true];
}

- (void)autoDownloadResetPressed {
    
    __weak TGChatSettingsController *weakSelf = self;
    [[[TGCustomActionSheet alloc] initWithTitle:TGLocalized(@"AutoDownloadSettings.ResetHelp") actions:@[
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"AutoDownloadSettings.Reset") action:@"reset" type:TGActionSheetActionTypeDestructive],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
    ] actionBlock:^(__unused id target, NSString *action) {
        __strong TGChatSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil && [action isEqualToString:@"reset"])
        {
            TGAppDelegateInstance.autoDownloadPreferences = [TGAutoDownloadPreferences defaultPreferences];
            strongSelf->_autoDownloadEnabledItem.isOn = true;
            strongSelf->_autoDownloadPhotosItem.enabled = true;
            strongSelf->_autoDownloadVideosItem.enabled = true;
            strongSelf->_autoDownloadDocumentsItem.enabled = true;
            strongSelf->_autoDownloadVoiceMessagesItem.enabled = true;
            strongSelf->_autoDownloadVideoMessagesItem.enabled = true;
            strongSelf->_autoDownloadResetItem.enabled = false;
        }
    } target:self] showInView:self.view];
}

- (void)updateAutoDownloadReset {
    _autoDownloadResetItem.enabled = !TGAppDelegateInstance.autoDownloadPreferences.isDefaultPreferences;
}

- (void)autosavePhotosPressed {
    [self.navigationController pushViewController:[[TGAutoDownloadSettingsController alloc] initWithMode:TGAutoDownloadSettingsModeSaveIncomingPhotos] animated:true];
}

- (void)useProxyPressed {
    TGProxySetupController *controller = [[TGProxySetupController alloc] init];
    __weak TGChatSettingsController *weakSelf = self;
    controller.completion = ^(MTSocksProxySettings *updatedSettings, bool inactive) {
        __strong TGChatSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            strongSelf->_proxySettings = inactive ? nil : updatedSettings;
            
            NSString *proxyType = TGLocalized(@"GroupInfo.SharedMediaNone");
            if (strongSelf->_proxySettings != nil)
            {
                if (_proxySettings.secret != nil)
                    proxyType = TGLocalized(@"SocksProxySetup.ProxyTelegram");
                else
                    proxyType = TGLocalized(@"SocksProxySetup.ProxySocks5");
            }
            
            strongSelf->_useProxyItem.variant = proxyType;
        }
    };
    
    [self.navigationController pushViewController:controller animated:true];
}

@end
