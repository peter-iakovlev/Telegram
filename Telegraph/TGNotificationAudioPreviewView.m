#import "TGNotificationAudioPreviewView.h"
#import "TGNotificationView.h"

#import "TGAppDelegate.h"

#import "TGFont.h"
#import "TGPeerIdAdapter.h"

#import "TGModernButton.h"
#import "TGAudioSliderView.h"

#import "TGAudioMediaAttachment.h"

#import "TGModernViewInlineMediaContext.h"

#import "TGMessage.h"
#import "TGAudioWaveformSignal.h"

typedef enum {
    TGNotificationAudioButtonPlay = 0,
    TGNotificationAudioButtonPause = 1,
    TGNotificationAudioButtonDownload = 2,
    TGNotificationAudioButtonCancel = 3
} TGNotificationAudioButtonType;

@interface TGNotificationAudioPreviewView () <TGModernViewInlineMediaContextDelegate, TGAudioSliderViewDelegate>
{
    UIView *_wrapperView;
    TGAudioSliderView *_sliderView;
    TGModernButton *_playButton;
    
    bool _progressVisible;
    bool _mediaIsAvailable;
    float _progress;
    
    TGAudioMediaAttachment *_attachment;
    int32_t _duration;
    int32_t _size;
    NSString *_fileType;
    
    TGNotificationAudioButtonType _playButtonType;
    bool _isPlayerActive;
    bool _isPaused;
    float _audioPosition;
    NSTimeInterval _preciseDuration;
    
    NSTimeInterval _audioPositionTimestamp;
    
    bool _updatedWaveform;
}
@end

@implementation TGNotificationAudioPreviewView

static UIImage *playImageWithColor(UIColor *color)
{
    CGFloat radius = 28;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius, radius), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, radius, radius));
    
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 11.0f, 8.0f);
    CGContextAddLineToPoint(context, 21.0f, 14.0f);
    CGContextAddLineToPoint(context, 11.0f, 20.0f);
    CGContextClosePath(context);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillPath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

static UIImage *pauseImageWithColor(UIColor *color)
{
    CGFloat radius = 28;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius, radius), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, radius, radius));
    
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, CGRectMake(10.0f, 9.0f, 2.5f, 10.0f));
    CGContextFillRect(context, CGRectMake(15.5f, 9.0f, 2.5f, 10.0f));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

static UIImage *downloadImageWithColor(UIColor *color)
{
    CGFloat radius = 28;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius, radius), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, 1.0f);
    CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, radius - 1.0f, radius - 1.0f));
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(13.0f, 8.5f, 2.0f, 8.0f));
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 10.0f, 16.5f);
    CGContextAddLineToPoint(context, 18.0f, 16.5f);
    CGContextAddLineToPoint(context, 14.5f, 20.5f);
    CGContextAddLineToPoint(context, 13.5f, 20.5f);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

static UIImage *cancelImageWithColor(UIColor *color)
{
    CGFloat radius = 28;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius, radius), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, 1.0f);
    CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, radius - 1.0f, radius - 1.0f));
    
    UIImage *crossImage = [UIImage imageNamed:@"ModernMessageAudioCancel_Notification.png"];
    CGContextDrawImage(context, CGRectMake(CGFloor((radius - crossImage.size.width) / 2), CGFloor((radius - crossImage.size.height) / 2), crossImage.size.width, crossImage.size.height), crossImage.CGImage);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (instancetype)initWithMessage:(TGMessage *)message conversation:(TGConversation *)conversation attachment:(id)attachment peers:(NSDictionary *)peers
{
    self = [super initWithMessage:message conversation:conversation peers:peers];
    if (self != nil)
    {
        [self setIcon:[UIImage imageNamed:@"MediaVoice"] text:TGLocalized(@"Message.Audio")];
        
        _attachment = attachment;
        if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]) {
            for (id attribute in ((TGDocumentMediaAttachment *)attachment).attributes) {
                if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                    _duration = ((TGDocumentAttributeAudio *)attribute).duration;
                    break;
                }
            }
            _size = ((TGDocumentMediaAttachment *)attachment).size;
        }
        _fileType = nil;
        _isPaused = true;
    
        _wrapperView = [[UIView alloc] initWithFrame:CGRectMake(TGNotificationPreviewContentInset.left - 8, 19, 0, 45)];
        _wrapperView.alpha = 0.0f;
        [self addSubview:_wrapperView];
        
        _sliderView = [[TGAudioSliderView alloc] init];
        _sliderView.delegate = self;
        _sliderView.style = TGAudioSliderViewStyleNotification;
        _sliderView.duration = _duration;
        [_wrapperView addSubview:_sliderView];
    
        _playButton = [[TGModernButton alloc] initWithFrame:CGRectMake(8, 8, 29, 29)];
        _playButton.extendedEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
        [_playButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_wrapperView addSubview:_playButton];
        
        [self updateAnimated:false];
    }
    return self;
}

- (void)dealloc
{
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if ([view isDescendantOfView:_wrapperView])
        return view;
    
    return nil;
}

- (void)updateAnimated:(bool)__unused animated
{
    TGNotificationAudioButtonType playButtonType = TGNotificationAudioButtonPlay;
    
    if (_progressVisible)
    {
        playButtonType = TGNotificationAudioButtonCancel;
        
        _sliderView.manualPositionAdjustmentEnabled = false;
    }
    else
    {
        if (_mediaIsAvailable)
            playButtonType = _isPaused ? TGNotificationAudioButtonPlay : TGNotificationAudioButtonPause;
        else
            playButtonType = TGNotificationAudioButtonDownload;
    }

    
    if (_playButtonType != playButtonType)
    {
        _playButtonType = playButtonType;
        
        switch (_playButtonType)
        {
            case TGNotificationAudioButtonPlay:
                [_playButton setBackgroundImage:[self playImage] forState:UIControlStateNormal];
                break;
            case TGNotificationAudioButtonPause:
                [_playButton setBackgroundImage:[self pauseImage] forState:UIControlStateNormal];
                break;
            case TGNotificationAudioButtonDownload:
                [_playButton setBackgroundImage:[self downloadImage] forState:UIControlStateNormal];
                break;
            case TGNotificationAudioButtonCancel:
                [_playButton setBackgroundImage:[self cancelImage] forState:UIControlStateNormal];
                break;
            default:
                break;
        }
    }
    
    if (!_updatedWaveform) {
        if ([_attachment isKindOfClass:[TGDocumentMediaAttachment class]]) {
            for (id attribute in ((TGDocumentMediaAttachment *)_attachment).attributes) {
                if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                    _updatedWaveform = true;
                    
                    [_sliderView setWaveformSignal:[SSignal single:((TGDocumentAttributeAudio *)attribute).waveform]];
                    break;
                }
            }
        }
    }
}

- (void)updateMediaAvailability:(bool)mediaIsAvailable
{
    [super updateMediaAvailability:mediaIsAvailable];
    
    _mediaIsAvailable = mediaIsAvailable;
    if (mediaIsAvailable)
        _progressVisible = false;
    
    [self updateAnimated:false];
}

- (void)updateProgress:(bool)progressVisible progress:(float)progress animated:(bool)animated
{
    [super updateProgress:progressVisible progress:progress animated:animated];
    
    _progressVisible = progressVisible;
    _progress = progress;
    
    [self updateAnimated:animated && (_progress < 0.01f ? false : true)];
}

- (void)inlineMediaPlaybackStateUpdated:(bool)isPaused playbackPosition:(float)playbackPosition timestamp:(CFAbsoluteTime)timestamp preciseDuration:(NSTimeInterval)preciseDuration
{
    _isPaused = isPaused;
    _audioPosition = playbackPosition;
    _audioPositionTimestamp = timestamp;
    _preciseDuration = preciseDuration;
    
    [self updateAnimated:false];
}

- (void)audioSliderViewDidBeginPositionAdjustment:(TGAudioSliderView *)__unused audioSliderView
{
}

- (void)audioSliderViewDidEndPositionAdjustment:(TGAudioSliderView *)__unused audioSliderView atPosition:(CGFloat)__unused position smallChange:(bool)__unused smallChange
{
}

- (void)audioSliderViewDidCancelPositionAdjustment:(TGAudioSliderView *)__unused audioSliderView
{
}

- (void)playButtonPressed
{
    _isIdle = false;
    if (_playButtonType == TGNotificationAudioButtonCancel)
    {
        if (self.cancelMedia != nil)
            self.cancelMedia(self.activeRequestMediaId);
    }
    else
    {
        if (_mediaIsAvailable)
        {
            if (!_isPlayerActive)
            {
                if (self.playMedia != nil)
                    self.playMedia(_attachment, _conversationId, _messageId);
            }
        }
        else
        {
            [self _requestMedia];
        }
    }
}

- (void)_requestMedia
{
    if (self.requestMedia != nil)
        _activeRequestMediaId = self.requestMedia(_attachment, _conversationId, _messageId);
}

- (void)setExpandProgress:(CGFloat)progress
{
    _expandProgress = progress;
    
    bool autoDownload = TGPeerIdIsGroup(_conversationId) || TGPeerIdIsChannel(_conversationId) ? TGAppDelegateInstance.autoDownloadAudioInGroups : TGAppDelegateInstance.autoDownloadAudioInPrivateChats;
    
    if (!_mediaIsAvailable && self.activeRequestMediaId == nil && autoDownload)
        [self _requestMedia];
    
    _wrapperView.alpha = progress * progress;
    [self _updateExpandProgress:progress hideText:true];
    
    [self setNeedsLayout];
}

- (CGFloat)expandedHeightForContainerSize:(CGSize)containerSize
{
    [super expandedHeightForContainerSize:containerSize];
    return _headerHeight + TGNotificationDefaultHeight + 2;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _wrapperView.frame = CGRectMake(_wrapperView.frame.origin.x, _textLabel.frame.origin.y - 4, self.frame.size.width - _wrapperView.frame.origin.x - TGNotificationPreviewContentInset.right - 8, 45);
    
    _sliderView.frame = CGRectMake(43, 11.5f, _wrapperView.frame.size.width - 35 - 39, 14);
}

- (UIImage *)playImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        image = playImageWithColor(UIColorRGB(0xf6f6f6));
    });
    
    return image;
}

- (UIImage *)pauseImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        image = pauseImageWithColor(UIColorRGB(0xf6f6f6));
    });
    
    return image;
}

- (UIImage *)downloadImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        image = downloadImageWithColor(UIColorRGB(0xf6f6f6));
    });
    
    return image;
}

- (UIImage *)cancelImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        image = cancelImageWithColor(UIColorRGB(0xf6f6f6));
    });
    
    return image;
}

@end
