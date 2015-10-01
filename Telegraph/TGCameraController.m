#import "TGCameraController.h"

#import <pop/POP.h>
#import <objc/runtime.h>

#import "Freedom.h"
#import "TGStringUtils.h"

#import "TGHacks.h"
#import "TGImageUtils.h"
#import "TGImageBlur.h"
#import "TGPhotoEditorUtils.h"
#import "TGPhotoEditorAnimation.h"

#import "PGCamera.h"
#import "PGCameraCaptureSession.h"
#import "PGCameraDeviceAngleSampler.h"
#import "PGCameraVolumeButtonHandler.h"

#import "TGCameraPreviewView.h"
#import "TGCameraMainPhoneView.h"
#import "TGCameraMainTabletView.h"
#import "TGCameraFocusCrosshairsControl.h"

#import "TGFullscreenContainerView.h"
#import "TGCameraPhotoPreviewController.h"
#import "TGPhotoEditorController.h"

#import "TGModernGalleryController.h"
#import "TGMediaPickerGalleryModel.h"
#import "TGMediaPickerGalleryPhotoItem.h"
#import "TGMediaPickerGalleryVideoItem.h"
#import "TGMediaPickerGalleryVideoItemView.h"
#import "TGOverlayControllerWindow.h"

#import "TGVideoConverter.h"

#import "PGPhotoEditorValues.h"
#import "TGVideoEditAdjustments.h"
#import "UIImage+TGEditablePhotoItem.h"
#import "AVURLAsset+TGEditablePhotoItem.h"

#import "TGModernGalleryZoomableScrollViewSwipeGestureRecognizer.h"

#import "TGMediaPickerAssetsLibrary.h"

#import "TGAudioSessionManager.h"

static const CGFloat TGCameraSwipeMinimumVelocity = 600.0f;
static const CGFloat TGCameraSwipeVelocityThreshold = 700.0f;
static const CGFloat TGCameraSwipeDistanceThreshold = 128.0f;

@implementation TGCameraControllerWindow

static CGPoint TGCameraControllerClampPointToScreenSize(__unused id self, __unused SEL _cmd, CGPoint point)
{
    CGSize screenSize = TGScreenSize();
    return CGPointMake(MAX(0, MIN(point.x, screenSize.width)), MAX(0, MIN(point.y, screenSize.height)));
}

+ (void)initialize
{
    static bool initialized = false;
    if (!initialized)
    {
        initialized = true;
        
        if (iosMajorVersion() > 8 || (iosMajorVersion() == 8 && iosMinorVersion() >= 3))
        {
            FreedomDecoration instanceDecorations[] =
            {
                { .name = 0x4ea0b831U,
                    .imp = (IMP)&TGCameraControllerClampPointToScreenSize,
                    .newIdentifier = FreedomIdentifierEmpty,
                    .newEncoding = FreedomIdentifierEmpty
                }
            };
            
            freedomClassAutoDecorate(0x913b3af6, NULL, 0, instanceDecorations, sizeof(instanceDecorations) / sizeof(instanceDecorations[0]));
        }
    }
}

@end

@interface TGCameraController () <UIGestureRecognizerDelegate>
{
    bool _standalone;
    TGCameraControllerIntent _intent;
    PGCamera *_camera;
    PGCameraVolumeButtonHandler *_buttonHandler;
    
    UIView *_backgroundView;
    TGCameraPreviewView *_previewView;
    TGCameraMainView *_interfaceView;
    UIView *_overlayView;
    TGCameraFocusCrosshairsControl *_focusControl;
    
    UISwipeGestureRecognizer *_photoSwipeGestureRecognizer;
    UISwipeGestureRecognizer *_videoSwipeGestureRecognizer;
    TGModernGalleryZoomableScrollViewSwipeGestureRecognizer *_panGestureRecognizer;
    UIPinchGestureRecognizer *_pinchGestureRecognizer;
    
    CGFloat _dismissProgress;
    bool _dismissing;
    bool _finishedWithResult;
    
    UIImage *_videoThumbnail;
    
    TGVideoConverter *_videoConverter;
    TGVideoEditAdjustments *_videoAdjustments;
    NSString *_videoCaption;
}
@end

@implementation TGCameraController

- (instancetype)init
{
    return [self initWithIntent:TGCameraControllerGenericIntent];
}

- (instancetype)initWithIntent:(TGCameraControllerIntent)intent
{
    return [self initWithCamera:[[PGCamera alloc] init] previewView:nil intent:intent];
}

- (instancetype)initWithCamera:(PGCamera *)camera previewView:(TGCameraPreviewView *)previewView intent:(TGCameraControllerIntent)intent
{
    self = [super init];
    if (self != nil)
    {
        if (previewView == nil)
            _standalone = true;
        _intent = intent;
        _camera = camera;
        _previewView = previewView;
        
        if (_intent == TGCameraControllerAvatarIntent)
            _disallowCaptions = true;
    }
    return self;
}

- (void)dealloc
{
    _camera.beganModeChange = nil;
    _camera.finishedModeChange = nil;
    _camera.beganPositionChange = nil;
    _camera.finishedPositionChange = nil;
    _camera.beganAdjustingFocus = nil;
    _camera.finishedAdjustingFocus = nil;
    _camera.flashActivityChanged = nil;
    _camera.flashAvailabilityChanged = nil;
    _camera.beganVideoRecording = nil;
    _camera.finishedVideoRecording = nil;
    _camera.captureInterrupted = nil;
    _camera.requestedCurrentInterfaceOrientation = nil;
    _camera.deviceAngleSampler.deviceOrientationChanged = nil;

    PGCamera *camera = _camera;
    if (_finishedWithResult || _standalone)
        [camera stopCaptureForPause:false completion:nil];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:false];
}

- (void)loadView
{
    [super loadView];
    object_setClass(self.view, [TGFullscreenContainerView class]);
    
    CGSize screenSize = TGScreenSize();
    self.view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    _backgroundView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_backgroundView];
    
    if (_previewView == nil)
    {
        _previewView = [[TGCameraPreviewView alloc] initWithFrame:[TGCameraController _cameraPreviewFrameForScreenSize:TGScreenSize() mode:PGCameraModePhoto]];
        [_camera attachPreviewView:_previewView];
        [self.view addSubview:_previewView];
    }
    
    _overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    _overlayView.clipsToBounds = true;
    _overlayView.frame = [TGCameraController _cameraPreviewFrameForScreenSize:TGScreenSize() mode:_camera.cameraMode];
    [self.view addSubview:_overlayView];
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (interfaceOrientation == UIInterfaceOrientationPortrait)
        interfaceOrientation = [TGCameraController _interfaceOrientationForDeviceOrientation:_camera.deviceAngleSampler.deviceOrientation];
    
    __weak TGCameraController *weakSelf = self;
    _focusControl = [[TGCameraFocusCrosshairsControl alloc] initWithFrame:_overlayView.bounds];
    _focusControl.enabled = (_camera.supportsFocusPOI || _camera.supportsExposurePOI);
    _focusControl.stopAutomatically = (_focusControl.enabled && !_camera.supportsFocusPOI);
    _focusControl.previewView = _previewView;
    _focusControl.focusPOIChanged = ^(CGPoint point)
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_camera setFocusPoint:point];
    };
    _focusControl.beganExposureChange = ^
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_camera beginExposureTargetBiasChange];
    };
    _focusControl.exposureChanged = ^(CGFloat value)
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_camera setExposureTargetBias:value];
    };
    _focusControl.endedExposureChange = ^
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_camera endExposureTargetBiasChange];
    };
    [_focusControl setInterfaceOrientation:interfaceOrientation animated:false];
    [_overlayView addSubview:_focusControl];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        _panGestureRecognizer = [[TGModernGalleryZoomableScrollViewSwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        _panGestureRecognizer.delegate = self;
        _panGestureRecognizer.delaysTouchesBegan = true;
        _panGestureRecognizer.cancelsTouchesInView = false;
        [_overlayView addGestureRecognizer:_panGestureRecognizer];
    }
    
    _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    _pinchGestureRecognizer.delegate = self;
    [_overlayView addGestureRecognizer:_pinchGestureRecognizer];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        _interfaceView = [[TGCameraMainPhoneView alloc] initWithFrame:self.view.bounds];
        [_interfaceView setInterfaceOrientation:interfaceOrientation animated:false];
    }
    else
    {
        _interfaceView = [[TGCameraMainTabletView alloc] initWithFrame:self.view.bounds];
        [_interfaceView setInterfaceOrientation:interfaceOrientation animated:false];
        
        CGSize referenceSize = [self referenceViewSizeForOrientation:interfaceOrientation];
        if (referenceSize.width > referenceSize.height)
            referenceSize = CGSizeMake(referenceSize.height, referenceSize.width);
        
        _interfaceView.transform = CGAffineTransformMakeRotation(TGRotationForInterfaceOrientation(interfaceOrientation));
        _interfaceView.frame = CGRectMake(0, 0, referenceSize.width, referenceSize.height);
    }
    
    _interfaceView.requestedVideoRecordingDuration = ^NSTimeInterval
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return 0.0;
        
        return strongSelf->_camera.videoRecordingDuration;
    };
    
    _interfaceView.cameraFlipped = ^
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_camera togglePosition];
    };
    
    _interfaceView.cameraModeChanged = ^(PGCameraMode mode)
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_camera setCameraMode:mode];
    };
    
    _interfaceView.flashModeChanged = ^(PGCameraFlashMode mode)
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_camera setFlashMode:mode];
    };
    
    _interfaceView.shutterPressed = ^(bool fromHardwareButton)
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (fromHardwareButton)
            [strongSelf->_interfaceView setShutterButtonHighlighted:true];
    };
        
    _interfaceView.shutterReleased = ^(bool fromHardwareButton)
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (fromHardwareButton)
            [strongSelf->_interfaceView setShutterButtonHighlighted:false];
        
        if (strongSelf->_previewView.hidden)
            return;
        
        if (strongSelf->_camera.cameraMode == PGCameraModePhoto || strongSelf->_camera.cameraMode == PGCameraModeSquare)
        {
            strongSelf->_buttonHandler.enabled = false;
            [strongSelf->_buttonHandler ignoreEventsFor:1.5f andDisable:true];
            
            strongSelf.view.userInteractionEnabled = false;
            
            strongSelf->_camera.disabled = true;
            
            [strongSelf->_camera takePhotoWithCompletion:^(UIImage *result, PGCameraShotMetadata *metadata)
            {
                TGDispatchOnMainThread(^
                {
                    [strongSelf presentPhotoResultControllerWithImage:result metadata:metadata completion:^
                    {
                        strongSelf.view.userInteractionEnabled = true;
                    }];
                });
            }];
        }
        else if (strongSelf->_camera.cameraMode == PGCameraModeVideo)
        {
            if (!strongSelf->_camera.isRecordingVideo)
            {
                [strongSelf->_buttonHandler ignoreEventsFor:1.0f andDisable:false];
                
                [strongSelf->_camera startVideoRecordingWithCompletion:^(NSURL *outputURL, __unused CGAffineTransform transform, CGSize dimensions, NSTimeInterval duration, bool success)
                {
                    if (success)
                        [strongSelf presentVideoResultControllerWithURL:outputURL dimensions:dimensions duration:duration completion:nil];
                    else
                        [strongSelf->_interfaceView setRecordingVideo:false animated:false];
                }];
            }
            else
            {
                strongSelf->_camera.disabled = true;
                
                [strongSelf->_buttonHandler ignoreEventsFor:1.0f andDisable:true];
                [strongSelf->_camera stopVideoRecording];
            }
        }
    };
    
    _interfaceView.cancelPressed = ^
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf beginTransitionOutWithVelocity:0.0f];
    };
    
    if (_intent == TGCameraControllerAvatarIntent)
        [_interfaceView setHasModeControl:false];
    [self.view addSubview:_interfaceView];
    
    _photoSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    _photoSwipeGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:_photoSwipeGestureRecognizer];
    
    _videoSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    _videoSwipeGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:_videoSwipeGestureRecognizer];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        _photoSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        _videoSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    }
    else
    {
        _photoSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        _videoSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    }
    
    void (^buttonPressed)(void) = ^
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_interfaceView.shutterPressed(true);
    };

    void (^buttonReleased)(void) = ^
    {        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_interfaceView.shutterReleased(true);
    };
    
    _buttonHandler = [[PGCameraVolumeButtonHandler alloc] initWithUpButtonPressedBlock:buttonPressed upButtonReleasedBlock:buttonReleased downButtonPressedBlock:buttonPressed downButtonReleasedBlock:buttonReleased];
    
    [self _configureCamera];
}

- (void)_configureCamera
{
    __weak TGCameraController *weakSelf = self;
    _camera.requestedCurrentInterfaceOrientation = ^UIInterfaceOrientation(bool *mirrored)
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return UIInterfaceOrientationUnknown;
        
        if (mirrored != NULL)
        {
            TGCameraPreviewView *previewView = strongSelf->_previewView;
            if (previewView != nil)
                *mirrored = previewView.previewLayer.connection.videoMirrored;
        }
        
        return [strongSelf->_interfaceView interfaceOrientation];
    };
    
    _camera.beganModeChange = ^(PGCameraMode mode, void(^commitBlock)(void))
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_buttonHandler.ignoring = true;
        
        [strongSelf->_focusControl reset];
        strongSelf->_focusControl.active = false;
        
        strongSelf.view.userInteractionEnabled = false;
        
        if (mode == PGCameraModeVideo)
            [[TGAudioSessionManager instance] cancelCurrentSession];
        
        PGCameraMode currentMode = strongSelf->_camera.cameraMode;
        if ((mode == PGCameraModePhoto && currentMode == PGCameraModeSquare) || (mode == PGCameraModeSquare && currentMode == PGCameraModePhoto))
        {
            if (commitBlock != nil)
                commitBlock();
        }
        else
        {
            strongSelf->_camera.zoomLevel = 0.0f;
            
            [strongSelf->_camera captureNextFrameForVideoThumbnail:false completion:^(UIImage *image)
            {
                if (commitBlock != nil)
                    commitBlock();
                 
                image = TGCameraModeSwitchImage(image, CGSizeMake(image.size.width, image.size.height));
                 
                TGDispatchOnMainThread(^
                {
                    [strongSelf->_previewView beginTransitionWithSnapshotImage:image animated:true];
                });
            }];
        }
    };
    
    _camera.finishedModeChange = ^
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        TGDispatchOnMainThread(^
        {
            [strongSelf->_previewView endTransitionAnimated:true];

            if (!strongSelf->_dismissing)
            {
                strongSelf.view.userInteractionEnabled = true;
                [strongSelf resizePreviewViewForCameraMode:strongSelf->_camera.cameraMode];
                
                strongSelf->_focusControl.active = true;
                [strongSelf->_interfaceView setFlashMode:strongSelf->_camera.flashMode];

                [strongSelf->_buttonHandler enableIn:1.5f];
            }
        });
    };
    
    _camera.beganPositionChange = ^(bool targetPositionHasFlash, bool targetPositionHasZoom, void(^commitBlock)(void))
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_focusControl reset];
        
        [strongSelf->_interfaceView setHasFlash:targetPositionHasFlash];
        [strongSelf->_interfaceView setHasZoom:targetPositionHasZoom];
        strongSelf->_camera.zoomLevel = 0.0f;
        
        strongSelf.view.userInteractionEnabled = false;
        
        [strongSelf->_camera captureNextFrameForVideoThumbnail:false completion:^(UIImage *image)
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
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        TGDispatchOnMainThread(^
        {
            [strongSelf->_previewView endTransitionAnimated:true];
            [strongSelf->_interfaceView setZoomLevel:0.0f displayNeeded:false];

            if (strongSelf->_camera.hasFlash && strongSelf->_camera.flashActive)
                [strongSelf->_interfaceView setFlashActive:true];
                                   
            strongSelf->_focusControl.enabled = (strongSelf->_camera.supportsFocusPOI || strongSelf->_camera.supportsExposurePOI);
            strongSelf->_focusControl.stopAutomatically = (strongSelf->_focusControl.enabled && !strongSelf->_camera.supportsFocusPOI);
        });
    };
    
    _camera.beganAdjustingFocus = ^
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_focusControl playAutoFocusAnimation];
    };
    
    _camera.finishedAdjustingFocus = ^
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_focusControl stopAutoFocusAnimation];
    };
    
    _camera.flashActivityChanged = ^(bool active)
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (strongSelf->_camera.flashMode != PGCameraFlashModeAuto)
            active = false;
        
        if (!strongSelf->_camera.isRecordingVideo)
            [strongSelf->_interfaceView setFlashActive:active];
    };
    
    _camera.flashAvailabilityChanged = ^(bool available)
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_interfaceView setFlashUnavailable:!available];
    };
    
    _camera.beganVideoRecording = ^
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_focusControl.ignoreAutofocusing = true;
        
        [strongSelf->_interfaceView setRecordingVideo:true animated:true];
        
        [strongSelf->_camera captureNextFrameForVideoThumbnail:true completion:^(UIImage *image)
        {
            strongSelf->_videoThumbnail = image;
        }];
    };
    
    _camera.captureInterrupted = ^(AVCaptureSessionInterruptionReason reason)
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (reason == AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableWithMultipleForegroundApps)
            [strongSelf beginTransitionOutWithVelocity:0.0f];
    };
    
    _camera.finishedVideoRecording = ^
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_focusControl.ignoreAutofocusing = false;
        [strongSelf->_interfaceView setFlashMode:PGCameraFlashModeOff];
    };
    
    _camera.deviceAngleSampler.deviceOrientationChanged = ^(UIDeviceOrientation orientation)
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf handleDeviceOrientationChangedTo:orientation];
    };
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.window.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2f];
    
    [UIView animateWithDuration:0.3f animations:^
    {
        [TGHacks setApplicationStatusBarAlpha:0.0f];
    }];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:true];
    
    if (!_camera.isCapturing)
        [_camera startCaptureForResume:false completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [UIView animateWithDuration:0.3f animations:^
    {
        [TGHacks setApplicationStatusBarAlpha:1.0f];
    }];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return false;
}

- (void)setInterfaceHidden:(bool)hidden animated:(bool)animated
{
    if (animated)
    {
        if (hidden && _interfaceView.alpha < FLT_EPSILON)
            return;

        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.fromValue = @(_interfaceView.alpha);
        animation.toValue = @(hidden ? 0.0f : 1.0f);
        animation.duration = 0.2f;
        [_interfaceView.layer addAnimation:animation forKey:@"opacity"];
        
        _interfaceView.alpha = hidden ? 0.0f : 1.0f;
    }
    else
    {
        [_interfaceView.layer removeAllAnimations];
        _interfaceView.alpha = 0.0f;
    }
}

#pragma mark - Photo Result

- (void)presentPhotoResultControllerWithImage:(UIImage *)image metadata:(PGCameraShotMetadata *)metadata completion:(void (^)(void))completion
{    
    [[UIApplication sharedApplication] setIdleTimerDisabled:false];
    
    __weak TGCameraController *weakSelf = self;
    TGOverlayController *overlayController = nil;
    
    _focusControl.ignoreAutofocusing = true;
    
    switch (_intent)
    {
        case TGCameraControllerAvatarIntent:
        {
            TGPhotoEditorController *controller = [[TGPhotoEditorController alloc] initWithItem:image intent:(TGPhotoEditorControllerFromCameraIntent | TGPhotoEditorControllerAvatarIntent) adjustments:nil caption:nil screenImage:image availableTabs:[TGPhotoEditorController defaultTabsForAvatarIntent] selectedTab:TGPhotoEditorCropTab];
            __weak TGPhotoEditorController *weakController = controller;
            controller.beginTransitionIn = ^UIView *(CGRect *referenceFrame, __unused UIView **parentView)
            {
                __strong TGCameraController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return nil;
                
                strongSelf->_previewView.hidden = true;
                *referenceFrame = strongSelf->_previewView.frame;
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:strongSelf->_previewView.frame];
                imageView.image = image;
                
                return imageView;
            };
            
            controller.beginTransitionOut = ^UIView *(CGRect *referenceFrame, __unused UIView **parentView)
            {
                __strong TGCameraController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return nil;
                
                CGRect startFrame = CGRectZero;
                if (referenceFrame != NULL)
                    startFrame = *referenceFrame;
                *referenceFrame = strongSelf->_previewView.frame;
                
                [strongSelf transitionBackFromResultControllerWithReferenceFrame:startFrame];
                
                return strongSelf->_previewView;
            };
            
            controller.finishedEditing = ^(PGPhotoEditorValues *editorValues, UIImage *resultImage, __unused UIImage *thumbnailImage, __unused bool noChanges)
            {
                if (noChanges)
                    return;
                
                __strong TGCameraController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                TGDispatchOnMainThread(^
                {
                    if (strongSelf.finishedWithPhoto != nil)
                        strongSelf.finishedWithPhoto(resultImage, nil);
                    
                    if (self.shouldStoreCapturedAssets)
                    {
                        [[TGMediaPickerAssetsLibrary sharedLibrary] saveAssetWithImage:image
                                                                       completionBlock:nil];
                        
                        if ([editorValues toolsApplied])
                        {
                            [[TGMediaPickerAssetsLibrary sharedLibrary] saveAssetWithImage:resultImage
                                                                           completionBlock:nil];
                        }
                    }
                    
                    __strong TGPhotoEditorController *strongController = weakController;
                    if (strongController != nil)
                    {
                        [strongController updateStatusBarAppearanceForDismiss];
                        [strongSelf dismissTransitionForResultController:strongController];
                    }
                });
            };
            
            overlayController = controller;
        }
            break;
            
        default:
        {
            TGCameraPhotoPreviewController *controller = [[TGCameraPhotoPreviewController alloc] initWithImage:image metadata:metadata];
            controller.disallowCaptions = self.disallowCaptions;
            
            __weak TGCameraPhotoPreviewController *weakController = controller;
            controller.beginTransitionIn = ^CGRect
            {
                __strong TGCameraController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return CGRectZero;
                
                strongSelf->_previewView.hidden = true;
                
                return strongSelf->_previewView.frame;
            };
            
            controller.beginTransitionOut = ^CGRect(CGRect referenceFrame)
            {
                __strong TGCameraController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return CGRectZero;
                
                return [strongSelf transitionBackFromResultControllerWithReferenceFrame:referenceFrame];
            };
            
            controller.retakePressed = ^
            {
                __strong TGCameraController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                [[UIApplication sharedApplication] setIdleTimerDisabled:true];
            };
            
            controller.sendPressed = ^(UIImage *originalImage, UIImage *resultImage, PGPhotoEditorValues *editorValues, NSString *caption)
            {
                __strong TGCameraController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                TGDispatchOnMainThread(^
                {
                    if (strongSelf.shouldStoreCapturedAssets)
                    {
                        [[TGMediaPickerAssetsLibrary sharedLibrary] saveAssetWithImage:originalImage
                                                                       completionBlock:nil];

                        if ([editorValues toolsApplied])
                        {
                            [[TGMediaPickerAssetsLibrary sharedLibrary] saveAssetWithImage:resultImage
                                                                           completionBlock:nil];
                        }
                    }
                    
                    if (strongSelf.finishedWithPhoto != nil)
                        strongSelf.finishedWithPhoto(resultImage, caption);
                    
                    __strong TGOverlayController *strongController = weakController;
                    if (strongController != nil)
                        [strongSelf dismissTransitionForResultController:strongController];
                });
            };
            
            controller.photoEditorShown = ^
            {
                __strong TGCameraController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                [strongSelf->_camera stopCaptureForPause:true completion:nil];
            };
            
            controller.photoEditorHidden = ^
            {
                __strong TGCameraController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                [strongSelf->_camera startCaptureForResume:true completion:nil];
            };
            
            overlayController = controller;
        }
            break;
    }
    
    TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithParentController:self contentController:overlayController];
    controllerWindow.windowLevel = self.view.window.windowLevel + 0.0001f;
    controllerWindow.hidden = false;
    
    if (completion != nil)
        completion();
    
    [UIView animateWithDuration:0.3f animations:^
    {
        _interfaceView.alpha = 0.0f;
    }];
}

- (CGRect)transitionBackFromResultControllerWithReferenceFrame:(CGRect)referenceFrame
{
    _camera.disabled = false;
    
    _buttonHandler.enabled = true;
    [_buttonHandler ignoreEventsFor:2.0f andDisable:false];
    _previewView.hidden = false;
    
    _focusControl.ignoreAutofocusing = false;
    
    CGRect targetFrame = _previewView.frame;
    
    _previewView.frame = referenceFrame;
    POPSpringAnimation *animation = [TGPhotoEditorAnimation prepareTransitionAnimationForPropertyNamed:kPOPViewFrame];
    animation.fromValue = [NSValue valueWithCGRect:referenceFrame];
    animation.toValue = [NSValue valueWithCGRect:targetFrame];
    [_previewView pop_addAnimation:animation forKey:@"frame"];
    
    [UIView animateWithDuration:0.3f delay:0.1f options:UIViewAnimationOptionCurveLinear animations:^
    {
        _interfaceView.alpha = 1.0f;
    } completion:nil];
    
    return targetFrame;
}

#pragma mark - Video Result

- (void)presentVideoResultControllerWithURL:(NSURL *)url dimensions:(CGSize)dimensions duration:(NSTimeInterval)duration completion:(void (^)(void))completion
{
    _videoAdjustments = nil;
    _videoCaption = nil;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:false];
    
    __weak TGCameraController *weakSelf = self;
    
    TGMediaPickerGalleryVideoItem *videoItem = [[TGMediaPickerGalleryVideoItem alloc] initWithFileURL:url dimensions:dimensions duration:duration];
    videoItem.immediateThumbnailImage = _videoThumbnail;
    videoItem.avAsset.fetchCaption = ^NSString *(__unused id<TGEditablePhotoItem> item)
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;
        
        return strongSelf->_videoCaption;
    };
    videoItem.avAsset.fetchEditorValues = ^id<TGMediaEditAdjustments>(__unused id<TGEditablePhotoItem> item)
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;
        
        return strongSelf->_videoAdjustments;
    };
    videoItem.updateAdjustments = ^(__unused id<TGEditablePhotoItem> item, id<TGMediaEditAdjustments> adjustments)
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf != nil)
            strongSelf->_videoAdjustments = adjustments;
    };
    
    TGModernGalleryController *galleryController = [[TGModernGalleryController alloc] init];
    galleryController.adjustsStatusBarVisibility = false;
    galleryController.hasFadeOutTransition = true;
    
    TGMediaPickerGalleryModel *model = [[TGMediaPickerGalleryModel alloc] initWithItems:@[ videoItem ] focusItem:videoItem allowsSelection:false allowsEditing:true hasCaptions:!self.disallowCaptions forVideo:true];
    model.controller = galleryController;
    model.saveEditedItem = ^(__unused id<TGEditablePhotoItem> item, id<TGMediaEditAdjustments> adjustments, __unused UIImage *screenImage, __unused UIImage *thumbnailImage)
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf != nil)
            strongSelf->_videoAdjustments = adjustments;
    };
    model.saveItemCaption = ^(__unused id<TGEditablePhotoItem> item, NSString *caption)
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf != nil)
            strongSelf->_videoCaption = caption;
    };
    
    model.interfaceView.hasSwipeGesture = false;
    model.interfaceView.usesSimpleLayout = true;
    galleryController.model = model;

    __weak TGModernGalleryController *weakGalleryController = galleryController;
    __weak TGMediaPickerGalleryModel *weakModel = model;
    
    model.interfaceView.donePressed = ^(__unused TGMediaPickerGalleryItem *item)
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        TGMediaPickerGalleryVideoItemView *itemView = (TGMediaPickerGalleryVideoItemView *)[galleryController itemViewForItem:galleryController.currentItem];
        [itemView stop];
        [itemView setPlayButtonHidden:true animated:true];
        
        bool isTrimmed = itemView.hasTrimming;
        bool isCropped = (strongSelf->_videoAdjustments != nil && ([strongSelf->_videoAdjustments cropAppliedForAvatar:false] || strongSelf->_videoAdjustments.cropOrientation != UIImageOrientationUp));
        
        void (^finishBlock)(NSString *, NSString *, UIImage *, NSTimeInterval, CGSize) = ^(NSString *path, NSString *hash, UIImage *previewImage, NSTimeInterval duration, CGSize dimensions)
        {
            NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
            int32_t fileSize = (int32_t)[[fileAttributes objectForKey:NSFileSize] intValue];
            
            TGDispatchOnMainThread(^
            {
                if (strongSelf.finishedWithVideo != nil)
                    strongSelf.finishedWithVideo(hash, path, fileSize, previewImage, duration, dimensions, strongSelf->_videoCaption);
                
                __strong TGOverlayController *strongController = weakGalleryController;
                if (strongController != nil)
                    [strongSelf dismissTransitionForResultController:strongController];
            });
        };
        
        if (!isTrimmed && !isCropped)
        {
            if (strongSelf.shouldStoreCapturedAssets)
            {
                AVURLAsset *urlAsset = [AVURLAsset assetWithURL:url];
                [TGVideoConverter computeHashForVideoAsset:urlAsset hasTrimming:false isCropped:false highDefinition:false completion:^(NSString *hash)
                {
                    [[TGMediaPickerAssetsLibrary sharedLibrary] saveAssetWithVideoAtURL:url
                                                                        completionBlock:^(__unused bool success,
                                                                                          __unused NSString *uniqueId,
                                                                                          __unused NSError *error)
                    {
                        finishBlock(url.path, hash, strongSelf->_videoThumbnail, duration, dimensions);
                    }];
                }];
            }
            else
            {
                finishBlock(url.path, nil, strongSelf->_videoThumbnail, duration, dimensions);
            }
        }
        else
        {
            strongSelf->_videoConverter = [[TGVideoConverter alloc] initForPassthroughWithItemURL:url liveUpload:strongSelf.liveUploadEnabled];
            strongSelf->_videoConverter.trimRange = itemView.trimRange;
            if (strongSelf->_videoAdjustments != nil)
            {
                strongSelf->_videoConverter.cropRect = strongSelf->_videoAdjustments.cropRect;
                strongSelf->_videoConverter.cropOrientation = strongSelf->_videoAdjustments.cropOrientation;
            }
         
            TGMediaPickerGalleryModel *strongModel = weakModel;
            if (strongModel == nil)
                return;
            
            [strongModel.interfaceView showVideoConversionProgressForItemsCount:1];
            strongModel.interfaceView.videoConversionCancelled = ^
            {
                __strong TGCameraController *strongSelf = weakSelf;
                [strongSelf->_videoConverter cancel];
                strongSelf->_videoConverter = nil;
            };
            
            [strongSelf->_videoConverter processWithCompletion:^(NSString *tempFilePath,
                                                                 CGSize dimensions,
                                                                 NSTimeInterval duration,
                                                                 UIImage *previewImage,
                                                                 __unused TGLiveUploadActorData *liveUploadData)
            {
                void (^conversionCompletionBlock)(void) = ^
                {
                    finishBlock(tempFilePath, nil, previewImage, duration, dimensions);
                    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path isDirectory:NULL])
                        [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
                };
                
                if (strongSelf.shouldStoreCapturedAssets)
                {
                    [[TGMediaPickerAssetsLibrary sharedLibrary] saveAssetWithVideoAtURL:url
                                                                        completionBlock:^(__unused bool success,
                                                                                          __unused NSString *uniqueId,
                                                                                          __unused NSError *error)
                    {
                        conversionCompletionBlock();
                    }];
                }
                else
                {
                    conversionCompletionBlock();
                }
            } progress:^(float progress)
            {
                TGDispatchOnMainThread(^
                {
                    __strong TGCameraController *strongSelf = weakSelf;
                    if (strongSelf == nil)
                        return;

                    [strongModel.interfaceView updateVideoConversionProgress:progress cancelEnabled:true];
                });
            }];
        }
    };
    
    CGSize snapshotSize = TGScaleToFill(CGSizeMake(480, 640), CGSizeMake(self.view.frame.size.width, self.view.frame.size.width));
    UIView *snapshotView = [_previewView snapshotViewAfterScreenUpdates:false];
    snapshotView.contentMode = UIViewContentModeScaleAspectFill;
    snapshotView.frame = CGRectMake(_previewView.center.x - snapshotSize.width / 2, _previewView.center.y - snapshotSize.height / 2, snapshotSize.width, snapshotSize.height);
    snapshotView.hidden = true;
    [_previewView.superview insertSubview:snapshotView aboveSubview:_previewView];
    
    galleryController.beginTransitionIn = ^UIView *(__unused TGMediaPickerGalleryItem *item, __unused TGModernGalleryItemView *itemView)
    {
        __strong TGCameraController *strongSelf = weakSelf;
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
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_camera stopCaptureForPause:true completion:nil];
        
        snapshotView.hidden = true;
        
        if (completion != nil)
            completion();
    };
    
    galleryController.beginTransitionOut = ^UIView *(__unused TGMediaPickerGalleryItem *item)
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [[UIApplication sharedApplication] setIdleTimerDisabled:true];
            
            [strongSelf->_interfaceView setRecordingVideo:false animated:false];

            strongSelf->_buttonHandler.enabled = true;
            [strongSelf->_buttonHandler ignoreEventsFor:2.0f andDisable:false];
            
            strongSelf->_camera.disabled = false;
            [strongSelf->_camera startCaptureForResume:true completion:nil];
            
            strongSelf->_videoThumbnail = nil;
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:url.path isDirectory:NULL])
                [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
            
            [UIView animateWithDuration:0.3f delay:0.1f options:UIViewAnimationOptionCurveLinear animations:^
            {
                strongSelf->_interfaceView.alpha = 1.0f;
            } completion:nil];
            
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

#pragma mark - Transition

- (void)beginTransitionInFromRect:(CGRect)rect
{
    [self.view insertSubview:_previewView aboveSubview:_backgroundView];
    
    _previewView.frame = rect;
    
    _backgroundView.alpha = 0.0f;
    _interfaceView.alpha = 0.0f;
    
    [UIView animateWithDuration:0.3f animations:^
    {
        _backgroundView.alpha = 1.0f;
        _interfaceView.alpha = 1.0f;
    }];
    
    CGRect fromFrame = rect;
    CGRect toFrame = [TGCameraController _cameraPreviewFrameForScreenSize:TGScreenSize() mode:_camera.cameraMode];

    POPSpringAnimation *frameAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    frameAnimation.fromValue = [NSValue valueWithCGRect:fromFrame];
    frameAnimation.toValue = [NSValue valueWithCGRect:toFrame];
    frameAnimation.springSpeed = 20;
    frameAnimation.springBounciness = 1;
    [_previewView pop_addAnimation:frameAnimation forKey:@"frame"];
}

- (void)beginTransitionOutWithVelocity:(CGFloat)__unused velocity
{
    _dismissing = true;
    self.view.userInteractionEnabled = false;
    
    _focusControl.active = false;
    
    [UIView animateWithDuration:0.3f animations:^
    {
        [TGHacks setApplicationStatusBarAlpha:1.0f];
    }];
    
    [self setInterfaceHidden:true animated:true];
    
    [UIView animateWithDuration:0.25f animations:^
    {
        _backgroundView.alpha = 0.0f;
    }];
    
    CGRect referenceFrame = CGRectZero;
    if (self.beginTransitionOut != nil)
        referenceFrame = self.beginTransitionOut();
    
    __weak TGCameraController *weakSelf = self;
    if (CGRectIsEmpty(referenceFrame))
    {
        [self simpleTransitionOutWithVelocity:velocity completion:^
        {
            __strong TGCameraController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf dismiss];
        }];
        return;
    }
    
    bool resetNeeded = _camera.isResetNeeded;
    if (resetNeeded)
        [_previewView beginResetTransitionAnimated:true];

    [_camera resetSynchronous:false completion:^
    {
        TGDispatchOnMainThread(^
        {
            if (resetNeeded)
                [_previewView endResetTransitionAnimated:true];
        });
    }];
    
    [_previewView.layer removeAllAnimations];
    
    POPSpringAnimation *frameAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    frameAnimation.fromValue = [NSValue valueWithCGRect:_previewView.frame];
    frameAnimation.toValue = [NSValue valueWithCGRect:referenceFrame];
    frameAnimation.springSpeed = 20;
    frameAnimation.springBounciness = 1;
    frameAnimation.completionBlock = ^(__unused POPAnimation *animation, __unused BOOL finished)
    {
        __strong TGCameraController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;

        if (strongSelf.finishedTransitionOut != nil)
            strongSelf.finishedTransitionOut();

        [strongSelf dismiss];
    };
    [_previewView pop_addAnimation:frameAnimation forKey:@"frame"];
}

- (void)dismissTransitionForResultController:(TGOverlayController *)resultController
{
    _finishedWithResult = true;
    
    [TGHacks setApplicationStatusBarAlpha:1.0f];
    
    self.view.hidden = true;
    
    [UIView animateWithDuration:0.3f delay:0.0f options:(7 << 16) animations:^
    {
        resultController.view.frame = CGRectOffset(resultController.view.frame, 0, resultController.view.frame.size.height);
    } completion:^(__unused BOOL finished)
    {
        [resultController dismiss];
        [self dismiss];
    }];
}

- (void)simpleTransitionOutWithVelocity:(CGFloat)velocity completion:(void (^)())completion
{
    self.view.userInteractionEnabled = false;
    
    const CGFloat minVelocity = 2000.0f;
    if (ABS(velocity) < minVelocity)
        velocity = (velocity < 0.0f ? -1.0f : 1.0f) * minVelocity;
    CGFloat distance = (velocity < FLT_EPSILON ? -1.0f : 1.0f) * self.view.frame.size.height;
    CGRect targetFrame = (CGRect){{_previewView.frame.origin.x, distance}, _previewView.frame.size};
    
    [UIView animateWithDuration:ABS(distance / velocity) animations:^
    {
        _previewView.frame = targetFrame;
    } completion:^(__unused BOOL finished)
    {
        if (completion)
            completion();
    }];
}

- (void)_updateDismissTransitionMovementWithDistance:(CGFloat)distance animated:(bool)animated
{
    CGRect originalFrame = [TGCameraController _cameraPreviewFrameForScreenSize:TGScreenSize() mode:_camera.cameraMode];
    CGRect frame = (CGRect){ { originalFrame.origin.x, originalFrame.origin.y + distance }, originalFrame.size };
    if (animated)
    {
        [UIView animateWithDuration:0.3 animations:^
        {
            _previewView.frame = frame;
        }];
    }
    else
    {
        _previewView.frame = frame;
    }
}

- (void)_updateDismissTransitionWithProgress:(CGFloat)progress animated:(bool)animated
{
    CGFloat alpha = 1.0f - MAX(0.0f, MIN(1.0f, progress * 4.0f));
    CGFloat transitionProgress = MAX(0.0f, MIN(1.0f, progress * 2.0f));
    
    if (transitionProgress > FLT_EPSILON)
    {
        [self setInterfaceHidden:true animated:true];
        _focusControl.active = false;
    }
    else if (animated)
    {
        [self setInterfaceHidden:false animated:true];
        _focusControl.active = true;
    }
    
    if (animated)
    {
        [UIView animateWithDuration:0.3 animations:^
        {
            _backgroundView.alpha = alpha;
        }];
    }
    else
    {
        _backgroundView.alpha = alpha;
    }
}

- (void)resizePreviewViewForCameraMode:(PGCameraMode)mode
{
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionLayoutSubviews animations:^
    {
        _previewView.frame = [TGCameraController _cameraPreviewFrameForScreenSize:TGScreenSize() mode:mode];
    } completion:nil];
}

- (void)handleDeviceOrientationChangedTo:(UIDeviceOrientation)deviceOrientation
{
    if (_camera.isRecordingVideo)
        return;
    
    UIInterfaceOrientation orientation = [TGCameraController _interfaceOrientationForDeviceOrientation:deviceOrientation];
    if ([_interfaceView isKindOfClass:[TGCameraMainPhoneView class]])
    {
        [_interfaceView setInterfaceOrientation:orientation animated:true];
    }
    else
    {
        if (orientation == UIInterfaceOrientationUnknown)
            return;
        
        switch (deviceOrientation)
        {
            case UIDeviceOrientationPortrait:
            {
                _photoSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
                _videoSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
            }
                break;
            case UIDeviceOrientationPortraitUpsideDown:
            {
                _photoSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
                _videoSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
            }
                break;
            case UIDeviceOrientationLandscapeLeft:
            {
                _photoSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
                _videoSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
            }
                break;
            case UIDeviceOrientationLandscapeRight:
            {
                _photoSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
                _videoSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
            }
                break;
                
            default:
                break;
        }
        
        [_interfaceView setInterfaceOrientation:orientation animated:false];
        CGSize referenceSize = [self referenceViewSizeForOrientation:orientation];
        if (referenceSize.width > referenceSize.height)
            referenceSize = CGSizeMake(referenceSize.height, referenceSize.width);
        
        self.view.userInteractionEnabled = false;
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews animations:^
        {
            _interfaceView.transform = CGAffineTransformMakeRotation(TGRotationForInterfaceOrientation(orientation));
            _interfaceView.frame = CGRectMake(0, 0, referenceSize.width, referenceSize.height);
            [_interfaceView setNeedsLayout];
        } completion:^(BOOL finished)
        {
            if (finished)
                self.view.userInteractionEnabled = true;
        }];
    }
    
    [_focusControl setInterfaceOrientation:orientation animated:true];
}

#pragma mark - Gesture Recognizers

- (CGFloat)dismissProgressForSwipeDistance:(CGFloat)distance
{
    return MAX(0.0f, MIN(1.0f, ABS(distance / 150.0f)));
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    PGCameraMode newMode = PGCameraModeUndefined;
    if (gestureRecognizer == _photoSwipeGestureRecognizer)
    {
        if (_camera.cameraMode == PGCameraModePhoto)
            newMode = PGCameraModeSquare;
        else if (_camera.cameraMode != PGCameraModeSquare)
            newMode = PGCameraModePhoto;
    }
    else if (gestureRecognizer == _videoSwipeGestureRecognizer)
    {
        if (_camera.cameraMode == PGCameraModeSquare)
            newMode = PGCameraModePhoto;
        else
            newMode = PGCameraModeVideo;
    }
    
    if (newMode != PGCameraModeUndefined && _camera.cameraMode != newMode)
    {
        [_camera setCameraMode:newMode];
        [_interfaceView setCameraMode:newMode];
    }
}

- (void)handlePan:(TGModernGalleryZoomableScrollViewSwipeGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateChanged:
        {
            _dismissProgress = [self dismissProgressForSwipeDistance:[gestureRecognizer swipeDistance]];
            [self _updateDismissTransitionWithProgress:_dismissProgress animated:false];
            [self _updateDismissTransitionMovementWithDistance:[gestureRecognizer swipeDistance] animated:false];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            CGFloat swipeVelocity = [gestureRecognizer swipeVelocity];
            if (ABS(swipeVelocity) < TGCameraSwipeMinimumVelocity)
                swipeVelocity = (swipeVelocity < 0.0f ? -1.0f : 1.0f) * TGCameraSwipeMinimumVelocity;
            
            __weak TGCameraController *weakSelf = self;
            bool(^transitionOut)(CGFloat) = ^bool(CGFloat swipeVelocity)
            {
                __strong TGCameraController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return false;
                
                [strongSelf beginTransitionOutWithVelocity:swipeVelocity];
                
                return true;
            };
            
            if ((ABS(swipeVelocity) < TGCameraSwipeVelocityThreshold && ABS([gestureRecognizer swipeDistance]) < TGCameraSwipeDistanceThreshold) || !transitionOut(swipeVelocity))
            {
                _dismissProgress = 0.0f;
                [self _updateDismissTransitionWithProgress:0.0f animated:true];
                [self _updateDismissTransitionMovementWithDistance:0.0f animated:true];
            }
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
        {
            _dismissProgress = 0.0f;
            [self _updateDismissTransitionWithProgress:0.0f animated:true];
            [self _updateDismissTransitionMovementWithDistance:0.0f animated:true];
        }
            break;
            
        default:
            break;
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateChanged:
        {
            CGFloat delta = (gestureRecognizer.scale - 1.0f) / 1.5f;
            CGFloat value = MAX(0.0f, MIN(1.0f, _camera.zoomLevel + delta));
            
            [_camera setZoomLevel:value];
            [_interfaceView setZoomLevel:value displayNeeded:true];
            
            gestureRecognizer.scale = 1.0f;
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            [_interfaceView zoomChangingEnded];
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _panGestureRecognizer)
        return !_camera.isRecordingVideo;
    else if (gestureRecognizer == _photoSwipeGestureRecognizer || gestureRecognizer == _videoSwipeGestureRecognizer)
        return _intent != TGCameraControllerAvatarIntent && !_camera.isRecordingVideo;
    else if (gestureRecognizer == _pinchGestureRecognizer)
        return _camera.isZoomAvailable;
    
    return true;
}

+ (CGRect)_cameraPreviewFrameForScreenSize:(CGSize)screenSize mode:(PGCameraMode)mode
{
    CGFloat widescreenWidth = MAX(screenSize.width, screenSize.height);

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        switch (mode)
        {
            case PGCameraModeVideo:
            {
                return CGRectMake(0, 0, screenSize.width, screenSize.height);
            }
                break;
            
            case PGCameraModeSquare:
            {
                CGRect rect = [self _cameraPreviewFrameForScreenSize:screenSize mode:PGCameraModePhoto];
                return CGRectMake(0, CGRectGetMidY(rect) - rect.size.width / 2, rect.size.width, rect.size.width);
            }
                break;
            
            default:
            {
                if (widescreenWidth >= 736.0f - FLT_EPSILON)
                    return CGRectMake(0, 44, screenSize.width, screenSize.height - 50 - 136);
                else if (widescreenWidth >= 667.0f - FLT_EPSILON)
                    return CGRectMake(0, 44, screenSize.width, screenSize.height - 44 - 123);
                else if (widescreenWidth >= 568.0f - FLT_EPSILON)
                    return CGRectMake(0, 40, screenSize.width, screenSize.height - 40 - 101);
                else
                    return CGRectMake(0, 0, screenSize.width, screenSize.height);
            }
                break;
        }
    }
    else
    {
        if (mode == PGCameraModeSquare)
            return CGRectMake(0, (screenSize.height - screenSize.width) / 2, screenSize.width, screenSize.width);
        
        return CGRectMake(0, 0, screenSize.width, screenSize.height);
    }
}

+ (UIInterfaceOrientation)_interfaceOrientationForDeviceOrientation:(UIDeviceOrientation)orientation
{
    switch (orientation)
    {
        case UIDeviceOrientationPortrait:
            return UIInterfaceOrientationPortrait;
            
        case UIDeviceOrientationPortraitUpsideDown:
            return UIInterfaceOrientationPortraitUpsideDown;
            
        case UIDeviceOrientationLandscapeLeft:
            return UIInterfaceOrientationLandscapeRight;
            
        case UIDeviceOrientationLandscapeRight:
            return UIInterfaceOrientationLandscapeLeft;
            
        default:
            return UIInterfaceOrientationUnknown;
    }
}

@end
