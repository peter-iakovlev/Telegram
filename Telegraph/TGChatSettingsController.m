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

@interface TGChatSettingsController () <TGTextSizeControllerDelegate>
{
    TGVariantCollectionItem *_textSizeItem;
    
    TGSwitchCollectionItem *_privateAutoDownloadItem;
    TGSwitchCollectionItem *_groupAutoDownloadItem;
    
    TGSwitchCollectionItem *_privateAudioAutoDownloadItem;
    TGSwitchCollectionItem *_groupAudioAutoDownloadItem;
    
    TGSwitchCollectionItem *_autoPlayAudioItem;
    
    TGSwitchCollectionItem *_useRTLItem;
    
    TGProgressWindow *_progressWindow;
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
        
        _privateAudioAutoDownloadItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.PrivateChats") isOn:TGAppDelegateInstance.autoDownloadAudioInPrivateChats];
        _privateAudioAutoDownloadItem.interfaceHandle = _actionHandle;
        _groupAudioAutoDownloadItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.Groups") isOn:TGAppDelegateInstance.autoDownloadAudioInGroups];
        _groupAudioAutoDownloadItem.interfaceHandle = _actionHandle;
        
        _autoPlayAudioItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.AutoPlayAudio") isOn:TGAppDelegateInstance.autoPlayAudio];
        _autoPlayAudioItem.interfaceHandle = _actionHandle;
        
        TGCollectionMenuSection *autoDownloadPhotoSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.AutomaticPhotoDownload")],
            _privateAutoDownloadItem,
            _groupAutoDownloadItem
        ]];
        if (iosMajorVersion() >= 7 || [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            UIEdgeInsets topSectionInsets = autoDownloadPhotoSection.insets;
            topSectionInsets.top = 32.0f;
            autoDownloadPhotoSection.insets = topSectionInsets;
        }
        [self.menuSections addSection:autoDownloadPhotoSection];
        
        TGCollectionMenuSection *autoDownloadAudioSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.AutomaticAudioDownload")],
            _privateAudioAutoDownloadItem,
            _groupAudioAutoDownloadItem,
            _autoPlayAudioItem
        ]];
        [self.menuSections addSection:autoDownloadAudioSection];
        
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
        
        if (TGIsCustomLocalizationActive())
        {
            TGButtonCollectionItem *resetLanguageItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.RevertLanguage") action:@selector(resetLanguagePressed)];
            resetLanguageItem.deselectAutomatically = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
            TGCollectionMenuSection *languageSection = [[TGCollectionMenuSection alloc] initWithItems:@[
                [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.Language")],
                resetLanguageItem
            ]];
            [self.menuSections addSection:languageSection];
        }
        
        TGDisclosureActionCollectionItem *cacheItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Cache.Title") action:@selector(cachePressed)];
        TGDisclosureActionCollectionItem *stickersItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.Stickers") action:@selector(stickersPressed)];
        TGCollectionMenuSection *otherSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.Other")],
            stickersItem,
            cacheItem
        ]];
        otherSection.insets = (UIEdgeInsets){otherSection.insets.top - 12.0f, otherSection.insets.left, otherSection.insets.bottom, otherSection.insets.right};
        [self.menuSections addSection:otherSection];
        
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
        else if (switchItem == _autoPlayAudioItem)
        {
            TGAppDelegateInstance.autoPlayAudio = switchItem.isOn;
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

- (void)resetLanguagePressed
{
    TGResetLocalization();
    [TGAppDelegateInstance resetLocalization];
    
    [TGAppDelegateInstance resetControllerStack];
    [self.navigationController popToRootViewControllerAnimated:true];
    
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow show:false];
    [progressWindow dismissWithSuccess];
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

@end
