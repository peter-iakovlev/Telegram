#import <Foundation/Foundation.h>
#import "PGCamera.h"

@class TGModernButton;
@class TGCameraShutterButton;
@class TGCameraModeControl;
@class TGCameraFlipButton;
@class TGCameraTimeCodeView;
@class TGCameraZoomView;

@interface TGCameraMainView : UIView
{
    UIInterfaceOrientation _interfaceOrientation;
    
    TGModernButton *_cancelButton;
    TGCameraShutterButton *_shutterButton;
    TGCameraModeControl *_modeControl;
    
    TGCameraFlipButton *_flipButton;
    TGCameraTimeCodeView *_timecodeView;
    
    TGCameraZoomView *_zoomView;
}

@property (nonatomic, copy) void(^cameraFlipped)(void);
@property (nonatomic, copy) void(^cameraModeChanged)(PGCameraMode mode);
@property (nonatomic, copy) void(^flashModeChanged)(PGCameraFlashMode mode);

@property (nonatomic, copy) void(^focusPointChanged)(CGPoint point);
@property (nonatomic, copy) void(^expositionChanged)(CGFloat value);

@property (nonatomic, copy) void(^shutterPressed)(bool fromHardwareButton);
@property (nonatomic, copy) void(^shutterReleased)(bool fromHardwareButton);
@property (nonatomic, copy) void(^cancelPressed)(void);

@property (nonatomic, copy) NSTimeInterval(^requestedVideoRecordingDuration)(void);

- (void)setCameraMode:(PGCameraMode)mode;
- (void)updateForCameraModeChangeWithPreviousMode:(PGCameraMode)previousMode;

- (void)setFlashMode:(PGCameraFlashMode)mode;
- (void)setFlashActive:(bool)active;
- (void)setFlashUnavailable:(bool)unavailable;
- (void)setHasFlash:(bool)hasFlash;

- (void)setHasZoom:(bool)hasZoom;
- (void)setZoomLevel:(CGFloat)zoomLevel displayNeeded:(bool)displayNeeded;
- (void)zoomChangingEnded;

- (void)setHasModeControl:(bool)hasModeControl;

- (void)setShutterButtonHighlighted:(bool)highlighted;

- (void)shutterButtonReleased;
- (void)flipButtonPressed;
- (void)cancelButtonPressed;

- (void)setRecordingVideo:(bool)recordingVideo animated:(bool)animated;
- (void)setInterfaceHiddenForVideoRecording:(bool)hidden animated:(bool)animated;

- (UIInterfaceOrientation)interfaceOrientation;
- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation animated:(bool)animated;

@end
