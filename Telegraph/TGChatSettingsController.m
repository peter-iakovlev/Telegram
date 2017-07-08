/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGChatSettingsController.h"

#import "TGHeaderCollectionItem.h"
#import "TGVariantCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGDisclosureActionCollectionItem.h"

#import "TGTextSizeController.h"

#import "TGTelegraphConversationMessageAssetsSource.h"
#import "TGAppDelegate.h"
#import "ActionStage.h"

#import "TGProgressWindow.h"
#import "TGAlertView.h"

#import "TGStringUtils.h"

#import "TGCacheController.h"

#import "TGStickerPacksSettingsController.h"

#import "TGNetworkUsageController.h"
#import "TGCallDataSettingsController.h"

#import "TGUsernameCollectionItem.h"

#import "TGProxySetupController.h"

#import <MTProtoKit/MTProtoKit.h>
#import "TGTelegramNetworking.h"

#import "TGDatabase.h"

@interface TGChatSettingsController () <TGTextSizeControllerDelegate>
{
    TGVariantCollectionItem *_textSizeItem;
    
    TGSwitchCollectionItem *_privateAutoDownloadItem;
    TGSwitchCollectionItem *_groupAutoDownloadItem;
    TGSwitchCollectionItem *_autosavePhotosItem;
    TGSwitchCollectionItem *_saveEditedPhotosItem;
    TGVariantCollectionItem *_useLessDataItem;
    
    TGSwitchCollectionItem *_privateAudioAutoDownloadItem;
    TGSwitchCollectionItem *_groupAudioAutoDownloadItem;
    
    TGSwitchCollectionItem *_privateVideoMessageAutoDownloadItem;
    TGSwitchCollectionItem *_groupVideoMessageAutoDownloadItem;
    
    TGSwitchCollectionItem *_autoPlayAnimationsItem;
    
    TGSwitchCollectionItem *_useRTLItem;
    
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
        
        TGCollectionMenuSection *appearanceSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.Appearance")],
            _textSizeItem
        ]];
        UIEdgeInsets topSectionInsets = appearanceSection.insets;
        topSectionInsets.top = 32.0f;
        appearanceSection.insets = topSectionInsets;
        if (iosMajorVersion() < 7 && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.menuSections addSection:appearanceSection];
        
        _privateAutoDownloadItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.PrivateChats") isOn:TGAppDelegateInstance.autoDownloadPhotosInPrivateChats];
        _privateAutoDownloadItem.interfaceHandle = _actionHandle;
        _groupAutoDownloadItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.Groups") isOn:TGAppDelegateInstance.autoDownloadPhotosInGroups];
        _groupAutoDownloadItem.interfaceHandle = _actionHandle;
        
        _autosavePhotosItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.SaveIncomingPhotos") isOn:TGAppDelegateInstance.autosavePhotos];
        _autosavePhotosItem.interfaceHandle = _actionHandle;
        
        _saveEditedPhotosItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.SaveEditedPhotos") isOn:TGAppDelegateInstance.saveEditedPhotos];
        _saveEditedPhotosItem.interfaceHandle = _actionHandle;
        
        _privateAudioAutoDownloadItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.PrivateChats") isOn:TGAppDelegateInstance.autoDownloadAudioInPrivateChats];
        _privateAudioAutoDownloadItem.interfaceHandle = _actionHandle;
        _groupAudioAutoDownloadItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.Groups") isOn:TGAppDelegateInstance.autoDownloadAudioInGroups];
        _groupAudioAutoDownloadItem.interfaceHandle = _actionHandle;
        
        _privateVideoMessageAutoDownloadItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.PrivateChats") isOn:TGAppDelegateInstance.autoDownloadVideoMessageInPrivateChats];
        _privateVideoMessageAutoDownloadItem.interfaceHandle = _actionHandle;
        _groupVideoMessageAutoDownloadItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.Groups") isOn:TGAppDelegateInstance.autoDownloadVideoMessageInGroups];
        _groupVideoMessageAutoDownloadItem.interfaceHandle = _actionHandle;
        
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
        
        TGCollectionMenuSection *autoDownloadPhotoSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.AutomaticPhotoDownload")],
            _privateAutoDownloadItem,
            _groupAutoDownloadItem
        ]];
        [self.menuSections addSection:autoDownloadPhotoSection];
        
        TGCollectionMenuSection *autoDownloadAudioSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.AutomaticAudioDownload")],
            _privateAudioAutoDownloadItem,
            _groupAudioAutoDownloadItem,
        ]];
        [self.menuSections addSection:autoDownloadAudioSection];
        
        TGCollectionMenuSection *autoDownloadVideoMessageSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.AutomaticVideoMessageDownload")],
            _privateVideoMessageAutoDownloadItem,
            _groupVideoMessageAutoDownloadItem,
        ]];
        [self.menuSections addSection:autoDownloadVideoMessageSection];
        
        _useLessDataItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"CallSettings.UseLessData") action:@selector(useLessDataPressed)];
        _useLessDataItem.variant = [self labelForCallDataMode:TGAppDelegateInstance.callsDataUsageMode];
        
        TGCollectionMenuSection *callsSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:[TGLocalized(@"Settings.CallSettings") uppercaseString]],
            _useLessDataItem
        ]];
        [self.menuSections addSection:callsSection];
        
        bool preCondition = TGIsRTL();
#ifdef DEBUG
        preCondition = true;
#endif
        
        if (preCondition && false)
        {
            _useRTLItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.UseExperimentalRTLLayout") isOn:[TGViewController useExperimentalRTL]];
            _useRTLItem.interfaceHandle = _actionHandle;
            
            TGCollectionMenuSection *languageSection = [[TGCollectionMenuSection alloc] initWithItems:@[
                [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.Language")],
                _useRTLItem
            ]];
            [self.menuSections addSection:languageSection];
        }
        
        /*if (TGIsCustomLocalizationActive())
        {
            TGButtonCollectionItem *resetLanguageItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.RevertLanguage") action:@selector(resetLanguagePressed)];
            resetLanguageItem.deselectAutomatically = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
            TGCollectionMenuSection *languageSection = [[TGCollectionMenuSection alloc] initWithItems:@[
                [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.Language")],
                resetLanguageItem
            ]];
            [self.menuSections addSection:languageSection];
        }*/
        
        TGCollectionMenuSection *otherSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.Other")],
            _autosavePhotosItem,
            _saveEditedPhotosItem,
            _autoPlayAnimationsItem
        ]];
        otherSection.insets = (UIEdgeInsets){otherSection.insets.top - 12.0f, otherSection.insets.left, otherSection.insets.bottom, otherSection.insets.right};
        [self.menuSections addSection:otherSection];
        
        _proxySettings = [[TGTelegramNetworking instance] context].apiEnvironment.socksProxySettings;
        
        _useProxyItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.ConnectionType.UseProxy") variant:_proxySettings != nil ? TGLocalized(@"ChatSettings.ConnectionType.UseSocks5") : TGLocalized(@"GroupInfo.SharedMediaNone") action:@selector(useProxyPressed)];
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

- (void)videoMessagePressed
{
    
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
        
        if (switchItem == _privateAutoDownloadItem)
        {
            TGAppDelegateInstance.autoDownloadPhotosInPrivateChats = switchItem.isOn;
            [TGAppDelegateInstance saveSettings];
        }
        else if (switchItem == _groupAutoDownloadItem)
        {
            TGAppDelegateInstance.autoDownloadPhotosInGroups = switchItem.isOn;
            [TGAppDelegateInstance saveSettings];
        }
        else if (switchItem == _autosavePhotosItem)
        {
            TGAppDelegateInstance.autosavePhotos = switchItem.isOn;
            [TGAppDelegateInstance saveSettings];
        }
        else if (switchItem == _saveEditedPhotosItem)
        {
            TGAppDelegateInstance.saveEditedPhotos = switchItem.isOn;
            [TGAppDelegateInstance saveSettings];
        }
        else if (switchItem == _privateAudioAutoDownloadItem)
        {
            TGAppDelegateInstance.autoDownloadAudioInPrivateChats = switchItem.isOn;
            [TGAppDelegateInstance saveSettings];
        }
        else if (switchItem == _groupAudioAutoDownloadItem)
        {
            TGAppDelegateInstance.autoDownloadAudioInGroups = switchItem.isOn;
            [TGAppDelegateInstance saveSettings];
        }
        else if (switchItem == _privateVideoMessageAutoDownloadItem)
        {
            TGAppDelegateInstance.autoDownloadVideoMessageInPrivateChats = switchItem.isOn;
            [TGAppDelegateInstance saveSettings];
        }
        else if (switchItem == _groupVideoMessageAutoDownloadItem)
        {
            TGAppDelegateInstance.autoDownloadVideoMessageInGroups = switchItem.isOn;
            [TGAppDelegateInstance saveSettings];
        }
        else if (switchItem == _autoPlayAnimationsItem)
        {
            TGAppDelegateInstance.autoPlayAnimations = switchItem.isOn;
            [TGAppDelegateInstance saveSettings];
        }
        else if (switchItem == _useRTLItem)
        {
            [TGViewController setUseExperimentalRTL:switchItem.isOn];
            
            [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"ChatSettings.LayoutSettingsNeedsAppRestart") delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil] show];
        }
    }
}

- (void)actorCompleted:(int)__unused status path:(NSString *)__unused path result:(id)__unused result
{
}

/*- (void)resetLanguagePressed
{
    TGResetLocalization();
    [TGAppDelegateInstance resetLocalization];
    
    [TGAppDelegateInstance resetControllerStack];
    [self.navigationController popToRootViewControllerAnimated:true];
    
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow show:false];
    [progressWindow dismissWithSuccess];
}*/

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

- (void)useProxyPressed {
    TGProxySetupController *controller = [[TGProxySetupController alloc] initWithCurrentSettings];
    __weak TGChatSettingsController *weakSelf = self;
    controller.completion = ^(MTSocksProxySettings *updatedSettings, bool inactive) {
        __strong TGChatSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            NSData *data = nil;
            if (updatedSettings != nil) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                if (updatedSettings.ip != nil && updatedSettings.port != 0) {
                    dict[@"ip"] = updatedSettings.ip;
                    dict[@"port"] = @(updatedSettings.port);
                }
                if (updatedSettings.username.length != 0) {
                    dict[@"username"] = updatedSettings.username;
                }
                if (updatedSettings.password.length != 0) {
                    dict[@"password"] = updatedSettings.password;
                }
                dict[@"inactive"] = @(inactive);
                data = [NSKeyedArchiver archivedDataWithRootObject:dict];
            } else {
                data = [NSData data];
            }
            [TGDatabaseInstance() setCustomProperty:@"socksProxyData" value:data];
            strongSelf->_proxySettings = inactive ? nil : updatedSettings;
            strongSelf->_useProxyItem.variant = (!inactive && updatedSettings != nil) ? TGLocalized(@"ChatSettings.ConnectionType.UseSocks5") : TGLocalized(@"GroupInfo.SharedMediaNone");
            
            [[[TGTelegramNetworking instance] context] updateApiEnvironment:^MTApiEnvironment *(MTApiEnvironment *apiEnvironment) {
                return [apiEnvironment withUpdatedSocksProxySettings:inactive ? nil : updatedSettings];
            }];
        }
    };
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller]];
    [self presentViewController:navigationController animated:true completion:nil];
}

@end
