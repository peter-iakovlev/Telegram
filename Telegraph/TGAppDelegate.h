/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "TGNavigationController.h"
#import "TGMainTabsController.h"
#import "TGDialogListController.h"
#import "TGContactsController.h"
#import "TGRecentCallsController.h"
#import "TGAccountSettingsController.h"
#import "TGRootController.h"
#import "TGNotificationController.h"
#import "TGKeyCommandController.h"

#import "TGResetAccountState.h"

#import "ActionStage.h"

#import "TGHolderSet.h"

#import "TGMessage.h"

#import "TGApplicationMainWindow.h"

extern CFAbsoluteTime applicationStartupTimestamp;
extern CFAbsoluteTime mainLaunchTimestamp;

@class TGAppDelegate;
extern TGAppDelegate *TGAppDelegateInstance;

@class TGGlobalContext;

@protocol TGStickerPackReference;

extern NSString *TGDeviceProximityStateChangedNotification;

@protocol TGDeviceTokenListener <NSObject>

@required

- (void)deviceTokenRequestCompleted:(NSString *)deviceToken;

@end

@class SSignal;

@interface TGAppDelegate : UIResponder <UIApplicationDelegate, ASWatcher>

@property (nonatomic, strong, readonly) ASHandle *actionHandle;

@property (nonatomic, strong) TGApplicationMainWindow *window;
@property (nonatomic, strong) UIWindow *contentWindow;

@property (nonatomic, strong, readonly) SSignal *localizationUpdated;

@property (nonatomic) bool isManuallyLocked;
@property (nonatomic) int32_t automaticLockTimeout;

- (bool)isCurrentlyLocked;
- (void)resetRemoteDeviceLocked;
- (bool)isDisplayingPasscodeWindow;

// Settings
@property (nonatomic) bool soundEnabled;
@property (nonatomic) bool outgoingSoundEnabled;
@property (nonatomic) bool vibrationEnabled;
@property (nonatomic) bool bannerEnabled;
@property (nonatomic) bool locationTranslationEnabled;
@property (nonatomic) bool exclusiveConversationControllers;

@property (nonatomic) bool autosavePhotos;
@property (nonatomic) bool saveEditedPhotos;
@property (nonatomic) bool saveCapturedMedia;
@property (nonatomic) bool customChatBackground;

@property (nonatomic) bool autoDownloadPhotosInGroups;
@property (nonatomic) bool autoDownloadPhotosInPrivateChats;

@property (nonatomic) bool autoDownloadAudioInGroups;
@property (nonatomic) bool autoDownloadAudioInPrivateChats;

@property (nonatomic) bool autoDownloadVideoMessageInGroups;
@property (nonatomic) bool autoDownloadVideoMessageInPrivateChats;

@property (nonatomic) bool autoPlayAudio;
@property (nonatomic) bool autoPlayAnimations;

@property (nonatomic) bool allowSecretWebpages;
@property (nonatomic) bool allowSecretWebpagesInitialized;

@property (nonatomic) bool secretInlineBotsInitialized;

@property (nonatomic) int callsDataUsageMode;
@property (nonatomic) bool callsDisableP2P;
@property (nonatomic) bool callsDisableCallKit;
@property (nonatomic) bool callsUseProxy;

@property (nonatomic) int alwaysShowStickersMode;

@property (nonatomic) bool useDifferentBackend;

@property (nonatomic, strong) TGNavigationController *loginNavigationController;

@property (nonatomic, strong) TGRootController *rootController;

@property (nonatomic, readonly) TGKeyCommandController *keyCommandController;

@property (nonatomic) bool deviceProximityState;
@property (nonatomic) TGHolderSet *deviceProximityListeners;

@property (nonatomic) CFAbsoluteTime enteredBackgroundTime;

@property (nonatomic) bool disableBackgroundMode;
@property (nonatomic, readonly) bool inBackground;
@property (nonatomic, readonly) bool backgroundTaskOngoing;

@property (nonatomic) int showCallsTab;
- (bool)callsTabFileExists;
- (void)resetCallsTab;

- (void)resetLocalization;

- (void)performPhoneCall:(NSURL *)url;

- (void)presentMainController;

- (void)presentLoginController:(bool)clearControllerStates animated:(bool)animated showWelcomeScreen:(bool)showWelcomeScreen phoneNumber:(NSString *)phoneNumber phoneCode:(NSString *)phoneCode phoneCodeHash:(NSString *)phoneCodeHash codeSentToTelegram:(bool)codeSentToTelegram codeSentViaPhone:(bool)codeSentViaPhone profileFirstName:(NSString *)profileFirstName profileLastName:(NSString *)profileLastName resetAccountState:(TGResetAccountState *)resetAccountState;
- (void)presentContentController:(UIViewController *)controller;
- (void)dismissContentController;

- (void)saveSettings;
- (void)loadSettings;

- (NSDictionary *)loadLoginState;
- (void)resetLoginState;
- (void)saveLoginStateWithDate:(int)date phoneNumber:(NSString *)phoneNumber phoneCode:(NSString *)phoneCode phoneCodeHash:(NSString *)phoneCodeHash codeSentToTelegram:(bool)codeSentToTelegram codeSentViaPhone:(bool)codeSentViaPhone firstName:(NSString *)firstName lastName:(NSString *)lastName photo:(NSData *)photo resetAccountState:(TGResetAccountState *)resetAccountState;

- (NSArray *)classicAlertSoundTitles;
- (NSArray *)modernAlertSoundTitles;

- (void)playSound:(NSString *)name vibrate:(bool)vibrate;
- (void)playNotificationSound:(NSString *)name;

- (void)requestDeviceToken:(id<TGDeviceTokenListener>)listener;

- (void)reloadSettingsController:(int)uid;

- (void)readyToApplyLocalizationFromFile:(NSString *)filePath warnings:(NSString *)warnings;

- (void)resetControllerStack;

- (void)handleOpenDocument:(NSURL *)url animated:(bool)animated;
- (void)handleOpenDocument:(NSURL *)url animated:(bool)animated keepStack:(bool)keepStack;

- (void)handleOpenInstantView:(NSString *)url;

- (void)previewStickerPackWithReference:(id<TGStickerPackReference>)packReference;

- (void)inviteBotToGroup:(TGUser *)user payload:(NSString *)payload;
- (void)startGameInConversation:(NSString *)shortName user:(TGUser *)user;

+ (NSString *)documentsPath;
+ (NSString *)cachePath;

- (bool)enableLogging;
- (void)setEnableLogging:(bool)enableLogging;

- (void)setupShortcutItems;

- (void)updatePushRegistration;

@end
