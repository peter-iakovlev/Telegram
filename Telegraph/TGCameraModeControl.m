#import "TGCameraModeControl.h"

#import "TGCameraInterfaceAssets.h"

#import "UIControl+HitTestEdgeInsets.h"

const CGFloat TGCameraModeControlInteritemSpace = 19.0f;
const CGFloat TGCameraModeControlVerticalInteritemSpace = 29.0f;

@interface TGCameraModeControl ()
{
    UIImageView *_dotView;
    UIControl *_wrapperView;
    UIButton *_photoModeButton;
    UIButton *_videoModeButton;
    UIButton *_squareModeButton;
    
    UIView *_maskView;
    CAGradientLayer *_maskLayer;
}
@end

@implementation TGCameraModeControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        static UIImage *dotImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(6, 6), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();

            CGContextSetFillColorWithColor(context, [TGCameraInterfaceAssets accentColor].CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0, 0, 6, 6));

            dotImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        _dotView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
        _dotView.image = dotImage;
        [self addSubview:_dotView];
        
        CGFloat kerning = 0.0f;
        if (frame.size.width > frame.size.height)
            kerning = 3.5f;
        else
            kerning = 2.0f;
                
        _videoModeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 20)];
        _videoModeButton.backgroundColor = [UIColor clearColor];
        _videoModeButton.exclusiveTouch = true;
        _videoModeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        _videoModeButton.tag = PGCameraModeVideo;
        _videoModeButton.titleLabel.font = [TGCameraInterfaceAssets normalFontOfSize:13];
        [_videoModeButton setAttributedTitle:[[NSAttributedString alloc] initWithString:TGLocalized(@"Camera.VideoMode") attributes:@{ NSForegroundColorAttributeName: [TGCameraInterfaceAssets normalColor], NSKernAttributeName: @(kerning) }] forState:UIControlStateNormal];
        [_videoModeButton setAttributedTitle:[[NSAttributedString alloc] initWithString:TGLocalized(@"Camera.VideoMode") attributes:@{ NSForegroundColorAttributeName: [TGCameraInterfaceAssets accentColor], NSKernAttributeName: @(kerning) }] forState:UIControlStateSelected];
        [_videoModeButton setAttributedTitle:[_videoModeButton attributedTitleForState:UIControlStateSelected] forState:UIControlStateHighlighted | UIControlStateSelected];
        [_videoModeButton sizeToFit];
        [_videoModeButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _photoModeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 20)];
        _photoModeButton.backgroundColor = [UIColor clearColor];
        _photoModeButton.exclusiveTouch = true;
        _photoModeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        _photoModeButton.tag = PGCameraModePhoto;
        _photoModeButton.titleLabel.font = [TGCameraInterfaceAssets normalFontOfSize:13];
        [_photoModeButton setAttributedTitle:[[NSAttributedString alloc] initWithString:TGLocalized(@"Camera.PhotoMode") attributes:@{ NSForegroundColorAttributeName: [TGCameraInterfaceAssets normalColor], NSKernAttributeName: @(kerning) }] forState:UIControlStateNormal];
        [_photoModeButton setAttributedTitle:[[NSAttributedString alloc] initWithString:TGLocalized(@"Camera.PhotoMode") attributes:@{ NSForegroundColorAttributeName: [TGCameraInterfaceAssets accentColor], NSKernAttributeName: @(kerning) }] forState:UIControlStateSelected];
        [_photoModeButton setAttributedTitle:[_photoModeButton attributedTitleForState:UIControlStateSelected] forState:UIControlStateHighlighted | UIControlStateSelected];
        [_photoModeButton sizeToFit];
        [_photoModeButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _squareModeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 20)];
        _squareModeButton.backgroundColor = [UIColor clearColor];
        _squareModeButton.exclusiveTouch = true;
        _squareModeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        _squareModeButton.tag = PGCameraModeSquare;
        _squareModeButton.titleLabel.font = [TGCameraInterfaceAssets normalFontOfSize:13];
        [_squareModeButton setAttributedTitle:[[NSAttributedString alloc] initWithString:TGLocalized(@"Camera.SquareMode") attributes:@{ NSForegroundColorAttributeName: [TGCameraInterfaceAssets normalColor], NSKernAttributeName: @(kerning) }] forState:UIControlStateNormal];
        [_squareModeButton setAttributedTitle:[[NSAttributedString alloc] initWithString:TGLocalized(@"Camera.SquareMode") attributes:@{ NSForegroundColorAttributeName: [TGCameraInterfaceAssets accentColor], NSKernAttributeName: @(kerning) }] forState:UIControlStateSelected];
        [_squareModeButton setAttributedTitle:[_photoModeButton attributedTitleForState:UIControlStateSelected] forState:UIControlStateHighlighted | UIControlStateSelected];
        [_squareModeButton sizeToFit];
        [_squareModeButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
        _maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_maskView];
        
        _wrapperView = [[UIControl alloc] initWithFrame:CGRectZero];
        _wrapperView.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        _wrapperView.opaque = false;
        [_wrapperView addSubview:_videoModeButton];
        [_wrapperView addSubview:_photoModeButton];
        [_wrapperView addSubview:_squareModeButton];
        [_maskView addSubview:_wrapperView];
        
        if (frame.size.width > frame.size.height)
        {
            _videoModeButton.frame = CGRectMake(0, 0, CGFloor(_videoModeButton.frame.size.width), 20);
            _photoModeButton.frame = CGRectMake(_videoModeButton.frame.size.width + TGCameraModeControlInteritemSpace, 0, CGFloor(_photoModeButton.frame.size.width), 20);
            _squareModeButton.frame = CGRectMake(_videoModeButton.frame.size.width + TGCameraModeControlInteritemSpace + _photoModeButton.frame.size.width + TGCameraModeControlInteritemSpace, 0, CGFloor(_squareModeButton.frame.size.width), 20);
            _wrapperView.frame = CGRectMake(0, 0, _videoModeButton.frame.size.width + TGCameraModeControlInteritemSpace + _photoModeButton.frame.size.width + TGCameraModeControlInteritemSpace + _squareModeButton.frame.size.width, 20);
            
            _maskLayer = [CAGradientLayer layer];
            _maskLayer.colors = @[ (id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor, (id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor ];
            _maskLayer.locations = @[ @0.0f, @0.33f, @0.67f, @1.0f ];
            _maskLayer.startPoint = CGPointMake(0.0f, 0.5f);
            _maskLayer.endPoint = CGPointMake(1.0f, 0.5f);
            _maskView.layer.mask = _maskLayer;
        }
        else
        {
            _videoModeButton.frame = CGRectMake(0, 0, _videoModeButton.frame.size.width, _videoModeButton.frame.size.height);
            _photoModeButton.frame = CGRectMake(0, _videoModeButton.frame.size.height + TGCameraModeControlVerticalInteritemSpace, _photoModeButton.frame.size.width, _photoModeButton.frame.size.height);
            _squareModeButton.frame = CGRectMake(0, _videoModeButton.frame.size.height + TGCameraModeControlVerticalInteritemSpace + _photoModeButton.frame.size.height + TGCameraModeControlVerticalInteritemSpace, _squareModeButton.frame.size.width, _squareModeButton.frame.size.height);
            _wrapperView.frame = CGRectMake(33, 0, self.frame.size.width, _videoModeButton.frame.size.height + TGCameraModeControlVerticalInteritemSpace + _photoModeButton.frame.size.height + TGCameraModeControlVerticalInteritemSpace + _squareModeButton.frame.size.height);
        }
        
        self.cameraMode = PGCameraModePhoto;
    }
    return self;
}

- (void)setCameraMode:(PGCameraMode)mode
{
    _cameraMode = mode;
    [self setCameraMode:mode animated:false];
}

- (void)setCameraMode:(PGCameraMode)mode animated:(bool)animated
{
    _cameraMode = mode;
    
    CGFloat targetPosition = 0;
    CGRect targetFrame = CGRectZero;
    
    if (self.frame.size.width > self.frame.size.height)
    {
        if (mode == PGCameraModeVideo)
            targetPosition = _videoModeButton.center.x - _wrapperView.frame.size.width / 2;
        else if (mode == PGCameraModePhoto)
            targetPosition = _photoModeButton.center.x - _wrapperView.frame.size.width / 2;
        else
            targetPosition = _squareModeButton.center.x - _wrapperView.frame.size.width / 2;
        
        targetFrame = CGRectMake((self.frame.size.width - _wrapperView.frame.size.width) / 2 - targetPosition + 1,
                                 (self.frame.size.height - _wrapperView.frame.size.height / 2) / 2,
                                 _wrapperView.frame.size.width,
                                 _wrapperView.frame.size.height);
    }
    else
    {
        if (mode == PGCameraModeVideo)
            targetPosition = _videoModeButton.center.y - _wrapperView.frame.size.height / 2;
        else if (mode == PGCameraModePhoto)
            targetPosition = _photoModeButton.center.y - _wrapperView.frame.size.height / 2;
        else
            targetPosition = _squareModeButton.center.y - _wrapperView.frame.size.height / 2;
        
        targetFrame = CGRectMake(33,
                                 (self.frame.size.height - _wrapperView.frame.size.height) / 2 - targetPosition + 1,
                                 _wrapperView.frame.size.width,
                                 _wrapperView.frame.size.height);
    }

    if (animated)
    {
        self.userInteractionEnabled = false;
        [self _updateButtonsHighlight];
        
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^
        {
            _wrapperView.frame = targetFrame;
            
            if (self.frame.size.width > self.frame.size.height)
                [self _layoutItemTransformationsForTargetFrame:targetFrame];
        } completion:^(BOOL finished)
        {
            if (finished)
                self.userInteractionEnabled = true;
        }];
    }
    else
    {
        [self _updateButtonsHighlight];
        
        if (self.frame.size.width > self.frame.size.height)
            [self _layoutItemTransformationsForTargetFrame:targetFrame];

        _wrapperView.frame = targetFrame;
    }
}

- (void)_layoutItemTransformationsForTargetFrame:(CGRect)targetFrame
{
    CGFloat targetCenter = targetFrame.origin.x - self.frame.size.width / 2;

    _videoModeButton.layer.transform = [self _transformForItemWithOffset:targetCenter + _videoModeButton.center.x];
    _photoModeButton.layer.transform = [self _transformForItemWithOffset:targetCenter + _photoModeButton.center.x];
    _squareModeButton.layer.transform = [self _transformForItemWithOffset:targetCenter + _squareModeButton.center.x];
}

- (CATransform3D)_transformForItemWithOffset:(CGFloat)offset
{
    CGFloat angle = ABS(offset / _wrapperView.frame.size.width * 0.99f);
    CGFloat sign = offset > 0 ? 1.0f : -1.0f;
    
    CATransform3D transform = CATransform3DTranslate(CATransform3DIdentity, -28 * angle * angle * sign, 0.0f, 0.0f);
    transform = CATransform3DRotate(transform, angle, 0.0f, sign, 0.0f);
    return transform;
}

- (UIButton *)_currentModeButton
{
    return [self _buttonForMode:_cameraMode];
}

- (UIButton *)_buttonForMode:(PGCameraMode)mode
{
    for (UIButton *button in _wrapperView.subviews)
    {
        if (button.tag == mode)
            return button;
    }
    
    return nil;
}

- (void)_updateButtonsHighlight
{
    _photoModeButton.selected = (_cameraMode == PGCameraModePhoto);
    _videoModeButton.selected = (_cameraMode == PGCameraModeVideo);
    _squareModeButton.selected = (_cameraMode == PGCameraModeSquare);
}

- (void)buttonPressed:(UIButton *)sender
{
    PGCameraMode previousMode = self.cameraMode;
    [self setCameraMode:(int)sender.tag animated:true];
    
    if ((PGCameraMode)sender.tag != previousMode && self.modeChanged != nil)
        self.modeChanged((PGCameraMode)sender.tag, previousMode);
}

- (void)setHidden:(BOOL)hidden
{
    self.alpha = hidden ? 0.0f : 1.0f;
    super.hidden = hidden;
}

- (void)setHidden:(bool)hidden animated:(bool)animated
{
    if (animated)
    {
        super.hidden = false;
        self.userInteractionEnabled = false;
        
        [UIView animateWithDuration:0.25f
                         animations:^
        {
            self.alpha = hidden ? 0.0f : 1.0f;
        } completion:^(BOOL finished)
        {
            self.userInteractionEnabled = true;
             
            if (finished)
                self.hidden = hidden;
        }];
    }
    else
    {
        self.alpha = hidden ? 0.0f : 1.0f;
        super.hidden = hidden;
    }
}

#pragma mark - Layout

- (void)layoutSubviews
{
    if (self.frame.size.width > self.frame.size.height)
    {
        _dotView.frame = CGRectMake((self.frame.size.width - _dotView.frame.size.width) / 2, self.frame.size.height / 2 - 12, _dotView.frame.size.width, _dotView.frame.size.height);
        _maskLayer.frame = CGRectMake(0, 0, _maskView.frame.size.width, _maskView.frame.size.height);
    }
    else
    {
        _dotView.frame = CGRectMake(13, (self.frame.size.height - _dotView.frame.size.height) / 2, _dotView.frame.size.width, _dotView.frame.size.height);
    }
}

@end
