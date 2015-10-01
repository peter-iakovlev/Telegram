#import "TGCameraPreviewView.h"

#import <AVFoundation/AVFoundation.h>
#import "TGImageUtils.h"

#import "PGCamera.h"
#import "PGCameraCaptureSession.h"

@interface TGCameraPreviewLayerWrapperView : UIView

@end

@implementation TGCameraPreviewLayerWrapperView

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

@end

@interface TGCameraPreviewView ()
{
    TGCameraPreviewLayerWrapperView *_wrapperView;
    UIView *_fadeView;
    UIView *_snapshotView;
    
    PGCamera *_camera;
}
@end

@implementation TGCameraPreviewView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.backgroundColor = [UIColor blackColor];
        self.clipsToBounds = true;
                
        _wrapperView = [[TGCameraPreviewLayerWrapperView alloc] init];
        [self addSubview:_wrapperView];
        
        AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)_wrapperView.layer;
        [layer setVideoGravity:AVLayerVideoGravityResize];
        
        _fadeView = [[UIView alloc] initWithFrame:self.bounds];
        _fadeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _fadeView.backgroundColor = [UIColor blackColor];
        _fadeView.userInteractionEnabled = false;
        [self addSubview:_fadeView];
    }
    return self;
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    return (AVCaptureVideoPreviewLayer *)_wrapperView.layer;
}

- (void)setupWithCamera:(PGCamera *)camera
{
    _camera = camera;
    
    [self.previewLayer setSession:camera.captureSession];
    
    __weak TGCameraPreviewView *weakSelf = self;
    camera.captureStarted = ^(bool resume)
    {
        __strong TGCameraPreviewView *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (resume)
            [strongSelf endResetTransitionAnimated:true];
        else
            [strongSelf fadeInAnimated:true];
    };
    
    camera.captureStopped = ^(bool pause)
    {
        __strong TGCameraPreviewView *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (pause)
            [strongSelf beginResetTransitionAnimated:true];
        else
            [strongSelf fadeOutAnimated:true];
    };
}

- (void)invalidate
{
    [self.previewLayer setSession:nil];
    _wrapperView = nil;
}

- (PGCamera *)camera
{
    return _camera;
}

- (void)fadeInAnimated:(bool)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.3f delay:0.05f options:UIViewAnimationOptionCurveLinear animations:^
        {
            _fadeView.alpha = 0.0f;
        } completion:nil];
    }
    else
    {
        _fadeView.alpha = 0.0f;
    }
}

- (void)fadeOutAnimated:(bool)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.3f animations:^
        {
            _fadeView.alpha = 1.0f;
        }];
    }
    else
    {
        _fadeView.alpha = 1.0f;
    }
}

- (void)beginTransitionWithSnapshotImage:(UIImage *)image animated:(bool)animated
{
    [_snapshotView removeFromSuperview];
    
    UIImageView *snapshotView = [[UIImageView alloc] initWithFrame:_wrapperView.frame];
    snapshotView.image = image;
    [self insertSubview:snapshotView aboveSubview:_wrapperView];
    
    _snapshotView = snapshotView;
    
    if (animated)
    {
        _snapshotView.alpha = 0.0f;
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^
        {
            _snapshotView.alpha = 1.0f;
        } completion:nil];
    }
}

- (void)endTransitionAnimated:(bool)animated
{
    if (animated)
    {
        UIView *snapshotView = _snapshotView;
        _snapshotView = nil;
        
        [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            snapshotView.alpha = 0.0f;
        } completion:^(__unused BOOL finished)
        {
            [snapshotView removeFromSuperview];
        }];
    }
    else
    {
        [_snapshotView removeFromSuperview];
        _snapshotView = nil;
    }
}

- (void)beginResetTransitionAnimated:(bool)animated
{
    if (iosMajorVersion() < 7)
        return;
    
    [_snapshotView removeFromSuperview];
    
    _snapshotView = [_wrapperView snapshotViewAfterScreenUpdates:false];
    _snapshotView.frame = _wrapperView.frame;
    [self insertSubview:_snapshotView aboveSubview:_wrapperView];
    
    if (animated)
    {
        _snapshotView.alpha = 0.0f;
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^
        {
            _snapshotView.alpha = 1.0f;
        } completion:nil];
    }
}

- (void)endResetTransitionAnimated:(bool)animated
{
    if (iosMajorVersion() < 7)
        return;
    
    if (animated)
    {
        UIView *snapshotView = _snapshotView;
        _snapshotView = nil;
        
        [UIView animateWithDuration:0.4f delay:0.05f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            snapshotView.alpha = 0.0f;
        } completion:^(__unused BOOL finished)
        {
            [snapshotView removeFromSuperview];
        }];
    }
    else
    {
        [_snapshotView removeFromSuperview];
        _snapshotView = nil;
    }
}

- (CGPoint)devicePointOfInterestForPoint:(CGPoint)point
{
    return [self.previewLayer captureDevicePointOfInterestForPoint:point];
}

- (void)layoutSubviews
{
    CGSize scaledSize = TGScaleToFill(CGSizeMake(320, 428), self.bounds.size);
    _wrapperView.frame = CGRectMake((self.bounds.size.width - scaledSize.width) / 2, (self.bounds.size.height - scaledSize.height) / 2, scaledSize.width, scaledSize.height);
    _snapshotView.frame = _wrapperView.frame;
}

@end
