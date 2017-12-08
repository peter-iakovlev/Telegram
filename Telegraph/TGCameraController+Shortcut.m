#import "TGCameraController+Shortcut.h"

#import "TGAlertView.h"
#import "TGApplicationFeatures.h"
#import "TGAppDelegate.h"
#import "TGShareTargetController.h"
#import "TGCameraShareSignals.h"

#import "TGLegacyComponentsContext.h"

@implementation TGCameraController (Shortcut)

+ (void)startShortcutCamera
{
    __autoreleasing NSString *disabledMessage = nil;
    if (![TGApplicationFeatures isPhotoUploadEnabledForPeerType:TGApplicationFeaturePeerPrivate disabledMessage:&disabledMessage])
    {
        [[[TGAlertView alloc] initWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
        return;
    }
    
    if (![[[LegacyComponentsGlobals provider] accessChecker] checkCameraAuthorizationStatusForIntent:TGCameraAccessIntentDefault alertDismissCompletion:nil])
        return;
    
    if (TGAppDelegateInstance.rootController.isSplitView)
        return;
    
    TGCameraController *controller = [[TGCameraController alloc] initWithContext:[TGLegacyComponentsContext shared] saveEditedPhotos:TGAppDelegateInstance.saveEditedPhotos saveCapturedMedia:TGAppDelegateInstance.saveCapturedMedia];
    controller.shortcut = true;
    controller.isImportant = true;
    controller.shouldStoreCapturedAssets = true;
    controller.allowCaptions = true;
    
    TGCameraControllerWindow *controllerWindow = [[TGCameraControllerWindow alloc] initWithManager:[[TGLegacyComponentsContext shared] makeOverlayWindowManager] parentController:TGAppDelegateInstance.rootController contentController:controller];
    controllerWindow.hidden = false;
    
    CGSize screenSize = TGScreenSize();
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        controllerWindow.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    
    CGRect startFrame = CGRectMake(0, screenSize.height, screenSize.width, screenSize.height);
    [controller beginTransitionInFromRect:startFrame];
    
    __weak TGCameraController *weakCameraController = controller;
    controller.finishedWithPhoto = ^(TGOverlayController *controller, UIImage *resultImage, NSString *caption, NSArray *stickers, NSNumber *timer)
    {
        __autoreleasing NSString *disabledMessage = nil;
        if (![TGApplicationFeatures isPhotoUploadEnabledForPeerType:TGApplicationFeaturePeerPrivate disabledMessage:&disabledMessage])
        {
            [[[TGAlertView alloc] initWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
            return;
        }
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[@"type"] = @"image";
        dict[@"image"] = resultImage;
        if (caption.length > 0)
            dict[@"caption"] = caption;
        if (stickers.count > 0)
            dict[@"stickers"] = stickers;
        if (timer != nil)
            dict[@"timer"] = timer;
        
        __strong TGCameraController *strongCameraController = weakCameraController;
        [TGCameraController showTargetController:@[dict] cameraController:strongCameraController resultController:controller navigationController:(TGNavigationController *)controller.navigationController];
    };
    
    controller.finishedWithVideo = ^(TGOverlayController *controller, NSURL *videoURL, UIImage *previewImage, NSTimeInterval duration, CGSize dimensions, TGVideoEditAdjustments *adjustments, NSString *caption, NSArray *stickers, NSNumber *timer)
    {
        __autoreleasing NSString *disabledMessage = nil;
        if (![TGApplicationFeatures isFileUploadEnabledForPeerType:TGApplicationFeaturePeerPrivate disabledMessage:&disabledMessage])
        {
            [[[TGAlertView alloc] initWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
            return;
        }
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[@"type"] = @"cameraVideo";
        dict[@"url"] = videoURL;
        dict[@"duration"] = @(duration);
        dict[@"dimensions"] = [NSValue valueWithCGSize:dimensions];
        if (adjustments != nil)
            dict[@"adjustments"] = adjustments;
        if (previewImage != nil)
            dict[@"previewImage"] = previewImage;
        if (caption.length > 0)
            dict[@"caption"] = caption;
        if (stickers.count > 0)
            dict[@"stickers"] = stickers;
        if (timer != nil)
            dict[@"timer"] = timer;
        
        __strong TGCameraController *strongCameraController = weakCameraController;
        [TGCameraController showTargetController:@[dict] cameraController:strongCameraController resultController:controller navigationController:(TGNavigationController *)controller.navigationController];
    };
}

+ (void)showTargetController:(NSArray *)fileArray cameraController:(TGCameraController *)cameraController resultController:(TGOverlayController *)resultController navigationController:(TGNavigationController *)navigationController
{
    [[TGLegacyComponentsContext shared] setApplicationStatusBarAlpha:1.0f];
    
    TGShareTargetController *controller = [[TGShareTargetController alloc] init];
    controller.completionBlock = ^(NSArray *selectedPeerIds)
    {
        [cameraController _dismissTransitionForResultController:resultController];
        [[TGCameraShareSignals shareMedia:[fileArray firstObject] peerIds:selectedPeerIds] startWithNext:nil];
    };
    [navigationController pushViewController:controller animated:true];
}

@end
