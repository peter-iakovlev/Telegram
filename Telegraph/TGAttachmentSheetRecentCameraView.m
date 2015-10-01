#import "TGAttachmentSheetRecentCameraView.h"

#import "PGCamera.h"
#import "TGCameraPreviewView.h"
#import "TGPhotoEditorUtils.h"

#import <AVFoundation/AVFoundation.h>

#import "ATQueue.h"

@interface TGAttachmentSheetRecentCameraView ()
{
    UIView *_wrapperView;
    UIImageView *_iconView;
    
    TGCameraPreviewView *_previewView;
    __weak PGCamera *_camera;
}
@end

@implementation TGAttachmentSheetRecentCameraView

- (instancetype)initWithFrontCamera:(bool)withFrontCamera
{
    self = [super init];
    if (self != nil)
    {
        self.backgroundColor = [UIColor clearColor];

        _wrapperView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 78.0f, 78.0f)];
        [self addSubview:_wrapperView];
        
        PGCamera *camera = nil;
        if ([PGCamera cameraAvailable])
            camera = [[PGCamera alloc] initWithPosition:withFrontCamera ? PGCameraPositionFront : PGCameraPositionUndefined];
        
        _camera = camera;
        
        _previewView = [[TGCameraPreviewView alloc] initWithFrame:CGRectMake(0, 0, 78.0f, 78.0f)];
        [_wrapperView addSubview:_previewView];
        [camera attachPreviewView:_previewView];
        
        _iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AttachmentMenuInteractiveCameraIcon.png"]];
        [self addSubview:_iconView];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)]];
        
        [self setInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation] animated:false];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    TGCameraPreviewView *previewView = _previewView;
    if (previewView.superview == _wrapperView && _camera != nil)
        [self stopPreview];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (TGCameraPreviewView *)previewView
{
    return _previewView;
}

- (bool)previewViewAttached
{
    return _previewView.superview == _wrapperView;
}

- (void)detachPreviewView
{
    _iconView.alpha = 0.0f;
}

- (void)attachPreviewViewAnimated:(bool)animated
{
    [_wrapperView addSubview:_previewView];
    [self setNeedsLayout];
    
    if (animated)
    {
        _iconView.alpha = 0.0f;
        [UIView animateWithDuration:0.2 animations:^
        {
            _iconView.alpha = 1.0f;
        }];
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        if (_pressed)
            _pressed();
    }
}

- (void)startPreview
{
    PGCamera *camera = _camera;
    [camera startCaptureForResume:false completion:nil];
}

- (void)stopPreview
{
    PGCamera *camera = _camera;
    [camera stopCaptureForPause:false completion:nil];
    _camera = nil;
}

- (void)pausePreview
{
    TGCameraPreviewView *previewView = _previewView;
    if (previewView.superview != _wrapperView)
        return;
    
    PGCamera *camera = _camera;
    [camera stopCaptureForPause:true completion:nil];
}

- (void)resumePreview
{
    TGCameraPreviewView *previewView = _previewView;
    if (previewView.superview != _wrapperView)
        return;
    
    PGCamera *camera = _camera;
    [camera startCaptureForResume:true completion:nil];
}

- (void)handleOrientationChange:(NSNotification *)__unused notification
{
    [self setInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation] animated:true];
}

- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation animated:(bool)animated
{
    void(^block)(void) = ^
    {
        _wrapperView.transform = CGAffineTransformMakeRotation(-1 * TGRotationForInterfaceOrientation(orientation));
    };
    
    if (animated)
        [UIView animateWithDuration:0.3f animations:block];
    else
        block();
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    TGCameraPreviewView *previewView = _previewView;
    if (previewView.superview == _wrapperView)
        previewView.frame = self.bounds;
    
    _iconView.frame = (CGRect){{CGFloor((self.frame.size.width - _iconView.frame.size.width) / 2.0f), CGFloor((self.frame.size.height - _iconView.frame.size.height) / 2.0f)}, _iconView.frame.size};
}

@end
