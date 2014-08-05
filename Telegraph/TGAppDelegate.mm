#import "TGAppDelegate.h"

#import "Freedom.h"
#import "FreedomUIKit.h"

#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"

#import "TGGlobalContext.h"

#import "TGPhoneMainViewController.h"
#import "TGTabletMainViewController.h"

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

#import "TGContentViewController.h"

#import "TGModernConversationController.h"
#import "TGGenericModernConversationCompanion.h"

#import "TGOverlayControllerWindow.h"
#import "TGModernGalleryController.h"
#import "TGModernGallerySecretImageItem.h"
#import "TGModernGallerySecretVideoItem.h"

#import "TGSecretModernConversationCompanion.h"

#import "TGForwardTargetController.h"

#import "TGTimerTarget.h"

#import "TGAlertView.h"

#import <pthread.h>

#import <objc/runtime.h>

#import <AVFoundation/AVFoundation.h>

#include <inttypes.h>

#define TG_SYNCHRONIZED_DEFINE(lock) pthread_mutex_t TG_SYNCHRONIZED_##lock
#define TG_SYNCHRONIZED_INIT(lock) pthread_mutex_init(&TG_SYNCHRONIZED_##lock, NULL)
#define TG_SYNCHRONIZED_BEGIN(lock) pthread_mutex_lock(&TG_SYNCHRONIZED_##lock);
#define TG_SYNCHRONIZED_END(lock) pthread_mutex_unlock(&TG_SYNCHRONIZED_##lock);

#import <HockeySDK/HockeySDK.h>

CFAbsoluteTime applicationStartupTimestamp = 0;
CFAbsoluteTime mainLaunchTimestamp = 0;

NSArray *preloadedDialogList = nil;
NSArray *preloadedDialogListUids = nil;

dispatch_semaphore_t preloadedDialogListSemaphore = NULL;

static void printStartupCheckpoint(int index)
{
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    TGLog(@"<<< Checkpoint %d-%d: %d ms >>>", index - 1, index, (int)((currentTime - mainLaunchTimestamp) * 1000));
    mainLaunchTimestamp = currentTime;
}

TGAppDelegate *TGAppDelegateInstance = nil;
TGTelegraph *telegraph = nil;

@interface TGAppDelegate () <BITHockeyManagerDelegate, BITUpdateManagerDelegate, BITCrashManagerDelegate, AVAudioPlayerDelegate>
{
    bool _inBackground;
    bool _enteringForeground;
    
    NSTimer *_foregroundResumeTimer;
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

@end

@implementation TGAppDelegate

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

+ (void)beginEarlyInitialization
{
    preloadedDialogListSemaphore = dispatch_semaphore_create(0);
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
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
        
        TGLog(@"###### Early initialization ######");
        
        [TGDatabase setDatabaseName:@"tgdata"];
        [TGDatabase setLiveMessagesDispatchPath:@"/tg/conversations"];
        [TGDatabase setLiveBroadcastMessagesDispatchPath:@"/tg/broadcastConversations"];
        [TGDatabase setLiveUnreadCountDispatchPath:@"/tg/unreadCount"];
        
/*#if TARGET_IPHONE_SIMULATOR
        [TGDatabaseInstance() loadMessagesFromConversation:-90443398 maxMid:INT_MAX maxDate:INT_MAX maxLocalMid:INT_MAX atMessageId:0 limit:10000 extraUnread:false completion:^(NSArray *messages, __unused bool historyExistsBelow) {
            for (TGMessage *message in messages)
            {
                if (message.mid >= 37830)
                {
                    std::vector<TGDatabaseMessageFlagValue> flags;
                    TGDatabaseMessageFlagValue unreadFlag = {TGDatabaseMessageFlagUnread, true};
                    flags.push_back(unreadFlag);
                    
                    [TGDatabaseInstance() updateMessage:message.mid flags:flags dispatch:false];
                }
            }
        }];
#endif*/
        
        [[TGDatabase instance] markAllPendingMessagesAsFailed];
        [[TGDatabase instance] loadConversationListInitial:^(NSArray *dialogList, NSArray *userIds)
        {   
            TGLog(@"###### Dialog list loaded ######");
            
            preloadedDialogList = dialogList;
            preloadedDialogListUids = userIds;
            
            dispatch_semaphore_signal(preloadedDialogListSemaphore);
        }];
    }];
}

static void overridenDrawRect(__unused id self, __unused SEL _cmd, __unused CGRect rect)
{
}

static unsigned int overrideIndexAbove(__unused id self, __unused SEL _cmd)
{
    return [(TGNavigationBar *)self indexAboveBackdropBackground];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _globalContext = [[TGGlobalContext alloc] initWithName:@"default"];
    
    [FFNotificationCenter setShouldRotateBlock:^ bool()
    {
        return [_window.rootViewController shouldAutorotate];
    }];
    
    freedomInit();
    
    printStartupCheckpoint(-1);
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
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
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
    
    printStartupCheckpoint(0);
    
    [TGHacks hackSetAnimationDuration];
    
    printStartupCheckpoint(1);
    
    //[[TGDatabase instance] dropDatabase];
    
    printStartupCheckpoint(3);
    
    printStartupCheckpoint(4);
    
    TGTelegraphDialogListCompanion *dialogListCompanion = [[TGTelegraphDialogListCompanion alloc] init];
    dialogListCompanion.showBroadcastsMenu = true;
    _dialogListController = [[TGDialogListController alloc] initWithCompanion:dialogListCompanion];
    
    _contactsController = [[TGContactsController alloc] initWithContactsMode:TGContactsModeMainContacts | TGContactsModeRegistered | TGContactsModePhonebook];
    
    //_addContactsController.tabBarItem.title = TGLocalized(@"AddContacts.TabTitle");
    //_addContactsController.tabBarItem.image = [UIImage imageNamed:@"Tabbar_Add.png"];
    
    _settingsController = [[TGAccountSettingsController alloc] initWithUid:0];
    
    printStartupCheckpoint(5);
    
    _mainTabsController = [[TGMainTabsController alloc] init];
    [_mainTabsController setViewControllers:[NSArray arrayWithObjects:_contactsController, _dialogListController, _settingsController, nil]];
    [_mainTabsController setSelectedIndex:1];
    
    printStartupCheckpoint(6);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        _phoneMainViewController = [[TGPhoneMainViewController alloc] initWithGlobalContext:_globalContext];
        
        _mainNavigationController = [TGNavigationController navigationControllerWithRootController:_mainTabsController];
        self.window.rootViewController = _mainNavigationController;
    }
    else
    {
        _tabletMainViewController = [[TGTabletMainViewController alloc] init];
        
        _tabletMainViewController.masterViewController = [TGNavigationController navigationControllerWithControllers:@[_mainTabsController]];
        
        //_mainNavigationController = [TGNavigationController navigationControllerWithRootController:_tabletMainViewController];
        
        self.window.rootViewController = _tabletMainViewController;
    }
    
    printStartupCheckpoint(7);
    
    self.window.backgroundColor = [UIColor blackColor];
    
    [self.window makeKeyAndVisible];
    
    TGCache *sharedCache = [[TGCache alloc] init];
    //sharedCache.imageMemoryLimit = 0;
    //sharedCache.imageMemoryEvictionInterval = 0;
    [TGRemoteImageView setSharedCache:sharedCache];
    
    printStartupCheckpoint(8);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
    //dispatch_async(dispatch_get_main_queue(), ^
    {
        [self loadSettings];
        
        dispatch_semaphore_wait(preloadedDialogListSemaphore, DISPATCH_TIME_FOREVER);
        
        SGraphListNode *node = [[SGraphListNode alloc] init];
        node.items = preloadedDialogList;
        
        std::vector<int> uids;
        for (NSNumber *nUid in preloadedDialogListUids)
        {
            uids.push_back([nUid intValue]);
        }
        [TGDatabaseInstance() loadUsers:uids];
        [(id<ASWatcher>)_dialogListController.dialogListCompanion actorCompleted:ASStatusSuccess path:@"/tg/dialoglist/(0)" result:node];
        TGLog(@"===== Dispatched dialog list");
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            printStartupCheckpoint(9);
            
            [[TGTelegramNetworking instance] loadCredentials];
            
            if (TGTelegraphInstance.clientUserId != 0)
            {
                printStartupCheckpoint(11);
                
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
                
                printStartupCheckpoint(12);
                
            }
            else
            {
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
        }];
    });
    
#ifndef EXTERNAL_INTERNAL_RELEASE
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^
    {
        NSString *appId = nil;
        
#if defined(DEBUG) || defined(INTERNAL_RELEASE)
        if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"org.telegram.TelegramEnterprise"])
            appId = @"3ad4b94adc8b2ccddcea172a1cfc0af2";
        else if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"org.telegram.TelegramHD"])
            appId = @"9b35ab047aa742d7604372d155da96f6";
        else
            appId = @"af86b54bbc799bd3e6d570ae30035037";
#else
        appId = @"af8bed54bcf6227c821901dbd47a2510";
#endif
        
        TGLog(@"starting with %@", appId);
        
        [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:appId delegate:self];
        [[BITHockeyManager sharedHockeyManager] startManager];
        [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    });
#endif
    
    if (iosMajorVersion() >= 7)
    {
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freedomOne:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    }
    
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
    
    return true;
}

- (void)freedomOne:(NSNotification *)__unused notification
{
    bool foundOverlay = false;
    
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if ([window isKindOfClass:[TGOverlayControllerWindow class]])
        {
            TGOverlayControllerWindow *overlayControllerWindow = (TGOverlayControllerWindow *)window;
            if ([overlayControllerWindow.rootViewController isKindOfClass:[TGModernGalleryController class]])
            {
                TGModernGalleryController *galleryController = (TGModernGalleryController *)overlayControllerWindow.rootViewController;
                for (id item in galleryController.items)
                {
                    int32_t secretMessageId = 0;
                    if ([item isKindOfClass:[TGModernGallerySecretImageItem class]])
                        secretMessageId = ((TGModernGallerySecretImageItem *)item).messageId;
                    if ([item isKindOfClass:[TGModernGallerySecretVideoItem class]])
                        secretMessageId = ((TGModernGallerySecretVideoItem *)item).messageId;
                    
                    if (secretMessageId != 0)
                    {
                        [TGDatabaseInstance() dispatchOnDatabaseThread:^
                        {
                            int messageFlags = [TGDatabaseInstance() secretMessageFlags:secretMessageId];
                            if ((messageFlags & TGSecretMessageFlagScreenshot) == 0)
                            {
                                messageFlags |= TGSecretMessageFlagScreenshot;
                                TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:secretMessageId];
                                if (message != nil)
                                {
                                    [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%" PRId64 ")/messageFlagChanges", message.cid] resource:@{@(secretMessageId): @(messageFlags)}];
                                    
                                    int64_t encryptedConversationId = [TGDatabaseInstance() encryptedConversationIdForPeerId:message.cid];
                                    int64_t randomId = [TGDatabaseInstance() randomIdForMessageId:secretMessageId];
                                    
                                    if (encryptedConversationId != 0 && randomId != 0)
                                    {
                                        [TGDatabaseInstance() raiseSecretMessageFlagsByRandomId:randomId flagsToRise:TGSecretMessageFlagScreenshot];
                                        
                                        int64_t actionRandomId = 0;
                                        arc4random_buf(&actionRandomId, 8);
                                        [TGDatabaseInstance() storeFutureActions:@[[[TGEncryptedChatServiceAction alloc] initWithEncryptedConversationId:encryptedConversationId messageRandomId:actionRandomId action:TGEncryptedChatServiceActionMessageScreenshotTaken actionContext:randomId]]];
                                        [ActionStageInstance() requestActor:@"/tg/service/synchronizeserviceactions/(settings)" options:nil watcher:TGTelegraphInstance];
                                    }
                                }
                            }
                        } synchronous:false];
                        
                        foundOverlay = true;
                        
                        break;
                    }
                }
            }
        }
    }
    
    if (!foundOverlay)
    {
//#if TG_MODERN_SECRET_MEDIA
        if ([_mainNavigationController.topViewController isKindOfClass:[TGModernConversationController class]])
        {
            TGModernConversationController *conversationController = (TGModernConversationController *)_mainNavigationController.topViewController;
            TGGenericModernConversationCompanion *companion = (TGGenericModernConversationCompanion *)conversationController.companion;
            if ([companion isKindOfClass:[TGSecretModernConversationCompanion class]])
            {
                int64_t conversationId = companion.conversationId;
                if (conversationId != 0)
                {
                    [TGDatabaseInstance() dispatchOnDatabaseThread:^
                    {
                        int64_t encryptedConversationId = [TGDatabaseInstance() encryptedConversationIdForPeerId:conversationId];
                        
                        int64_t actionRandomId = 0;
                        arc4random_buf(&actionRandomId, 8);
                        [TGDatabaseInstance() storeFutureActions:@[[[TGEncryptedChatServiceAction alloc] initWithEncryptedConversationId:encryptedConversationId messageRandomId:actionRandomId action:TGEncryptedChatServiceActionChatScreenshotTaken actionContext:0]]];
                        [ActionStageInstance() requestActor:@"/tg/service/synchronizeserviceactions/(settings)" options:nil watcher:TGTelegraphInstance];
                    } synchronous:false];
                }
            }
        }
//#endif
    }
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
}

- (void)applicationSignificantTimeChange:(UIApplication *)__unused application
{
    TGLog(@"***** Significant time change");
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [ActionStageInstance() dispatchResource:@"/system/significantTimeChange" resource:nil];
    }];
    
    [TGDatabaseInstance() processAndScheduleSelfDestruct];
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
    
    [ActionStageInstance() requestActor:@"/tg/service/updatepresence/(timeout)" options:nil watcher:TGTelegraphInstance];
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
    
    
}

- (void)applicationWillTerminate:(UIApplication *)__unused application
{
    TGLogSynchronize();
}

- (void)resetLocalization
{
    [TGDateUtils reset];
    
    [_mainTabsController localizationUpdated];
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
        
        UINavigationController *containingNavigationController = nil;
        UIViewController *presentingController = nil;
        if (TGAppDelegateInstance.phoneMainViewController != nil)
        {
            containingNavigationController = TGAppDelegateInstance.mainNavigationController;
            presentingController = containingNavigationController;
        }
        else
        {
            containingNavigationController = (UINavigationController *)(TGAppDelegateInstance.tabletMainViewController.detailViewController);
            presentingController = TGAppDelegateInstance.tabletMainViewController;
        }
        
        if (presentingController.presentedViewController != nil)
        {
            if (presentingController.presentedViewController == loginNavigationController)
                return;
            
            [presentingController dismissViewControllerAnimated:true completion:nil];
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^
            {
                [presentingController presentViewController:loginNavigationController animated:[[UIApplication sharedApplication] applicationState] == UIApplicationStateActive completion:nil];
            });
        }
        else
            [presentingController presentViewController:loginNavigationController animated:[[UIApplication sharedApplication] applicationState] == UIApplicationStateActive completion:nil];
        
        if (clearControllerStates)
        {
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^
            {
                [_mainTabsController setSelectedIndex:1];
                
                [_dialogListController.dialogListCompanion clearData];
                [_contactsController clearData];
                //[_addContactsController clearData];
                
                //NSArray *controllers = [_mainNavigationController.viewControllers copy];
                
                [containingNavigationController popToViewController:[containingNavigationController.viewControllers objectAtIndex:0] animated:false];
                
                [TGAppDelegateInstance resetControllerStack];
                
                /*for (int i = 1; i < (int)controllers.count; i++)
                {
                    UIViewController *controller = [controllers objectAtIndex:i];
                    if ([controller conformsToProtocol:@protocol(TGDestructableViewController)])
                        [(id<TGDestructableViewController>)controller cleanupBeforeDestruction];
                }*/
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
    
    UINavigationController *containingNavigationController = nil;
    UIViewController *presentingController = nil;
    if (TGAppDelegateInstance.phoneMainViewController != nil)
    {
        containingNavigationController = TGAppDelegateInstance.mainNavigationController;
        presentingController = containingNavigationController;
    }
    else
    {
        containingNavigationController = (UINavigationController *)(TGAppDelegateInstance.tabletMainViewController.detailViewController);
        presentingController = TGAppDelegateInstance.tabletMainViewController;
    }
    
    self.loginNavigationController = nil;
    
    UIViewController *presentedViewController = nil;
    presentedViewController = presentingController.presentedViewController;
    
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
            [presentingController dismissViewControllerAnimated:[[UIApplication sharedApplication] applicationState] == UIApplicationStateActive  completion:nil];
        }
    }
    else
    {
        [presentingController dismissViewControllerAnimated:[[UIApplication sharedApplication] applicationState] == UIApplicationStateActive completion:nil];
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
    
    if ([self.mainNavigationController.topViewController conformsToProtocol:@protocol(TGDestructableViewController)] && [self.mainNavigationController.topViewController respondsToSelector:@selector(contentControllerWillBeDismissed)])
        [(id<TGDestructableViewController>)self.mainNavigationController.topViewController contentControllerWillBeDismissed];
    
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
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) objectAtIndex:0];
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
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) objectAtIndex:0];
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
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) objectAtIndex:0];
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
            NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) objectAtIndex:0];
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
        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive || name == nil)
            return;
        
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
        
        if (name != nil)
        {
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
            AudioServicesPlaySystemSound((SystemSoundID)[soundId unsignedLongValue]);
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
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:NULL];
            [[AVAudioSession sharedInstance] setActive:true error:NULL];
            
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
        
        [[AVAudioSession sharedInstance] setActive:false error:NULL];
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
        if (_contentWindow != nil)
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
                _notificationWindow = [[TGNotificationWindow alloc] initWithFrame:CGRectZero];
                _notificationWindow.windowHeight = 20 + 44;
                [_notificationWindow adjustToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
                _notificationWindow.windowLevel = UIWindowLevelStatusBar + 0.1f;
                //_notificationWindow.backgroundColor = [UIColor greenColor];
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
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
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
    if (!_inBackground || [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        return;
    
    int64_t conversationId = [[notification.userInfo objectForKey:@"cid"] longLongValue];
    
    if (conversationId != 0 && _mainNavigationController.topViewController != _mainTabsController)
    {
        bool foundActive = false;
        
        for (UIViewController *controller in _mainNavigationController.viewControllers)
        {
            if ([controller isKindOfClass:[TGModernConversationController class]])
            {
                TGModernConversationController *conversationController = (TGModernConversationController *)controller;
                if (((TGGenericModernConversationCompanion *)conversationController.companion).conversationId == conversationId)
                {
                    foundActive = true;
                    break;
                }
            }
        }
        
        if (!foundActive)
        {
            [self dismissContentController];
            
#warning TODO reset back id
            //[TGModernConversationController resetLastConversationIdForBackAction];
            [self resetControllerStack];
            if (_mainTabsController.selectedIndex != 1)
                [_mainTabsController setSelectedIndex:1];
        }
    }
}

- (void)application:(UIApplication *)__unused application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self processPossibleConfigUpdateNotification:userInfo];
    
    if (!_inBackground)
        return;
    
    [self processRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)__unused application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    /*if (![[UIApplication sharedApplication] isProtectedDataAvailable])
    {
        TGLog(@"[wake up failed because protected data was not available]");
        completionHandler(UIBackgroundFetchResultFailed);
        
        return;
    }*/
    
    [self processPossibleConfigUpdateNotification:userInfo];
    
    if ([application applicationState] != UIApplicationStateActive)
    {
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
                        completionHandler(UIBackgroundFetchResultNewData);
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
    
    int conversationId = 0;
    
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
    else
    {
        [removeView removeFromSuperview];
    }
    
    if (conversationId != 0 && _mainNavigationController.topViewController != _mainTabsController)
    {
        bool foundActive = false;
        
        for (UIViewController *controller in _mainNavigationController.viewControllers)
        {
            if ([controller isKindOfClass:[TGModernConversationController class]])
            {
                TGModernConversationController *conversationController = (TGModernConversationController *)controller;
                if (((TGGenericModernConversationCompanion *)conversationController.companion).conversationId == conversationId)
                {
                    foundActive = true;
                    break;
                }
            }
        }
        
        if (!foundActive)
        {
            [self dismissContentController];
            
#warning TODO same here
            //[TGConversationController resetLastConversationIdForBackAction];
            [self resetControllerStack];
            if (_mainTabsController.selectedIndex != 1)
                [_mainTabsController setSelectedIndex:1];
        }
    }
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
                [[TGTelegramNetworking instance] mergeDatacenterAddress:datacenterId address:[[MTDatacenterAddress alloc] initWithIp:ip port:(uint16_t)(port == 0 ? 443 : port)]];
            }
        }
    }
}

- (NSUInteger)application:(UIApplication *)__unused application supportedInterfaceOrientationsForWindow:(UIWindow *)__unused window
{
#if TG_USE_CUSTOM_CAMERA
    if ([window isKindOfClass:[TGCameraWindow class]])
    {
        return UIInterfaceOrientationMaskPortrait;
    }
#endif
    
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
    for (id controller in _mainTabsController.viewControllers)
    {
        index++;
        if ([controller isKindOfClass:[TGAccountSettingsController class]])
            break;
    }
    
    if (index != -1)
    {
        NSMutableArray *viewControllers = [_mainTabsController.viewControllers mutableCopy];
        [viewControllers replaceObjectAtIndex:index withObject:accountSettingsController];
        [_mainTabsController setViewControllers:viewControllers];
        _settingsController = accountSettingsController;
    }
}

- (BOOL)application:(UIApplication *)__unused application openURL:(NSURL *)url sourceApplication:(NSString *)__unused sourceApplication annotation:(id)__unused annotation
{
    [self handleOpenDocument:url animated:false];
    
    return true;
}

- (void)resetControllerStack
{
    if (TGAppDelegateInstance.tabletMainViewController != nil)
        TGAppDelegateInstance.tabletMainViewController.detailViewController = nil;
    else
        [TGAppDelegateInstance.mainNavigationController popToRootViewControllerAnimated:true];
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
                
                NSString *extension = [url lastPathComponent].pathExtension;
                if ([[extension lowercaseString] isEqualToString:@"gif"])
                {
                    
                }
                
                TGForwardTargetController *forwardController = [[TGForwardTargetController alloc] initWithDocumentFile:url size:fileSize];
                TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[forwardController]];
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                {
                    navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
                    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                }
                [_mainTabsController presentViewController:navigationController animated:false completion:nil];
            }
        }
        else if ([url.scheme isEqualToString:@"telegram"] || [url.scheme isEqualToString:@"tg"])
        {
            if ([url.resourceSpecifier hasPrefix:@"//msg?"])
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
                    
                    TGForwardTargetController *forwardController = [[TGForwardTargetController alloc] initWithForwardMessages:nil sendMessages:@[message]];
                    
                    [self resetControllerStack];
                    
                    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[forwardController]];
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                    {
                        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
                        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                    }
                    [_mainTabsController presentViewController:navigationController animated:false completion:nil];
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
        }
    }
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

@end

@interface UICollectionViewDisableForwardToUICollectionViewSentinel : NSObject @end @implementation UICollectionViewDisableForwardToUICollectionViewSentinel @end
