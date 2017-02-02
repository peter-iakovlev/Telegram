#import "TGFastCameraControlPanel.h"
#import "TGModernButton.h"
#import "TGCameraShutterButton.h"
#import "TGCameraInterfaceAssets.h"

@interface TGFastCameraControlPanel ()
{
    UIView *_wrapperView;
    UIVisualEffectView *_backgroundView;
    UILabel *_videoLabel;
    TGCameraShutterButton *_videoButton;
    UILabel *_photoLabel;
    TGCameraShutterButton *_photoButton;
    TGModernButton *_cancelButton;
    UIImageView *_cancelIcon;
    
    NSTimeInterval _videoRecognizedTimestamp;
    bool _videoButtonRecognized;
    bool _cancelButtonDisabled;
    UIPanGestureRecognizer *_panGestureRecognizer;
    
    bool _recordingVideo;
}
@end

@implementation TGFastCameraControlPanel

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 60.0f, 240.0f)];
    if (self != nil)
    {
        _wrapperView = [[UIView alloc] initWithFrame:self.bounds];
        _wrapperView.clipsToBounds = true;
        _wrapperView.layer.cornerRadius = 30.0f;
        [self addSubview:_wrapperView];
        
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _backgroundView = [[UIVisualEffectView alloc] initWithEffect:effect];
        _backgroundView.frame = _wrapperView.bounds;
        [_wrapperView addSubview:_backgroundView];
        
        _videoButton = [[TGCameraShutterButton alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 50.0f, 50.0f)];
        _videoButton.userInteractionEnabled = false;
        [_videoButton setButtonMode:TGCameraShutterButtonVideoMode animated:false];
        [_wrapperView addSubview:_videoButton];
        
        _videoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _videoLabel.alpha = 0.0f;
        _videoLabel.attributedText = [[NSAttributedString alloc] initWithString:TGLocalized(@"Camera.VideoMode") attributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor], NSKernAttributeName: @(2.0f), NSFontAttributeName: [TGCameraInterfaceAssets normalFontOfSize:13] }];
        _videoLabel.backgroundColor = [UIColor clearColor];
        _videoLabel.layer.shadowOpacity = 0.8f;
        _videoLabel.layer.shadowRadius = 3.0f;
        _videoLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _videoLabel.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        [_videoLabel sizeToFit];
        _videoLabel.frame = CGRectMake(70.0f, _videoButton.frame.origin.y + 18.0f, _videoLabel.frame.size.width, _videoLabel.frame.size.height);
        [self addSubview:_videoLabel];
        
        _photoButton = [[TGCameraShutterButton alloc] initWithFrame:CGRectMake(5.0f, 95.0f, 50.0f, 50.0f)];
        _photoButton.userInteractionEnabled = false;
        [_wrapperView addSubview:_photoButton];
        
        _photoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _photoLabel.alpha = 0.0f;
        _photoLabel.attributedText = [[NSAttributedString alloc] initWithString:TGLocalized(@"Camera.PhotoMode") attributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor], NSKernAttributeName: @(2.0f), NSFontAttributeName: [TGCameraInterfaceAssets normalFontOfSize:13] }];
        _photoLabel.backgroundColor = [UIColor clearColor];
        _photoLabel.layer.shadowOpacity = 0.8f;
        _photoLabel.layer.shadowRadius = 3.0f;
        _photoLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _photoLabel.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        [_photoLabel sizeToFit];
        _photoLabel.frame = CGRectMake(70.0f, _photoButton.frame.origin.y + 18.0f, _photoLabel.frame.size.width, _photoLabel.frame.size.height);
        [self addSubview:_photoLabel];
        
        UIVisualEffectView *vibrantView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:effect]];
        vibrantView.frame = _backgroundView.bounds;
        [_backgroundView.contentView addSubview:vibrantView];
        
        static dispatch_once_t onceToken;
        static UIImage *cancelImage;
        dispatch_once(&onceToken, ^
        {
            CGRect rect = CGRectMake(0.0f, 0.0f, 36.0f, 36.0f);
            UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0f);
            
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillEllipseInRect(context, rect);
            
            cancelImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        _cancelButton = [[TGModernButton alloc] initWithFrame:CGRectMake(12.0f, self.frame.size.height - 12.0f - 36.0f, 36.0f, 36.0f)];
        _cancelButton.userInteractionEnabled = false;
        [_cancelButton setBackgroundImage:cancelImage forState:UIControlStateNormal];
        [vibrantView.contentView addSubview:_cancelButton];
        
        _cancelIcon = [[UIImageView alloc] initWithFrame:_cancelButton.frame];
        _cancelIcon.contentMode = UIViewContentModeCenter;
        _cancelIcon.image = [UIImage imageNamed:@"FastCameraCrossIcon"];
        [_wrapperView addSubview:_cancelIcon];
        
        _cancelButtonDisabled = true;
    }
    return self;
}

- (void)setRecordingVideo:(bool)recordingVideo animated:(bool)animated
{
    _recordingVideo = recordingVideo;
    [_videoButton setButtonMode:recordingVideo ? TGCameraShutterButtonRecordingMode : TGCameraShutterButtonVideoMode animated:animated];
    
    void (^changeBlock)(void) = ^
    {
        _photoButton.alpha = recordingVideo ? 0.5f : 1.0f;
    };
    
    if (animated)
        [UIView animateWithDuration:0.25 animations:changeBlock];
    else
        changeBlock();
}

- (void)setLabelsHidden:(bool)hidden
{
    CGFloat targetAlpha = hidden ? 0.0f : 1.0f;
    _videoLabel.alpha = targetAlpha;
    _photoLabel.alpha = targetAlpha;
}

- (void)recognizerVideoButtonRelease:(bool)release
{
    if (!_videoButtonRecognized || (release && (CFAbsoluteTimeGetCurrent() - _videoRecognizedTimestamp) > 0.5))
    {
        if (!_videoButtonRecognized)
        {
            _videoButtonRecognized = true;
            _videoRecognizedTimestamp = CFAbsoluteTimeGetCurrent();
        }
        
        if (self.videoPressed != nil)
            self.videoPressed();
    }
}

- (void)handlePanAt:(CGPoint)location
{
    CGPoint localPoint = [self convertPoint:location fromView:nil];
    
    UIControl *highlightedButton = nil;
    
    if (CGRectContainsPoint(_videoButton.frame, localPoint))
    {
        highlightedButton = _videoButton;
        
        [self recognizerVideoButtonRelease:false];
    }
    else if (CGRectContainsPoint(_photoButton.frame, localPoint))
    {
        if (!_recordingVideo)
            highlightedButton = _photoButton;
    }
    else if (CGRectContainsPoint(CGRectInset(_cancelButton.frame, -12.0f, -12.0f), localPoint))
    {
        if (!_cancelButtonDisabled)
            highlightedButton = _cancelButton;
    }
    
    [_videoButton setHighlighted:(_videoButton == highlightedButton) animated:(_videoButton != highlightedButton)];
    [_photoButton setHighlighted:(_photoButton == highlightedButton) animated:(_photoButton != highlightedButton)];
    
    if (_cancelButton != highlightedButton)
    {
        [UIView animateWithDuration:0.25 animations:^
        {
           _cancelButton.highlighted = false;
        }];
    }
    else
    {
        _cancelButton.highlighted = true;
    }
}

- (void)handleReleaseAt:(CGPoint)location
{
    CGPoint localPoint = [self convertPoint:location fromView:nil];
    
    if (CGRectContainsPoint(_videoButton.frame, localPoint))
    {
        [self recognizerVideoButtonRelease:true];
    }
    else if (CGRectContainsPoint(_photoButton.frame, localPoint))
    {
        if (!_recordingVideo && self.photoPressed != nil)
            self.photoPressed();
    }
    else if (CGRectContainsPoint(CGRectInset(_cancelButton.frame, -12.0f, -12.0f), localPoint))
    {
        if (!_cancelButtonDisabled && self.cancelPressed != nil)
            self.cancelPressed();
    }
    
    [_videoButton setHighlighted:false animated:true];
    [_photoButton setHighlighted:false animated:true];
    [UIView animateWithDuration:0.25 animations:^
    {
        _cancelButton.highlighted = false;
    }];
    
    _videoButtonRecognized = false;
    _cancelButtonDisabled = false;
}

@end
