#import "TGFastCameraController.h"
#import "TGCameraController.h"
#import "TGTelegraph.h"
#import "TGAppDelegate.h"

#import "TGHacks.h"
#import "TGImageBlur.h"
#import "TGImageUtils.h"
#import "TGPhotoEditorUtils.h"

#import "PGCamera.h"
#import "PGCameraCaptureSession.h"
#import "PGCameraDeviceAngleSampler.h"
#import "PGCameraVolumeButtonHandler.h"

#import "TGCameraPreviewView.h"
#import "TGFastCameraControlPanel.h"

#import "TGCameraTimeCodeView.h"
#import "TGCameraFlipButton.h"

#import "TGCameraPhotoPreviewController.h"

#import "TGModernGalleryController.h"
#import "TGMediaPickerGalleryModel.h"
#import "TGMediaPickerGalleryVideoItem.h"
#import "TGMediaPickerGalleryVideoItemView.h"

#import "TGMediaAssetsLibrary.h"
#import "TGMediaAssetImageSignals.h"
#import "AVURLAsset+TGMediaItem.h"
#import "TGVideoEditAdjustments.h"
#import "TGPaintingData.h"

NSString *const TGFastCameraUseRearCameraKey = @"fastCameraUseRear_v1";

@interface TGFastCameraController ()
{
    PGCamera *_camera;
    PGCameraVolumeButtonHandler *_buttonHandler;
    
    CGRect _attachmentButtonFrame;
    
    UIView *_interfaceView;
    UIView *_topPanelView;
    TGFastCameraControlPanel *_controlPanel;
    TGCameraPreviewView *_previewView;
    TGCameraTimeCodeView *_timecodeView;
    TGCameraFlipButton *_flipButton;
    
    bool _autorotationWasEnabled;
    
    UILongPressGestureRecognizer *_gestureRecognizer;
    
    NSTimeInterval _startTimestamp;

    TGMediaEditingContext *_editingContext;
}
@end

@implementation TGFastCameraController

- (instancetype)initWithParentController:(TGViewController *)parentController attachmentButtonFrame:(CGRect)attachmentButtonFrame
{
    self = [super init];
    if (self != nil)
    {
        self.isImportant = true;
        
        bool useRearCamera = [[[NSUserDefaults standardUserDefaults] objectForKey:TGFastCameraUseRearCameraKey] boolValue];
        PGCameraPosition position = useRearCamera ? PGCameraPositionRear : PGCameraPositionFront;
        
        _camera = [[PGCamera alloc] initWithMode:PGCameraModeVideo position:position];
        _attachmentButtonFrame = attachmentButtonFrame;
        
        TGCameraControllerWindow *window = [[TGCameraControllerWindow alloc] initWithParentController:parentController contentController:self keepKeyboard:true];
        window.windowLevel = 100000000.0f + 0.001f;
        window.hidden = false;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    _previewView = [[TGCameraPreviewView alloc] initWithFrame:self.view.bounds];
    _previewView.alpha = 0.0f;
    [self.view addSubview:_previewView];
 
    _interfaceView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_interfaceView];
    
    _controlPanel = [[TGFastCameraControlPanel alloc] init];
    CGFloat y = MIN(self.view.frame.size.height - 4.0f - _controlPanel.frame.size.height, CGRectGetMidY(_attachmentButtonFrame) - 210.0f);
    _controlPanel.frame = CGRectMake(4.0f, y, _controlPanel.frame.size.width, _controlPanel.frame.size.height);
    CGRect oldFrame = _controlPanel.frame;
    _controlPanel.layer.anchorPoint = CGPointMake(0.5f, 0.9f);
    _controlPanel.frame = oldFrame;
    _controlPanel.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
    __weak TGFastCameraController *weakSelf = self;
    _controlPanel.videoPressed = ^
    {
        __strong TGFastCameraController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf videoPressed];
    };
    _controlPanel.photoPressed = ^
    {
        __strong TGFastCameraController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf photoPressed];
    };
    _controlPanel.cancelPressed = ^
    {
        __strong TGFastCameraController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf dismiss];
    };
    [_interfaceView addSubview:_controlPanel];
    
    _topPanelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40.0f)];
    _topPanelView.alpha = 0.0f;
    _topPanelView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.37f];
    [_interfaceView addSubview:_topPanelView];
    
    _flipButton = [[TGCameraFlipButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 44.0f, 0, 40.0f, 40.0f)];
    [_flipButton addTarget:self action:@selector(flipButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_topPanelView addSubview:_flipButton];
    
    _timecodeView = [[TGCameraTimeCodeView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 120) / 2, 10, 120, 20)];
    _timecodeView.hidden = true;
    _timecodeView.requestedRecordingDuration = ^NSTimeInterval
    {
        __strong TGFastCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return 0.0;
        
        return strongSelf->_camera.videoRecordingDuration;
    };
    [_topPanelView addSubview:_timecodeView];
    
    void (^voidBlock)(void) = ^{};
    _buttonHandler = [[PGCameraVolumeButtonHandler alloc] initWithUpButtonPressedBlock:voidBlock upButtonReleasedBlock:voidBlock downButtonPressedBlock:voidBlock downButtonReleasedBlock:voidBlock];
    
    [self configureCamera];
    
    _gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    _gestureRecognizer.minimumPressDuration = 0.05;
    [_controlPanel addGestureRecognizer:_gestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    __weak TGFastCameraController *weakSelf = self;
    [_camera attachPreviewView:_previewView];
    [_camera startCaptureForResume:false completion:^
    {
        __strong TGFastCameraController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf captureStarted];
    }];
    
    _camera.captureSession.alwaysSetFlash = true;
    [_camera setFlashMode:PGCameraFlashModeAuto];
    
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.6f initialSpringVelocity:0.25f options:UIViewAnimationOptionCurveLinear animations:^
    {
        _controlPanel.transform = CGAffineTransformIdentity;
    } completion:nil];
    
    _startTimestamp = CFAbsoluteTimeGetCurrent();
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:true];
    
    if (TGTelegraphInstance.musicPlayer != nil)
        [TGTelegraphInstance.musicPlayer controlPause];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _autorotationWasEnabled = [TGViewController autorotationAllowed];
    [TGViewController disableAutorotation];
}

- (void)dismissImmediately
{
    [super dismiss];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:false];
    [self stopCapture];
    
    if (_autorotationWasEnabled)
        [TGViewController enableAutorotation];
}

- (void)dismiss
{
    NSTimeInterval timeDelta = CFAbsoluteTimeGetCurrent() - _startTimestamp;
    if (timeDelta < 1.0)
    {
        TGDispatchAfter(1.0 - timeDelta, dispatch_get_main_queue(), ^
        {
            [self dismiss];
        });
        
        return;
    }
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.userInteractionEnabled = false;
    
    [UIView animateWithDuration:0.15 animations:^
    {
        [_controlPanel setLabelsHidden:false];
        _previewView.alpha = 0.0f;
        _topPanelView.alpha = 0.0f;
        [TGHacks setApplicationStatusBarAlpha:1.0f];
    }];
    
    [UIView animateWithDuration:0.38 delay:0.05 usingSpringWithDamping:0.65f initialSpringVelocity:0.15f options:UIViewAnimationOptionCurveLinear animations:^
    {
        _controlPanel.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
        _controlPanel.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        [self dismissImmediately];
    }];
}

#pragma mark - 

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:nil];
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        {
            [self handlePanAt:location];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            [self handleReleaseAt:location];
        }
            break;
            
        default:
            break;
    }
}

- (void)handlePanAt:(CGPoint)location
{
    [_controlPanel handlePanAt:location];
}

- (void)handleReleaseAt:(CGPoint)location
{
    [_controlPanel handleReleaseAt:location];
}

#pragma mark - 

- (void)videoPressed
{
    if (!_camera.isRecordingVideo)
    {
        [_buttonHandler ignoreEventsFor:1.0f andDisable:false];
        
        __weak TGFastCameraController *weakSelf = self;
        [_camera startVideoRecordingForMoment:false completion:^(NSURL *outputURL, __unused CGAffineTransform transform, CGSize dimensions, NSTimeInterval duration, __unused TGLiveUploadActorData *liveUploadData, bool success)
         {
             __strong TGFastCameraController *strongSelf = weakSelf;
             if (strongSelf == nil)
                 return;
             
             if (success)
                 [strongSelf presentVideoResultControllerWithURL:outputURL dimensions:dimensions duration:duration completion:nil];
             else
                 [strongSelf setRecordingVideo:false animated:false];
         }];
    }
    else
    {
        _camera.disabled = true;
        
        [_buttonHandler ignoreEventsFor:1.0f andDisable:true];
        [_camera stopVideoRecording];
    }
}

- (void)photoPressed
{
    self.view.userInteractionEnabled = false;
    
    _buttonHandler.enabled = false;
    [_buttonHandler ignoreEventsFor:1.5f andDisable:true];
    
    _camera.disabled = true;
    
    [_camera takePhotoWithCompletion:^(UIImage *result, PGCameraShotMetadata *metadata)
    {
        TGDispatchOnMainThread(^
        {
            [self presentPhotoResultControllerWithImage:result metadata:metadata completion:^
            {
                self.view.userInteractionEnabled = true;
            }];
        });
    }];
}

#pragma mark - 

- (void)presentPhotoResultControllerWithImage:(UIImage *)image metadata:(PGCameraShotMetadata *)metadata completion:(void (^)(void))completion
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:false];
    
    __weak TGFastCameraController *weakSelf = self;
    TGOverlayController *overlayController = nil;
    
    TGCameraPhotoPreviewController *controller = [[TGCameraPhotoPreviewController alloc] initWithImage:image metadata:metadata recipientName:self.recipientName backButtonTitle:TGLocalized(@"Common.Cancel") doneButtonTitle:TGLocalized(@"MediaPicker.Send")];
    controller.allowCaptions = self.allowCaptions;
    controller.shouldStoreAssets = self.shouldStoreCapturedAssets;
    controller.suggestionContext = self.suggestionContext;
    controller.hasTimer = self.hasTimer;
    
    __weak TGCameraPhotoPreviewController *weakController = controller;
    controller.beginTransitionIn = ^CGRect
    {
        __strong TGFastCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return CGRectZero;
        
        strongSelf->_previewView.hidden = true;
        
        return strongSelf->_previewView.frame;
    };
    
    controller.finishedTransitionIn = ^
    {
        __strong TGFastCameraController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf->_camera stopCaptureForPause:true completion:nil];
    };
    
    controller.beginTransitionOut = ^CGRect(CGRect referenceFrame)
    {
        __strong TGFastCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return CGRectZero;
        
        return referenceFrame;
    };
    
    controller.retakePressed = ^
    {
        __strong TGFastCameraController *strongSelf = weakSelf;
        __strong TGOverlayController *strongController = weakController;
        if (strongSelf != nil && strongController != nil)
            [strongSelf dismissTransitionForResultController:strongController success:false];
    };
    
    controller.sendPressed = ^(__unused TGOverlayController *controller, UIImage *resultImage, NSString *caption, NSArray *stickers, NSNumber *timer)
    {
        __strong TGFastCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (strongSelf.finishedWithPhoto != nil)
            strongSelf.finishedWithPhoto(resultImage, caption, stickers, timer);
        
        __strong TGOverlayController *strongController = weakController;
        if (strongController != nil)
            [strongSelf dismissTransitionForResultController:strongController success:true];
    };
    
    overlayController = controller;
    
    TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithParentController:self contentController:controller];
    controllerWindow.windowLevel = self.view.window.windowLevel + 0.0001f;
    controllerWindow.hidden = false;
    
    if (completion != nil)
        completion();
    
    [UIView animateWithDuration:0.3f animations:^
    {
        _interfaceView.alpha = 0.0f;
    }];
}

- (void)presentVideoResultControllerWithURL:(NSURL *)url dimensions:(CGSize)dimensions duration:(NSTimeInterval)duration completion:(void (^)(void))completion
{
    TGMediaEditingContext *editingContext = [[TGMediaEditingContext alloc] init];
    _editingContext = editingContext;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:false];
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = true;
    generator.maximumSize = CGSizeMake(640.0f, 640.0f);
    CGImageRef imageRef = [generator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:NULL];
    UIImage *thumbnailImage = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    __weak TGFastCameraController *weakSelf = self;
    
    TGMediaPickerGalleryVideoItem *videoItem = [[TGMediaPickerGalleryVideoItem alloc] initWithFileURL:url dimensions:dimensions duration:duration];
    videoItem.editingContext = _editingContext;
    videoItem.immediateThumbnailImage = thumbnailImage;
    
    TGModernGalleryController *galleryController = [[TGModernGalleryController alloc] init];
    galleryController.adjustsStatusBarVisibility = false;
    galleryController.hasFadeOutTransition = true;
    
    TGMediaPickerGalleryModel *model = [[TGMediaPickerGalleryModel alloc] initWithItems:@[ videoItem ] focusItem:videoItem selectionContext:nil editingContext:_editingContext hasCaptions:self.allowCaptions hasTimer:self.hasTimer inhibitDocumentCaptions:self.inhibitDocumentCaptions hasSelectionPanel:false recipientName:self.recipientName];
    model.controller = galleryController;
    model.suggestionContext = self.suggestionContext;
    
    model.willFinishEditingItem = ^(id<TGMediaEditableItem> editableItem, id<TGMediaEditAdjustments> adjustments, id representation, bool hasChanges)
    {
        __strong TGFastCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (hasChanges)
        {
            [editingContext setAdjustments:adjustments forItem:editableItem];
            [editingContext setTemporaryRep:representation forItem:editableItem];
        }
    };
    
    model.didFinishEditingItem = ^(id<TGMediaEditableItem> editableItem, __unused id<TGMediaEditAdjustments> adjustments, UIImage *resultImage, UIImage *thumbnailImage)
    {
        [editingContext setImage:resultImage thumbnailImage:thumbnailImage forItem:editableItem synchronous:false];
    };
    
    model.saveItemCaption = ^(__unused id<TGMediaEditableItem> item, NSString *caption)
    {
        __strong TGFastCameraController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf->_editingContext setCaption:caption forItem:videoItem.avAsset];
    };
    
    model.interfaceView.hasSwipeGesture = false;
    model.interfaceView.usesSimpleLayout = true;
    galleryController.model = model;
    
    __weak TGModernGalleryController *weakGalleryController = galleryController;
    __weak TGMediaPickerGalleryModel *weakModel = model;
    
    model.interfaceView.donePressed = ^(__unused TGMediaPickerGalleryItem *item)
    {
        __strong TGFastCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        TGMediaPickerGalleryModel *strongModel = weakModel;
        if (strongModel == nil)
            return;
        
        __strong TGModernGalleryController *strongController = weakGalleryController;
        if (strongController == nil)
            return;
        
        TGMediaPickerGalleryVideoItemView *itemView = (TGMediaPickerGalleryVideoItemView *)[strongController itemViewForItem:strongController.currentItem];
        [itemView stop];
        [itemView setPlayButtonHidden:true animated:true];
        
        [strongSelf dismissTransitionForResultController:strongController success:true];
        
        TGVideoEditAdjustments *adjustments = (TGVideoEditAdjustments *)[strongSelf->_editingContext adjustmentsForItem:videoItem.avAsset];
        NSString *caption = [strongSelf->_editingContext captionForItem:videoItem.avAsset];
        NSNumber *timer = [strongSelf->_editingContext timerForItem:videoItem.avAsset];
        
        SSignal *thumbnailSignal = [SSignal single:thumbnailImage];
        if (adjustments.trimStartValue > FLT_EPSILON)
        {
            thumbnailSignal = [TGMediaAssetImageSignals videoThumbnailForAVAsset:[AVURLAsset URLAssetWithURL:url options:nil] size:dimensions timestamp:CMTimeMakeWithSeconds(adjustments.trimStartValue, NSEC_PER_SEC)];
        }
        if ([adjustments cropAppliedForAvatar:false] || adjustments.hasPainting)
        {
            thumbnailSignal = [thumbnailSignal map:^UIImage *(UIImage *image)
            {
                CGRect scaledCropRect = CGRectMake(adjustments.cropRect.origin.x * image.size.width / adjustments.originalSize.width, adjustments.cropRect.origin.y * image.size.height / adjustments.originalSize.height, adjustments.cropRect.size.width * image.size.width / adjustments.originalSize.width, adjustments.cropRect.size.height * image.size.height / adjustments.originalSize.height);
                
                return TGPhotoEditorCrop(image, adjustments.paintingData.image, adjustments.cropOrientation, 0, scaledCropRect, adjustments.cropMirrored, CGSizeMake(256, 256), image.size, true);
            }];

        }
        
        [[thumbnailSignal deliverOn:[SQueue mainQueue]] startWithNext:^(UIImage *thumbnailImage)
        {
            if (strongSelf.finishedWithVideo != nil)
                strongSelf.finishedWithVideo(url, thumbnailImage, duration, dimensions, adjustments, caption, adjustments.paintingData.stickers, timer);
        }];
        
        if (strongSelf.shouldStoreCapturedAssets)
            [strongSelf _saveVideoToCameraRollWithURL:url completion:nil];
    };
    
    CGSize snapshotSize = TGScaleToFill(CGSizeMake(480, 640), CGSizeMake(self.view.frame.size.width, self.view.frame.size.width));
    UIView *snapshotView = [_previewView snapshotViewAfterScreenUpdates:false];
    snapshotView.contentMode = UIViewContentModeScaleAspectFill;
    snapshotView.frame = CGRectMake(_previewView.center.x - snapshotSize.width / 2, _previewView.center.y - snapshotSize.height / 2, snapshotSize.width, snapshotSize.height);
    snapshotView.hidden = true;
    [_previewView.superview insertSubview:snapshotView aboveSubview:_previewView];
    
    galleryController.beginTransitionIn = ^UIView *(__unused TGMediaPickerGalleryItem *item, __unused TGModernGalleryItemView *itemView)
    {
        __strong TGFastCameraController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            TGModernGalleryController *strongGalleryController = weakGalleryController;
            strongGalleryController.view.alpha = 0.0f;
            [UIView animateWithDuration:0.3f animations:^
             {
                 strongGalleryController.view.alpha = 1.0f;
                 strongSelf->_interfaceView.alpha = 0.0f;
             }];
            return snapshotView;
        }
        return nil;
    };
    
    galleryController.finishedTransitionIn = ^(__unused TGMediaPickerGalleryItem *item, __unused TGModernGalleryItemView *itemView)
    {
        __strong TGFastCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_camera stopCaptureForPause:true completion:nil];
        
        snapshotView.hidden = true;
        
        if (completion != nil)
            completion();
    };
    
    galleryController.beginTransitionOut = ^UIView *(__unused TGMediaPickerGalleryItem *item, __unused TGModernGalleryItemView *itemView)
    {
        __strong TGFastCameraController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if ([[NSFileManager defaultManager] fileExistsAtPath:url.path isDirectory:NULL])
                [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
            
            TGModernGalleryController *strongController = weakGalleryController;
            
            if (strongSelf != nil && strongController != nil)
                [strongSelf dismissTransitionForResultController:strongController success:false];
            
            return snapshotView;
        }
        return nil;
    };
    
    galleryController.completedTransitionOut = ^
    {
        [snapshotView removeFromSuperview];
    };
    
    TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithParentController:self contentController:galleryController];
    controllerWindow.hidden = false;
    controllerWindow.windowLevel = self.view.window.windowLevel + 0.0001f;
    galleryController.view.clipsToBounds = true;
}

#pragma mark -

- (void)dismissTransitionForResultController:(TGOverlayController *)resultController success:(bool)success
{
    self.view.hidden = true;
    [TGHacks setApplicationStatusBarAlpha:1.0f];
    
    if (success)
    {
        [UIView animateWithDuration:0.3f delay:0.0f options:(7 << 16) animations:^
        {
            resultController.view.frame = CGRectOffset(resultController.view.frame, 0, resultController.view.frame.size.height);
        } completion:^(__unused BOOL finished)
        {
            [resultController dismiss];
            [self dismissImmediately];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^
        {
            resultController.view.alpha = 0.0f;
        } completion:^(__unused BOOL finished)
        {
            [resultController dismiss];
            [self dismissImmediately];
        }];
    }
}

#pragma mark -

- (void)_savePhotoToCameraRollWithOriginalImage:(UIImage *)originalImage editedImage:(UIImage *)editedImage
{
    if (originalImage == nil)
        return;
    
    SSignal *savePhotoSignal = TGAppDelegateInstance.saveCapturedMedia ? [[TGMediaAssetsLibrary sharedLibrary] saveAssetWithImage:originalImage] : [SSignal complete];
    if (TGAppDelegateInstance.saveEditedPhotos && editedImage != nil)
        savePhotoSignal = [savePhotoSignal then:[[TGMediaAssetsLibrary sharedLibrary] saveAssetWithImage:editedImage]];
    
    [savePhotoSignal startWithNext:nil];
}

- (void)_saveVideoToCameraRollWithURL:(NSURL *)url completion:(void (^)(void))completion
{
    if (!TGAppDelegateInstance.saveCapturedMedia)
        return;
    
    [[[TGMediaAssetsLibrary sharedLibrary] saveAssetWithVideoAtUrl:url] startWithNext:nil error:^(__unused NSError *error)
    {
        if (completion != nil)
            completion();
    } completed:completion];
}

#pragma mark - 

- (void)setRecordingVideo:(bool)recordingVideo animated:(bool)animated
{
    _timecodeView.hidden = false;
    [_controlPanel setRecordingVideo:recordingVideo animated:animated];
    
    [_flipButton setHidden:recordingVideo animated:animated];
    if (animated)
    {
        [UIView animateWithDuration:0.25 animations:^
        {
            [_controlPanel setLabelsHidden:true];
        }];
    }
    else
    {
        [_controlPanel setLabelsHidden:true];
    }
    
    if (recordingVideo)
    {
        [_timecodeView startRecording];
    }
    else
    {
        [_timecodeView stopRecording];
        [_timecodeView reset];
    }

}

#pragma mark - 

- (void)captureStarted
{
    [UIView animateWithDuration:0.3 animations:^
    {
        [_controlPanel setLabelsHidden:false];
        _previewView.alpha = 1.0f;
        _topPanelView.alpha = 1.0f;
        [TGHacks setApplicationStatusBarAlpha:0.0f];
    } completion:^(__unused BOOL finished)
    {
        self.view.backgroundColor = [UIColor blackColor];
    }];
}

- (void)stopCapture
{
    [_camera stopCaptureForPause:false completion:nil];
    _camera = nil;
}

- (void)configureCamera
{
    __weak TGFastCameraController *weakSelf = self;
    _camera.requestedCurrentInterfaceOrientation = ^UIInterfaceOrientation(bool *mirrored)
    {
        __strong TGFastCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
        return UIInterfaceOrientationUnknown;
        
        if (mirrored != NULL)
        {
            TGCameraPreviewView *previewView = strongSelf->_previewView;
            if (previewView != nil)
            *mirrored = previewView.captureConnection.videoMirrored;
        }
        
        return [TGCameraController _interfaceOrientationForDeviceOrientation:strongSelf->_camera.deviceAngleSampler.deviceOrientation];
    };

    _camera.beganPositionChange = ^(__unused bool targetPositionHasFlash, __unused bool targetPositionHasZoom, void(^commitBlock)(void))
    {
        __strong TGFastCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf.view.userInteractionEnabled = false;
        
        [strongSelf->_camera captureNextFrameCompletion:^(UIImage *image)
        {
            if (commitBlock != nil)
                commitBlock();
            
            image = TGCameraPositionSwitchImage(image, CGSizeMake(image.size.width, image.size.height));
            
            TGDispatchOnMainThread(^
            {
                [UIView transitionWithView:strongSelf->_previewView duration:0.4f options:UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionCurveEaseOut animations:^
                {
                    [strongSelf->_previewView beginTransitionWithSnapshotImage:image animated:false];
                } completion:^(__unused BOOL finished)
                {
                    strongSelf.view.userInteractionEnabled = true;
                }];
            });
        }];
    };
    
    _camera.finishedPositionChange = ^
    {
        __strong TGFastCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        TGDispatchOnMainThread(^
        {
            [strongSelf->_previewView endTransitionAnimated:true];
            [strongSelf->_camera setFlashMode:PGCameraFlashModeAuto];
        });
    };

    _camera.beganVideoRecording = ^(__unused bool moment)
    {
        __strong TGFastCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf setRecordingVideo:true animated:true];
    };
    
    _camera.captureInterrupted = ^(AVCaptureSessionInterruptionReason reason)
    {
        __strong TGFastCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (reason == AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableWithMultipleForegroundApps)
            [strongSelf dismissImmediately];
    };
}

#pragma mark - 

- (void)flipButtonPressed
{
    PGCameraPosition newPosition = [_camera togglePosition];
    [[NSUserDefaults standardUserDefaults] setObject:@(newPosition == PGCameraPositionRear) forKey:TGFastCameraUseRearCameraKey];
}

@end
