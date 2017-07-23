/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMessageImageView.h"

#import <AVFoundation/AVFoundation.h>

#import "UIImage+TG.h"
#import "TGModernButton.h"

#import "TGMessageImageViewModel.h"

#import "TGMessageImageViewOverlayView.h"
#import "TGMessageImageViewTimestampView.h"
#import "TGMessageImageAdditionalDataView.h"
#import "TGStaticBackdropImageData.h"

#import "TGModernGalleryTransitionView.h"

#import "TGFont.h"

#import "TGInlineVideoView.h"
#import "TGModernGalleryVideoView.h"

#import "TGAudioSessionManager.h"

static const CGFloat timestampWidth = 200.0f;
static const CGFloat timestampHeight = 18.0f;
static const CGFloat timestampRightPadding = 6.0f;
static const CGFloat timestampBottomPadding = 6.0f;

static const CGFloat additionalDataWidth = 180.0f;
static const CGFloat additionalDataHeight = 18.0f;
static const CGFloat additionalDataLeftPadding = 6.0f;
static const CGFloat additionalDataTopPadding = 6.0f;

@interface TGMessageImageViewContainer () <TGModernGalleryTransitionView>
{
    TGMessageImageViewTimestampView *_timestampView;
}

@end

@interface TGMessageImageView ()
{
    TGModernButton *_buttonView;
    TGMessageImageViewOverlayView *_overlayView;
    
    TGMessageImageAdditionalDataView *_additionalDataView;
    TGStaticBackdropAreaData *_additionalDataBackdropArea;
    int _additionalDataPosition;
    
    UIImageView *_detailStringsBackground;
    UILabel *_detailStringLabel1;
    UILabel *_detailStringLabel2;
    UIEdgeInsets _detailStringsEdgeInsets;
    
    int _timestampPosition;
    
    bool _blurless;
    CGFloat _overlayDiameter;
    CGPoint _timestampOffset;
    UIColor *_timestampColor;
    
    TGInlineVideoView *_inlineVideoView;
    
    UIView *_videoViewWrapper;
    TGModernGalleryVideoView *_videoView;
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@property (nonatomic, strong) TGMessageImageViewTimestampView *timestampView;

@end

@implementation TGMessageImageView

- (void)loadUri:(NSString *)uri withOptions:(NSDictionary *)options
{
    self.viewStateIdentifier = [[NSString alloc] initWithFormat:@"TGMessageImageView/%@", uri];
    
    [super loadUri:uri withOptions:options];
}

- (void)willBecomeRecycled
{
    self.viewStateIdentifier = nil;
    
    [_timestampView setDisplayProgress:false];
    
    [self reset];
    
    [_inlineVideoView setVideoPathSignal:nil];
    
    [_inlineVideoView removeFromSuperview];
    _inlineVideoView = nil;
    
    [_videoView removeFromSuperview];
    _videoView = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _overlayDiameter = 50.0f;
        
        _buttonView = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _overlayDiameter, _overlayDiameter)];
        _buttonView.adjustsImageWhenHighlighted = false;
        _buttonView.exclusiveTouch = true;
        _buttonView.modernHighlight = true;
        [_buttonView addTarget:self action:@selector(actionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        _overlayView = [[TGMessageImageViewOverlayView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _overlayDiameter, _overlayDiameter)];
        [_overlayView setRadius:_overlayDiameter];
        _overlayView.userInteractionEnabled = false;
        [_buttonView addSubview:_overlayView];
    }
    return self;
}

- (UIImage *)highlightImageForDiameter:(CGFloat)diameter
{
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dict = [[NSMutableDictionary alloc] init];
    });
    
    UIImage *image = dict[@(diameter)];
    if (image != nil)
        return image;
    
    if (diameter > FLT_EPSILON)
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, UIColorRGBA(0x000000, 0.4f).CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dict[@(diameter)] = image;
    }
    
    return image;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGRect buttonFrame = _buttonView.frame;
    buttonFrame.origin = CGPointMake(CGFloor(frame.size.width - buttonFrame.size.width) / 2.0f, CGFloor(frame.size.height - buttonFrame.size.height) / 2.0f);
    if (!CGRectEqualToRect(_buttonView.frame, buttonFrame))
    {
        _buttonView.frame = buttonFrame;
    }
    
    [self _updateTimestampViewFrame];
    
    if (_detailStringsBackground.superview != nil)
    {
        CGFloat height = _detailStringsBackground.frame.size.height;
        _detailStringsBackground.frame = CGRectMake(_detailStringsEdgeInsets.left, self.frame.size.height - height - _detailStringsEdgeInsets.bottom + 1, self.frame.size.width - _detailStringsEdgeInsets.left - _detailStringsEdgeInsets.right, height);
    }
    
    CGRect bounds = self.bounds;
    bounds.origin.x += _inlineVideoInsets.left;
    bounds.origin.y += _inlineVideoInsets.top;
    bounds.size.width -= _inlineVideoInsets.left + _inlineVideoInsets.right;
    bounds.size.height -= _inlineVideoInsets.top + _inlineVideoInsets.bottom;
    _inlineVideoView.frame = bounds;
}

- (void)_updateTimestampViewFrame
{
    CGFloat maxTimestampWidth = self.frame.size.width - 34.0f;
    CGFloat nominalMaximumTimestampWidth = maxTimestampWidth + 34.0f;
    if (_flexibleTimestamp) {
        maxTimestampWidth = 120.0f;
    }
    CGSize currentSize = [_timestampView sizeForMaxWidth:maxTimestampWidth];
    if (_timestampPosition == TGMessageImageViewTimestampPositionDefault)
    {
        CGFloat offset = MAX(0.0f, currentSize.width - nominalMaximumTimestampWidth);
        _timestampView.frame = CGRectMake(self.frame.size.width - currentSize.width - timestampRightPadding + offset + _timestampOffset.x, self.frame.size.height - timestampHeight - timestampBottomPadding + _timestampOffset.y, currentSize.width, timestampHeight);
    }
    else if (_timestampPosition == TGMessageImageViewTimestampPositionLeft)
    {
        _timestampView.frame = CGRectMake(-currentSize.width + _timestampOffset.x, self.frame.size.height - timestampHeight - timestampBottomPadding + _timestampOffset.y, currentSize.width, timestampHeight);
    }
    else if (_timestampPosition == TGMessageImageViewTimestampPositionRight)
    {
        _timestampView.frame = CGRectMake(self.frame.size.width - currentSize.width + _timestampOffset.x, self.frame.size.height - timestampHeight - timestampBottomPadding + _timestampOffset.y, currentSize.width, timestampHeight);
    }
    else if (_timestampPosition == TGMessageImageViewTimestampPositionRightLong)
    {
        _timestampView.frame = CGRectMake(self.frame.size.width + _timestampOffset.x, self.frame.size.height - timestampHeight - timestampBottomPadding + _timestampOffset.y, currentSize.width, timestampHeight);
    }
}

- (void)performTransitionToImage:(UIImage *)image partial:(bool)partial duration:(NSTimeInterval)duration
{
    [super performTransitionToImage:image partial:partial duration:duration];
    
    TGStaticBackdropImageData *backdropData = [image staticBackdropImageData];
    UIImage *actionCircleImage = [backdropData backdropAreaForKey:TGStaticBackdropMessageActionCircle].background;
    
    [_overlayView setBlurredBackgroundImage:actionCircleImage];
    
    [_timestampView setBackdropArea:[backdropData backdropAreaForKey:TGStaticBackdropMessageTimestamp] transitionDuration:duration];
    
    _additionalDataBackdropArea = [backdropData backdropAreaForKey:TGStaticBackdropMessageAdditionalData];
    [_additionalDataView setBackdropArea:_additionalDataBackdropArea transitionDuration:duration];
    
    if (!partial && _completionBlock)
        _completionBlock(self);
}

- (void)performProgressUpdate:(CGFloat)progress
{
    if (_progressBlock)
        _progressBlock(self, progress);
}

- (void)setBlurlessOverlay:(bool)blurless
{
    _blurless = blurless;
    
    [_overlayView setBlurless:blurless];
}

- (void)setOverlayBackgroundColorHint:(UIColor *)overlayBackgroundColorHint
{
    _overlayBackgroundColorHint = overlayBackgroundColorHint;
    
    [_overlayView setOverlayBackgroundColorHint:overlayBackgroundColorHint];
}

- (void)setOverlayDiameter:(CGFloat)overlayDiameter
{
    _overlayDiameter = overlayDiameter;
    
    [_overlayView setRadius:overlayDiameter];
    
    _buttonView.frame = CGRectMake(CGFloor(self.frame.size.width - overlayDiameter) / 2.0f, CGFloor(self.frame.size.height - overlayDiameter) / 2.0f, overlayDiameter, overlayDiameter);
    
    if (ABS(overlayDiameter - _overlayDiameter) > FLT_EPSILON)
    {
        _buttonView.highlightImage = [self highlightImageForDiameter:_overlayDiameter];
    }
}

- (void)setOverlayType:(int)overlayType
{
    [self setOverlayType:overlayType animated:false];
}

- (void)setOverlayType:(int)overlayType animated:(bool)animated
{
    if (_overlayType != overlayType)
    {
        _overlayType = overlayType;
        
        switch (_overlayType)
        {
            case TGMessageImageViewOverlayDownload:
            {
                if (_buttonView.superview == nil)
                    [self addSubview:_buttonView];
                
                _buttonView.alpha = 1.0f;
                
                [_overlayView setDownload];
                
                break;
            }
            case TGMessageImageViewOverlayPlay:
            {
                if (_buttonView.superview == nil)
                    [self addSubview:_buttonView];
                
                _buttonView.alpha = 1.0f;
                
                [_overlayView setPlay];
                
                break;
            }
            case TGMessageImageViewOverlayPlayMedia:
            {
                if (_buttonView.superview == nil)
                    [self addSubview:_buttonView];
                
                _buttonView.alpha = 1.0f;
                
                [_overlayView setPlayMedia];
                
                break;
            }
            case TGMessageImageViewOverlayPauseMedia:
            {
                if (_buttonView.superview == nil)
                    [self addSubview:_buttonView];
                
                _buttonView.alpha = 1.0f;
                
                [_overlayView setPauseMedia];
                
                break;
            }
            case TGMessageImageViewOverlaySecret:
            case TGMessageImageViewOverlaySecretViewed:
            {
                if (_buttonView.superview == nil)
                    [self addSubview:_buttonView];
                
                _buttonView.alpha = 1.0f;
                
                [_overlayView setSecret:_overlayType == TGMessageImageViewOverlaySecretViewed];
                
                break;
            }
            case TGMessageImageViewOverlayProgress:
            {
                if (_buttonView.superview == nil)
                    [self addSubview:_buttonView];
                
                _buttonView.alpha = 1.0f;
                
                [_overlayView setProgress:_progress animated:false];
                
                break;
            }
            case TGMessageImageViewOverlayProgressNoCancel:
            {
                if (_buttonView.superview == nil)
                    [self addSubview:_buttonView];
                
                _buttonView.alpha = 1.0f;
                
                [_overlayView setProgress:_progress cancelEnabled:false animated:false];
                
                break;
            }
            case TGMessageImageViewOverlaySecretProgress:
            {
                if (_buttonView.superview == nil)
                    [self addSubview:_buttonView];
                
                _buttonView.alpha = 1.0f;
                
                [_overlayView setSecretProgress:_progress completeDuration:_completeDuration animated:false];
                
                break;
            }
            case TGMessageImageViewOverlayNone:
            default:
            {
                [_overlayView setNone];
                
                if (_buttonView.superview != nil)
                {
                    if (animated)
                    {
                        [UIView animateWithDuration:0.2 animations:^
                        {
                            _buttonView.alpha = 0.0f;
                        } completion:^(BOOL finished)
                        {
                            if (finished)
                                [_buttonView removeFromSuperview];
                        }];
                    }
                    else
                    {
                        [_buttonView removeFromSuperview];
                    }
                }
                
                break;
            }
        }
    }
}

- (void)setProgress:(CGFloat)progress
{
    [self setProgress:progress animated:false];
}

- (void)setProgress:(CGFloat)progress animated:(bool)animated
{
    if (ABS(_progress - progress) > FLT_EPSILON)
    {
        _progress = progress;
        
        if (_overlayType == TGMessageImageViewOverlayProgress)
            [_overlayView setProgress:progress animated:animated];
        else if (_overlayType == TGMessageImageViewOverlayProgressNoCancel)
            [_overlayView setProgress:progress cancelEnabled:false animated:animated];
    }
}

- (void)setSecretProgress:(CGFloat)progress completeDuration:(NSTimeInterval)completeDuration animated:(bool)animated
{
    if (ABS(_progress - progress) > FLT_EPSILON || ABS(completeDuration - _completeDuration) > DBL_EPSILON)
    {
        _progress = progress;
        _completeDuration = completeDuration;
        
        if (_overlayType == TGMessageImageViewOverlaySecretProgress)
            [_overlayView setSecretProgress:progress completeDuration:completeDuration animated:animated];
    }
}

- (void)setTimestampColor:(UIColor *)color
{
    _timestampColor = color;
    
    [_timestampView setTimestampColor:color];
    [_additionalDataView setTimestampColor:color];
}

- (void)setTimestampHidden:(bool)timestampHidden
{
    _timestampView.hidden = timestampHidden;
}

- (void)setTimestampPosition:(int)timestampPosition
{
    _timestampPosition = timestampPosition;
    [self _updateTimestampViewFrame];
}

- (void)setTimestampString:(NSString *)timestampString signatureString:(NSString *)signatureString displayCheckmarks:(bool)displayCheckmarks checkmarkValue:(int)checkmarkValue displayViews:(bool)displayViews viewsValue:(int)viewsValue animated:(bool)animated
{
    [_timestampView setTimestampString:timestampString signatureString:signatureString displayCheckmarks:displayCheckmarks checkmarkValue:checkmarkValue displayViews:displayViews viewsValue:viewsValue animated:animated];
    
    [self _updateTimestampViewFrame];
}

- (void)setAdditionalDataString:(NSString *)additionalDataString animated:(bool)animated
{
    if (additionalDataString.length != 0)
    {
        CGPoint position = CGPointMake(additionalDataLeftPadding, additionalDataTopPadding);
        if (_additionalDataPosition == TGMessageImageViewTimestampPositionLeftBottom)
            position = CGPointMake(0.0f, 194.0f);
        CGRect frame = CGRectMake(position.x, position.y, additionalDataWidth, additionalDataHeight);
        
        if (_additionalDataView == nil)
            _additionalDataView = [[TGMessageImageAdditionalDataView alloc] initWithFrame:frame];
        else
            _additionalDataView.frame = frame;
    
        [_additionalDataView setTimestampColor:_timestampColor];
        [_additionalDataView setBackdropArea:_additionalDataBackdropArea transitionDuration:0.0];
        [_additionalDataView setText:additionalDataString];
        
        if (_additionalDataView.superview == nil)
        {
            _additionalDataView.alpha = 0.0f;
            [self addSubview:_additionalDataView];
        }
        
        if (animated)
        {
            [UIView animateWithDuration:0.3 animations:^
            {
                _additionalDataView.alpha = 1.0f;
            }];
        }
        else
        {
            _additionalDataView.alpha = 1.0f;
        }
    }
    else
        [_additionalDataView removeFromSuperview];
}

- (void)setAdditionalDataPosition:(int)additionalDataPosition
{
    _additionalDataPosition = additionalDataPosition;
    
    if (additionalDataPosition == TGMessageImageViewTimestampPositionLeftBottom)
    {
        _additionalDataView.frame = CGRectMake(0.0f, self.frame.size.height - 16.0f, _additionalDataView.frame.size.width, _additionalDataView.frame.size.height);
    }
    else
    {
        _additionalDataView.frame = CGRectMake(additionalDataLeftPadding, additionalDataTopPadding, additionalDataWidth, additionalDataHeight);
    }
}

- (void)setDisplayTimestampProgress:(bool)displayTimestampProgress
{
    [_timestampView setDisplayProgress:displayTimestampProgress];
}

- (void)setTimestampOffset:(CGPoint)timestampOffset
{
    _timestampOffset = timestampOffset;
    [self _updateTimestampViewFrame];
}

- (void)setIsBroadcast:(bool)isBroadcast
{
    [_timestampView setIsBroadcast:isBroadcast];
}

- (void)setDetailStrings:(NSArray *)detailStrings detailStringsEdgeInsets:(UIEdgeInsets)detailStringsEdgeInsets animated:(bool)animated
{
    [_timestampView setTransparent:detailStrings.count != 0];
    
    _detailStringsEdgeInsets = detailStringsEdgeInsets;
    
    if (detailStrings.count == 0)
    {
        [_detailStringsBackground removeFromSuperview];
        [_detailStringLabel1 removeFromSuperview];
        [_detailStringLabel2 removeFromSuperview];
    }
    else
    {
        if (_detailStringsBackground == nil)
        {
            static UIImage *backgroundImage = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                CGFloat diameter = 26.0f;
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter / 2 + 1), false, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                CGContextSetFillColorWithColor(context, UIColorRGBA(0x000000, 0.5f).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, -diameter / 2, diameter, diameter));
                
                backgroundImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)(diameter / 2) topCapHeight:1];
                UIGraphicsEndImageContext();
            });
            _detailStringsBackground = [[UIImageView alloc] initWithImage:backgroundImage];
        }
        
        if (_detailStringsBackground.superview == nil)
        {
            _detailStringsBackground.alpha = 0.0f;
            [self insertSubview:_detailStringsBackground belowSubview:_timestampView];
        }
        
        CGFloat height = 41.0f;
        
        _detailStringsBackground.frame = CGRectMake(_detailStringsEdgeInsets.left, self.frame.size.height - height - _detailStringsEdgeInsets.bottom + 1, self.frame.size.width - _detailStringsEdgeInsets.left - _detailStringsEdgeInsets.right, height);
        
        if (_detailStringLabel1 == nil)
        {
            _detailStringLabel1 = [[UILabel alloc] init];
            _detailStringLabel1.backgroundColor = [UIColor clearColor];
            _detailStringLabel1.textColor = [UIColor whiteColor];
            _detailStringLabel1.font = TGSystemFontOfSize(13.0f);
            
            _detailStringLabel1.text = @" ";
            [_detailStringLabel1 sizeToFit];
        }
        
        if (_detailStringLabel1.superview == nil)
        {
            _detailStringLabel1.alpha = 0.0f;
            [self addSubview:_detailStringLabel1];
        }
        
        _detailStringLabel1.text = detailStrings[0];
        
        _detailStringLabel1.frame = CGRectMake(12.0f, _detailStringsBackground.frame.origin.y + 4.0f, self.frame.size.width - 30.0f, _detailStringLabel1.frame.size.height);
        
        if (detailStrings.count >= 2)
        {
            if (_detailStringLabel2 == nil)
            {
                _detailStringLabel2 = [[UILabel alloc] init];
                _detailStringLabel2.backgroundColor = [UIColor clearColor];
                _detailStringLabel2.textColor = [UIColor whiteColor];
                _detailStringLabel2.font = TGSystemFontOfSize(12.0f);
                
                _detailStringLabel2.text = @" ";
                [_detailStringLabel2 sizeToFit];
            }
            
            if (_detailStringLabel2.superview == nil)
            {
                _detailStringLabel2.alpha = 0.0f;
                [self addSubview:_detailStringLabel2];
            }
            
            _detailStringLabel2.text = detailStrings[1];
            
            _detailStringLabel2.frame = CGRectMake(12.0f, _detailStringsBackground.frame.origin.y + 20.0f, self.frame.size.width - 24.0f - 60.0f, _detailStringLabel2.frame.size.height);
        }
        else
            [_detailStringLabel2 removeFromSuperview];
        
        if (animated)
        {
            [UIView animateWithDuration:0.3 animations:^
            {
                _detailStringsBackground.alpha = 1.0f;
                _detailStringLabel1.alpha = 1.0f;
                _detailStringLabel2.alpha = 1.0f;
            }];
        }
        else
        {
            _detailStringsBackground.alpha = 1.0f;
            _detailStringLabel1.alpha = 1.0f;
            _detailStringLabel2.alpha = 1.0f;
        }
    }
}

- (void)actionButtonPressed
{
    TGMessageImageViewActionType action = TGMessageImageViewActionDownload;
    
    switch (_overlayType)
    {
        case TGMessageImageViewOverlayDownload:
        {
            action = TGMessageImageViewActionDownload;
            break;
        }
        case TGMessageImageViewOverlayProgress:
        {
            action = TGMessageImageViewActionCancelDownload;
            break;
        }
        case TGMessageImageViewOverlayPlay:
        {
            action = TGMessageImageViewActionPlay;
            break;
        }
        case TGMessageImageViewOverlaySecret:
        {
            action = TGMessageImageViewActionSecret;
            break;
        }
        case TGMessageImageViewOverlaySecretViewed:
        {
            action = TGMessageImageViewActionSecret;
            break;
        }
        default:
            break;
    }
    
    id<TGMessageImageViewDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(messageImageViewActionButtonPressed:withAction:)])
        [delegate messageImageViewActionButtonPressed:self withAction:action];
}

- (CGRect)_videoFrame
{
    CGRect frame = self.bounds;
    frame.origin.x += _inlineVideoInsets.left;
    frame.origin.y += _inlineVideoInsets.top;
    frame.size.width -= _inlineVideoInsets.left + _inlineVideoInsets.right;
    frame.size.height -= _inlineVideoInsets.top + _inlineVideoInsets.bottom;
    return frame;
}

- (void)setVideoPathSignal:(SSignal *)signal {
    if (_inlineVideoView == nil) {
        _inlineVideoView = [[TGInlineVideoView alloc] initWithFrame:[self _videoFrame]];
        _inlineVideoView.cornerRadius = _inlineVideoCornerRadius;
        _inlineVideoView.videoSize = _inlineVideoSize;
        [self insertSubview:_inlineVideoView atIndex:0];
    }
    [_inlineVideoView setVideoPathSignal:signal];
}

- (void)showVideo
{
    _inlineVideoView.hidden = false;
}

- (void)hideVideo
{
    [_inlineVideoView removeFromSuperview];
    _inlineVideoView = nil;
}

- (void)setInlineVideoInsets:(UIEdgeInsets)inlineVideoInsets {
    _inlineVideoInsets = inlineVideoInsets;
    
    CGRect bounds = self.bounds;
    bounds.origin.x += _inlineVideoInsets.left;
    bounds.origin.y += _inlineVideoInsets.top;
    bounds.size.width -= _inlineVideoInsets.left + _inlineVideoInsets.right;
    bounds.size.height -= _inlineVideoInsets.top + _inlineVideoInsets.bottom;
    _inlineVideoView.frame = bounds;
}

- (void)setInlineVideoCornerRadius:(CGFloat)inlineVideoCornerRadius
{
    _inlineVideoCornerRadius = inlineVideoCornerRadius;
    
    _inlineVideoView.cornerRadius = inlineVideoCornerRadius;
}

- (void)setVideoView:(TGModernGalleryVideoView *)videoView
{
    if (videoView != nil && _videoView == videoView && _videoViewWrapper != nil && videoView.superview == _videoViewWrapper)
        return;
    
    if (_videoView != nil && _videoView.superview == _videoViewWrapper)
    {
        [_videoView removeFromSuperview];
        _videoView = nil;
    }
    
    _videoView = videoView;

    if (videoView == nil)
    {
        [_videoViewWrapper removeFromSuperview];
        _videoViewWrapper = nil;
        return;
    }
    
    if (_videoViewWrapper == nil)
    {
        _videoViewWrapper = [[UIView alloc] initWithFrame:[self _videoFrame]];
        _videoViewWrapper.clipsToBounds = true;
        _videoViewWrapper.layer.cornerRadius = _inlineVideoCornerRadius;
        if (_inlineVideoView)
            [self insertSubview:_videoViewWrapper aboveSubview:_inlineVideoView];
        else
            [self insertSubview:_videoViewWrapper atIndex:0];
    }
    
    _videoView.frame = CGRectInset(_videoViewWrapper.bounds, -2.0f, -2.0f);
    [_videoViewWrapper addSubview:_videoView];
}

@end

@implementation TGMessageImageViewContainer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _imageView = [[TGMessageImageView alloc] initWithFrame:(CGRect){CGPointZero, frame.size}];
        _imageView.userInteractionEnabled = true;
        [self addSubview:_imageView];
        
        _timestampView = [[TGMessageImageViewTimestampView alloc] initWithFrame:CGRectMake(frame.size.width - timestampWidth - timestampRightPadding, frame.size.height - timestampHeight - timestampBottomPadding, timestampWidth, timestampHeight)];
        _timestampView.userInteractionEnabled = false;
        [self addSubview:_timestampView];
        _imageView.timestampView = _timestampView;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _imageView.frame = (CGRect){CGPointZero, frame.size};
}

- (void)setViewIdentifier:(NSString *)viewIdentifier
{
    [_imageView setViewIdentifier:viewIdentifier];
}

- (NSString *)viewIdentifier
{
    return [_imageView viewIdentifier];
}

- (void)setViewStateIdentifier:(NSString *)viewStateIdentifier
{
    [_imageView setViewStateIdentifier:viewStateIdentifier];
}

- (NSString *)viewStateIdentifier
{
    return _imageView.viewStateIdentifier;
}

- (void)willBecomeRecycled
{
    [_imageView willBecomeRecycled];
}

- (UIImage *)transitionImage
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0f);
    if (false && [UIView instancesRespondToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
    {
        [_imageView drawViewHierarchyInRect:_imageView.frame afterScreenUpdates:false];
        [_timestampView drawViewHierarchyInRect:_timestampView.frame afterScreenUpdates:false];
    }
    else
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [_imageView.image drawInRect:_imageView.frame blendMode:kCGBlendModeCopy alpha:1.0f];
        CGContextTranslateCTM(context, _timestampView.frame.origin.x, _timestampView.frame.origin.y);
        [_timestampView.layer renderInContext:context];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (bool)hasComplexTransition
{
    return !CGSizeEqualToSize(_imageView.inlineVideoSize, CGSizeZero);
}

- (TGModernGalleryComplexTransitionDescription *)complexTransitionDescription
{
    UIGraphicsBeginImageContextWithOptions(CGRectInset(self.frame, _imageView.inlineVideoInsets.left, _imageView.inlineVideoInsets.top).size, false, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, _timestampView.frame.origin.x - _imageView.inlineVideoInsets.left, _timestampView.frame.origin.y - _imageView.inlineVideoInsets.top);
    [_timestampView.layer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    TGModernGalleryComplexTransitionDescription *description = [[TGModernGalleryComplexTransitionDescription alloc] init];
    description.overlayImage = image;
    description.insets = _imageView.inlineVideoInsets;
    description.cornerRadius = 21.0f;
    
    return description;
}

@end
