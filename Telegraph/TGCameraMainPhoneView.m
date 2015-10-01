#import "TGCameraMainPhoneView.h"

#import "UIControl+HitTestEdgeInsets.h"

#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGPhotoEditorUtils.h"
#import "TGCameraInterfaceAssets.h"

#import "TGModernButton.h"
#import "TGCameraShutterButton.h"
#import "TGCameraModeControl.h"
#import "TGCameraFlashControl.h"
#import "TGCameraFlashActiveView.h"
#import "TGCameraFlipButton.h"
#import "TGCameraTimeCodeView.h"
#import "TGCameraZoomView.h"

@interface TGCameraTopPanelView : UIView

@property (nonatomic, copy) bool(^isPointInside)(CGPoint point);

@end

@implementation TGCameraTopPanelView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.hidden)
        return [super pointInside:point withEvent:event];
    
    CGRect relativeFrame = self.bounds;
    bool insideBounds = CGRectContainsPoint(relativeFrame, point);
    
    bool additionalCheck = false;
    if (self.isPointInside != nil)
        additionalCheck = self.isPointInside(point);
    
    return insideBounds || additionalCheck;
}

@end

@interface TGCameraMainPhoneView ()
{
    TGCameraTopPanelView *_topPanelView;
    UIView *_bottomPanelView;
    UIView *_bottomPanelBackgroundView;
    
    UIView *_videoLandscapePanelView;;
    
    TGCameraFlashControl *_flashControl;
    TGCameraFlashActiveView *_flashActiveView;
    
    CGFloat _topPanelHeight;
    CGFloat _bottomPanelHeight;
    CGFloat _modeControlHeight;
}
@end

@implementation TGCameraMainPhoneView

@synthesize requestedVideoRecordingDuration;
@synthesize cameraFlipped;
@synthesize cameraModeChanged;
@synthesize flashModeChanged;
@synthesize focusPointChanged;
@synthesize expositionChanged;
@synthesize shutterPressed;
@synthesize shutterReleased;
@synthesize cancelPressed;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        CGSize screenSize = TGScreenSize();
        CGFloat widescreenWidth = MAX(screenSize.width, screenSize.height);
        if (widescreenWidth >= 736.0f - FLT_EPSILON)
        {
            _topPanelHeight = 44.0f;
            _bottomPanelHeight = 140.0f;
            _modeControlHeight = 50.0f;
        }
        else if (widescreenWidth >= 667.0f - FLT_EPSILON)
        {
            _topPanelHeight = 44.0f;
            _bottomPanelHeight = 123.0f;
            _modeControlHeight = 42.0f;
        }
        else
        {
            _topPanelHeight = 40.0f;
            _bottomPanelHeight = 101.0f;
            _modeControlHeight = 31.0f;
        }
        
        __weak TGCameraMainPhoneView *weakSelf = self;
        
        _topPanelView = [[TGCameraTopPanelView alloc] init];
        _topPanelView.backgroundColor = [TGCameraInterfaceAssets transparentPanelBackgroundColor];
        _topPanelView.isPointInside = ^bool(CGPoint point)
        {
            __strong TGCameraMainPhoneView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return false;
            
            CGRect rect = [strongSelf->_topPanelView convertRect:strongSelf->_flashControl.frame
                                                        fromView:strongSelf->_flashControl.superview];
            
            return CGRectContainsPoint(rect, point);
        };
        [self addSubview:_topPanelView];
        
        _bottomPanelView = [[UIView alloc] init];
        [self addSubview:_bottomPanelView];
        
        _bottomPanelBackgroundView = [[UIView alloc] initWithFrame:_bottomPanelView.bounds];
        _bottomPanelBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _bottomPanelBackgroundView.backgroundColor = [TGCameraInterfaceAssets transparentPanelBackgroundColor];
        [_bottomPanelView addSubview:_bottomPanelBackgroundView];
        
        _cancelButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        _cancelButton.backgroundColor = [UIColor clearColor];
        _cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _cancelButton.exclusiveTouch = true;
        _cancelButton.titleLabel.font = TGSystemFontOfSize(18);
        _cancelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        [_cancelButton setTitle:TGLocalized(@"Common.Cancel") forState:UIControlStateNormal];
        [_cancelButton setTintColor:[TGCameraInterfaceAssets normalColor]];
        [_cancelButton sizeToFit];
        _cancelButton.frame = CGRectMake(0, 0.5f, MAX(60.0f, _cancelButton.frame.size.width), 44);
        [_cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_bottomPanelView addSubview:_cancelButton];
        
        _shutterButton = [[TGCameraShutterButton alloc] initWithFrame:CGRectMake((frame.size.width - 66) / 2, 10, 66, 66)];
        [_shutterButton addTarget:self action:@selector(shutterButtonReleased) forControlEvents:UIControlEventTouchUpInside];
        [_bottomPanelView addSubview:_shutterButton];
        
        _modeControl = [[TGCameraModeControl alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, _modeControlHeight)];
        [_bottomPanelView addSubview:_modeControl];
        
        _flashControl = [[TGCameraFlashControl alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, TGCameraFlashControlHeight)];
        [_topPanelView addSubview:_flashControl];
        
        _timecodeView = [[TGCameraTimeCodeView alloc] initWithFrame:CGRectMake((frame.size.width - 120) / 2, 12, 120, 20)];
        _timecodeView.hidden = true;
        _timecodeView.requestedRecordingDuration = ^NSTimeInterval
        {
            __strong TGCameraMainPhoneView *strongSelf = weakSelf;
            if (strongSelf == nil || strongSelf.requestedVideoRecordingDuration == nil)
                return 0.0;
            
            return strongSelf.requestedVideoRecordingDuration();
        };
        [_topPanelView addSubview:_timecodeView];
        
        _flipButton = [[TGCameraFlipButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [_flipButton addTarget:self action:@selector(flipButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_topPanelView addSubview:_flipButton];

        _videoLandscapePanelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 274, 44)];
        _videoLandscapePanelView.alpha = 0.0f;
        _videoLandscapePanelView.backgroundColor = [TGCameraInterfaceAssets transparentPanelBackgroundColor];
        _videoLandscapePanelView.hidden = true;
        _videoLandscapePanelView.layer.cornerRadius = 3.5f;
        [self addSubview:_videoLandscapePanelView];
        
        _flashActiveView = [[TGCameraFlashActiveView alloc] initWithFrame:CGRectMake((frame.size.width - 40) / 2, frame.size.height - _bottomPanelHeight - 37, 40, 21)];
        [self addSubview:_flashActiveView];
        
        _zoomView = [[TGCameraZoomView alloc] initWithFrame:CGRectMake(10, frame.size.height - _bottomPanelHeight - 18, frame.size.width - 20, 1.5f)];
        _zoomView.activityChanged = ^(bool active)
        {
            __strong TGCameraMainPhoneView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^
            {
                [strongSelf _layoutFlashActiveViewForInterfaceOrientation:strongSelf->_interfaceOrientation zoomViewHidden:!active];
            } completion:nil];
        };
        [self addSubview:_zoomView];
    
        _flashControl.becameActive = ^
        {
            __strong TGCameraMainPhoneView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (UIInterfaceOrientationIsPortrait(strongSelf->_interfaceOrientation) || strongSelf->_modeControl.cameraMode == PGCameraModeVideo)
                [strongSelf->_flipButton setHidden:true animated:true];
            
            if (strongSelf->_modeControl.cameraMode == PGCameraModeVideo)
                [strongSelf->_timecodeView setHidden:true animated:true];
        };
        
        _flashControl.modeChanged = ^(PGCameraFlashMode mode)
        {
            __strong TGCameraMainPhoneView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (strongSelf.flashModeChanged != nil)
                strongSelf.flashModeChanged(mode);
            
            [strongSelf->_flipButton setHidden:false animated:true];
            
            if (strongSelf->_modeControl.cameraMode == PGCameraModeVideo)
                [strongSelf->_timecodeView setHidden:false animated:true];
        };
        
        _modeControl.modeChanged = ^(PGCameraMode mode, PGCameraMode previousMode)
        {
            __strong TGCameraMainPhoneView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (strongSelf.cameraModeChanged != nil)
                strongSelf.cameraModeChanged(mode);
            
            [strongSelf updateForCameraModeChangeWithPreviousMode:previousMode];
        };
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    if ([view isDescendantOfView:_topPanelView] || [view isDescendantOfView:_bottomPanelView] || [view isDescendantOfView:_videoLandscapePanelView])
        return view;
    
    return nil;
}

#pragma mark - Actions

- (void)shutterButtonReleased
{
    [super shutterButtonReleased];
    
    [_flashControl dismissAnimated:true];
}

- (void)updateForCameraModeChangeWithPreviousMode:(PGCameraMode)previousMode
{
    [super updateForCameraModeChangeWithPreviousMode:previousMode];
    
    UIInterfaceOrientation orientation = _interfaceOrientation;
    PGCameraMode cameraMode = _modeControl.cameraMode;
    
    if (UIInterfaceOrientationIsLandscape(orientation) && !((cameraMode == PGCameraModePhoto && previousMode == PGCameraModeSquare) || (cameraMode == PGCameraModeSquare && previousMode == PGCameraModePhoto)))
    {
        if (cameraMode == PGCameraModeVideo)
            _timecodeView.hidden = true;
        
        [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^
        {
            _topPanelView.alpha = 0.0f;
            _videoLandscapePanelView.alpha = 0.0f;
        } completion:^(__unused BOOL finished)
        {
            if (cameraMode == PGCameraModeVideo)
            {
                _timecodeView.hidden = false;
                _flipButton.transform = CGAffineTransformIdentity;
                _flashControl.transform = CGAffineTransformIdentity;
                _flashControl.interfaceOrientation = UIInterfaceOrientationPortrait;
                [self _layoutTopPanelViewForInterfaceOrientation:orientation];
            }
            else
            {
                _flipButton.transform = CGAffineTransformMakeRotation(TGRotationForInterfaceOrientation(orientation));
                _flashControl.transform = CGAffineTransformMakeRotation(TGRotationForInterfaceOrientation(orientation));
                _flashControl.interfaceOrientation = orientation;
                [self _layoutTopPanelViewForInterfaceOrientation:UIInterfaceOrientationPortrait];
            }
             
            if (cameraMode == PGCameraModeVideo)
                [self _attachControlsToLandscapePanel];
            else
                [self _attachControlsToTopPanel];
            
            _flipButton.hidden = false;
             
            [self _layoutTopPanelSubviewsForInterfaceOrientation:orientation];
            [_flashControl dismissAnimated:false];
            
            [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^
            {
                if (cameraMode == PGCameraModeVideo)
                    _videoLandscapePanelView.alpha = 1.0f;
                else
                    _topPanelView.alpha = 1.0f;
            } completion:nil];
        }];
    }
}

#pragma mark - Flash

- (void)setFlashMode:(PGCameraFlashMode)mode
{
    [_flashControl setMode:mode];
    [_flipButton setHidden:false animated:true];
}

- (void)setFlashActive:(bool)active
{
    [_flashActiveView setActive:active animated:true];
}

- (void)setFlashUnavailable:(bool)unavailable
{
    [_flashControl setFlashUnavailable:unavailable];
}

- (void)setHasFlash:(bool)hasFlash
{
    if (!hasFlash)
        [_flashActiveView setActive:false animated:true];
    
    [_flashControl setHidden:!hasFlash animated:true];
}

#pragma mark - Layout

- (void)setInterfaceHiddenForVideoRecording:(bool)hidden animated:(bool)animated
{
    if (animated)
    {
        _modeControl.hidden = false;
        _cancelButton.hidden = false;
        _flashControl.hidden = false;
        _flipButton.hidden = false;
        _bottomPanelBackgroundView.hidden = false;
        
        [UIView animateWithDuration:0.25f
                         animations:^
        {
            CGFloat alpha = hidden ? 0.0f : 1.0f;
            _modeControl.alpha = alpha;
            _cancelButton.alpha = alpha;
            _flashControl.alpha = alpha;
            _flipButton.alpha = alpha;
            _bottomPanelBackgroundView.alpha = alpha;
        } completion:^(BOOL finished)
        {
            if (finished)
            {
                _modeControl.hidden = hidden;
                _cancelButton.hidden = hidden;
                _flashControl.hidden = hidden;
                _flipButton.hidden = hidden;
                _bottomPanelBackgroundView.hidden = hidden;
            }
        }];
    }
    else
    {
        [_modeControl setHidden:hidden animated:false];
        
        CGFloat alpha = hidden ? 0.0f : 1.0f;
        _modeControl.hidden = hidden;
        _modeControl.alpha = alpha;
        _cancelButton.hidden = hidden;
        _cancelButton.alpha = alpha;
        _flashControl.hidden = hidden;
        _flashControl.alpha = alpha;
        _flipButton.hidden = hidden;
        _flipButton.alpha = alpha;
        _bottomPanelBackgroundView.hidden = hidden;
        _bottomPanelBackgroundView.alpha = alpha;
    }
}

- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation animated:(bool)animated
{
    if (orientation == UIInterfaceOrientationUnknown || orientation == _interfaceOrientation)
        return;
 
    _interfaceOrientation = orientation;
    
    if (animated)
    {
        [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^
        {
            _flashActiveView.alpha = 0.0f;
            
            if (_modeControl.cameraMode == PGCameraModeVideo)
            {
                _topPanelView.alpha = 0.0f;
                _videoLandscapePanelView.alpha = 0.0f;
            }
            else
            {
                _flipButton.transform = CGAffineTransformMakeRotation(TGRotationForInterfaceOrientation(orientation));
                _flipButton.hidden = false;
                _flipButton.alpha = 1.0f;
                
                _flashControl.alpha = 0.0f;
            }
        } completion:^(__unused BOOL finished)
        {
            [self _layoutFlashActiveViewForInterfaceOrientation:orientation zoomViewHidden:!_zoomView.isActive];
            
            if (_modeControl.cameraMode == PGCameraModeVideo)
            {
                _flipButton.transform = CGAffineTransformIdentity;
                _flashControl.transform = CGAffineTransformIdentity;
                _flashControl.interfaceOrientation = UIInterfaceOrientationPortrait;
             
                [self _layoutTopPanelViewForInterfaceOrientation:orientation];
                
                if (UIInterfaceOrientationIsLandscape(orientation))
                    [self _attachControlsToLandscapePanel];
                else
                    [self _attachControlsToTopPanel];
                
                _timecodeView.hidden = false;
                _flipButton.hidden = false;
            }
            else
            {
                _flashControl.transform = CGAffineTransformMakeRotation(TGRotationForInterfaceOrientation(orientation));
                _flashControl.interfaceOrientation = orientation;
            }
            
            [self _layoutTopPanelSubviewsForInterfaceOrientation:orientation];

            [_flashControl dismissAnimated:false];
            
            [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^
            {
                _flashActiveView.alpha = 1.0f;
                
                if (_modeControl.cameraMode == PGCameraModeVideo)
                {
                    if (UIInterfaceOrientationIsLandscape(orientation))
                        _videoLandscapePanelView.alpha = 1.0f;
                    else
                        _topPanelView.alpha = 1.0f;
                }
                else
                {
                    _flashControl.alpha = 1.0f;
                }
            } completion:nil];
        }];
    }
    else
    {
        [_flashControl dismissAnimated:false];
        
        _flipButton.transform = CGAffineTransformMakeRotation(TGRotationForInterfaceOrientation(orientation));
        _flashControl.transform = CGAffineTransformMakeRotation(TGRotationForInterfaceOrientation(orientation));
        _flashControl.interfaceOrientation = orientation;
        
        [self _layoutTopPanelSubviewsForInterfaceOrientation:orientation];
        
        [self _layoutFlashActiveViewForInterfaceOrientation:orientation zoomViewHidden:!_zoomView.isActive];
        
        if (_modeControl.cameraMode == PGCameraModeVideo)
        {
            _timecodeView.hidden = false;
            _flipButton.hidden = false;
        }
    }
}

- (void)_layoutFlashActiveViewForInterfaceOrientation:(UIInterfaceOrientation)orientation zoomViewHidden:(bool)zoomViewHidden
{
    _flashActiveView.transform = CGAffineTransformMakeRotation(TGRotationForInterfaceOrientation(orientation));
    switch (orientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            _flashActiveView.frame = CGRectMake((self.frame.size.width - 40) / 2, _topPanelHeight + 16, 40, 21);
        }
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
        {
            _flashActiveView.frame = CGRectMake(self.frame.size.width - 37, _topPanelHeight + (self.frame.size.height - _topPanelHeight - _bottomPanelHeight - 40) / 2, 21, 40);
        }
            break;
            
        case UIInterfaceOrientationLandscapeRight:
        {
            _flashActiveView.frame = CGRectMake(16, _topPanelHeight + (self.frame.size.height - _topPanelHeight - _bottomPanelHeight - 40) / 2, 21, 40);
        }
            break;
            
        default:
        {
            CGFloat offset = 0;
            if (!zoomViewHidden)
                offset -= 23;
            
            _flashActiveView.frame = CGRectMake((self.frame.size.width - 40) / 2, self.frame.size.height - _bottomPanelHeight - 37 + offset, 40, 21);
        }
            break;
    }
}

- (void)_layoutTopPanelViewForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    CGAffineTransform transform = CGAffineTransformMakeRotation(TGRotationForInterfaceOrientation(orientation));
    
    switch (orientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
        {
            _videoLandscapePanelView.hidden = false;
            _topPanelView.hidden = true;
            
            _videoLandscapePanelView.transform = transform;
            _videoLandscapePanelView.frame = CGRectMake(3, (self.frame.size.height - _videoLandscapePanelView.frame.size.height) / 2, _videoLandscapePanelView.frame.size.width, _videoLandscapePanelView.frame.size.height);
        }
            break;
        case UIInterfaceOrientationLandscapeRight:
        {
            _videoLandscapePanelView.hidden = false;
            _topPanelView.hidden = true;
            
            _videoLandscapePanelView.transform = transform;
            _videoLandscapePanelView.frame = CGRectMake(self.frame.size.width - _videoLandscapePanelView.frame.size.width - 3, (self.frame.size.height - _videoLandscapePanelView.frame.size.height) / 2, _videoLandscapePanelView.frame.size.width, _videoLandscapePanelView.frame.size.height);
        }
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            _videoLandscapePanelView.hidden = true;
            _topPanelView.hidden = false;
            
            _topPanelView.transform = transform;
            _topPanelView.frame = CGRectMake(0, 0, _topPanelView.frame.size.width, _topPanelView.frame.size.height);
        }
            break;
            
        default:
        {
            _videoLandscapePanelView.hidden = true;
            _topPanelView.hidden = false;
            
            _topPanelView.transform = transform;
            _topPanelView.frame = CGRectMake(0, 0, _topPanelView.frame.size.width, _topPanelView.frame.size.height);
        }
            break;
    }
}

- (void)_attachControlsToTopPanel
{
    [_topPanelView addSubview:_flashControl];
    [_topPanelView addSubview:_timecodeView];
    [_topPanelView addSubview:_flipButton];
}

- (void)_attachControlsToLandscapePanel
{
    [_videoLandscapePanelView addSubview:_flashControl];
    [_videoLandscapePanelView addSubview:_timecodeView];
    [_videoLandscapePanelView addSubview:_flipButton];
}

- (void)_layoutTopPanelSubviewsForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    UIView *superview = _flashControl.superview;
    CGSize superviewSize = superview.frame.size;
    
    if (superview == _videoLandscapePanelView && superviewSize.width < superviewSize.height)
        superviewSize = CGSizeMake(superviewSize.height, superviewSize.width);
    
    if (UIInterfaceOrientationIsLandscape(orientation) && _flashControl.interfaceOrientation == orientation && _flashControl.superview == _topPanelView)
    {
        if (orientation == UIInterfaceOrientationLandscapeLeft)
            _flashControl.frame = CGRectMake(7, 0, TGCameraFlashControlHeight, 370);
        else if (orientation == UIInterfaceOrientationLandscapeRight)
            _flashControl.frame = CGRectMake(7, 0, TGCameraFlashControlHeight, 370);
    }
    else
    {
        _flashControl.frame = CGRectMake(0, (superviewSize.height - TGCameraFlashControlHeight) / 2, superviewSize.width, TGCameraFlashControlHeight);
    }
    _timecodeView.frame = CGRectMake((superviewSize.width - 120) / 2, (superviewSize.height - 20) / 2, 120, 20);
    _flipButton.frame = CGRectMake(superviewSize.width - 42, (superviewSize.height - _flipButton.frame.size.height) / 2, _flipButton.frame.size.width, _flipButton.frame.size.height);
}

- (void)layoutSubviews
{
    _topPanelView.frame = CGRectMake(0, 0, self.frame.size.width, _topPanelHeight);
    [self _layoutTopPanelSubviewsForInterfaceOrientation:_interfaceOrientation];
    
    _bottomPanelView.frame = CGRectMake(0, self.frame.size.height - _bottomPanelHeight, self.frame.size.width, _bottomPanelHeight);
    _modeControl.frame = CGRectMake(0, 0, self.frame.size.width, _modeControlHeight);
    _shutterButton.frame = CGRectMake((self.frame.size.width - 66) / 2, _modeControlHeight, _shutterButton.frame.size.width, _shutterButton.frame.size.height);
    _cancelButton.frame = CGRectMake(0, _shutterButton.frame.origin.y + 11, _cancelButton.frame.size.width, _cancelButton.frame.size.height);
}

@end