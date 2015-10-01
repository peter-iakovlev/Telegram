#import "TGAppDelegate.h"

#import "Freedom.h"
#import "FreedomUIKit.h"

#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"

#import <MTProtoKit/MTDatacenterAddress.h>

#import "TGDatabase.h"
#import "TGMessage+Telegraph.h"

#import "TGDateUtils.h"
#import "TGStringUtils.h"

#import "TGInterfaceManager.h"
#import "TGInterfaceAssets.h"

#import "TGSchema.h"

#import "TGImageManager.h"

#import "TGCache.h"
#import "TGRemoteImageView.h"
#import "TGImageUtils.h"

#import "TGViewController.h"

#import "TGTelegraphDialogListCompanion.h"

#import "TGNavigationBar.h"

#import "SGraphListNode.h"
#import "TGImageDownloadActor.h"

#import "TGHacks.h"

#import "TGTelegraphConversationMessageAssetsSource.h"
#import "TGReusableLabel.h"

#import "TGFont.h"

#import "TGNotificationWindow.h"
#import "TGMessageNotificationView.h"

#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <ImageIO/ImageIO.h>

#import "RMIntroViewController.h"

#import "TGLoginWelcomeController.h"
#import "TGLoginPhoneController.h"
#import "TGLoginCodeController.h"
#import "TGLoginProfileController.h"
#import "TGLoginInactiveUserController.h"

#import "TGApplication.h"

#import "TGPasscodeWindow.h"

#import "TGContentViewController.h"

#import "TGModernConversationController.h"
#import "TGGenericModernConversationCompanion.h"

#import "TGOverlayControllerWindow.h"
#import "TGModernGalleryController.h"

#import "TGSecretModernConversationCompanion.h"

#import "TGForwardTargetController.h"

#import "TGTimerTarget.h"

#import "TGAlertView.h"

#import "TGModernGalleryModel.h"

#import "TGConversationAddMessagesActor.h"

#import <pthread.h>

#import <objc/runtime.h>

#import <AVFoundation/AVFoundation.h>

#include <inttypes.h>

#import "TGProgressWindow.h"

#import "TGPasscodeSettingsController.h"
#import "TGPasscodeEntryController.h"

#import "TGDropboxHelper.h"

#import "TGStickersSignals.h"

#import <LocalAuthentication/LocalAuthentication.h>

#import "TGStickerPackPreviewWindow.h"

#import "TGBotSignals.h"

#import "TGBridgeServer.h"
#import "TGBridgeRemoteHandler.h"

#import "TGPeerIdAdapter.h"

#define TG_SYNCHRONIZED_DEFINE(lock) pthread_mutex_t TG_SYNCHRONIZED_##lock
#define TG_SYNCHRONIZED_INIT(lock) pthread_mutex_init(&TG_SYNCHRONIZED_##lock, NULL)
#define TG_SYNCHRONIZED_BEGIN(lock) pthread_mutex_lock(&TG_SYNCHRONIZED_##lock);
#define TG_SYNCHRONIZED_END(lock) pthread_mutex_unlock(&TG_SYNCHRONIZED_##lock);

#import <HockeySDK/HockeySDK.h>

#import "TGGroupManagementSignals.h"

#import "TGSendMessageSignals.h"
#import "TGChatMessageListSignal.h"

#import "TGAudioSessionManager.h"

#import "TGApplicationMainWindow.h"

#import "TGRootController.h"

#import "../../config.h"

NSString *TGDeviceProximityStateChangedNotification = @"TGDeviceProximityStateChangedNotification";

CFAbsoluteTime applicationStartupTimestamp = 0;
CFAbsoluteTime mainLaunchTimestamp = 0;

TGAppDelegate *TGAppDelegateInstance = nil;
TGTelegraph *telegraph = nil;

@interface TGAppDelegate () <BITHockeyManagerDelegate, BITUpdateManagerDelegate, BITCrashManagerDelegate, AVAudioPlayerDelegate>
{
    bool _inBackground;
    bool _enteringForeground;
    
    NSTimer *_foregroundResumeTimer;
    
    TGProgressWindow *_progressWindow;
    
    bool _didBecomeInactive;
    
    TGPasscodeWindow *_passcodeWindow;
    
    SMetaDisposable *_deviceLockedRequestDisposable;
    bool _didUpdateDeviceLocked;
    
    TGUser *_currentInviteBot;
    NSString *_currentInviteBotPayload;
}

@property (nonatomic) bool tokenAlreadyRequested;
@property (nonatomic, strong) id<TGDeviceTokenListener> deviceTokenListener;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic, strong) NSTimer *backgroundTaskExpirationTimer;

@property (nonatomic, strong) NSMutableDictionary *loadedSoundSamples;

@property (nonatomic, strong) TGNotificationWindow *notificationWindow;
@property (nonatomic, strong) NSTimer *notificationWindowTimeoutTimer;

@property (nonatomic, strong) UIWebView *callingWebView;

@property (nonatomic, strong) AVAudioPlayer *currentAudioPlayer;
@property (nonatomic, strong) SMetaDisposable *currentAudioPlayerSession;

@end

@implementation TGAppDelegate

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [TGBridgeServer instance];
    }
    return self;
}

- (TGNavigationController *)loginNavigationController
{
    if (_loginNavigationController == nil)
    {
        UIViewController *rootController = nil;
        bool useAnimated = true;
#if TARGET_IPHONE_SIMULATOR
        //useAnimated = false;
#endif
        if (useAnimated)
        {
            rootController = [[RMIntroViewController alloc] init];
        }
        else
            rootController = [[TGLoginWelcomeController alloc] init];
        
        _loginNavigationController = [TGNavigationController navigationControllerWithControllers:@[rootController] navigationBarClass:[TGTransparentNavigationBar class]];
        _loginNavigationController.restrictLandscape = !TGIsPad();
        _loginNavigationController.disableInteractiveKeyboardTransition = true;
        
        //_loginNavigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    
    return _loginNavigationController;
}

static void overridenDrawRect(__unused id self, __unused SEL _cmd, __unused CGRect rect)
{
}

static unsigned int overrideIndexAbove(__unused id self, __unused SEL _cmd)
{
    return [(TGNavigationBar *)self indexAboveBackdropBackground];
}

- (bool)enableLogging
{
    NSNumber *logsEnabled = [[NSUserDefaults standardUserDefaults] objectForKey:@"__logsEnabled"];
#if (defined(DEBUG) || defined(INTERNAL_RELEASE)) && !defined(DISABLE_LOGGING)
    if (logsEnabled == nil)
        return true;
#endif
    return logsEnabled == nil || [logsEnabled boolValue];
}

- (void)setEnableLogging:(bool)enableLogging
{
    [[NSUserDefaults standardUserDefaults] setObject:@(enableLogging) forKey:@"__logsEnabled"];
    TGLogSetEnabled(enableLogging);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    TGLogSetEnabled([self enableLogging]);
    
    TGLog(@"didFinishLaunchingWithOptions state: %@, %d", [UIApplication sharedApplication], [UIApplication sharedApplication].applicationState);
    
    [TGAppDelegate movePathsToContainer];
    
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    [[NSURL fileURLWithPath:documentsDirectory] setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
    
    [TGMessage registerMediaAttachmentParser:TGActionMediaAttachmentType parser:[[TGActionMediaAttachment alloc] init]];
    [TGMessage registerMediaAttachmentParser:TGImageMediaAttachmentType parser:[[TGImageMediaAttachment alloc] init]];
    [TGMessage registerMediaAttachmentParser:TGLocationMediaAttachmentType parser:[[TGLocationMediaAttachment alloc] init]];
    [TGMessage registerMediaAttachmentParser:TGLocalMessageMetaMediaAttachmentType parser:[[TGLocalMessageMetaMediaAttachment alloc] init]];
    [TGMessage registerMediaAttachmentParser:TGVideoMediaAttachmentType parser:[[TGVideoMediaAttachment alloc] init]];
    [TGMessage registerMediaAttachmentParser:TGContactMediaAttachmentType parser:[[TGContactMediaAttachment alloc] init]];
    [TGMessage registerMediaAttachmentParser:TGForwardedMessageMediaAttachmentType parser:[[TGForwardedMessageMediaAttachment alloc] init]];
    [TGMessage registerMediaAttachmentParser:TGUnsupportedMediaAttachmentType parser:[[TGUnsupportedMediaAttachment alloc] init]];
    [TGMessage registerMediaAttachmentParser:TGDocumentMediaAttachmentType parser:[[TGDocumentMediaAttachment alloc] init]];
    [TGMessage registerMediaAttachmentParser:TGAudioMediaAttachmentType parser:[[TGAudioMediaAttachment alloc] init]];
    [TGMessage registerMediaAttachmentParser:TGReplyMessageMediaAttachmentType parser:[[TGReplyMessageMediaAttachment alloc] init]];
    [TGMessage registerMediaAttachmentParser:TGWebPageMediaAttachmentType parser:[[TGWebPageMediaAttachment alloc] init]];
    [TGMessage registerMediaAttachmentParser:TGReplyMarkupAttachmentType parser:[[TGReplyMarkupAttachment alloc] init]];
    [TGMessage registerMediaAttachmentParser:TGMessageEntitiesAttachmentType parser:[[TGMessageEntitiesAttachment alloc] init]];
    
    TGLog(@"###### Early initialization ######");
    
    [TGDatabase setPasswordRequiredBlock:^TGDatabasePasswordCheckResultBlock (void (^verifyBlock)(NSString *), bool simple)
    {
        TGDispatchOnMainThread(^
        {
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
            if (_passcodeWindow == nil)
            {
                CGRect passcodeFrame = [UIScreen mainScreen].bounds;
                _passcodeWindow = [[TGPasscodeWindow alloc] initWithFrame:passcodeFrame];
                TGPasscodeEntryController *controller = [[TGPasscodeEntryController alloc] initWithStyle:TGPasscodeEntryControllerStyleTranslucent mode:simple ? TGPasscodeEntryControllerModeVerifySimple : TGPasscodeEntryControllerModeVerifyComplex cancelEnabled:false allowTouchId:false completion:^(NSString *passcode)
                {
                    verifyBlock(passcode);
                }];
                
                _passcodeWindow.windowLevel = 10000100.0f;
                TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller]];
                navigationController.restrictLandscape = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone;
                _passcodeWindow.rootViewController = navigationController;
                _passcodeWindow.hidden = false;
                [controller prepareForAppear];
            }
            else
            {
                _passcodeWindow.hidden = false;
                if (TGIsPad())
                    _passcodeWindow.frame = [UIScreen mainScreen].bounds;
                else
                    _passcodeWindow.frame = (CGRect){CGPointZero, TGScreenSize()};
                TGPasscodeEntryController *controller = (TGPasscodeEntryController *)(((TGNavigationController *)_passcodeWindow.rootViewController).topViewController);
                controller.completion = ^(NSString *passcode)
                {
                    verifyBlock(passcode);
                };
                controller.checkCurrentPasscode = nil;
                [controller resetMode:simple ? TGPasscodeEntryControllerModeVerifySimple : TGPasscodeEntryControllerModeVerifyComplex];
                [controller prepareForAppear];
            }
            
            [[TGBridgeServer instance] startRunning];
        });
        
        return ^(bool match)
        {
            TGDispatchOnMainThread(^
            {
                if (match)
                {
                    [_passcodeWindow endEditing:true];
                    TGPasscodeEntryController *controller = (TGPasscodeEntryController *)(((TGNavigationController *)_passcodeWindow.rootViewController).topViewController);
                    [controller resetInvalidPasscodeAttempts];
                    [controller prepareForDisappear];
                    
                    [UIView animateWithDuration:0.3 delay:0 options:[TGViewController preferredAnimationCurve] << 16 animations:^
                    {
                        _passcodeWindow.frame = CGRectOffset(_passcodeWindow.frame, 0.0f, _passcodeWindow.frame.size.height);
                    } completion:^(__unused BOOL finished)
                    {
                        _passcodeWindow.hidden = true;
                    }];
                }
                else
                {
                    TGPasscodeEntryController *controller = (TGPasscodeEntryController *)(((TGNavigationController *)_passcodeWindow.rootViewController).topViewController);
                    [controller addInvalidPasscodeAttempt];
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                }
            });
        };
    }];
    __block TGProgressWindow *progressWindow = nil;
    [TGDatabase setUpgradingBlock:^TGDatabaseUpgradeCompletedBlock ()
    {
        TGDispatchOnMainThread(^
        {
            progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [progressWindow show:true];
        });
        
        return ^
        {
            TGDispatchOnMainThread(^
            {
                [progressWindow dismiss:true];
            });
        };
    }];
    
    [TGDatabase setLiveMessagesDispatchPath:@"/tg/conversations"];
    [TGDatabase setLiveBroadcastMessagesDispatchPath:@"/tg/broadcastConversations"];
    [TGDatabase setLiveUnreadCountDispatchPath:@"/tg/unreadCount"];
    
    [[TGDatabase instance] markAllPendingMessagesAsFailed];
    
    _deviceProximityListeners = [[TGHolderSet alloc] init];
    _deviceProximityListeners.emptyStateChanged = ^(bool listenersExist)
    {
        [UIDevice currentDevice].proximityMonitoringEnabled = listenersExist;
        if (!listenersExist)
            _deviceProximityState = false;
    };
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceProximityStateDidChangeNotification object:[UIDevice currentDevice] queue:nil usingBlock:^(__unused NSNotification *notification)
    {
        _deviceProximityState = [UIDevice currentDevice].proximityState;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TGDeviceProximityStateChangedNotification object:nil];
    }];
    
    [FFNotificationCenter setShouldRotateBlock:^ bool()
    {
        bool restrictPasscodeWindow = false;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && _passcodeWindow != nil && !_passcodeWindow.hidden && [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait)
        {
            restrictPasscodeWindow = true;
        }
        return [_window.rootViewController shouldAutorotate] && !restrictPasscodeWindow;
    }];
    
    freedomInit();
    freedomUIKitInit();
    
    TGAppDelegateInstance = self;
    
    if (iosMajorVersion() < 7)
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 30), false, 0.0f);
        UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIBarButtonItem *item = [UIBarButtonItem appearanceWhenContainedIn:[TGNavigationBar class], nil];
        
        [item setBackgroundImage:transparentImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        UIImage *backImage = [UIImage imageNamed:@"NavigationBackButton.png"];
        UIImage *backHighlightedImage = [UIImage imageNamed:@"NavigationBackButton_Highlighted.png"];
        UIImage *backLandscapeImage = [UIImage imageNamed:@"NavigationBackButtonLandscape.png"];
        UIImage *backLandscapeHighlightedImage = [UIImage imageNamed:@"NavigationBackButtonLandscape_Highlighted.png"];
        [item setBackButtonBackgroundImage:[backImage stretchableImageWithLeftCapWidth:(int)(backImage.size.width) topCapHeight:0] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [item setBackButtonBackgroundImage:[backHighlightedImage stretchableImageWithLeftCapWidth:(int)(backHighlightedImage.size.width) topCapHeight:0] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        [item setBackButtonBackgroundImage:[backLandscapeImage stretchableImageWithLeftCapWidth:(int)(backLandscapeImage.size.width) topCapHeight:0] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
        [item setBackButtonBackgroundImage:[backLandscapeHighlightedImage stretchableImageWithLeftCapWidth:(int)(backLandscapeHighlightedImage.size.width) topCapHeight:0] forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
        [item setBackButtonTitlePositionAdjustment:UIOffsetMake(5, -1) forBarMetrics:UIBarMetricsDefault];
        [item setBackButtonTitlePositionAdjustment:UIOffsetMake(5, -3) forBarMetrics:UIBarMetricsLandscapePhone];
        
        [item setTitlePositionAdjustment:UIOffsetMake(0, 1) forBarMetrics:UIBarMetricsDefault];
        
        [item setTitleTextAttributes:@{UITextAttributeTextColor: TGAccentColor(), UITextAttributeTextShadowColor: [UIColor clearColor], UITextAttributeFont: TGSystemFontOfSize(16.0f)} forState:UIControlStateNormal];
        [item setTitleTextAttributes:@{UITextAttributeTextColor: [TGAccentColor() colorWithAlphaComponent:0.4f], UITextAttributeTextShadowColor: [UIColor clearColor], UITextAttributeFont: TGSystemFontOfSize(16.0f)} forState:UIControlStateHighlighted];
        
        [[TGNavigationBar appearance] setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor blackColor], UITextAttributeTextShadowColor: [UIColor clearColor], UITextAttributeFont: TGBoldSystemFontOfSize(17.0f)}];
        [[TGNavigationBar appearance] setTitleVerticalPositionAdjustment:(TGIsRetina() ? 0.5f : 0.0f) forBarMetrics:UIBarMetricsDefault];
        [[TGNavigationBar appearance] setTitleVerticalPositionAdjustment:-1.0f forBarMetrics:UIBarMetricsLandscapePhone];
    }
    else
    {
        //UIBarButtonItem *item = [UIBarButtonItem appearanceWhenContainedIn:[TGNavigationBar class], nil];
        //[item setBackButtonTitlePositionAdjustment:UIOffsetMake([TGViewController useExperimentalRTL] ? -18.0f : 0.0f, -1) forBarMetrics:UIBarMetricsLandscapePhone];
        
        //[[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake([TGViewController useExperimentalRTL] ? -18.0f : 0.0f, 0.0f) forBarMetrics:UIBarMetricsDefault];
    }
    
    _window = [[TGApplicationMainWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [(TGApplication *)application forceSetStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:false];
    
    if (iosMajorVersion() < 7)
    {
        FreedomDecoration instanceDecorations[] = {
            { .name = 0x7927c35dU,
              .imp = (IMP)&overridenDrawRect,
              .newIdentifier = FreedomIdentifierEmpty,
              .newEncoding = FreedomIdentifierEmpty
            },
            { .name = 0xc6dda86U,
              .imp = (IMP)&overrideIndexAbove,
              .newIdentifier = FreedomIdentifierEmpty,
              .newEncoding = FreedomIdentifierEmpty
            }
        };
        
        freedomClassAutoDecorate(0xf457bfb2U, NULL, 0, instanceDecorations, sizeof(instanceDecorations) / sizeof(instanceDecorations[0]));
    }
    
    _loadedSoundSamples = [[NSMutableDictionary alloc] init];
    
    _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
    
    [ASActor registerActorClass:[TGImageDownloadActor class]];
    
    [TGInterfaceManager instance];
    
    telegraph = [[TGTelegraph alloc] init];
    
    [TGHacks hackSetAnimationDuration];
    
    _rootController = [[TGRootController alloc] init];
    self.window.rootViewController = _rootController;
    
    self.window.backgroundColor = [UIColor blackColor];
    
    [self.window makeKeyAndVisible];
    
    TGCache *sharedCache = [[TGCache alloc] init];
    //sharedCache.imageMemoryLimit = 0;
    //sharedCache.imageMemoryEvictionInterval = 0;
    [TGRemoteImageView setSharedCache:sharedCache];
    
    if (![TGDatabaseInstance() isEncryptionEnabled])
    {
        TGDispatchOnMainThread(^
        {
            [self displayUnlockWindowIfNeeded];
            TGPasscodeEntryController *controller = (TGPasscodeEntryController *)(((TGNavigationController *)_passcodeWindow.rootViewController).topViewController);
            [controller refreshTouchId];
        });
    }
    
    [[TGBridgeServer instance] setPasscodeEnabled:[TGDatabaseInstance() isPasswordSet:NULL] passcodeEncrypted:[TGDatabaseInstance() isEncryptionEnabled]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
    {
        [self loadSettings];
        
        [TGDatabaseInstance() dispatchOnDatabaseThread:^
         {
             [TGDatabaseInstance() loadConversationListFromDate:INT32_MAX limit:32 excludeConversationIds:nil completion:^(NSArray *dialogList)
             {
                 bool dialogListLoaded = [TGDatabaseInstance() customProperty:@"dialogListLoaded"].length != 0;
                 
                 NSMutableArray *filteredResult = [[NSMutableArray alloc] initWithArray:dialogList];
                 [filteredResult sortUsingComparator:^NSComparisonResult(TGConversation *lhs, TGConversation *rhs) {
                     if (lhs.date > rhs.date) {
                         return NSOrderedAscending;
                     } else if (lhs.date < rhs.date) {
                         return NSOrderedDescending;
                     } else {
                         if (lhs.conversationId < rhs.conversationId) {
                             return NSOrderedDescending;
                         } else {
                             return NSOrderedAscending;
                         }
                     }
                 }];
                 
                 if (!dialogListLoaded) {
                     while (filteredResult.count != 0 && ((TGConversation *)[filteredResult lastObject]).isChannel) {
                         [filteredResult removeLastObject];
                     }
                 }
                 
                 TGLog(@"###### Dialog list loaded ######");
                 
                 SGraphListNode *node = [[SGraphListNode alloc] init];
                 node.items = filteredResult;
                 
                 [(id<ASWatcher>)_rootController.dialogListController.dialogListCompanion actorCompleted:ASStatusSuccess path:@"/tg/dialoglist/(0)" result:node];
                 TGLog(@"===== Dispatched dialog list");
                 
                 [ActionStageInstance() dispatchOnStageQueue:^
                 {
                     [[TGTelegramNetworking instance] loadCredentials];
                     
                     if (TGTelegraphInstance.clientUserId != 0)
                     {
                         [TGTelegraphInstance processAuthorizedWithUserId:TGTelegraphInstance.clientUserId clientIsActivated:TGTelegraphInstance.clientIsActivated];
                         if (!TGTelegraphInstance.clientIsActivated)
                         {
                             TGLog(@"===== User is not activated, presenting welcome screen");
                             [self presentLoginController:false showWelcomeScreen:true phoneNumber:nil phoneCode:nil phoneCodeHash:nil codeSentToTelegram:false profileFirstName:nil profileLastName:nil];
                         }
                         else if (launchOptions[UIApplicationLaunchOptionsURLKey] != nil)
                         {
                             dispatch_async(dispatch_get_main_queue(), ^
                             {
                                 [self handleOpenDocument:launchOptions[UIApplicationLaunchOptionsURLKey] animated:false];
                             });
                         }
                         else if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] != nil)
                         {
                             dispatch_async(dispatch_get_main_queue(), ^
                             {
                                 id nFromId = [launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey:@"from_id"];
                                 id nChatId = [launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey:@"chat_id"];
                                 id nContactId = [launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey:@"contact_id"];
                                 
                                 int64_t peerId = 0;
                                 
                                 if (nFromId != nil && [TGSchema canCreateIntFromObject:nFromId])
                                 {
                                     peerId = [TGSchema intFromObject:nFromId];
                                 }
                                 else if (nChatId != nil && [TGSchema canCreateIntFromObject:nChatId])
                                 {
                                     peerId = -[TGSchema intFromObject:nChatId];
                                 }
                                 else if (nContactId != nil && [TGSchema canCreateIntFromObject:nContactId])
                                 {
                                     peerId = [TGSchema intFromObject:nContactId];
                                 }
                                 
                                 if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive)
                                     [self _replyActionForPeerId:peerId mid:0 openKeyboard:false responseInfo:nil completion:nil];
                             });
                         }
                         else if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] != nil)
                         {
                             if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive)
                             {
                                 dispatch_async(dispatch_get_main_queue(), ^
                                 {
                                     if ([launchOptions respondsToSelector:@selector(objectForKeyedSubscript:)] && [launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] respondsToSelector:@selector(objectForKey:)] && [launchOptions[UIApplicationLaunchOptionsLocalNotificationKey][@"cid"] respondsToSelector:@selector(longLongValue)])
                                     {
                                         int64_t peerId = [[launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] objectForKey:@"cid"] longLongValue];
                                         [self _replyActionForPeerId:peerId mid:0 openKeyboard:false responseInfo:nil completion:nil];
                                     }
                                 });
                             }
                         }
                     }
                     else
                     {
                         [TGTelegraphInstance processUnauthorized];
                         
                         NSDictionary *blockStateDict = [self loadLoginState];
                         
                         dispatch_async(dispatch_get_main_queue(), ^
                         {
                             NSDictionary *stateDict = blockStateDict;
                             
                             int currentDate = ((int)CFAbsoluteTimeGetCurrent());
                             int stateDate = [stateDict[@"date"] intValue];
                             if (currentDate - stateDate > 60 * 60 * 23)
                             {
                                 stateDict = nil;
                                 [self resetLoginState];
                             }
                             
                             [self presentLoginController:false showWelcomeScreen:false phoneNumber:stateDict[@"phoneNumber"] phoneCode:stateDict[@"phoneCode"] phoneCodeHash:stateDict[@"phoneCodeHash"] codeSentToTelegram:[stateDict[@"codeSentToTelegram"] boolValue] profileFirstName:stateDict[@"firstName"] profileLastName:stateDict[@"lastName"]];
                         });
                         
                         [[TGDatabase instance] dropDatabase];
                     }
                     
                     [[TGTelegramNetworking instance] start];
                     
                     if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] != nil)
                         [self processPossibleConfigUpdateNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
                     
                     [[TGBridgeServer instance] startRunning];
                 }];
              }];
         } synchronous:false];
    });
    
#ifndef EXTERNAL_INTERNAL_RELEASE
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^
    {
        NSString *appId = nil;
        
#ifdef SETUP_HOCKEYAPP_APP_ID
        SETUP_HOCKEYAPP_APP_ID(appId)
#endif
        
        if (appId != nil) {
            TGLog(@"starting with %@", appId);
            
            [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:appId delegate:self];
            [[BITHockeyManager sharedHockeyManager] startManager];
            [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
        }
    });
#endif
    
    _foregroundResumeTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(checkForegroundResume) interval:2.0 repeat:true];
    
    TGDispatchAfter(1.0, dispatch_get_main_queue(), ^
    {
        @try
        {
            [UIView setAnimationsEnabled:true];
            [CATransaction commit];
        }
        @catch (__unused NSException *exception)
        {
        }
    });
    
    [[TGBridgeServer instance] startServices];
    
    return true;
}

- (void)checkForegroundResume
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
        [[TGTelegramNetworking instance] resume];
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)__unused application
{
    TGLog(@"******* Memory warning ******");
}

- (void)applicationWillResignActive:(UIApplication *)__unused application
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        int unreadCount = [TGDatabaseInstance() databaseState].unreadCount;
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadCount];
        });
    }];
    
    [self onBecomeInactive];
}

- (void)displayUnlockWindowIfNeeded
{
    NSNumber *nDeactivationDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"Passcode_deactivationDate"];
    bool displayByDeactivationTimeout = false;
    if (nDeactivationDate != nil)
    {
        int32_t lockTimeout = [self automaticLockTimeout];
        if (lockTimeout >= 0)
        {
            displayByDeactivationTimeout = [[NSDate date] timeIntervalSince1970] > ([nDeactivationDate doubleValue] + lockTimeout);
        }
    }
    
    if ([self isManuallyLocked] || displayByDeactivationTimeout)
    {
        bool isStrong = false;
        if ([TGDatabaseInstance() isPasswordSet:&isStrong])
        {
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
            
            TGPasscodeEntryControllerMode mode = (!isStrong) ? TGPasscodeEntryControllerModeVerifySimple : TGPasscodeEntryControllerModeVerifyComplex;
            if (_passcodeWindow == nil)
            {
                CGRect passcodeFrame = [UIScreen mainScreen].bounds;
                if (TGIsPad())
                    passcodeFrame = [UIScreen mainScreen].bounds;
                else
                    passcodeFrame = (CGRect){CGPointZero, TGScreenSize()};
                _passcodeWindow = [[TGPasscodeWindow alloc] initWithFrame:passcodeFrame];
                TGPasscodeEntryController *controller = [[TGPasscodeEntryController alloc] initWithStyle:TGPasscodeEntryControllerStyleTranslucent mode:mode cancelEnabled:false allowTouchId:[TGPasscodeSettingsController enableTouchId] completion:^(NSString *passcode)
                {
                    if ([TGDatabaseInstance() verifyPassword:passcode])
                    {
                        TGDispatchOnMainThread(^
                        {
                            [self setIsManuallyLocked:false];
                            
                            [_passcodeWindow endEditing:true];
                            TGPasscodeEntryController *controller = (TGPasscodeEntryController *)(((TGNavigationController *)_passcodeWindow.rootViewController).topViewController);
                            [controller prepareForDisappear];

                            [UIView animateWithDuration:0.3 delay:0 options:[TGViewController preferredAnimationCurve] << 16 animations:^
                            {
                                _passcodeWindow.frame = CGRectOffset(_passcodeWindow.frame, 0.0f, _passcodeWindow.frame.size.height);
                            } completion:^(__unused BOOL finished)
                            {
                                _passcodeWindow.hidden = true;
                            }];
                        });
                    }
                }];
                controller.touchIdCompletion = ^
                {
                    TGDispatchOnMainThread(^
                    {
                        [self setIsManuallyLocked:false];
                        
                        [_passcodeWindow endEditing:true];
                        TGPasscodeEntryController *controller = (TGPasscodeEntryController *)(((TGNavigationController *)_passcodeWindow.rootViewController).topViewController);
                        [controller prepareForDisappear];
                        
                        [UIView animateWithDuration:0.3 delay:0 options:[TGViewController preferredAnimationCurve] << 16 animations:^
                        {
                            _passcodeWindow.frame = CGRectOffset(_passcodeWindow.frame, 0.0f, _passcodeWindow.frame.size.height);
                        } completion:^(__unused BOOL finished)
                        {
                            _passcodeWindow.hidden = true;
                        }];
                    });
                };
                controller.checkCurrentPasscode = ^bool (NSString *passcode)
                {
                    return [TGDatabaseInstance() verifyPassword:passcode];
                };
                _passcodeWindow.windowLevel = UIWindowLevelStatusBar - 0.0001f;
                TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller]];
                navigationController.restrictLandscape = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone;
                _passcodeWindow.rootViewController = navigationController;
                _passcodeWindow.hidden = false;
                [controller prepareForAppear];
                
                if (!TGIsPad())
                {
                    navigationController.view.frame = (CGRect){CGPointZero, TGScreenSize()};;
                    controller.view.frame = (CGRect){CGPointZero, TGScreenSize()};;
                }
                
                if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
                    [controller refreshTouchId];
            }
            else if (_passcodeWindow.hidden)
            {
                TGPasscodeEntryController *controller = (TGPasscodeEntryController *)(((TGNavigationController *)_passcodeWindow.rootViewController).topViewController);
                controller.checkCurrentPasscode = ^(NSString *passcode)
                {
                    return [TGDatabaseInstance() verifyPassword:passcode];
                };
                controller.completion = ^(NSString *passcode)
                {
                    if ([TGDatabaseInstance() verifyPassword:passcode])
                    {
                        TGDispatchOnMainThread(^
                        {
                            [self setIsManuallyLocked:false];
                            
                            [_passcodeWindow endEditing:true];
                            TGPasscodeEntryController *controller = (TGPasscodeEntryController *)(((TGNavigationController *)_passcodeWindow.rootViewController).topViewController);
                            [controller prepareForDisappear];
                            
                            [UIView animateWithDuration:0.3 delay:0 options:[TGViewController preferredAnimationCurve] << 16 animations:^
                             {
                                 _passcodeWindow.frame = CGRectOffset(_passcodeWindow.frame, 0.0f, _passcodeWindow.frame.size.height);
                             } completion:^(__unused BOOL finished)
                             {
                                 _passcodeWindow.hidden = true;
                             }];
                        });
                    }
                };
                controller.touchIdCompletion = ^
                {
                    TGDispatchOnMainThread(^
                    {
                        [self setIsManuallyLocked:false];
                        
                        [_passcodeWindow endEditing:true];
                        TGPasscodeEntryController *controller = (TGPasscodeEntryController *)(((TGNavigationController *)_passcodeWindow.rootViewController).topViewController);
                        [controller prepareForDisappear];
                        
                        [UIView animateWithDuration:0.3 delay:0 options:[TGViewController preferredAnimationCurve] << 16 animations:^
                        {
                            _passcodeWindow.frame = CGRectOffset(_passcodeWindow.frame, 0.0f, _passcodeWindow.frame.size.height);
                        } completion:^(__unused BOOL finished)
                        {
                            _passcodeWindow.hidden = true;
                        }];
                    });
                };
                [controller resetMode:mode];
                if (TGIsPad())
                    _passcodeWindow.frame = [UIScreen mainScreen].bounds;
                else
                    _passcodeWindow.frame = (CGRect){CGPointZero, TGScreenSize()};
                _passcodeWindow.hidden = false;
                [controller prepareForAppear];
                
                controller.allowTouchId = [TGPasscodeSettingsController enableTouchId];
                
                if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
                    [controller refreshTouchId];
            }
        }
    }
}

- (void)applicationSignificantTimeChange:(UIApplication *)__unused application
{
    TGLog(@"***** Significant time change");
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [ActionStageInstance() dispatchResource:@"/system/significantTimeChange" resource:nil];
    }];
    
    [TGDatabaseInstance() processAndScheduleSelfDestruct];
    [TGDatabaseInstance() processAndScheduleMediaCleanup];
    [TGDatabaseInstance() processAndScheduleMute];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
#if defined(DEBUG) || defined(INTERNAL_RELEASE)
    TGLogSynchronize();
#endif
    
    _inBackground = true;
    
    if (_backgroundTaskExpirationTimer != nil && [_backgroundTaskExpirationTimer isValid])
    {
        [_backgroundTaskExpirationTimer invalidate];
        _backgroundTaskExpirationTimer = nil;
    }
    
    _backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^
    {
        if (_backgroundTaskExpirationTimer != nil)
        {
            if ([_backgroundTaskExpirationTimer isValid])
                [_backgroundTaskExpirationTimer invalidate];
            _backgroundTaskExpirationTimer = nil;
        }
        
        UIBackgroundTaskIdentifier identifier = _backgroundTaskIdentifier;
        _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        [application endBackgroundTask:identifier];
    }];
    
    _enteredBackgroundTime = CFAbsoluteTimeGetCurrent();
    
    NSTimeInterval maxBackgroundTime = 5.0;
    if ([application backgroundTimeRemaining] >= 0.5 * 60.0 + 5)
        maxBackgroundTime = [application backgroundTimeRemaining] - 0.5 * 60.0;
    
    if (maxBackgroundTime < 60.0)
        maxBackgroundTime = 60.0;
    
    if (_disableBackgroundMode)
        maxBackgroundTime = 1;
    
#ifdef DEBUG
    //maxBackgroundTime = 5;
#endif
    
    TGLog(@"Background time remaining: %d m %d s", (int)(maxBackgroundTime / 60.0), ((int)maxBackgroundTime) % 60);
    
    _backgroundTaskExpirationTimer = [NSTimer timerWithTimeInterval:MAX(maxBackgroundTime, 1.0) target:self selector:@selector(backgroundExpirationTimerEvent:) userInfo:nil repeats:false];
    [[NSRunLoop mainRunLoop] addTimer:_backgroundTaskExpirationTimer forMode:NSRunLoopCommonModes];
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [ActionStageInstance() removeWatcher:TGTelegraphInstance fromPath:@"/tg/service/updatepresence/(online)"];
        [ActionStageInstance() removeWatcher:TGTelegraphInstance fromPath:@"/tg/service/updatepresence/(offline)"];
        [ActionStageInstance() requestActor:@"/tg/service/updatepresence/(timeout)" options:nil watcher:TGTelegraphInstance];
    }];
    
    _didBecomeInactive = true;
    
    if ([self isManuallyLocked])
        [self displayUnlockWindowIfNeeded];
    
    [self onBecomeInactive];
}

- (void)backgroundExpirationTimerEvent:(NSTimer *)__unused timer
{
    [[TGTelegramNetworking instance] pause];
    
    _backgroundTaskExpirationTimer = nil;
    
    UIBackgroundTaskIdentifier identifier = _backgroundTaskIdentifier;
    _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    if (identifier == UIBackgroundTaskInvalid)
        TGLog(@"***** Strange. *****");
    
    double delayInSeconds = 5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^
    {
        [[UIApplication sharedApplication] endBackgroundTask:identifier];
    });
}

- (bool)backgroundTaskOngoing
{
    return (_backgroundTaskExpirationTimer != nil);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    _enteringForeground = true;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        _inBackground = false;
        _enteringForeground = false;
    });
    
    if (_backgroundTaskIdentifier != UIBackgroundTaskInvalid)
    {
        UIBackgroundTaskIdentifier identifier = _backgroundTaskIdentifier;
        _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        [application endBackgroundTask:identifier];
    }
    if (_backgroundTaskExpirationTimer != nil)
    {
        if ([_backgroundTaskExpirationTimer isValid])
            [_backgroundTaskExpirationTimer invalidate];
        _backgroundTaskExpirationTimer = nil;
    }
    
    if (_callingWebView != nil)
    {
        [_callingWebView stopLoading];
        _callingWebView = nil;
    }
    
    [[TGTelegramNetworking instance] resume];
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if ([ActionStageInstance() executingActorWithPath:@"/tg/service/updatepresence/(timeout)"] != nil)
            [ActionStageInstance() removeWatcher:TGTelegraphInstance fromPath:@"/tg/service/updatepresence/(timeout)"];
        else
            [TGTelegraphInstance updatePresenceNow];
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)__unused application
{
    //[ActionStageInstance() requestActor:@"/tg/locationServicesState/(dispatch)" options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithBool:true], @"dispatch", nil] watcher:TGTelegraphInstance];
    
    if (_didBecomeInactive)
    {
        _didBecomeInactive = false;
        
        [self onBecomeActive];
        
        if (_passcodeWindow != nil && [self isManuallyLocked])
        {
            [_window endEditing:true];
            
            TGPasscodeEntryController *controller = (TGPasscodeEntryController *)(((TGNavigationController *)_passcodeWindow.rootViewController).topViewController);
            [controller refreshTouchId];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)__unused application
{
    TGLogSynchronize();
}

- (void)resetLocalization
{
    [TGDateUtils reset];
    
    [_rootController localizationUpdated];
}

- (void)performPhoneCall:(NSURL *)url
{
    NSURL *realUrl = url;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        if ([url.scheme isEqualToString:@"tel"])
        {
            realUrl = [NSURL URLWithString:[[url absoluteString] stringByReplacingOccurrencesOfString:@"tel:" withString:@"facetime:"]];
        }
    }
    _callingWebView = [[UIWebView alloc] init];
    [_callingWebView loadRequest:[NSURLRequest requestWithURL:realUrl]];
}

- (void)presentLoginController:(bool)clearControllerStates showWelcomeScreen:(bool)showWelcomeScreen phoneNumber:(NSString *)phoneNumber phoneCode:(NSString *)phoneCode phoneCodeHash:(NSString *)phoneCodeHash codeSentToTelegram:(bool)codeSentToTelegram profileFirstName:(NSString *)profileFirstName profileLastName:(NSString *)profileLastName
{
    if (![[NSThread currentThread] isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self presentLoginController:clearControllerStates showWelcomeScreen:showWelcomeScreen phoneNumber:phoneNumber phoneCode:phoneCode phoneCodeHash:phoneCodeHash codeSentToTelegram:codeSentToTelegram profileFirstName:profileFirstName profileLastName:profileLastName];
        });
        
        return;
    }
    else
    {
        TGNavigationController *loginNavigationController = [self loginNavigationController];
        NSMutableArray *viewControllers = [[loginNavigationController viewControllers] mutableCopy];
        
        if (showWelcomeScreen)
        {
            TGLoginInactiveUserController *inactiveUserController = [[TGLoginInactiveUserController alloc] init];
            [viewControllers addObject:inactiveUserController];
        }
        else
        {
            if (phoneNumber.length != 0)
            {
                TGLoginPhoneController *phoneController = [[TGLoginPhoneController alloc] init];
                [(TGLoginPhoneController *)phoneController setPhoneNumber:phoneNumber];
                [viewControllers addObject:phoneController];
                
                NSMutableString *cleanPhone = [[NSMutableString alloc] init];
                for (int i = 0; i < (int)phoneNumber.length; i++)
                {
                    unichar c = [phoneNumber characterAtIndex:i];
                    if (c >= '0' && c <= '9')
                        [cleanPhone appendString:[[NSString alloc] initWithCharacters:&c length:1]];
                }
                
                if (phoneCode.length != 0 && phoneCodeHash.length != 0)
                {
                    TGLoginProfileController *profileController = [[TGLoginProfileController alloc] initWithShowKeyboard:true phoneNumber:cleanPhone phoneCodeHash:phoneCodeHash phoneCode:phoneCode];
                    [viewControllers addObject:profileController];
                }
                else if (phoneCodeHash.length != 0)
                {
                    TGLoginCodeController *codeController = [[TGLoginCodeController alloc] initWithShowKeyboard:true phoneNumber:cleanPhone phoneCodeHash:phoneCodeHash phoneTimeout:60.0 messageSentToTelegram:codeSentToTelegram];
                    [viewControllers addObject:codeController];
                }
            }
        }
        
        [loginNavigationController setViewControllers:viewControllers animated:false];
        
        if (TGAppDelegateInstance.rootController.presentedViewController != nil)
        {
            if (TGAppDelegateInstance.rootController.presentedViewController == loginNavigationController)
                return;
            
            [TGAppDelegateInstance.rootController dismissViewControllerAnimated:true completion:nil];
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^
            {
                [TGAppDelegateInstance.rootController presentViewController:loginNavigationController animated:[[UIApplication sharedApplication] applicationState] == UIApplicationStateActive completion:nil];
            });
        }
        else
            [TGAppDelegateInstance.rootController presentViewController:loginNavigationController animated:[[UIApplication sharedApplication] applicationState] == UIApplicationStateActive completion:nil];
        
        if (clearControllerStates)
        {
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^
            {
                [_rootController.mainTabsController setSelectedIndex:1];
                
                [_rootController.dialogListController.dialogListCompanion clearData];
                [_rootController.contactsController clearData];
                
                [TGAppDelegateInstance.rootController clearContentControllers];
                
                [TGAppDelegateInstance resetControllerStack];
            });
        }
    }
}

- (void)presentMainController
{
    if (![[NSThread currentThread] isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self presentMainController];
        });
        
        return;
    }
    
    self.loginNavigationController = nil;
    
    UIViewController *presentedViewController = nil;
    presentedViewController = TGAppDelegateInstance.rootController.presentedViewController;
    
    if ([presentedViewController respondsToSelector:@selector(isBeingDismissed)])
    {
        if ([presentedViewController isBeingDismissed] || [presentedViewController isBeingPresented])
        {
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            TGDispatchAfter(0.1, dispatch_get_main_queue(), ^
            {
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                
                [self presentMainController];
            });
        }
        else
        {
            [TGAppDelegateInstance.rootController dismissViewControllerAnimated:[[UIApplication sharedApplication] applicationState] == UIApplicationStateActive  completion:nil];
        }
    }
    else
    {
        [TGAppDelegateInstance.rootController dismissViewControllerAnimated:[[UIApplication sharedApplication] applicationState] == UIApplicationStateActive completion:nil];
    }
}

- (void)presentContentController:(UIViewController *)controller
{
    _contentWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _contentWindow.windowLevel = UIWindowLevelStatusBar - 0.1f;
    
    _contentWindow.rootViewController = controller;
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self dismissNotification];
        
        [_contentWindow makeKeyAndVisible];
    });
}

- (void)dismissContentController
{
    if ([_contentWindow.rootViewController conformsToProtocol:@protocol(TGContentViewController)])
    {
        [(id<TGContentViewController>)_contentWindow.rootViewController contentControllerWillBeDismissed];
    }
    
    [_contentWindow.rootViewController viewWillDisappear:false];
    [_contentWindow.rootViewController viewDidDisappear:false];
    _contentWindow.rootViewController = nil;
    if (_contentWindow.isKeyWindow)
        [_contentWindow resignKeyWindow];
    [_window makeKeyWindow];
    _contentWindow = nil;
    
    UIViewController *topViewController = TGAppDelegateInstance.rootController.viewControllers.lastObject;
    if ([topViewController conformsToProtocol:@protocol(TGDestructableViewController)] && [topViewController respondsToSelector:@selector(contentControllerWillBeDismissed)]) {
        [(id<TGDestructableViewController>)topViewController contentControllerWillBeDismissed];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if (!_window.isKeyWindow)
            [_window makeKeyWindow];
    });
}

- (void)openURLNative:(NSURL *)url
{
    [(TGApplication *)[UIApplication sharedApplication] openURL:url forceNative:true];
}

#pragma mark -

- (NSDictionary *)loadLoginState
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    NSData *stateData = [[NSData alloc] initWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:@"state.data"]];
    
    if (stateData.length != 0)
    {
        NSInputStream *is = [[NSInputStream alloc] initWithData:stateData];
        [is open];
        
        uint8_t version = 0;
        [is read:(uint8_t *)&version maxLength:1];
        
        {
            int date = [is readInt32];
            if (date != 0)
                dict[@"date"] = @(date);
        }
        
        {
            NSString *phoneNumber = [is readString];
            if (phoneNumber.length != 0)
                dict[@"phoneNumber"] = phoneNumber;
        }
        
        {
            NSString *phoneCode = [is readString];
            if (phoneCode.length != 0)
                dict[@"phoneCode"] = phoneCode;
        }
        
        {
            NSString *phoneCodeHash = [is readString];
            if (phoneCodeHash.length != 0)
                dict[@"phoneCodeHash"] = phoneCodeHash;
        }
        
        {
            NSString *firstName = [is readString];
            if (firstName.length != 0)
                dict[@"firstName"] = firstName;
        }
        
        {
            NSString *lastName = [is readString];
            if (lastName.length != 0)
                dict[@"lastName"] = lastName;
        }
        
        {
            NSData *photo = [is readBytes];
            if (photo.length != 0)
                dict[@"photo"] = photo;
        }
        
        if (version >= 1)
        {
            dict[@"codeSentToTelegram"] = @([is readInt32] != 0);
        }
        
        [is close];
    }
    
    return dict;
}

- (void)resetLoginState
{
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"state.data"] error:nil];
}

- (void)saveLoginStateWithDate:(int)date phoneNumber:(NSString *)phoneNumber phoneCode:(NSString *)phoneCode phoneCodeHash:(NSString *)phoneCodeHash codeSentToTelegram:(bool)codeSentToTelegram firstName:(NSString *)firstName lastName:(NSString *)lastName photo:(NSData *)photo
{
    NSOutputStream *os = [[NSOutputStream alloc] initToMemory];
    [os open];
    
    uint8_t version = 1;
    [os write:&version maxLength:1];
    
    [os writeInt32:date];
    
    [os writeString:phoneNumber];
    [os writeString:phoneCode];
    [os writeString:phoneCodeHash];
    [os writeString:firstName];
    [os writeString:lastName];
    [os writeBytes:photo];
    [os writeInt32:codeSentToTelegram ? 1 : 0];
    
    [os close];
    
    NSData *data = [os currentBytes];
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    [data writeToFile:[documentsDirectory stringByAppendingPathComponent:@"state.data"] atomically:true];
}

- (void)loadSettings
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    TGTelegraphInstance.clientUserId = [[userDefaults objectForKey:@"telegraphUserId"] intValue];
    TGTelegraphInstance.clientIsActivated = [[userDefaults objectForKey:@"telegraphUserActivated"] boolValue];
    
    TGLog(@"Activated = %d", TGTelegraphInstance.clientIsActivated ? 1 : 0);
    
    id value = nil;
    if ((value = [userDefaults objectForKey:@"soundEnabled"]) != nil)
        _soundEnabled = [value boolValue];
    else
        _soundEnabled = true;
    
    if ((value = [userDefaults objectForKey:@"outgoingSoundEnabled"]) != nil)
        _outgoingSoundEnabled = [value boolValue];
    else
        _outgoingSoundEnabled = true;
    
    if ((value = [userDefaults objectForKey:@"vibrationEnabled"]) != nil)
        _vibrationEnabled = [value boolValue];
    else
        _vibrationEnabled = false;
    
    if ((value = [userDefaults objectForKey:@"bannerEnabled"]) != nil)
        _bannerEnabled = [value boolValue];
    else
        _bannerEnabled = true;
    
    if ((value = [userDefaults objectForKey:@"locationTranslationEnabled"]) != nil)
        _locationTranslationEnabled = [value boolValue];
    else
        _locationTranslationEnabled = false;
    
    if ((value = [userDefaults objectForKey:@"exclusiveConversationControllers"]) != nil)
        _exclusiveConversationControllers = [value boolValue];
    else
        _exclusiveConversationControllers = true;
    
    if ((value = [userDefaults objectForKey:@"autosavePhotos"]) != nil)
        _autosavePhotos = [value boolValue];
    else
        _autosavePhotos = false;

    if ((value = [userDefaults objectForKey:@"customChatBackground"]) != nil)
        _customChatBackground = [value boolValue];
    else
    {
        _customChatBackground = false;
        
        NSString *imageUrl = @"wallpaper-original-pattern-default";
        NSString *thumbnailUrl = @"local://wallpaper-thumb-pattern-default";
        NSString *filePath = [[NSBundle mainBundle] pathForResource:imageUrl ofType:@"jpg"];
        int tintColor = 0x0c3259;
        
        if (filePath != nil)
        {
            NSFileManager *fileManager = [[NSFileManager alloc] init];
            NSString *documentsDirectory = [TGAppDelegate documentsPath];
            NSString *wallpapersPath = [documentsDirectory stringByAppendingPathComponent:@"wallpapers"];
            [fileManager createDirectoryAtPath:wallpapersPath withIntermediateDirectories:true attributes:nil error:nil];
            
            [fileManager copyItemAtPath:filePath toPath:[wallpapersPath stringByAppendingPathComponent:@"_custom.jpg"] error:nil];
            [[thumbnailUrl dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[wallpapersPath stringByAppendingPathComponent:@"_custom-meta"] atomically:false];
            
            [(tintColor == -1 ? [NSData data] : [[NSData alloc] initWithBytes:&tintColor length:4]) writeToFile:[wallpapersPath stringByAppendingPathComponent:@"_custom_mono.dat"] atomically:false];
            
            _customChatBackground = true;
        }
    }

    if ((value = [userDefaults objectForKey:@"useDifferentBackend"]) != nil)
        _useDifferentBackend = [value boolValue];
    else
        _useDifferentBackend = true;
    
    if ((value = [userDefaults objectForKey:@"baseFontSize"]) != nil)
        TGBaseFontSize = MAX(16, MIN(60, [value intValue]));
    else
        TGBaseFontSize = 16;
    
    if ((value = [userDefaults objectForKey:@"autoDownloadPhotosInGroups"]) != nil)
        _autoDownloadPhotosInGroups = [value boolValue];
    else
        _autoDownloadPhotosInGroups = true;
    
    if ((value = [userDefaults objectForKey:@"autoDownloadPhotosInPrivateChats"]) != nil)
        _autoDownloadPhotosInPrivateChats = [value boolValue];
    else
        _autoDownloadPhotosInPrivateChats = true;
    
    if ((value = [userDefaults objectForKey:@"autoDownloadAudioInGroups"]) != nil)
        _autoDownloadAudioInGroups = [value boolValue];
    else
        _autoDownloadAudioInGroups = true;
    
    if ((value = [userDefaults objectForKey:@"autoDownloadAudioInPrivateChats"]) != nil)
        _autoDownloadAudioInPrivateChats = [value boolValue];
    else
        _autoDownloadAudioInPrivateChats = true;
    
    if ((value = [userDefaults objectForKey:@"autoPlayAudio"]) != nil)
        _autoPlayAudio = [value boolValue];
    else
        _autoPlayAudio = false;
    
    if ((value = [userDefaults objectForKey:@"alwaysShowStickersMode"]) != nil)
        _alwaysShowStickersMode = [value intValue];
    else
        _alwaysShowStickersMode = false;
    
    _locationTranslationEnabled = false;
}

- (void)saveSettings
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:[[NSNumber alloc] initWithInt:TGTelegraphInstance.clientUserId] forKey:@"telegraphUserId"];
    [userDefaults setObject:[[NSNumber alloc] initWithBool:TGTelegraphInstance.clientIsActivated] forKey:@"telegraphUserActivated"];
    
    [userDefaults setObject:[NSNumber numberWithBool:_soundEnabled] forKey:@"soundEnabled"];
    [userDefaults setObject:[NSNumber numberWithBool:_outgoingSoundEnabled] forKey:@"outgoingSoundEnabled"];
    [userDefaults setObject:[NSNumber numberWithBool:_vibrationEnabled] forKey:@"vibrationEnabled"];
    [userDefaults setObject:[NSNumber numberWithBool:_bannerEnabled] forKey:@"bannerEnabled"];
    [userDefaults setObject:[NSNumber numberWithBool:_locationTranslationEnabled] forKey:@"locationTranslationEnabled"];
    [userDefaults setObject:[NSNumber numberWithBool:_exclusiveConversationControllers] forKey:@"exclusiveConversationControllers"];
    
    [userDefaults setObject:[NSNumber numberWithBool:_autosavePhotos] forKey:@"autosavePhotos"];
    [userDefaults setObject:[NSNumber numberWithBool:_customChatBackground] forKey:@"customChatBackground"];

    [userDefaults setObject:[NSNumber numberWithBool:_useDifferentBackend] forKey:@"useDifferentBackend"];

    [userDefaults setObject:[NSNumber numberWithInt:TGBaseFontSize] forKey:@"baseFontSize"];
    
    [userDefaults setObject:[NSNumber numberWithBool:_autoDownloadPhotosInGroups] forKey:@"autoDownloadPhotosInGroups"];
    [userDefaults setObject:[NSNumber numberWithBool:_autoDownloadPhotosInPrivateChats] forKey:@"autoDownloadPhotosInPrivateChats"];
    [userDefaults setObject:[NSNumber numberWithBool:_autoDownloadAudioInGroups] forKey:@"autoDownloadAudioInGroups"];
    [userDefaults setObject:[NSNumber numberWithBool:_autoDownloadAudioInPrivateChats] forKey:@"autoDownloadAudioInPrivateChats"];
    
    [userDefaults setObject:[NSNumber numberWithBool:_autoPlayAudio] forKey:@"autoPlayAudio"];
    
    [userDefaults setObject:[NSNumber numberWithInt:_alwaysShowStickersMode] forKey:@"alwaysShowStickersMode"];
    
    [userDefaults synchronize];
}

#pragma mark -

- (NSArray *)modernAlertSoundTitles
{
    static NSArray *soundArray = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:@"None"];
        [array addObject:@"Default"];
        [array addObject:@"Note"];
        [array addObject:@"Aurora"];
        [array addObject:@"Bamboo"];
        [array addObject:@"Chord"];
        [array addObject:@"Circles"];
        [array addObject:@"Complete"];
        [array addObject:@"Hello"];
        [array addObject:@"Input"];
        [array addObject:@"Keys"];
        [array addObject:@"Popcorn"];
        [array addObject:@"Pulse"];
        [array addObject:@"Synth"];
        soundArray = array;
    });
    
    return soundArray;
}

- (NSArray *)classicAlertSoundTitles
{
    static NSArray *soundArray = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:@"Tri-tone"];
        [array addObject:@"Tremolo"];
        [array addObject:@"Alert"];
        [array addObject:@"Bell"];
        [array addObject:@"Calypso"];
        [array addObject:@"Chime"];
        [array addObject:@"Glass"];
        [array addObject:@"Telegraph"];
        soundArray = array;
    });
    
    return soundArray;
}

- (void)playSound:(NSString *)name vibrate:(bool)vibrate
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
            return;
        
        if (name != nil && TGAppDelegateInstance.soundEnabled)
        {
            static NSMutableDictionary *soundPlayed = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                soundPlayed = [[NSMutableDictionary alloc] init];
            });
            
            double lastTimeSoundPlayed = [[soundPlayed objectForKey:name] doubleValue];
            
            CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
            if (currentTime - lastTimeSoundPlayed < 0.25)
                return;
        
            [soundPlayed setObject:[[NSNumber alloc] initWithDouble:currentTime] forKey:name];
        
            NSNumber *soundId = [_loadedSoundSamples objectForKey:name];
            if (soundId == nil)
            {
                NSString *path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], name];
                NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
                SystemSoundID sound;
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &sound);
                soundId = [NSNumber numberWithUnsignedLong:sound];
                [_loadedSoundSamples setObject:soundId forKey:name];
            }
            
            CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
            AudioServicesPlaySystemSound((SystemSoundID)[soundId unsignedLongValue]);
            TGLog(@"sound time: %f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
        }
        
        if (vibrate && TGAppDelegateInstance.vibrationEnabled)
        {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    });
}

- (void)playNotificationSound:(NSString *)name
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        _currentAudioPlayer.delegate = nil;
        _currentAudioPlayer = nil;
        
        NSError *error = nil;
        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:name withExtension: @"m4a"] error:&error];
        if (error == nil)
        {
            if (_currentAudioPlayerSession == nil)
                _currentAudioPlayerSession = [[SMetaDisposable alloc] init];
            [_currentAudioPlayerSession setDisposable:[[TGAudioSessionManager instance] requestSessionWithType:TGAudioSessionTypePlayMusic interrupted:^
            {
                _currentAudioPlayer.delegate = nil;
                [_currentAudioPlayer stop];
                _currentAudioPlayer = nil;
            }]];
            
            _currentAudioPlayer = audioPlayer;
            audioPlayer.delegate = self;
            [audioPlayer play];
        }
    });
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)__unused flag
{
    if (player == _currentAudioPlayer)
    {
        _currentAudioPlayer.delegate = nil;
        _currentAudioPlayer = nil;
        
        [_currentAudioPlayerSession setDisposable:nil];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)__unused player error:(NSError *)__unused error
{
    if (player == _currentAudioPlayer)
    {
        _currentAudioPlayer.delegate = nil;
        _currentAudioPlayer = nil;
    }
}

- (void)displayNotification:(NSString *)identifier timeout:(NSTimeInterval)timeout constructor:(UIView *(^)(UIView *existingView))constructor watcher:(ASHandle *)watcher watcherAction:(NSString *)watcherAction watcherOptions:(NSDictionary *)watcherOptions
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if (_contentWindow != nil || (_passcodeWindow != nil && !_passcodeWindow.hidden))
            return;
        
        static NSMutableDictionary *viewsByIdentifier = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            viewsByIdentifier = [[NSMutableDictionary alloc] init];
        });
        
        UIView *existingView = [viewsByIdentifier objectForKey:identifier];
        UIView *view = constructor(existingView);
        if (view != nil)
        {
            if (_notificationWindow == nil)
            {
                _notificationWindow = [[TGNotificationWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                _notificationWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                _notificationWindow.windowHeight = 20 + 44;
                //[_notificationWindow adjustToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
                _notificationWindow.windowLevel = UIWindowLevelStatusBar + 0.1f;
            }
            
            [_notificationWindow setContentView:view];
            _notificationWindow.watcher = watcher;
            _notificationWindow.watcherAction = watcherAction;
            _notificationWindow.watcherOptions = watcherOptions;
            [_notificationWindow animateIn];
            
            if (_notificationWindowTimeoutTimer != nil)
            {
                [_notificationWindowTimeoutTimer invalidate];
                _notificationWindowTimeoutTimer = nil;
            }
            
            _notificationWindowTimeoutTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:timeout] interval:timeout target:self selector:@selector(notificationWindowTimeoutTimerEvent) userInfo:nil repeats:false];
            [[NSRunLoop mainRunLoop] addTimer:_notificationWindowTimeoutTimer forMode:NSRunLoopCommonModes];
        }
    });
}

- (void)notificationWindowTimeoutTimerEvent
{
    _notificationWindowTimeoutTimer = nil;
    
    [_notificationWindow animateOut];
}

- (void)dismissNotification
{
    if (_notificationWindowTimeoutTimer != nil)
    {
        [_notificationWindowTimeoutTimer invalidate];
        _notificationWindowTimeoutTimer = nil;
    }
    
    [_notificationWindow animateOut];
}

- (UIView *)currentNotificationView
{
    return _notificationWindow.isDismissed ? nil : _notificationWindow.contentView;
}

#pragma mark -

- (void)requestDeviceToken:(id<TGDeviceTokenListener>)listener
{
    if (_tokenAlreadyRequested)
    {
        [_deviceTokenListener deviceTokenRequestCompleted:nil];
        return;
    }
    
    _deviceTokenListener = listener;
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIMutableUserNotificationCategory *muteActionCategory = [[UIMutableUserNotificationCategory alloc] init];
        [muteActionCategory setIdentifier:@"m"];
        
        UIMutableUserNotificationCategory *replyActionCategory = [[UIMutableUserNotificationCategory alloc] init];
        [replyActionCategory setIdentifier:@"r"];
        
        UIMutableUserNotificationCategory *channelActionCategory = [[UIMutableUserNotificationCategory alloc] init];
        [channelActionCategory setIdentifier:@"c"];

        bool exclusiveQuickReplySupported = ((iosMajorVersion() == 9 && iosMinorVersion() >= 1) || iosMajorVersion() > 9);
        {
            UIMutableUserNotificationAction *replyAction = [[UIMutableUserNotificationAction alloc] init];
            [replyAction setTitle:TGLocalized(@"Notification.Reply")];
            [replyAction setIdentifier:@"reply"];
            [replyAction setDestructive:false];
            if (iosMajorVersion() >= 9)
            {
                [replyAction setAuthenticationRequired:false];
                [replyAction setBehavior:UIUserNotificationActionBehaviorTextInput];
                [replyAction setActivationMode:UIUserNotificationActivationModeBackground];
            }
            else
            {
                [replyAction setAuthenticationRequired:true];
                [replyAction setActivationMode:UIUserNotificationActivationModeForeground];
            }
            
            UIMutableUserNotificationAction *muteAction = [[UIMutableUserNotificationAction alloc] init];
            [muteAction setActivationMode:UIUserNotificationActivationModeBackground];
            [muteAction setTitle:TGLocalized(@"Notification.Mute1h")];
            [muteAction setIdentifier:@"mute"];
            [muteAction setDestructive:true];
            [muteAction setAuthenticationRequired:false];
            
            if (exclusiveQuickReplySupported)
            {
                [muteActionCategory setActions:@[replyAction] forContext:UIUserNotificationActionContextDefault];
            }
            else
            {
                [muteActionCategory setActions:@[replyAction, muteAction] forContext:UIUserNotificationActionContextDefault];
            }
        }
        {
            UIMutableUserNotificationAction *replyAction = [[UIMutableUserNotificationAction alloc] init];
            [replyAction setTitle:TGLocalized(@"Notification.Reply")];
            [replyAction setIdentifier:@"reply"];
            [replyAction setDestructive:false];
            if (iosMajorVersion() >= 9)
            {
                [replyAction setAuthenticationRequired:false];
                [replyAction setBehavior:UIUserNotificationActionBehaviorTextInput];
                [replyAction setActivationMode:UIUserNotificationActivationModeBackground];
            }
            else
            {
                [replyAction setAuthenticationRequired:true];
                [replyAction setActivationMode:UIUserNotificationActivationModeForeground];
            }
            
            UIMutableUserNotificationAction *muteAction = [[UIMutableUserNotificationAction alloc] init];
            [muteAction setActivationMode:UIUserNotificationActivationModeBackground];
            [muteAction setTitle:TGLocalized(@"Notification.Mute1hMin")];
            [muteAction setIdentifier:@"mute"];
            [muteAction setDestructive:true];
            [muteAction setAuthenticationRequired:false];
            
            if (exclusiveQuickReplySupported)
            {
                [muteActionCategory setActions:@[replyAction] forContext:UIUserNotificationActionContextMinimal];
            }
            else
            {
                [muteActionCategory setActions:@[replyAction, muteAction] forContext:UIUserNotificationActionContextMinimal];
            }
        }
        
        {
            UIMutableUserNotificationAction *replyAction = [[UIMutableUserNotificationAction alloc] init];
            [replyAction setTitle:TGLocalized(@"Notification.Reply")];
            [replyAction setIdentifier:@"reply"];
            [replyAction setDestructive:false];
            if (iosMajorVersion() >= 9)
            {
                [replyAction setAuthenticationRequired:false];
                [replyAction setBehavior:UIUserNotificationActionBehaviorTextInput];
                [replyAction setActivationMode:UIUserNotificationActivationModeBackground];
            }
            else
            {
                [replyAction setAuthenticationRequired:true];
                [replyAction setActivationMode:UIUserNotificationActivationModeForeground];
            }
            
            UIMutableUserNotificationAction *likeAction = [[UIMutableUserNotificationAction alloc] init];
            [likeAction setActivationMode:UIUserNotificationActivationModeBackground];
            [likeAction setTitle:@"👍"];
            [likeAction setIdentifier:@"like"];
            [likeAction setDestructive:false];
            [likeAction setAuthenticationRequired:false];
            
            if (exclusiveQuickReplySupported)
            {
                [replyActionCategory setActions:@[replyAction] forContext:UIUserNotificationActionContextDefault];
            }
            else
            {
                [replyActionCategory setActions:@[replyAction, likeAction] forContext:UIUserNotificationActionContextDefault];
            }
        }
        {
            UIMutableUserNotificationAction *replyAction = [[UIMutableUserNotificationAction alloc] init];
            [replyAction setTitle:TGLocalized(@"Notification.Reply")];
            [replyAction setIdentifier:@"reply"];
            [replyAction setDestructive:false];
            if (iosMajorVersion() >= 9)
            {
                [replyAction setAuthenticationRequired:false];
                [replyAction setBehavior:UIUserNotificationActionBehaviorTextInput];
                [replyAction setActivationMode:UIUserNotificationActivationModeBackground];
            }
            else
            {
                [replyAction setAuthenticationRequired:true];
                [replyAction setActivationMode:UIUserNotificationActivationModeForeground];
            }
            
            UIMutableUserNotificationAction *likeAction = [[UIMutableUserNotificationAction alloc] init];
            [likeAction setActivationMode:UIUserNotificationActivationModeBackground];
            [likeAction setTitle:@"👍"];
            [likeAction setIdentifier:@"like"];
            [likeAction setDestructive:false];
            [likeAction setAuthenticationRequired:false];
            
            if (exclusiveQuickReplySupported)
            {
                [replyActionCategory setActions:@[replyAction] forContext:UIUserNotificationActionContextMinimal];
            }
            else
            {
                [replyActionCategory setActions:@[replyAction, likeAction] forContext:UIUserNotificationActionContextMinimal];
            }
        }
        
        {
            UIMutableUserNotificationAction *muteAction = [[UIMutableUserNotificationAction alloc] init];
            [muteAction setActivationMode:UIUserNotificationActivationModeBackground];
            [muteAction setTitle:TGLocalized(@"Notification.Mute1h")];
            [muteAction setIdentifier:@"mute"];
            [muteAction setDestructive:true];
            [muteAction setAuthenticationRequired:false];
            
            [channelActionCategory setActions:@[muteAction] forContext:UIUserNotificationActionContextDefault];
        }
        {
            UIMutableUserNotificationAction *muteAction = [[UIMutableUserNotificationAction alloc] init];
            [muteAction setActivationMode:UIUserNotificationActivationModeBackground];
            [muteAction setTitle:TGLocalized(@"Notification.Mute1hMin")];
            [muteAction setIdentifier:@"mute"];
            [muteAction setDestructive:true];
            [muteAction setAuthenticationRequired:false];
            
            [channelActionCategory setActions:@[muteAction] forContext:UIUserNotificationActionContextMinimal];
        }
        
        NSSet *categories = [NSSet setWithObjects:muteActionCategory, replyActionCategory, channelActionCategory, nil];
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)__unused notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication*)__unused application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    _tokenAlreadyRequested = true;
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    TGLog(@"Device token: %@", token);
    
    [_deviceTokenListener deviceTokenRequestCompleted:token];
    _deviceTokenListener = nil;
}

- (void)application:(UIApplication*)__unused application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    _tokenAlreadyRequested = true;
    
	TGLog(@"Failed register for remote notifications: %@", error);
    [_deviceTokenListener deviceTokenRequestCompleted:nil];
    _deviceTokenListener = nil;
}

- (void)application:(UIApplication *)__unused application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (iosMajorVersion() >= 8 && [notification.category isEqualToString:@"wr"])
    {
        [TGBridgeRemoteHandler handleLocalNotification:notification.userInfo];
        return;
    }
    
    if (!_inBackground || [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        return;
    
    int64_t peerId = [[notification.userInfo objectForKey:@"cid"] longLongValue];
    [self _replyActionForPeerId:peerId mid:0 openKeyboard:false responseInfo:nil completion:nil];
}

- (void)application:(UIApplication *)__unused application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
#ifdef DEBUG
    TGLog(@"remoteNotification: %@", userInfo);
#endif
    
    [self processPossibleConfigUpdateNotification:userInfo];
    
    if (!_inBackground)
        return;
    
    [self processRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)__unused application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self processPossibleConfigUpdateNotification:userInfo];
    
    if ([application applicationState] != UIApplicationStateActive)
    {
        if ([self isCurrentlyLocked] && (_passcodeWindow == nil || _passcodeWindow.hidden))
            [self displayUnlockWindowIfNeeded];
        
        [[TGTelegramNetworking instance] resume];
        
        if (completionHandler != nil)
        {
            [[TGTelegramNetworking instance] wakeUpWithCompletion:^
            {
                TGDispatchOnMainThread(^
                {
                    if (_inBackground)
                    {
                        [[TGTelegramNetworking instance] pause];
                        TGLog(@"paused network");
                        
                        NSTimeInterval remainingTime = [[UIApplication sharedApplication] backgroundTimeRemaining];
                        if (remainingTime > 2.0) {
                            TGDispatchAfter(MIN(remainingTime, 5.0), dispatch_get_main_queue(), ^
                            {
                                TGLog(@"completed fetch");
                                completionHandler(UIBackgroundFetchResultNewData);
                            });
                        } else {
                            completionHandler(UIBackgroundFetchResultNewData);
                        }
                    }
                });
            }];
        }
    }
    else if (completionHandler != nil)
        completionHandler(UIBackgroundFetchResultNewData);
    
    if (!_inBackground || !_enteringForeground)
        return;
    
    [self processRemoteNotification:userInfo];
}

- (void)processRemoteNotification:(NSDictionary *)userInfo
{
    [self processRemoteNotification:userInfo removeView:nil];
}

- (void)processRemoteNotification:(NSDictionary *)userInfo removeView:(UIView *)removeView
{
    if (TGTelegraphInstance.clientUserId == 0)
    {
        [removeView removeFromSuperview];
        return;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        return;
    
    id nFromId = [userInfo objectForKey:@"from_id"];
    id nChatId = [userInfo objectForKey:@"chat_id"];
    id nContactId = [userInfo objectForKey:@"contact_id"];
    id nChannelId = [userInfo objectForKey:@"channel_id"];
    
    int64_t conversationId = 0;
    
    if (nFromId != nil && [TGSchema canCreateIntFromObject:nFromId])
    {
        conversationId = [TGSchema intFromObject:nFromId];
    }
    else if (nChatId != nil && [TGSchema canCreateIntFromObject:nChatId])
    {
        conversationId = -[TGSchema intFromObject:nChatId];
    }
    else if (nContactId != nil && [TGSchema canCreateIntFromObject:nContactId])
    {
        conversationId = [TGSchema intFromObject:nContactId];
    }
    else if (nChannelId != nil && [TGSchema canCreateIntFromObject:nChannelId])
    {
        conversationId = TGPeerIdFromChannelId([TGSchema intFromObject:nChannelId]);
    }
    else
    {
        [removeView removeFromSuperview];
    }
    
    [self _replyActionForPeerId:conversationId mid:0 openKeyboard:false responseInfo:nil completion:nil];
}

- (void)processPossibleConfigUpdateNotification:(NSDictionary *)userInfo
{
    if (userInfo[@"dc"] != nil && [userInfo[@"dc"] respondsToSelector:@selector(intValue)] && userInfo[@"addr"] != nil && [userInfo[@"addr"] respondsToSelector:@selector(rangeOfString:)])
    {
        int datacenterId = [userInfo[@"dc"] intValue];
        
        NSString *addr = userInfo[@"addr"];
        NSRange range = [addr rangeOfString:@":"];
        if (range.location != NSNotFound)
        {
            NSString *ip = [addr substringWithRange:NSMakeRange(0, range.location)];
            int port = [[addr substringWithRange:NSMakeRange(range.location + 1, addr.length - range.location - 1)] intValue];
            
            TGLog(@"===== Updating dc%d: %@:%d", datacenterId, ip, port);
            
            if (ip.length != 0)
            {                
                [[TGTelegramNetworking instance] mergeDatacenterAddress:datacenterId address:[[MTDatacenterAddress alloc] initWithIp:ip port:(uint16_t)(port == 0 ? 443 : port) preferForMedia:false]];
            }
        }
    }
}

- (void)_generateUpdateNetworkConfigurationMessage
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        TGUser *selfUser = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
        if (selfUser != nil)
        {
            int uid = [TGTelegraphInstance createServiceUserIfNeeded];
            
            TGMessage *message = [[TGMessage alloc] init];
            message.mid = [[[TGDatabaseInstance() generateLocalMids:1] objectAtIndex:0] intValue];
            
            message.fromUid = uid;
            message.toUid = TGTelegraphInstance.clientUserId;
            message.date = (int)[[TGTelegramNetworking instance] approximateRemoteTime];
            message.unread = false;
            message.outgoing = false;
            message.cid = uid;
            
            NSString *displayName = selfUser.firstName;
            if (displayName.length == 0)
                displayName = selfUser.lastName;
            
            message.text = TGLocalized(@"Service.NetworkConfigurationUpdatedMessage");
            
            static int messageActionId = 1000000;
            [[[TGConversationAddMessagesActor alloc] initWithPath:[NSString stringWithFormat:@"/tg/addmessage/(%dact3)", messageActionId++]] execute:[NSDictionary dictionaryWithObjectsAndKeys:[[NSArray alloc] initWithObjects:message, nil], @"messages", nil]];
        }
    }];
}

- (NSUInteger)application:(UIApplication *)__unused application supportedInterfaceOrientationsForWindow:(UIWindow *)__unused window
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? UIInterfaceOrientationMaskAllButUpsideDown : UIInterfaceOrientationMaskAll;
}

#pragma mark - BITUpdateManagerDelegate

- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)__unused updateManager
{
#if defined(DEBUG) || defined(INTERNAL_RELEASE)
    TGLog(@"returning devide identifier");
    if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)])
        return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
#endif
    return nil;
}

- (void)reloadSettingsController:(int)uid
{
    TGAccountSettingsController *accountSettingsController = [[TGAccountSettingsController alloc] initWithUid:uid];
    
    int index = -1;
    for (id controller in _rootController.mainTabsController.viewControllers)
    {
        index++;
        if ([controller isKindOfClass:[TGAccountSettingsController class]])
            break;
    }
    
    if (index != -1)
    {
        NSMutableArray *viewControllers = [_rootController.mainTabsController.viewControllers mutableCopy];
        [viewControllers replaceObjectAtIndex:index withObject:accountSettingsController];
        [_rootController.mainTabsController setViewControllers:viewControllers];
        _rootController.accountSettingsController = accountSettingsController;
    }
}

- (BOOL)application:(UIApplication *)__unused application openURL:(NSURL *)url sourceApplication:(NSString *)__unused sourceApplication annotation:(id)__unused annotation
{
    [self handleOpenDocument:url animated:false];
    
    return true;
}

- (void)resetControllerStack
{
    [TGAppDelegateInstance.rootController clearContentControllers];
}

- (void)handleOpenDocument:(NSURL *)url animated:(bool)__unused animated
{
    if (TGTelegraphInstance.clientUserId != 0 && TGTelegraphInstance.clientIsActivated)
    {
        if ([url isFileURL])
        {
            [self resetControllerStack];
            
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[url path] error:nil];
            
            if (attributes != nil)
            {
                int fileSize = [[attributes objectForKey:NSFileSize] intValue];
                
                TGForwardTargetController *forwardController = [[TGForwardTargetController alloc] initWithDocumentFile:url size:fileSize];
                TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[forwardController]];
                [TGAppDelegateInstance.rootController dismissViewControllerAnimated:false completion:nil];
                
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [TGAppDelegateInstance.rootController presentViewController:navigationController animated:false completion:nil];
                });
            }
        }
        else if ([url.scheme isEqualToString:@"telegram"] || [url.scheme isEqualToString:@"tg"])
        {
            if ([url.resourceSpecifier hasPrefix:@"//share?"])
            {
                NSMutableArray *uploadFileArray = [[NSMutableArray alloc] init];
                NSMutableArray *forwardMessageArray = [[NSMutableArray alloc] init];
                NSMutableArray *sendMessageArray = [[NSMutableArray alloc] init];
                
                NSString *groupName = [@"group." stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]];
                
                NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupName];
                if (groupURL != nil)
                {
                    NSURL *inboxUrl = [groupURL URLByAppendingPathComponent:@"share-inbox" isDirectory:true];
                    
                    [[NSFileManager defaultManager] createDirectoryAtURL:inboxUrl withIntermediateDirectories:true attributes:nil error:nil];
                    
                    NSDictionary *dict = [TGStringUtils argumentDictionaryInUrlString:[url query]];
                    NSUInteger counter = 0;
                    while (true)
                    {
                        NSString *fileId = [[NSString alloc] initWithFormat:@"f%d", (int)counter];
                        if (dict[fileId] != nil)
                        {
                            NSURL *fileUrl = [inboxUrl URLByAppendingPathComponent:dict[fileId]];
                            
                            NSString *fileType = @"raw";
                            NSString *rawFileType = dict[[[NSString alloc] initWithFormat:@"t%d", (int)counter]];
                            
                            if ([rawFileType isEqualToString:@"i"])
                                fileType = @"image";
                            else if ([rawFileType isEqualToString:@"v"])
                                fileType = @"video";
                            
                            NSString *fileName = dict[[[NSString alloc] initWithFormat:@"n%d", (int)counter]];
                            
                            [uploadFileArray addObject:@{@"url": fileUrl, @"type": fileType, @"fileName": fileName == nil ? @"" : fileName}];
                            
                            counter++;
                        }
                        else
                        {
                            NSString *internalMessageIdString = dict[[[NSString alloc] initWithFormat:@"m%d", (int)counter]];
                            if (internalMessageIdString != nil)
                            {
                                TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:[internalMessageIdString intValue] peerId:0];
                                if (message == nil)
                                {
                                    message = [TGDatabaseInstance() loadMediaMessageWithMid:[internalMessageIdString intValue]];
                                }
                                
                                if (message != nil)
                                    [forwardMessageArray addObject:message];
                                
                                counter++;
                            }
                            else
                            {
                                NSString *urlString = dict[[[NSString alloc] initWithFormat:@"u%d", (int)counter]];
                                if (urlString != nil)
                                {
                                    TGMessage *message = [[TGMessage alloc] init];
                                    message.text = urlString;
                                    [sendMessageArray addObject:message];
                                    
                                    counter++;
                                }
                                else
                                    break;
                            }
                        }
                    }
                }
                
                if (uploadFileArray.count != 0)
                {
                    TGForwardTargetController *forwardController = [[TGForwardTargetController alloc] initWithDocumentFiles:uploadFileArray];
                    forwardController.controllerTitle = TGLocalized(@"Share.Title");
                    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[forwardController]];
                    
                    [_rootController clearContentControllers];
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                    {
                        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
                        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^
                    {
                        [_rootController presentViewController:navigationController animated:false completion:nil];
                    });
                }
                else if (forwardMessageArray.count != 0 || sendMessageArray.count != 0)
                {
                    TGForwardTargetController *forwardController = [[TGForwardTargetController alloc] initWithForwardMessages:forwardMessageArray sendMessages:sendMessageArray showSecretChats:true];
                    
                    forwardController.controllerTitle = TGLocalized(@"Share.Title");
                    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[forwardController]];
                    
                    [_rootController clearContentControllers];
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                    {
                        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
                        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^
                    {
                        [_rootController presentViewController:navigationController animated:false completion:nil];
                    });
                }
            }
            else if ([url.resourceSpecifier hasPrefix:@"//msg?"])
            {
                NSDictionary *dict = [TGStringUtils argumentDictionaryInUrlString:[url query]];
                
                std::map<int, int> phoneIdToUid;
                [TGDatabaseInstance() loadRemoteContactUidsContactIds:phoneIdToUid];
                
                if ([dict[@"to"] respondsToSelector:@selector(characterAtIndex:)] && [(NSString *)dict[@"to"] length] != 0)
                {
                    int32_t phoneId = phoneMatchHash(dict[@"to"]);
                    
                    for (auto it : phoneIdToUid)
                    {
                        if (it.first == phoneId)
                        {
                            NSDictionary *actions = nil;
                            if ([dict[@"text"] respondsToSelector:@selector(characterAtIndex:)] && [(NSString *)dict[@"text"] length] != 0)
                            {
                                actions = @{@"text": dict[@"text"]};
                            }
                            [[TGInterfaceManager instance] navigateToConversationWithId:it.second conversation:nil performActions:actions animated:false];
                            
                            break;
                        }
                    }
                }
                else if ([dict[@"text"] respondsToSelector:@selector(characterAtIndex:)] && [(NSString *)dict[@"text"] length] != 0)
                {
                    TGMessage *message = [[TGMessage alloc] init];
                    message.text = dict[@"text"];
                    
                    TGForwardTargetController *forwardController = [[TGForwardTargetController alloc] initWithForwardMessages:nil sendMessages:@[message] showSecretChats:true];
                    
                    [self resetControllerStack];
                    
                    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[forwardController]];
                    
                    [_rootController clearContentControllers];
                    [_rootController dismissViewControllerAnimated:false completion:nil];
                    
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                    {
                        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
                        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                    }
                    
                    [_rootController presentViewController:navigationController animated:false completion:nil];
                }
            }
            else if ([url.resourceSpecifier hasPrefix:@"//download-language?"])
            {
                NSDictionary *dict = [TGStringUtils argumentDictionaryInUrlString:[url query]];
                
                if ([dict[@"url"] respondsToSelector:@selector(characterAtIndex:)])
                {
                    [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/downloadLocalization/(%d)", murMurHash32(dict[@"url"])] options:@{@"url": dict[@"url"]} flags:0 watcher:TGTelegraphInstance];
                }
            }
            else if ([url.resourceSpecifier hasPrefix:@"//resolve?"])
            {
                NSDictionary *dict = [TGStringUtils argumentDictionaryInUrlString:[url query]];
                
                if ([dict[@"domain"] respondsToSelector:@selector(characterAtIndex:)])
                {
                    [_rootController dismissViewControllerAnimated:false completion:nil];
                    
                    NSMutableDictionary *arguments = [[NSMutableDictionary alloc] init];
                    if (dict[@"start"] != nil)
                        arguments[@"start"] = dict[@"start"];
                    if (dict[@"startgroup"] != nil)
                        arguments[@"startgroup"] = dict[@"startgroup"];
                    
                    [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/resolveDomain/(%@)", dict[@"domain"]] options:@{@"domain": dict[@"domain"], @"arguments": arguments} flags:0 watcher:TGTelegraphInstance];
                }
            }
            else if ([url.resourceSpecifier hasPrefix:@"//join?"])
            {
                NSDictionary *dict = [TGStringUtils argumentDictionaryInUrlString:[url query]];
                if ([dict[@"invite"] respondsToSelector:@selector(characterAtIndex:)])
                {
                    [_rootController dismissViewControllerAnimated:false completion:nil];
                    
                    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                    [progressWindow show:true];
                    
                    [[[[TGGroupManagementSignals groupInvitationLinkInfo:dict[@"invite"]] deliverOn:[SQueue mainQueue]] onDispose:^
                    {
                        TGDispatchOnMainThread(^
                        {
                            [progressWindow dismiss:true];
                        });
                    }] startWithNext:^(TGGroupInvitationInfo *invitationInfo)
                    {
                        if (invitationInfo.alreadyAccepted && !invitationInfo.left)
                        {
                            NSString *format = TGLocalized(@"GroupInfo.InvitationLinkAlreadyAccepted");
                            NSString *text = [[NSString alloc] initWithFormat:format, invitationInfo.title];
                            [[[TGAlertView alloc] initWithTitle:nil message:text cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
                        }
                        else
                        {
                            NSString *format = TGLocalized(@"GroupInfo.InvitationLinkAccept");
                            if (invitationInfo.isChannel) {
                                format = TGLocalized(@"GroupInfo.InvitationLinkAcceptChannel");
                            }
                            NSString *text = [[NSString alloc] initWithFormat:format, invitationInfo.title];
                            [[[TGAlertView alloc] initWithTitle:nil message:text cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed)
                            {
                                if (okButtonPressed)
                                {
                                    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                                    [progressWindow show:true];
                                    
                                    [[[[TGGroupManagementSignals acceptGroupInvitationLink:dict[@"invite"]] deliverOn:[SQueue mainQueue]] onDispose:^
                                    {
                                        TGDispatchOnMainThread(^
                                        {
                                            [progressWindow dismiss:true];
                                        });
                                    }] startWithNext:^(TGConversation *conversation)
                                    {
                                        [[TGInterfaceManager instance] navigateToConversationWithId:conversation.conversationId conversation:conversation.isChannel ? conversation : nil];
                                    } error:^(__unused id error)
                                    {
                                        NSString *text = TGLocalized(@"GroupInfo.InvitationLinkDoesNotExist");
                                        if ([error respondsToSelector:@selector(characterAtIndex:)])
                                        {
                                            if ([error isEqualToString:@"USERS_TOO_MUCH"])
                                                text = TGLocalized(@"GroupInfo.InvitationLinkGroupFull");
                                        }
                                        [[[TGAlertView alloc] initWithTitle:nil message:text cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
                                    } completed:nil];
                                }
                            }] show];
                        }
                    } error:^(id error)
                    {
                        NSString *text = TGLocalized(@"GroupInfo.InvitationLinkDoesNotExist");
                        if ([error respondsToSelector:@selector(characterAtIndex:)])
                        {
                            if ([error isEqualToString:@"USER_ALREADY_PARTICIPANT"])
                                text = TGLocalized(@"GroupInfo.InvitationLinkAlreadyAccepted");
                        }
                        [[[TGAlertView alloc] initWithTitle:nil message:text cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
                    } completed:nil];
                }
            }
            else if ([url.resourceSpecifier hasPrefix:@"//addstickers?"])
            {
                NSDictionary *dict = [TGStringUtils argumentDictionaryInUrlString:[url query]];
                if ([dict[@"set"] respondsToSelector:@selector(characterAtIndex:)])
                {
                    TGStickerPackShortnameReference *packReference = [[TGStickerPackShortnameReference alloc] initWithShortName:dict[@"set"]];
                    
                    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                    [progressWindow show:true];
                    
                    SSignal *stickerPackInfo = [TGStickersSignals stickerPackInfo:packReference];
                    SSignal *currentStickerPacks = [[TGStickersSignals stickerPacks] take:1];
                    SSignal *combinedSignal = [SSignal combineSignals:@[stickerPackInfo, currentStickerPacks]];
                    
                    [[[combinedSignal deliverOn:[SQueue mainQueue]] onDispose:^
                    {
                        TGDispatchOnMainThread(^
                        {
                            [progressWindow dismiss:true];
                        });
                    }] startWithNext:^(NSArray *combined)
                    {
                        [self previewStickerPack:combined[0] currentStickerPacks:combined[1][@"packs"]];
                    } error:^(__unused id error)
                    {
                        
                    } completed:nil];
                }
            }
        }
        else if ([url.scheme isEqualToString:[TGDropboxHelper dropboxURLScheme]])
        {
            [TGDropboxHelper handleOpenURL:url];
        }
    }
}

- (NSString *)stickerPackShortname:(TGStickerPack *)stickerPack
{
    NSString *shortName = nil;
    if ([stickerPack.packReference isKindOfClass:[TGStickerPackIdReference class]])
        shortName = ((TGStickerPackIdReference *)stickerPack.packReference).shortName;
    else if ([stickerPack.packReference isKindOfClass:[TGStickerPackShortnameReference class]])
        shortName = ((TGStickerPackShortnameReference *)stickerPack.packReference).shortName;
    return shortName;
}

- (void)previewStickerPack:(TGStickerPack *)stickerPack currentStickerPacks:(NSArray *)currentStickerPacks
{
    TGStickerPackPreviewWindow *previewWindow = [[TGStickerPackPreviewWindow alloc] initWithParentController:_rootController.dialogListController stickerPack:stickerPack];
    __weak TGStickerPackPreviewWindow *weakPreviewWindow = previewWindow;
    
    bool alreadyInstalled = false;
    for (TGStickerPack *currentStickerPack in currentStickerPacks)
    {
        if ([stickerPack.packReference isEqual:currentStickerPack.packReference])
        {
            alreadyInstalled = true;
            break;
        }
    }
    
    if (!alreadyInstalled && [self stickerPackShortname:stickerPack].length != 0)
    {
        NSString *text = [[NSString alloc] initWithFormat:TGLocalized([TGStringUtils integerValueFormat:@"StickerPack.AddStickerCount_" value:stickerPack.documents.count]), [TGStringUtils stringWithLocalizedNumber:(NSInteger)stickerPack.documents.count]];
        [previewWindow.view setAction:^
        {
            __strong TGStickerPackPreviewWindow *strongPreviewWindow = weakPreviewWindow;
            if (strongPreviewWindow != nil)
            {
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                [progressWindow show:true];
                
                [[[[TGStickersSignals installStickerPack:stickerPack.packReference] deliverOn:[SQueue mainQueue]] onDispose:^
                {
                    TGDispatchOnMainThread(^
                    {
                        [progressWindow dismissWithSuccess];
                    });
                }] startWithNext:nil error:nil completed:^
                {
                    __strong TGStickerPackPreviewWindow *strongPreviewWindow = weakPreviewWindow;
                    [strongPreviewWindow.view animateDismiss:^
                    {
                        __strong TGStickerPackPreviewWindow *strongPreviewWindow = weakPreviewWindow;
                        if (strongPreviewWindow != nil)
                            [strongPreviewWindow dismiss];
                    }];
                }];
            }
        } title:text];
    }
    previewWindow.view.dismiss = ^
    {
        __strong TGStickerPackPreviewWindow *strongPreviewWindow = weakPreviewWindow;
        if (strongPreviewWindow != nil)
            [strongPreviewWindow dismiss];
    };
    previewWindow.hidden = false;
}

- (void)readyToApplyLocalizationFromFile:(NSString *)filePath warnings:(NSString *)warnings
{
    [[[TGAlertView alloc] initWithTitle:nil message:warnings.length == 0 ? TGLocalized(@"Service.ApplyLocalization") : [[NSString alloc] initWithFormat:TGLocalized(@"Service.ApplyLocalizationWithWarnings"), warnings] cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed)
    {
        if (okButtonPressed)
        {
            TGSetLocalizationFromFile(filePath);
            [TGAppDelegateInstance resetLocalization];
            
            [self resetControllerStack];
        }
    }] show];
}

- (BOOL)application:(UIApplication *)__unused application willContinueUserActivityWithType:(NSString *)userActivityType
{
    if ([userActivityType isEqualToString:@"org.telegram.conversation"]) {
        if (_progressWindow != nil) {
            [_progressWindow dismiss:true];
        }
        
        _progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_progressWindow show:true];
    }
    
    return true;
}

- (BOOL)application:(UIApplication *)__unused application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))__unused restorationHandler
{
    [_progressWindow dismiss:true];
    
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        [application openURL:userActivity.webpageURL];
    } else if ([userActivity.activityType isEqualToString:@"org.telegram.conversation"]) {
        if ([userActivity.userInfo[@"user_id"] intValue] == TGTelegraphInstance.clientUserId)
        {
            int64_t peerId = 0;
            
            if ([userActivity.userInfo[@"peer"][@"type"] isEqual:@"user"])
                peerId = [userActivity.userInfo[@"peer"][@"id"] intValue];
            else if ([userActivity.userInfo[@"peer"][@"type"] isEqual:@"group"])
                peerId = -[userActivity.userInfo[@"peer"][@"id"] intValue];
            
            if (peerId != 0)
            {
                [[TGInterfaceManager instance] navigateToConversationWithId:peerId conversation:nil performActions:userActivity.userInfo[@"text"] == nil ? nil : @{@"text": userActivity.userInfo[@"text"]} animated:false];
                
                bool didSetText = false;
                TGModernConversationController *controller = [[TGInterfaceManager instance] currentControllerWithPeerId:peerId];
                if (controller != nil)
                    didSetText = TGStringCompare(userActivity.userInfo[@"text"], [controller inputText]);
                
                if (didSetText)
                {
                    [userActivity getContinuationStreamsWithCompletionHandler:^(__unused NSInputStream *inputStream, NSOutputStream *outputStream, NSError *error)
                    {
                        if (error == nil)
                        {
                            @try {
                                [outputStream open];
                                [outputStream close];
                            }
                            @catch (NSException *exception) {
                            }
                            @finally {
                            }
                        }
                    }];
                }
            }
        }
    }
    
    return true;
}

- (void)application:(UIApplication *)__unused application didFailToContinueUserActivityWithType:(NSString *)__unused userActivityType error:(NSError *)__unused error
{
    [_progressWindow dismiss:true];   
}

- (void)application:(UIApplication *)__unused application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    [_rootController clearContentControllers];
    [_rootController.mainTabsController setSelectedIndex:1];
    
    if ([shortcutItem.type isEqualToString:@"compose"])
    {
        [_rootController.dialogListController.dialogListCompanion composeMessage];
    }
    else if ([shortcutItem.type isEqualToString:@"search"])
    {
        [_rootController.dialogListController startSearch];
    }
    
    if (completionHandler != nil)
        completionHandler(true);
}

- (void)application:(UIApplication *)__unused application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    [self application:application handleActionWithIdentifier:identifier forRemoteNotification:userInfo withResponseInfo:@{} completionHandler:completionHandler];
}

- (void)application:(UIApplication *)__unused application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(nonnull NSDictionary *)responseInfo completionHandler:(nonnull void (^)())completionHandler
{
    id nFromId = [userInfo objectForKey:@"from_id"];
    id nChatId = [userInfo objectForKey:@"chat_id"];
    id nContactId = [userInfo objectForKey:@"contact_id"];
    id nChannelId = [userInfo objectForKey:@"channel_id"];
    id nMid = [userInfo objectForKey:@"msg_id"];
    
    int64_t peerId = 0;
    int32_t mid = 0;
    
    if (nFromId != nil && [TGSchema canCreateIntFromObject:nFromId])
        peerId = [TGSchema intFromObject:nFromId];
    else if (nChatId != nil && [TGSchema canCreateIntFromObject:nChatId])
        peerId = -[TGSchema intFromObject:nChatId];
    else if (nContactId != nil && [TGSchema canCreateIntFromObject:nContactId])
        peerId = [TGSchema intFromObject:nContactId];
    else if (nChannelId != nil && [TGSchema canCreateIntFromObject:nChannelId])
        peerId = TGPeerIdFromChannelId([TGSchema intFromObject:nChannelId]);
    
    if (nMid != nil && [TGSchema canCreateIntFromObject:nMid])
        mid = [TGSchema intFromObject:nMid];
    
    if ([identifier isEqualToString:@"reply"])
        [self _replyActionForPeerId:peerId mid:mid openKeyboard:true responseInfo:responseInfo completion:completionHandler];
    else if ([identifier isEqualToString:@"like"])
        [self _likeActionForPeerId:peerId completion:completionHandler];
    else if ([identifier isEqualToString:@"mute"])
        [self _muteActionForPeerId:peerId completion:completionHandler];
    else if (completionHandler)
        completionHandler();
}

- (void)application:(UIApplication *)__unused application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    [self application:application handleActionWithIdentifier:identifier forLocalNotification:notification withResponseInfo:@{} completionHandler:completionHandler];
}

- (void)application:(UIApplication *)__unused application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(nonnull NSDictionary *)responseInfo completionHandler:(nonnull void (^)())completionHandler
{
    int64_t peerId = [notification.userInfo[@"cid"] longLongValue];
    int32_t mid = [notification.userInfo[@"mid"] int32Value];
    
    if ([identifier isEqualToString:@"reply"])
        [self _replyActionForPeerId:peerId mid:mid openKeyboard:true responseInfo:responseInfo completion:completionHandler];
    else if ([identifier isEqualToString:@"like"])
        [self _likeActionForPeerId:peerId completion:completionHandler];
    else if ([identifier isEqualToString:@"mute"])
        [self _muteActionForPeerId:peerId completion:completionHandler];
    else if (completionHandler)
        completionHandler();
}

- (void)_replyActionForPeerId:(int64_t)peerId mid:(int32_t)mid openKeyboard:(bool)openKeyboard responseInfo:(NSDictionary *)responseInfo completion:(void (^)())completion
{
    if (iosMajorVersion() >= 9 && openKeyboard)
    {
        if (peerId == 0)
            return;
        
        int32_t replyToMid = 0;
        if (TGPeerIdIsGroup(peerId))
            replyToMid = mid;
        
        void (^suspendBlock)(void) = ^
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                [ActionStageInstance() removeWatcher:TGTelegraphInstance fromPath:@"/tg/service/updatepresence/(online)"];
                [ActionStageInstance() removeWatcher:TGTelegraphInstance fromPath:@"/tg/service/updatepresence/(offline)"];
                [ActionStageInstance() requestActor:@"/tg/service/updatepresence/(timeout)" options:nil watcher:TGTelegraphInstance];
            }];
            
            TGDispatchAfter(5.0, dispatch_get_main_queue(), ^
            {
                [[TGTelegramNetworking instance] wakeUpWithCompletion:^
                {
                    TGDispatchOnMainThread(^
                    {
                        if (_inBackground)
                        {
                            [[TGTelegramNetworking instance] pause];
                            if (completion)
                                completion();
                        }
                    });
                }];
            });
        };
        
        NSString *text = responseInfo[UIUserNotificationActionResponseTypedTextKey];
        NSString *trimmedText = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (trimmedText.length == 0)
        {
            suspendBlock();
        }
        else
        {
            [[[[TGSendMessageSignals sendTextMessageWithPeerId:peerId text:text replyToMid:replyToMid] then:[[TGChatMessageListSignal readChatMessageListWithPeerId:peerId] delay:1.5 onQueue:[SQueue mainQueue]]] catch:^SSignal *(__unused id error)
            {
                suspendBlock();
                return nil;
            }] startWithNext:nil error: nil completed:^
            {
                suspendBlock();
            }];
        }
        
        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
            [[TGTelegramNetworking instance] resume];
    }
    else
    {
        
        TGLog(@"Reply action for %" PRId64 "", peerId);
        if (peerId != 0 && [TGDatabaseInstance() loadConversationWithId:peerId] != nil)
        {
            [[TGInterfaceManager instance] navigateToConversationWithId:peerId conversation:nil performActions:nil atMessage:nil clearStack:true openKeyboard:openKeyboard && (_passcodeWindow == nil || _passcodeWindow.hidden) animated:false];
        }
        
        if (completion)
            completion();
    }
}

- (void)_likeActionForPeerId:(int64_t)peerId completion:(void (^)())completion
{
    [[TGSendMessageSignals sendTextMessageWithPeerId:peerId text:@"👍" replyToMid:0] startWithNext:nil error: nil completed: ^
    {
        TGDispatchOnMainThread(^
        {
            if (_inBackground)
            {
                [[TGTelegramNetworking instance] pause];
                if (completion)
                    completion();
            }
        });
    }];
    
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
        [[TGTelegramNetworking instance] resume];
}

- (void)_muteActionForPeerId:(int64_t)peerId completion:(void (^)())completion
{
    int muteUntil = 0;
    [TGDatabaseInstance() loadPeerNotificationSettings:peerId soundId:NULL muteUntil:&muteUntil previewText:NULL photoNotificationsEnabled:NULL notFound:NULL];
    
    int muteTime = 1 * 60 * 60;
    
    muteUntil = MAX(muteUntil, (int)[[TGTelegramNetworking instance] approximateRemoteTime] + muteTime);
    
    static int actionId = 0;
    
    void (^muteBlock)(int64_t, int32_t, NSNumber *) = ^(int64_t peerId, int32_t muteUntil, NSNumber *accessHash)
    {
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:@{ @"peerId": @(peerId), @"muteUntil": @(muteUntil) }];
        if (accessHash != nil)
            options[@"accessHash"] = accessHash;
        
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%" PRId64 ")/(muteAction%d)", peerId, actionId++] options:options watcher:TGTelegraphInstance];
    };
    
    if (TGPeerIdIsChannel(peerId))
    {
        [[[TGDatabaseInstance() existingChannel:peerId] take:1] startWithNext:^(TGConversation *channel)
        {
            muteBlock(peerId, muteUntil, @(channel.accessHash));
        }];
    }
    else
    {
        muteBlock(peerId, muteUntil, nil);
    }
    
    
    TGDispatchAfter(9.0, dispatch_get_main_queue(), ^
    {
        if (completion)
            completion();
    });
    
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
    {
        [[TGTelegramNetworking instance] resume];
        
        if (completion != nil)
        {
            [[TGTelegramNetworking instance] wakeUpWithCompletion:^
            {
                TGDispatchOnMainThread(^
                {
                    if (_inBackground)
                    {
                        [[TGTelegramNetworking instance] pause];
                        
                        if (completion != nil)
                            completion();
                    }
                });
            }];
        }
    }
}

- (bool)isManuallyLocked
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"Passcode_lockManually"] boolValue];
}

- (int32_t)automaticLockTimeout
{
    NSNumber *nLockTimeout = [[NSUserDefaults standardUserDefaults] objectForKey:@"Passcode_lockTimeout"];
    if (nLockTimeout == nil)
        return 1 * 60 * 60;
    return (int32_t)[nLockTimeout intValue];
}

- (void)setAutomaticLockTimeout:(int32_t)automaticLockTimeout
{
    [[NSUserDefaults standardUserDefaults] setObject:@(automaticLockTimeout) forKey:@"Passcode_lockTimeout"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setIsManuallyLocked:(bool)isLocked
{
    [[NSUserDefaults standardUserDefaults] setObject:@(isLocked) forKey:@"Passcode_lockManually"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [ActionStageInstance() dispatchResource:@"/databasePasswordChanged" resource:nil];
}

- (bool)isCurrentlyLocked
{
    return [self isCurrentlyLocked:NULL];
}

- (bool)isCurrentlyLocked:(bool *)byTimeout
{
    if ([TGDatabaseInstance() isPasswordSet:NULL])
    {
        NSNumber *nDeactivationDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"Passcode_deactivationDate"];
        bool displayByDeactivationTimeout = false;
        if (nDeactivationDate != nil)
        {
            int32_t lockTimeout = [self automaticLockTimeout];
            if (lockTimeout >= 0)
            {
                displayByDeactivationTimeout = [[NSDate date] timeIntervalSince1970] > ([nDeactivationDate doubleValue] + lockTimeout);
                if (byTimeout)
                    *byTimeout = displayByDeactivationTimeout;
            }
        }
        
        return [self isManuallyLocked] || displayByDeactivationTimeout;
    }
    
    return false;
}

- (bool)isDisplayingPasscodeWindow
{
    return _passcodeWindow != nil && !_passcodeWindow.hidden;
}

- (void)onBecomeInactive
{
    if ([self isCurrentlyLocked])
    {
        [self setIsManuallyLocked:true];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Passcode_deactivationDate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@([[NSDate date] timeIntervalSince1970]) forKey:@"Passcode_deactivationDate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if ([TGDatabaseInstance() isPasswordSet:NULL])
    {
        if (TGTelegraphInstance.clientUserId != 0)
        {
            TLRPCaccount_updateDeviceLocked$account_updateDeviceLocked *updateDeviceLocked = [[TLRPCaccount_updateDeviceLocked$account_updateDeviceLocked alloc] init];
            if ([self isManuallyLocked])
                updateDeviceLocked.period = 0;
            else
                updateDeviceLocked.period = [self automaticLockTimeout];
            
            if (_deviceLockedRequestDisposable == nil)
                _deviceLockedRequestDisposable = [[SMetaDisposable alloc] init];
            
            [_deviceLockedRequestDisposable setDisposable:[[[TGTelegramNetworking instance] requestSignal:updateDeviceLocked] startWithNext:^(__unused id next)
            {
            }]];
            
            _didUpdateDeviceLocked = true;
        }
    }
}

- (void)onBecomeActive
{
    if (_didUpdateDeviceLocked)
    {
        _didUpdateDeviceLocked = false;
        
        [self resetRemoteDeviceLocked];
    }
    
    if ([self isCurrentlyLocked])
    {
        [self setIsManuallyLocked:true];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Passcode_deactivationDate"];
    }
    
    [self displayUnlockWindowIfNeeded];
}

- (void)resetRemoteDeviceLocked
{
    if (TGTelegraphInstance.clientUserId != 0)
    {
        TLRPCaccount_updateDeviceLocked$account_updateDeviceLocked *updateDeviceLocked = [[TLRPCaccount_updateDeviceLocked$account_updateDeviceLocked alloc] init];
        updateDeviceLocked.period = -1;
        
        if (_deviceLockedRequestDisposable == nil)
            _deviceLockedRequestDisposable = [[SMetaDisposable alloc] init];
        
        [_deviceLockedRequestDisposable setDisposable:[[[TGTelegramNetworking instance] requestSignal:updateDeviceLocked] startWithNext:^(__unused id next)
        {
            
        }]];
    }
}

+ (void)movePathsToContainer
{
    if (iosMajorVersion() >= 8)
    {
        NSString *groupName = [@"group." stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSURL *groupURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:groupName];
        if (groupURL != nil)
        {
            NSString *documentsPath = [[groupURL path] stringByAppendingPathComponent:@"Documents"];
            
            [fileManager createDirectoryAtPath:documentsPath withIntermediateDirectories:true attributes:nil error:NULL];
            
            NSString *defaultDocumentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0];
            NSArray *documentItems = [fileManager contentsOfDirectoryAtPath:defaultDocumentsPath error:nil];
            int documentFileCount = 0;
            for (NSString *fileName in documentItems)
            {
                documentFileCount++;
                [fileManager moveItemAtPath:[defaultDocumentsPath stringByAppendingPathComponent:fileName] toPath:[documentsPath stringByAppendingPathComponent:fileName] error:nil];
            }
            
            TGLog(@"Moved %d document items to container", documentFileCount);
            
            NSString *cachesPath = [[groupURL path] stringByAppendingPathComponent:@"Caches"];
            
            [fileManager createDirectoryAtPath:cachesPath withIntermediateDirectories:true attributes:nil error:NULL];
            
            NSString *defaultCachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true)[0];
            NSArray *cacheItems = [fileManager contentsOfDirectoryAtPath:defaultCachesPath error:nil];
            int cacheFileCount = 0;
            for (NSString *fileName in cacheItems)
            {
                cacheFileCount++;
                [fileManager moveItemAtPath:[defaultCachesPath stringByAppendingPathComponent:fileName] toPath:[cachesPath stringByAppendingPathComponent:fileName] error:nil];
            }
            
            TGLog(@"Moved %d cache items to container", cacheFileCount);
        }
    }
}

+ (NSString *)documentsPath
{
    static NSString *path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (iosMajorVersion() >= 8)
        {
            NSString *groupName = [@"group." stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]];
            
            NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupName];
            if (groupURL != nil)
            {
                NSString *documentsPath = [[groupURL path] stringByAppendingPathComponent:@"Documents"];
                
                [[NSFileManager defaultManager] createDirectoryAtPath:documentsPath withIntermediateDirectories:true attributes:nil error:NULL];
                
                path = documentsPath;
            }
            else
                path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0];
        }
        else
            path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0];
    });
    
    return path;
}

+ (NSString *)cachePath
{
    static NSString *path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (iosMajorVersion() >= 8)
        {
            NSString *groupName = [@"group." stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]];
            
            NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupName];
            if (groupURL != nil)
            {
                NSString *cachePath = [[groupURL path] stringByAppendingPathComponent:@"Caches"];
                
                [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:true attributes:nil error:NULL];
                
                path = cachePath;
            }
            else
                path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true)[0];
        }
        else
            path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true)[0];
    });
    
    return path;
}

- (void)inviteBotToGroup:(TGUser *)user payload:(NSString *)payload
{
    TGForwardTargetController *controller = [[TGForwardTargetController alloc] initWithSelectGroup];
    controller.watcherHandle = self.actionHandle;
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller] navigationBarClass:[TGWhiteNavigationBar class]];
    
    if ([_rootController.viewControllers.lastObject isKindOfClass:[TGModernConversationController class]]) {
        [(TGModernConversationController *)_rootController.viewControllers.lastObject hideKeyboard];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self resetControllerStack];
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [_rootController presentViewController:navigationController animated:true completion:nil];
    });
    
    _currentInviteBot = user;
    _currentInviteBotPayload = payload;
}


- (void)setupShortcutItems
{
    if (iosMajorVersion() < 9 || [UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPhone)
        return;
    
    if (TGTelegraphInstance.clientUserId != 0 && TGTelegraphInstance.clientIsActivated)
    {
        UIApplicationShortcutItem *composeItem = [[UIApplicationShortcutItem alloc] initWithType:@"compose" localizedTitle:TGLocalized(@"Compose.NewMessage") localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeCompose] userInfo:nil];
        
        UIApplicationShortcutItem *searchItem = [[UIApplicationShortcutItem alloc] initWithType:@"search" localizedTitle:TGLocalized(@"Common.Search") localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeSearch] userInfo:nil];
        
        NSArray *shortcuts = @[ composeItem, searchItem ];
        [UIApplication sharedApplication].shortcutItems = shortcuts;
    }
    else
    {
        [UIApplication sharedApplication].shortcutItems = nil;
    }
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"willForwardMessages"])
    {
        int32_t uid = _currentInviteBot.uid;
        NSString *payload = _currentInviteBotPayload;
        _currentInviteBot = nil;
        _currentInviteBotPayload = nil;
        if (uid != 0 && payload.length != 0)
        {
            TGConversation *conversation = options[@"target"];
            
            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [progressWindow show:true];
            
            [[[[TGBotSignals botInviteUserId:uid toGroupId:(int32_t)conversation.conversationId payload:payload] deliverOn:[SQueue mainQueue]] onDispose:^
            {
                [progressWindow dismiss:true];
            }] startWithNext:^(__unused id next)
            {
                [[(UIViewController *)options[@"controller"] presentingViewController] dismissViewControllerAnimated:true completion:nil];
                [[TGInterfaceManager instance] navigateToConversationWithId:conversation.conversationId conversation:nil];
            } error:^(id error)
            {
                NSString *errorDescription = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
                NSString *alertText = TGLocalized(@"ConversationProfile.UnknownAddMemberError");
                if ([errorDescription isEqualToString:@"USER_ALREADY_PARTICIPANT"])
                    alertText = TGLocalized(@"Target.InviteToGroupErrorAlreadyInvited");
                
                [[[TGAlertView alloc] initWithTitle:nil message:alertText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
            } completed:nil];
        }
    }
}

@end

@interface UICollectionViewDisableForwardToUICollectionViewSentinel : NSObject @end @implementation UICollectionViewDisableForwardToUICollectionViewSentinel @end
