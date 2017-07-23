#import "TGMediaAvatarMenuMixin.h"

#import "TGAppDelegate.h"

#import "PGCamera.h"
#import "TGAccessChecker.h"
#import "TGImageUtils.h"
#import "TGActionSheet.h"

#import "TGMenuSheetController.h"
#import "TGOverlayFormsheetWindow.h"

#import "TGCameraPreviewView.h"
#import "TGAttachmentCameraView.h"
#import "TGAttachmentCarouselItemView.h"

#import "TGCameraController.h"
#import "TGLegacyCameraController.h"
#import "TGImagePickerController.h"
#import "TGMediaAssetsController.h"
#import "TGWebSearchController.h"

@interface TGMediaAvatarMenuMixin () <TGLegacyCameraControllerDelegate>
{
    TGViewController *_parentController;
    bool _hasDeleteButton;
    bool _personalPhoto;
}
@end

@implementation TGMediaAvatarMenuMixin

- (instancetype)initWithParentController:(TGViewController *)parentController hasDeleteButton:(bool)hasDeleteButton
{
    return [self initWithParentController:parentController hasDeleteButton:hasDeleteButton personalPhoto:false];
}

- (instancetype)initWithParentController:(TGViewController *)parentController hasDeleteButton:(bool)hasDeleteButton personalPhoto:(bool)personalPhoto
{
    self = [super init];
    if (self != nil)
    {
        _parentController = parentController;
        _hasDeleteButton = hasDeleteButton;
        _personalPhoto = ![TGCameraController useLegacyCamera] ? personalPhoto : false;
    }
    return self;
}

- (void)present
{
    [_parentController.view endEditing:true];
    
    if (iosMajorVersion() >= 7 && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        [self _presentAvatarMenu];
    else
        [self _presentLegacyAvatarMenu];
}

- (void)_presentAvatarMenu
{
    __weak TGMediaAvatarMenuMixin *weakSelf = self;
    TGMenuSheetController *controller = [[TGMenuSheetController alloc] init];
    controller.dismissesByOutsideTap = true;
    controller.hasSwipeGesture = true;
    controller.didDismiss = ^(bool manual)
    {
        if (!manual)
            return;
        
        __strong TGMediaAvatarMenuMixin *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (strongSelf.didDismiss != nil)
            strongSelf.didDismiss();
    };
    
    __weak TGMenuSheetController *weakController = controller;
    
    NSMutableArray *itemViews = [[NSMutableArray alloc] init];
    
    TGAttachmentCarouselItemView *carouselItem = [[TGAttachmentCarouselItemView alloc] initWithCamera:true selfPortrait:_personalPhoto forProfilePhoto:true assetType:TGMediaAssetPhotoType];
    carouselItem.parentController = _parentController;
    carouselItem.openEditor = true;
    carouselItem.cameraPressed = ^(TGAttachmentCameraView *cameraView)
    {
        __strong TGMediaAvatarMenuMixin *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        [strongSelf _displayCameraWithView:cameraView menuController:strongController];
    };
    carouselItem.avatarCompletionBlock = ^(UIImage *resultImage)
    {
        __strong TGMediaAvatarMenuMixin *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        if (strongSelf.didFinishWithImage != nil)
            strongSelf.didFinishWithImage(resultImage);
        
        [strongController dismissAnimated:false];
    };
    [itemViews addObject:carouselItem];
    
    TGMenuSheetButtonItemView *galleryItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.ChoosePhoto") type:TGMenuSheetButtonTypeDefault action:^
    {
        __strong TGMediaAvatarMenuMixin *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        [strongController dismissAnimated:true];
        [strongSelf _displayMediaPicker];
    }];
    [itemViews addObject:galleryItem];
        
    if (_hasDeleteButton)
    {
        TGMenuSheetButtonItemView *deleteItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"GroupInfo.SetGroupPhotoDelete") type:TGMenuSheetButtonTypeDestructive action:^
        {
            __strong TGMediaAvatarMenuMixin *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            __strong TGMenuSheetController *strongController = weakController;
            if (strongController == nil)
                return;
            
            [strongController dismissAnimated:true];
            [strongSelf _performDelete];
        }];
        [itemViews addObject:deleteItem];
    }
    
    TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
    {
        __strong TGMediaAvatarMenuMixin *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        [strongController dismissAnimated:true manual:true];
    }];
    [itemViews addObject:cancelItem];
    
    [controller setItemViews:itemViews];
    
    [controller presentInViewController:_parentController sourceView:nil animated:true];
}

- (void)_presentLegacyAvatarMenu
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    if ([PGCamera cameraAvailable])
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.TakePhoto") action:@"camera"]];
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.ChoosePhoto") action:@"choosePhoto"]];
//    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.SearchWebImages") action:@"searchWeb"]];
    
    if (_hasDeleteButton)
    {
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"GroupInfo.SetGroupPhotoDelete") action:@"delete" type:TGActionSheetActionTypeDestructive]];
    }
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
    
    [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(TGMediaAvatarMenuMixin *controller, NSString *action)
    {
        if ([action isEqualToString:@"camera"])
            [controller _displayCameraWithView:nil menuController:nil];
        else if ([action isEqualToString:@"choosePhoto"])
            [controller _displayMediaPicker];
        else if ([action isEqualToString:@"searchWeb"])
            [controller _displayWebSearch];
        else if ([action isEqualToString:@"delete"])
            [controller _performDelete];
        else if ([action isEqualToString:@"cancel"] && controller.didDismiss != nil)
            controller.didDismiss();
    } target:self] showInView:_parentController.view];
}

- (void)_displayCameraWithView:(TGAttachmentCameraView *)cameraView menuController:(TGMenuSheetController *)menuController
{
    if (![TGAccessChecker checkCameraAuthorizationStatusForIntent:TGCameraAccessIntentDefault alertDismissCompletion:nil])
        return;
    
    if (TGAppDelegateInstance.rootController.isSplitView)
        return;
    
    if ([TGCameraController useLegacyCamera])
    {
        [self _displayLegacyCamera];
        [menuController dismissAnimated:true];
        return;
    }
    
    TGCameraController *controller = nil;
    CGSize screenSize = TGScreenSize();
    
    if (cameraView.previewView != nil)
        controller = [[TGCameraController alloc] initWithCamera:cameraView.previewView.camera previewView:cameraView.previewView intent:TGCameraControllerAvatarIntent];
    else
        controller = [[TGCameraController alloc] initWithIntent:TGCameraControllerAvatarIntent];
    
    controller.shouldStoreCapturedAssets = true;
    
    TGCameraControllerWindow *controllerWindow = [[TGCameraControllerWindow alloc] initWithParentController:_parentController contentController:controller];
    controllerWindow.hidden = false;
    controllerWindow.clipsToBounds = true;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        controllerWindow.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    else
        controllerWindow.frame = TGAppDelegateInstance.rootController.applicationBounds;
    
    bool standalone = true;
    CGRect startFrame = CGRectMake(0, screenSize.height, screenSize.width, screenSize.height);
    if (cameraView != nil)
    {
        standalone = false;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
            startFrame = CGRectZero;
        else
            startFrame = [controller.view convertRect:cameraView.previewView.frame fromView:cameraView];
    }
    
    [cameraView detachPreviewView];
    [controller beginTransitionInFromRect:startFrame];
    
    __weak TGMediaAvatarMenuMixin *weakSelf = self;
    __weak TGCameraController *weakCameraController = controller;
    __weak TGAttachmentCameraView *weakCameraView = cameraView;
    
    controller.beginTransitionOut = ^CGRect
    {
        __strong TGCameraController *strongCameraController = weakCameraController;
        if (strongCameraController == nil)
            return CGRectZero;
        
        __strong TGAttachmentCameraView *strongCameraView = weakCameraView;
        if (strongCameraView != nil)
        {
            [strongCameraView willAttachPreviewView];
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
                return CGRectZero;
            
            return [strongCameraController.view convertRect:strongCameraView.frame fromView:strongCameraView.superview];
        }
        
        return CGRectZero;
    };
    
    controller.finishedTransitionOut = ^
    {
        __strong TGAttachmentCameraView *strongCameraView = weakCameraView;
        if (strongCameraView == nil)
            return;
        
        [strongCameraView attachPreviewViewAnimated:true];
    };
    
    controller.finishedWithPhoto = ^(__unused TGOverlayController *controller, UIImage *resultImage, __unused NSString *caption, __unused NSArray *stickers, __unused NSNumber *timer)
    {
        __strong TGMediaAvatarMenuMixin *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (strongSelf.didFinishWithImage != nil)
            strongSelf.didFinishWithImage(resultImage);
        
        [menuController dismissAnimated:false];
    };
}

- (void)_displayLegacyCamera
{
    TGLegacyCameraController *legacyCameraController = [[TGLegacyCameraController alloc] init];
    legacyCameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    legacyCameraController.avatarMode = true;
    legacyCameraController.completionDelegate = self;
    
    [_parentController presentViewController:legacyCameraController animated:true completion:nil];
}

- (void)_displayMediaPicker
{
    if (![TGAccessChecker checkPhotoAuthorizationStatusForIntent:TGPhotoAccessIntentRead alertDismissCompletion:nil])
        return;
    
    __weak TGMediaAvatarMenuMixin *weakSelf = self;
    void (^presentBlock)(TGMediaAssetsController *) = nil;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        presentBlock = ^(TGMediaAssetsController *controller)
        {
            __strong TGMediaAvatarMenuMixin *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            controller.dismissalBlock = ^
            {
                __strong TGMediaAvatarMenuMixin *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                [strongSelf->_parentController dismissViewControllerAnimated:true completion:nil];
                
                if (strongSelf.didDismiss != nil)
                    strongSelf.didDismiss();
            };
            
            [strongSelf->_parentController presentViewController:controller animated:true completion:nil];
        };
    }
    else
    {
        presentBlock = ^(TGMediaAssetsController *controller)
        {
            __strong TGMediaAvatarMenuMixin *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            controller.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
            controller.modalPresentationStyle = UIModalPresentationFormSheet;
            
            TGOverlayFormsheetWindow *formSheetWindow = [[TGOverlayFormsheetWindow alloc] initWithParentController:strongSelf->_parentController contentController:controller];
            [formSheetWindow showAnimated:true];
            
            __weak TGNavigationController *weakNavController = controller;
            __weak TGOverlayFormsheetWindow *weakFormSheetWindow = formSheetWindow;
            controller.dismissalBlock = ^
            {
                __strong TGMediaAvatarMenuMixin *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                __strong TGOverlayFormsheetWindow *strongFormSheetWindow = weakFormSheetWindow;
                if (strongFormSheetWindow == nil)
                    return;
                
                __strong TGNavigationController *strongNavController = weakNavController;
                if (strongNavController != nil)
                {
                    if (strongNavController.presentingViewController != nil)
                        [strongNavController.presentingViewController dismissViewControllerAnimated:true completion:nil];
                    else
                        [strongFormSheetWindow dismissAnimated:true];
                }
                
                if (strongSelf.didDismiss != nil)
                    strongSelf.didDismiss();
            };
        };
    }
    
    void (^showMediaPicker)(TGMediaAssetGroup *) = ^(TGMediaAssetGroup *group)
    {
        __strong TGMediaAvatarMenuMixin *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        TGMediaAssetsController *controller = [TGMediaAssetsController controllerWithAssetGroup:group intent:TGMediaAssetsControllerSetProfilePhotoIntent recipientName:nil];
        __weak TGMediaAssetsController *weakController = controller;
        controller.avatarCompletionBlock = ^(UIImage *resultImage)
        {
            __strong TGMediaAvatarMenuMixin *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (strongSelf.didFinishWithImage != nil)
                strongSelf.didFinishWithImage(resultImage);
            
            __strong TGMediaAssetsController *strongController = weakController;
            if (strongController != nil && strongController.dismissalBlock != nil)
                strongController.dismissalBlock();
        };
        presentBlock(controller);
    };
    
    if ([TGMediaAssetsLibrary authorizationStatus] == TGMediaLibraryAuthorizationStatusNotDetermined)
    {
        [TGMediaAssetsLibrary requestAuthorizationForAssetType:TGMediaAssetAnyType completion:^(__unused TGMediaLibraryAuthorizationStatus status, TGMediaAssetGroup *cameraRollGroup)
         {
             if (![TGAccessChecker checkPhotoAuthorizationStatusForIntent:TGPhotoAccessIntentRead alertDismissCompletion:nil])
                 return;
             
             showMediaPicker(cameraRollGroup);
         }];
    }
    else
    {
        showMediaPicker(nil);
    }
}

- (void)_displayWebSearch
{
    __weak TGMediaAvatarMenuMixin *weakSelf = self;
    TGNavigationController *navigationController = nil;
    
    TGWebSearchController *controller = [[TGWebSearchController alloc] initForAvatarSelection:true embedded:false];
    __weak TGWebSearchController *weakController = controller;
    controller.avatarCompletionBlock = ^(UIImage *resultImage)
    {
        __strong TGMediaAvatarMenuMixin *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (strongSelf.didFinishWithImage != nil)
            strongSelf.didFinishWithImage(resultImage);
        
        __strong TGWebSearchController *strongController = weakController;
        if (strongController != nil && strongController.dismiss != nil)
            strongController.dismiss();
    };
    
    navigationController = [TGNavigationController navigationControllerWithControllers:@[controller]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        void (^dismiss)(void) = ^
        {
            __strong TGMediaAvatarMenuMixin *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (strongSelf.didDismiss != nil)
                strongSelf.didDismiss();
            
            [strongSelf->_parentController dismissViewControllerAnimated:true completion:nil];
        };
        
        [_parentController presentViewController:navigationController animated:true completion:nil];
        
        controller.dismiss = dismiss;
    }
    else
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        
        TGOverlayFormsheetWindow *formSheetWindow = [[TGOverlayFormsheetWindow alloc] initWithParentController:_parentController contentController:navigationController];
        [formSheetWindow showAnimated:true];
        
        __weak TGNavigationController *weakNavController = navigationController;
        __weak TGOverlayFormsheetWindow *weakFormSheetWindow = formSheetWindow;
        void (^dismiss)(void) = ^
        {
            __strong TGMediaAvatarMenuMixin *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            __strong TGOverlayFormsheetWindow *strongFormSheetWindow = weakFormSheetWindow;
            if (strongFormSheetWindow == nil)
                return;
            
            if (strongSelf.didDismiss != nil)
                strongSelf.didDismiss();
            
            __strong TGNavigationController *strongNavController = weakNavController;
            if (strongNavController != nil)
            {
                if (strongNavController.presentingViewController != nil)
                    [strongNavController.presentingViewController dismissViewControllerAnimated:true completion:nil];
                else
                    [strongFormSheetWindow dismissAnimated:true];
            }
        };
        
        controller.dismiss = dismiss;
    }
}

- (void)imagePickerController:(TGImagePickerController *)__unused imagePicker didFinishPickingWithAssets:(NSArray *)assets
{
    UIImage *resultImage = nil;
    
    if (assets.count != 0)
    {
        if ([assets[0] isKindOfClass:[UIImage class]])
            resultImage = assets[0];
    }
    
    if (self.didFinishWithImage != nil)
        self.didFinishWithImage(resultImage);
    
    [_parentController dismissViewControllerAnimated:true completion:nil];
}

- (void)legacyCameraControllerCompletedWithNoResult
{
    [_parentController dismissViewControllerAnimated:true completion:nil];
    
    if (self.didDismiss != nil)
        self.didDismiss();
}

- (void)_performDelete
{
    if (self.didFinishWithDelete != nil)
        self.didFinishWithDelete();
}

@end
