#import "TGCameraController+Shortcut.h"

#import "TGCustomAlertView.h"
#import "TGApplicationFeatures.h"
#import "TGAppDelegate.h"
#import "TGShareTargetController.h"
#import "TGCameraShareSignals.h"

#import "TGLegacyComponentsContext.h"

#import "TGPresentation.h"

@implementation TGCameraController (Shortcut)

+ (void)startShortcutCamera
{
    __autoreleasing NSString *disabledMessage = nil;
    if (![TGApplicationFeatures isPhotoUploadEnabledForPeerType:TGApplicationFeaturePeerPrivate disabledMessage:&disabledMessage])
    {
        [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
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
    controller.finishedWithResults = ^(TGOverlayController *controller, TGMediaSelectionContext *selectionContext, TGMediaEditingContext *editingContext, id<TGMediaSelectableItem> currentItem)
    {
        __autoreleasing NSString *disabledMessage = nil;
        if (![TGApplicationFeatures isPhotoUploadEnabledForPeerType:TGApplicationFeaturePeerPrivate disabledMessage:&disabledMessage])
        {
            [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
            return;
        }
        
        __strong TGCameraController *strongCameraController = weakCameraController;
        if (strongCameraController == nil)
            return;
        
        [TGCameraController showTargetController:[TGCameraController resultSignalsForSelectionContext:selectionContext editingContext:editingContext currentItem:currentItem storeAssets:false saveEditedPhotos:false descriptionGenerator:^id(id item, NSString *caption, NSArray *entities, __unused NSString *stickers)
        {
            if ([item isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *dict = (NSDictionary *)item;
                NSString *type = dict[@"type"];
            
                if ([type isEqualToString:@"editedPhoto"])
                {
                    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
                    result[@"type"] = @"image";
                    result[@"image"] = dict[@"image"];
                    if (caption.length > 0)
                        result[@"caption"] = caption;
                    if (entities.count > 0)
                        result[@"entities"] = entities;
                    if (dict[@"stickers"] != nil)
                        result[@"stickers"] = dict[@"stickers"];
                    
                    return result;
                }
                else if ([type isEqualToString:@"cameraVideo"])
                {
                    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
                    result[@"type"] = @"cameraVideo";
                    result[@"url"] = dict[@"url"];
                    if (dict[@"adjustments"] != nil)
                        result[@"adjustments"] = dict[@"adjustments"];
                    if (entities.count > 0)
                        result[@"entities"] = entities;
                    if (dict[@"stickers"] != nil)
                        result[@"stickers"] = dict[@"stickers"];
                    if (dict[@"previewImage"] != nil)
                        result[@"previewImage"] = dict[@"previewImage"];
                    
                    return result;
                }
            }
            
            return nil;
        }] cameraController:strongCameraController resultController:controller navigationController:(TGNavigationController *)controller.navigationController];
    };
    
//    controller.finishedWithPhoto = ^(TGOverlayController *controller, UIImage *resultImage, NSString *caption, NSArray *entities, NSArray *stickers, NSNumber *timer)
//    {
//        __autoreleasing NSString *disabledMessage = nil;
//        if (![TGApplicationFeatures isPhotoUploadEnabledForPeerType:TGApplicationFeaturePeerPrivate disabledMessage:&disabledMessage])
//        {
//            [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
//            return;
//        }
//
//        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//        dict[@"type"] = @"image";
//        dict[@"image"] = resultImage;
//        if (caption.length > 0)
//            dict[@"caption"] = caption;
//        if (entities.count > 0)
//            dict[@"entities"] = entities;
//        if (stickers.count > 0)
//            dict[@"stickers"] = stickers;
//        if (timer != nil)
//            dict[@"timer"] = timer;
//
//        __strong TGCameraController *strongCameraController = weakCameraController;
//        [TGCameraController showTargetController:@[dict] cameraController:strongCameraController resultController:controller navigationController:(TGNavigationController *)controller.navigationController];
//    };
//
//    controller.finishedWithVideo = ^(TGOverlayController *controller, NSURL *videoURL, UIImage *previewImage, NSTimeInterval duration, CGSize dimensions, TGVideoEditAdjustments *adjustments, NSString *caption, NSArray *entities, NSArray *stickers, NSNumber *timer)
//    {
//        __autoreleasing NSString *disabledMessage = nil;
//        if (![TGApplicationFeatures isFileUploadEnabledForPeerType:TGApplicationFeaturePeerPrivate disabledMessage:&disabledMessage])
//        {
//            [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
//            return;
//        }
//
//        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//        dict[@"type"] = @"cameraVideo";
//        dict[@"url"] = videoURL;
//        dict[@"duration"] = @(duration);
//        dict[@"dimensions"] = [NSValue valueWithCGSize:dimensions];
//        if (adjustments != nil)
//            dict[@"adjustments"] = adjustments;
//        if (previewImage != nil)
//            dict[@"previewImage"] = previewImage;
//        if (caption.length > 0)
//            dict[@"caption"] = caption;
//        if (entities.count > 0)
//            dict[@"entities"] = entities;
//        if (stickers.count > 0)
//            dict[@"stickers"] = stickers;
//        if (timer != nil)
//            dict[@"timer"] = timer;
//
//        __strong TGCameraController *strongCameraController = weakCameraController;
//        [TGCameraController showTargetController:@[dict] cameraController:strongCameraController resultController:controller navigationController:(TGNavigationController *)controller.navigationController];
//    };
}

+ (void)showTargetController:(NSArray *)resultSignals cameraController:(TGCameraController *)cameraController resultController:(TGOverlayController *)resultController navigationController:(TGNavigationController *)navigationController
{
    [[TGLegacyComponentsContext shared] setApplicationStatusBarAlpha:1.0f];
    
    SSignal *combinedSignal = nil;
    for (SSignal *signal in resultSignals)
    {
        if (combinedSignal == nil)
            combinedSignal = signal;
        else
            combinedSignal = [combinedSignal then:signal];
    }
    
    TGShareTargetController *controller = [[TGShareTargetController alloc] init];
    controller.presentation = TGPresentation.current;
    controller.completionBlock = ^(NSArray *selectedPeerIds)
    {
        [cameraController _dismissTransitionForResultController:resultController];
        [[combinedSignal mapToSignal:^SSignal *(NSDictionary *result)
        {
            return [TGCameraShareSignals shareMedia:result peerIds:selectedPeerIds];
        }] startWithNext:nil];
    };
    [navigationController pushViewController:controller animated:true];
}

@end
