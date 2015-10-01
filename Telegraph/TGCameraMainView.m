#import "TGCameraMainView.h"

#import "TGImageUtils.h"

#import "TGCameraShutterButton.h"
#import "TGCameraModeControl.h"
#import "TGCameraTimeCodeView.h"
#import "TGCameraZoomView.h"

@implementation TGCameraMainView

#pragma mark - Mode

- (void)setInterfaceHiddenForVideoRecording:(bool)__unused hidden animated:(bool)__unused animated
{
}

- (void)setCameraMode:(PGCameraMode)mode
{
    PGCameraMode previousMode = _modeControl.cameraMode;
    [_modeControl setCameraMode:mode animated:true];
    [self updateForCameraModeChangeWithPreviousMode:previousMode];
}

- (void)updateForCameraModeChangeWithPreviousMode:(PGCameraMode)__unused previousMode
{
    if (_modeControl.cameraMode == PGCameraModePhoto)
    {
        [_shutterButton setButtonMode:TGCameraShutterButtonNormalMode animated:true];
        [_timecodeView setHidden:true animated:true];
    }
    else if (_modeControl.cameraMode == PGCameraModeVideo)
    {
        [_shutterButton setButtonMode:TGCameraShutterButtonVideoMode animated:true];
        [_timecodeView setHidden:false animated:true];
    }
    
    [_zoomView hideAnimated:true];
}

- (void)setHasModeControl:(bool)hasModeControl
{
    if (!hasModeControl)
        [_modeControl removeFromSuperview];
}

#pragma mark - Flash

- (void)setHasFlash:(bool)__unused hasFlash
{
    
}

- (void)setFlashMode:(PGCameraFlashMode)__unused mode
{
    
}

- (void)setFlashActive:(bool)__unused active
{
    
}

- (void)setFlashUnavailable:(bool)__unused unavailable
{
    
}

#pragma mark - Actions

- (void)setShutterButtonHighlighted:(bool)highlighted
{
    [_shutterButton setHighlighted:highlighted];
}

- (void)shutterButtonPressed
{
    if (self.shutterReleased != nil)
        self.shutterReleased(false);
}

- (void)shutterButtonReleased
{
    if (self.shutterReleased != nil)
        self.shutterReleased(false);
}

- (void)cancelButtonPressed
{
    if (self.cancelPressed != nil)
        self.cancelPressed();
}

- (void)flipButtonPressed
{
    if (self.cameraFlipped != nil)
        self.cameraFlipped();
}

#pragma mark - Zoom

- (void)setZoomLevel:(CGFloat)zoomLevel displayNeeded:(bool)displayNeeded
{
    [_zoomView setZoomLevel:zoomLevel displayNeeded:displayNeeded];
}

- (void)zoomChangingEnded
{
    [_zoomView interactionEnded];
}

- (void)setHasZoom:(bool)hasZoom
{
    if (!hasZoom)
        [_zoomView hideAnimated:true];
}

#pragma mark - Video

- (void)setRecordingVideo:(bool)recordingVideo animated:(bool)animated
{
    [_shutterButton setButtonMode:recordingVideo ? TGCameraShutterButtonRecordingMode : TGCameraShutterButtonVideoMode animated:animated];
    if (recordingVideo)
    {
        [_timecodeView startRecording];
    }
    else
    {
        [_timecodeView stopRecording];
        [_timecodeView reset];
    }
    [self setInterfaceHiddenForVideoRecording:recordingVideo animated:animated];
}

#pragma mark - 

- (UIInterfaceOrientation)interfaceOrientation
{
    return _interfaceOrientation;
}

- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation animated:(bool)__unused animated
{
    _interfaceOrientation = orientation;
}

@end