#import "TGLegacyComponentsGlobalsProvider.h"

#import "TGAccessChecker.h"

#import "TGAppDelegate.h"
#import "TGApplication.h"
#import "TGTelegraph.h"
#import "TGAudioSessionManager.h"

#import "TGStickersSignals.h"
#import "TGMaskStickersSignals.h"
#import "TGRecentMaskStickersSignal.h"

#import "TGWallpaperManager.h"

#import "TGSharedPhotoSignals.h"
#import "TGSharedMediaUtils.h"

#import "TGRemoteHttpLocationSignal.h"

#import "TGEmbedPIPController.h"

#import <thirdparty/AFNetworking/AFNetworking.h>

@interface AFHTTPRequestOperation (TG) <LegacyHTTPRequestOperation>

@end

@implementation AFHTTPRequestOperation (TG)

@end

static __strong NSTimer *userInteractionEnableTimer = nil;

@implementation TGLegacyComponentsGlobalsProvider

- (TGLocalization *)effectiveLocalization {
    return effectiveLocalization();
}

- (void)log:(NSString *)string {
    TGLog(@"%@", string);
}

- (UIViewController *)rootController {
    return TGAppDelegateInstance.rootController;
}

- (NSArray<UIWindow *> *)applicationWindows {
    return [[UIApplication sharedApplication] windows];
}

- (UIWindow *)applicationStatusBarWindow {
    static SEL selector = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *str1 = @"rs`str";
        NSString *str2 = @"A`qVhmcnv";
        
        selector = NSSelectorFromString([[NSString alloc] initWithFormat:@"%@%@", TGEncodeText(str1, 1), TGEncodeText(str2, 1)]);
    });
    
    if ([[UIApplication sharedApplication] respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        UIWindow *window = [[UIApplication sharedApplication] performSelector:selector];
#pragma clang diagnostic pop
        return window;
    }
    return nil;
}

- (UIWindow *)applicationKeyboardWindow {
    static Class keyboardWindowClass = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (iosMajorVersion() >= 9) {
            keyboardWindowClass = NSClassFromString(TGEncodeText(@"VJSfnpufLfzcpbseXjoepx", -1));
        } else {
            keyboardWindowClass = NSClassFromString(TGEncodeText(@"VJUfyuFggfdutXjoepx", -1));
        }
    });
    
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if ([[window class] isEqual:keyboardWindowClass])
            return window;
    }
    
    return nil;
}

- (UIApplication *)applicationInstance {
    return [UIApplication sharedApplication];
}

- (UIInterfaceOrientation)applicationStatusBarOrientation {
    return [[UIApplication sharedApplication] statusBarOrientation];
}

- (CGRect)statusBarFrame {
    return [[UIApplication sharedApplication] statusBarFrame];
}

- (bool)isStatusBarHidden {
    return [[UIApplication sharedApplication] isStatusBarHidden];
}

- (void)setStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation {
    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animation];
}

- (UIStatusBarStyle)statusBarStyle {
    return [[UIApplication sharedApplication] statusBarStyle];
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle animated:animated];
}

- (void)forceStatusBarAppearanceUpdate {
    static void (*methodImpl)(id, SEL) = NULL;
    static dispatch_once_t onceToken;
    static SEL methodSelector = NULL;
    dispatch_once(&onceToken, ^
    {
        methodImpl = (void (*)(id, SEL))freedomImpl([UIApplication sharedApplication], 0xa7a8dd8a, NULL);
    });
    
    if (methodImpl != NULL)
        methodImpl([UIApplication sharedApplication], methodSelector);
}

- (void)disableUserInteractionFor:(NSTimeInterval)timeInterval
{
    if (userInteractionEnableTimer != nil)
    {
        if ([userInteractionEnableTimer isValid])
        {
            [userInteractionEnableTimer invalidate];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
        userInteractionEnableTimer = nil;
    }
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    userInteractionEnableTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval] interval:0 target:self selector:@selector(userInteractionEnableTimerEvent) userInfo:nil repeats:false];
    [[NSRunLoop mainRunLoop] addTimer:userInteractionEnableTimer forMode:NSRunLoopCommonModes];
}

- (void)setIdleTimerDisabled:(bool)value {
    [[UIApplication sharedApplication] setIdleTimerDisabled:value];
}

- (void)userInteractionEnableTimerEvent
{
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    userInteractionEnableTimer = nil;
}

- (void)pauseMusicPlayback {
    [TGTelegraphInstance.musicPlayer controlPause];
}

- (NSString *)dataStoragePath {
    return [TGAppDelegate documentsPath];
}

- (NSString *)dataCachePath {
    return [TGAppDelegate cachePath];
}

- (id<LegacyComponentsAccessChecker>)accessChecker {
    static TGAccessChecker *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TGAccessChecker alloc] init];
    });
    return instance;
}

- (id<SDisposable>)requestAudioSession:(TGAudioSessionType)type interrupted:(void (^)())interrupted {
    return [[TGAudioSessionManager instance] requestSessionWithType:type interrupted:interrupted];
}

- (SSignal *)stickerPacksSignal {
    return [TGStickersSignals stickerPacks];
}

- (SSignal *)maskStickerPacksSignal {
    return [TGMaskStickersSignals stickerPacks];
}

- (SSignal *)recentStickerMasksSignal {
    return [TGRecentMaskStickersSignal recentStickers];
}

- (TGWallpaperInfo *)currentWallpaperInfo {
    return [[TGWallpaperManager instance] currentWallpaperInfo];
}

- (UIImage *)currentWallpaperImage {
    return [[TGWallpaperManager instance] currentWallpaperImage];
}

- (bool)canOpenURL:(NSURL *)url {
    return [[UIApplication sharedApplication] canOpenURL:url];
}

- (void)openURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url];
}

- (void)openURLNative:(NSURL *)url {
    [(TGApplication *)[UIApplication sharedApplication] openURL:url forceNative:true];
}

- (SThreadPool *)sharedMediaImageProcessingThreadPool {
    return [TGSharedMediaUtils sharedMediaImageProcessingThreadPool];
}

- (TGMemoryImageCache *)sharedMediaMemoryImageCache {
    return [TGSharedMediaUtils sharedMediaMemoryImageCache];
}

- (SSignal *)squarePhotoThumbnail:(TGImageMediaAttachment *)imageAttachment ofSize:(CGSize)size threadPool:(SThreadPool *)threadPool memoryCache:(TGMemoryImageCache *)memoryCache pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock downloadLargeImage:(bool)downloadLargeImage placeholder:(SSignal *)placeholder {
    return [TGSharedPhotoSignals squarePhotoThumbnail:imageAttachment ofSize:size threadPool:threadPool memoryCache:memoryCache pixelProcessingBlock:pixelProcessingBlock downloadLargeImage:downloadLargeImage placeholder:placeholder];
}

- (NSString *)localDocumentDirectoryForLocalDocumentId:(int64_t)localDocumentId version:(int32_t)version
{
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    NSString *filesDirectory = [documentsDirectory stringByAppendingPathComponent:@"files"];
    NSString *versionString = @"";
    if (version > 0) {
        versionString = [NSString stringWithFormat:@"-%d", version];
    }
    return [[filesDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"local%llx", localDocumentId]] stringByAppendingString:versionString];
}

- (NSString *)localDocumentDirectoryForDocumentId:(int64_t)documentId version:(int32_t)version
{
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    NSString *filesDirectory = [documentsDirectory stringByAppendingPathComponent:@"files"];
    NSString *versionString = @"";
    if (version > 0) {
        versionString = [NSString stringWithFormat:@"-%d", version];
    }
    return [[filesDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%llx", documentId]]  stringByAppendingString:versionString];
}

- (SSignal *)jsonForHttpLocation:(NSString *)httpLocation {
    return [TGRemoteHttpLocationSignal jsonForHttpLocation:httpLocation];
}

- (SSignal *)dataForHttpLocation:(NSString *)httpLocation {
    return [TGRemoteHttpLocationSignal dataForHttpLocation:httpLocation];
}

- (NSOperation<LegacyHTTPRequestOperation> *)makeHTTPRequestOperationWithRequest:(NSURLRequest *)request {
    return [[AFHTTPRequestOperation alloc] initWithRequest:request];
}

- (void)pausePictureInPicturePlayback {
    [TGEmbedPIPController pausePictureInPicturePlayback];
}

- (void)resumePictureInPicturePlayback {
    [TGEmbedPIPController resumePictureInPicturePlayback];
}

- (void)maybeReleaseVolumeOverlay {
    [TGEmbedPIPController maybeReleaseVolumeOverlay];
}

@end
