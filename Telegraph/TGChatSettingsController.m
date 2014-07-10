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

#import "TGTextSizeController.h"

#import "TGTelegraphConversationMessageAssetsSource.h"
#import "TGAppDelegate.h"
#import "ActionStage.h"

#import "TGProgressWindow.h"
#import "TGAlertView.h"

#import "TGStringUtils.h"

@interface TGChatSettingsController () <TGTextSizeControllerDelegate>
{
    TGVariantCollectionItem *_textSizeItem;
    
    TGSwitchCollectionItem *_privateAutoDownloadItem;
    TGSwitchCollectionItem *_groupAutoDownloadItem;
    
    TGSwitchCollectionItem *_privateAudioAutoDownloadItem;
    TGSwitchCollectionItem *_groupAudioAutoDownloadItem;
    
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
            _groupAudioAutoDownloadItem
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
        
        TGButtonCollectionItem *terminateSessionsItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.ClearOtherSessions") action:@selector(terminateSessionsPressed)];
        terminateSessionsItem.titleColor = TGDestructiveAccentColor();
        terminateSessionsItem.deselectAutomatically = true;
        
        TGCollectionMenuSection *securitySection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.Security")],
            terminateSessionsItem,
            [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"ChatSettings.ClearOtherSessionsHelp")]
        ]];
        [self.menuSections addSection:securitySection];
        
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
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

#pragma mark -

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

- (void)terminateSessionsPressed
{
    __weak TGChatSettingsController *weakSelf = self;
    [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"ChatSettings.ClearOtherSessionsConfirmation") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed)
    {
        if (okButtonPressed)
        {
            TGChatSettingsController *strongSelf = weakSelf;
            [strongSelf _commitTerminateSessions];
        }
    }] show];
}

- (void)_commitTerminateSessions
{
    _progressWindow = [[TGProgressWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_progressWindow show:true];
    
    [ActionStageInstance() requestActor:@"/tg/service/revokesessions" options:nil watcher:self];
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
        else if (switchItem == _useRTLItem)
        {
            [TGViewController setUseExperimentalRTL:switchItem.isOn];
            
            [[[UIAlertView alloc] initWithTitle:nil message:TGLocalized(@"ChatSettings.LayoutSettingsNeedsAppRestart") delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil] show];
        }
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)__unused result
{
    if ([path isEqualToString:@"/tg/service/revokesessions"])
    {
        TGDispatchOnMainThread(^
        {
            if (status == ASStatusSuccess)
            {
                [_progressWindow dismissWithSuccess];
                _progressWindow = nil;
            }
            else
            {
                [_progressWindow dismiss:true];
                _progressWindow = nil;
                
                [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"ChatSettings.ClearOtherSessionsFailed") cancelButtonTitle:nil okButtonTitle:TGLocalized(@"Common.OK") completionBlock:nil] show];
            }
        });
    }
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

@end
