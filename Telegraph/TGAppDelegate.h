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
#import "TGAccountSettingsController.h"
#import "TGRootController.h"

#import "ActionStage.h"

#import "TGHolderSet.h"

extern CFAbsoluteTime applicationStartupTimestamp;
extern CFAbsoluteTime mainLaunchTimestamp;

@class TGAppDelegate;
extern TGAppDelegate *TGAppDelegateInstance;

@class TGGlobalContext;

@class TGStickerPack;

extern NSString *TGDeviceProximityStateChangedNotification;

@protocol TGDeviceTokenListener <NSObject>

@required

- (void)deviceTokenRequestCompleted:(NSString *)deviceToken;

@end

@interface TGAppDelegate : UIResponder <UIApplicationDelegate, ASWatcher>

@property (nonatomic, strong, readonly) ASHandle *actionHandle;

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIWindow *contentWindow;

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
@property (nonatomic) bool customChatBackground;

@property (nonatomic) bool autoDownloadPhotosInGroups;
@property (nonatomic) bool autoDownloadPhotosInPrivateChats;

@property (nonatomic) bool autoDownloadAudioInGroups;
@property (nonatomic) bool autoDownloadAudioInPrivateChats;

@property (nonatomic) bool autoPlayAudio;

@property (nonatomic) int alwaysShowStickersMode;

@property (nonatomic) bool useDifferentBackend;

@property (nonatomic, strong) TGNavigationController *loginNavigationController;

@property (nonatomic, strong) TGRootController *rootController;

@property (nonatomic) bool deviceProximityState;
@property (nonatomic) TGHolderSet *deviceProximityListeners;

@property (nonatomic) CFAbsoluteTime enteredBackgroundTime;

@property (nonatomic) bool disableBackgroundMode;
@property (nonatomic, readonly) bool inBackground;
@property (nonatomic, readonly) bool backgroundTaskOngoing;

- (void)resetLocalization;

- (void)performPhoneCall:(NSURL *)url;

- (void)presentMainController;

- (void)presentLoginController:(bool)clearControllerStates showWelcomeScreen:(bool)showWelcomeScreen phoneNumber:(NSString *)phoneNumber phoneCode:(NSString *)phoneCode phoneCodeHash:(NSString *)phoneCodeHash codeSentToTelegram:(bool)codeSentToTelegram profileFirstName:(NSString *)profileFirstName profileLastName:(NSString *)profileLastName;
- (void)presentContentController:(UIViewController *)controller;
- (void)dismissContentController;

- (void)saveSettings;
- (void)loadSettings;

- (NSDictionary *)loadLoginState;
- (void)resetLoginState;
- (void)saveLoginStateWithDate:(int)date phoneNumber:(NSString *)phoneNumber phoneCode:(NSString *)phoneCode phoneCodeHash:(NSString *)phoneCodeHash codeSentToTelegram:(bool)codeSentToTelegram firstName:(NSString *)firstName lastName:(NSString *)lastName photo:(NSData *)photo;

- (NSArray *)classicAlertSoundTitles;
- (NSArray *)modernAlertSoundTitles;

- (void)playSound:(NSString *)name vibrate:(bool)vibrate;
- (void)playNotificationSound:(NSString *)name;
- (void)displayNotification:(NSString *)identifier timeout:(NSTimeInterval)timeout constructor:(UIView *(^)(UIView *existingView))constructor watcher:(ASHandle *)watcher watcherAction:(NSString *)watcherAction watcherOptions:(NSDictionary *)watcherOptions;
- (void)dismissNotification;
- (UIView *)currentNotificationView;

- (void)requestDeviceToken:(id<TGDeviceTokenListener>)listener;

- (void)reloadSettingsController:(int)uid;

- (void)readyToApplyLocalizationFromFile:(NSString *)filePath warnings:(NSString *)warnings;

- (void)resetControllerStack;

- (void)handleOpenDocument:(NSURL *)url animated:(bool)animated;

- (void)previewStickerPack:(TGStickerPack *)stickerPack currentStickerPacks:(NSArray *)currentStickerPacks;

- (void)inviteBotToGroup:(TGUser *)user payload:(NSString *)payload;

+ (NSString *)documentsPath;
+ (NSString *)cachePath;

- (bool)enableLogging;
- (void)setEnableLogging:(bool)enableLogging;

- (void)setupShortcutItems;

@end
