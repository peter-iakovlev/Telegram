/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGAudioMessageViewModel.h"

#import "TGImageUtils.h"
#import "TGMessage.h"
#import "TGPeerIdAdapter.h"

#import "TGFont.h"

#import "TGModernViewContext.h"
#import "TGTelegraphConversationMessageAssetsSource.h"
#import "TGModernConversationItem.h"
#import "TGModernButtonViewModel.h"
#import "TGTextMessageBackgroundViewModel.h"
#import "TGModernLabelViewModel.h"
#import "TGModernFlatteningViewModel.h"
#import "TGModernDateViewModel.h"
#import "TGModernColorViewModel.h"
#import "TGAudioSliderViewModel.h"
#import "TGModernTextViewModel.h"

#import "TGAudioSliderView.h"
#import "TGModernViewInlineMediaContext.h"
#import "TGDoubleTapGestureRecognizer.h"

#import "TGReplyHeaderModel.h"

typedef enum {
    TGAudioMessageButtonPlay = 0,
    TGAudioMessageButtonPause = 1,
    TGAudioMessageButtonDownload = 2,
    TGAudioMessageButtonCancel = 3
} TGAudioMessageButtonType;

@interface TGAudioMessageViewModel () <TGModernViewInlineMediaContextDelegate, TGAudioSliderViewDelegate>
{
    bool _progressVisible;
    bool _mediaIsAvailable;
    float _progress;
    
    int32_t _duration;
    int32_t _size;
    NSString *_fileType;
    
    CGPoint _boundOffset;
    
    TGModernButtonViewModel *_playButtonModel;
    TGAudioMessageButtonType _playButtonType;
    
    TGAudioSliderViewModel *_sliderModel;
    
    CGFloat _headerHeight;
    
    bool _isPlayerActive;
    bool _isPaused;
    float _audioPosition;
    NSTimeInterval _preciseDuration;
    
    NSTimeInterval _audioPositionTimestamp;
    
    TGModernViewInlineMediaContext *_inlineMediaContext;
}

@end

@implementation TGAudioMessageViewModel

static UIImage *playImageWithColor(UIColor *color)
{
    CGFloat radius = 28.0f;
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
    CGFloat radius = 28.0f;
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
    CGFloat radius = 28.0f;
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

static UIImage *cancelImageWithColor(UIColor *color, bool incoming)
{
    CGFloat radius = 28.0f;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius, radius), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, 1.0f);
    CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, radius - 1.0f, radius - 1.0f));
    
    UIImage *crossImage = incoming ? [UIImage imageNamed:@"ModernMessageAudioCancel_Incoming.png"] : [UIImage imageNamed:@"ModernMessageAudioCancel_Outgoing.png"];
    CGContextDrawImage(context, CGRectMake(CGFloor((radius - crossImage.size.width) / 2), CGFloor((radius - crossImage.size.height) / 2), crossImage.size.width, crossImage.size.height), crossImage.CGImage);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)playImage:(bool)incoming
{
    static UIImage *incomingImage = nil;
    static UIImage *outgoingImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        incomingImage = playImageWithColor(TGAccentColor());
        outgoingImage = playImageWithColor(UIColorRGB(0x3fc33b));
    });
    
    return incoming ? incomingImage : outgoingImage;
}

- (UIImage *)pauseImage:(bool)incoming
{
    static UIImage *incomingImage = nil;
    static UIImage *outgoingImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        incomingImage = pauseImageWithColor(TGAccentColor());
        outgoingImage = pauseImageWithColor(UIColorRGB(0x3fc33b));
    });
    
    return incoming ? incomingImage : outgoingImage;
}

- (UIImage *)downloadImage:(bool)incoming
{
    static UIImage *incomingImage = nil;
    static UIImage *outgoingImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        incomingImage = downloadImageWithColor(TGAccentColor());
        outgoingImage = downloadImageWithColor(UIColorRGB(0x3fc33b));
    });
    
    return incoming ? incomingImage : outgoingImage;
}

- (UIImage *)cancelImage:(bool)incoming
{
    static UIImage *incomingImage = nil;
    static UIImage *outgoingImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        incomingImage = cancelImageWithColor(TGAccentColor(), true);
        outgoingImage = cancelImageWithColor(UIColorRGB(0x3fc33b), false);
    });
    
    return incoming ? incomingImage : outgoingImage;
}

- (instancetype)initWithMessage:(TGMessage *)message duration:(int32_t)duration size:(int32_t)size fileType:(NSString *)fileType authorPeer:(id)authorPeer context:(TGModernViewContext *)context
{
    self = [super initWithMessage:message authorPeer:authorPeer context:context];
    if (self != nil)
    {
        _playButtonModel = [[TGModernButtonViewModel alloc] init];
        [_playButtonModel setBackgroundImage:[self downloadImage:_incomingAppearance]];
        _playButtonModel.modernHighlight = true;
        _playButtonModel.skipDrawInContext = true;
        _playButtonModel.extendedEdgeInsets = UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f);
        [self updateButtonText:false];
        
        _duration = duration;
        _size = size;
        _fileType = fileType;
        _isPaused = true;
        
        _sliderModel = [[TGAudioSliderViewModel alloc] init];
        _sliderModel.incoming = _incomingAppearance;
        _sliderModel.duration = _duration;
        [self addSubmodel:_sliderModel];
        [self updateButtonText:false];
        
        [self addSubmodel:_playButtonModel];
        
        _sliderModel.listenedStatus = !_context.viewStatusEnabled || message.contentProperties[@"contentsRead"] != nil;
    }
    return self;
}

- (void)updateButtonText:(bool)animated
{
    TGAudioMessageButtonType playButtonType = TGAudioMessageButtonPlay;
    
    _sliderModel.progressMode = _progressVisible || !_mediaIsAvailable;
    
    if (_progressVisible)
    {
        playButtonType = TGAudioMessageButtonCancel;
        
        [_sliderModel setAudioPosition:_progress animated:animated timestamp:DBL_MAX isPlaying:false];
        
        _sliderModel.audioDurationText = [[NSString alloc] initWithFormat:@"%d:%02d", (int)_duration / 60, (int)_duration % 60];
        
        _sliderModel.manualPositionAdjustmentEnabled = false;
    }
    else
    {
        if (_mediaIsAvailable)
            playButtonType = _isPaused ? TGAudioMessageButtonPlay : TGAudioMessageButtonPause;
        else
            playButtonType = TGAudioMessageButtonDownload;
        
        _sliderModel.viewUserInteractionDisabled = !_isPlayerActive;
        
        [_sliderModel setPreciseDuration:_preciseDuration];
        bool isPlaying = _isPlayerActive && !_isPaused;
        [_sliderModel setAudioPosition:_audioPosition animated:animated timestamp:isPlaying ? _audioPositionTimestamp : DBL_MAX isPlaying:isPlaying];
        
        int currentDuration = _isPlayerActive ? (int)(_duration * _audioPosition) : (int)_duration;
        if (_duration == 0 && _fileType.length != 0)
        {
            NSString *sizeString = @"";
            if (_size < 1024 * 1024)
            {
                sizeString = [[NSString alloc] initWithFormat:TGLocalizedStatic(@"Conversation.Kilobytes"), (int)(int)(_size / 1024)];
            }
            else
            {
                sizeString = [[NSString alloc] initWithFormat:TGLocalizedStatic(@"Conversation.Megabytes"), (float)(float)_size / (1024 * 1024)];
            }
            if (_fileType.length != 0)
                sizeString = [[NSString alloc] initWithFormat:@"%@, %@ ", _fileType, sizeString];
            _sliderModel.audioDurationText = sizeString;
        }
        else
        {
            _sliderModel.audioDurationText = [[NSString alloc] initWithFormat:@"%d:%02d", (int)currentDuration / 60, (int)currentDuration % 60];
        }
        
        _sliderModel.manualPositionAdjustmentEnabled = _isPlayerActive;
    }
    
    if (_playButtonType != playButtonType)
    {
        _playButtonType = playButtonType;
        
        switch (_playButtonType)
        {
            case TGAudioMessageButtonPlay:
                [_playButtonModel setBackgroundImage:[self playImage:_incomingAppearance]];
                break;
            case TGAudioMessageButtonPause:
                [_playButtonModel setBackgroundImage:[self pauseImage:_incomingAppearance]];
                break;
            case TGAudioMessageButtonDownload:
                [_playButtonModel setBackgroundImage:[self downloadImage:_incomingAppearance]];
                break;
            case TGAudioMessageButtonCancel:
                [_playButtonModel setBackgroundImage:[self cancelImage:_incomingAppearance]];
                break;
            default:
                break;
        }
    }
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage sizeUpdated:(bool *)sizeUpdated
{
    [super updateMessage:message viewStorage:viewStorage sizeUpdated:sizeUpdated];
    
    [self updateButtonText:false];
    
    _sliderModel.listenedStatus = !_context.viewStatusEnabled || message.contentProperties[@"contentsRead"] != nil;
}

- (void)updateMediaAvailability:(bool)mediaIsAvailable viewStorage:(TGModernViewStorage *)__unused viewStorage
{
    [super updateMediaAvailability:mediaIsAvailable viewStorage:viewStorage];
    
    _mediaIsAvailable = mediaIsAvailable;
    
    [self updateButtonText:false];
}
        
- (void)updateProgress:(bool)progressVisible progress:(float)progress viewStorage:(TGModernViewStorage *)viewStorage animated:(bool)animated
{
    [super updateProgress:progressVisible progress:progress viewStorage:viewStorage animated:animated];
    
    _progressVisible = progressVisible;
    _progress = progress;
    
    [self updateButtonText:animated && (_progress < 0.01f ? false : true)];
}

- (void)updateInlineMediaContext
{
    bool isPlayerActive = false;
    bool isPaused = true;
    float audioPosition = 0.0f;
    NSTimeInterval playbackPositionTimestamp = DBL_MAX;
    
    _inlineMediaContext = [_context inlineMediaContext:_mid];
    if (_inlineMediaContext != nil)
    {
        _inlineMediaContext.delegate = self;
        
        isPlayerActive = true;
        isPaused = [_inlineMediaContext isPaused];
        audioPosition = [_inlineMediaContext playbackPosition:&playbackPositionTimestamp];
    }
    else
    {
        isPlayerActive = false;
        isPaused = true;
        audioPosition = 0.0f;
    }
    
    if (_isPlayerActive != isPlayerActive || _isPaused != isPaused || ABS(audioPosition - _audioPosition) > FLT_EPSILON || ABS(playbackPositionTimestamp - _audioPositionTimestamp) > DBL_EPSILON)
    {
        _isPlayerActive = isPlayerActive;
        _isPaused = isPaused;
        _audioPosition = audioPosition;
        _audioPositionTimestamp = playbackPositionTimestamp;
        
        [self updateButtonText:false];
    }
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    _boundOffset = itemPosition;
    
    [super bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:itemPosition];
    
    [_playButtonModel bindViewToContainer:container viewStorage:viewStorage];
    [_playButtonModel boundView].frame = CGRectOffset([_playButtonModel boundView].frame, itemPosition.x, itemPosition.y);
    
    [_sliderModel bindViewToContainer:container viewStorage:viewStorage];
    [_sliderModel boundView].frame = CGRectOffset([_sliderModel boundView].frame, itemPosition.x, itemPosition.y);
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    _boundOffset = CGPointZero;
    
    [self updateInlineMediaContext];
    
    [self updateEditingState:nil viewStorage:nil animationDelay:-1.0];
    
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    [(UIButton *)[_playButtonModel boundView] addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    ((TGAudioSliderView *)[_sliderModel boundView]).delegate = self;
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    [(UIButton *)[_playButtonModel boundView] removeTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    ((TGAudioSliderView *)[_sliderModel boundView]).delegate = nil;
    
    [_inlineMediaContext removeDelegate:self];
    
    [super unbindView:viewStorage];
}

- (void)playButtonPressed
{
    if (_playButtonType == TGAudioMessageButtonCancel)
        [_context.companionHandle requestAction:@"mediaProgressCancelRequested" options:@{@"mid": @(_mid)}];
    else
    {
        if (_mediaIsAvailable)
        {
            if (_inlineMediaContext != nil)
            {
                if (_isPaused)
                    [_inlineMediaContext play];
                else
                    [_inlineMediaContext pause];
            }
            else if (!_isPlayerActive)
                [_context.companionHandle requestAction:@"openMediaRequested" options:@{@"mid": @(_mid)}];
            else
                [_inlineMediaContext pause];
        }
        else
            [_context.companionHandle requestAction:@"mediaDownloadRequested" options:@{@"mid": @(_mid)}];
    }
}

- (void)layoutContentForHeaderHeight:(CGFloat)headerHeight
{
    _headerHeight = headerHeight;
}

- (CGSize)contentSizeForContainerSize:(CGSize)__unused containerSize needsContentsUpdate:(bool *)__unused needsContentsUpdate hasDate:(bool)__unused hasDate hasViews:(bool)__unused hasViews
{
    return CGSizeMake(MAX(160, MIN(205, _duration * 30)), 45);
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    [super layoutForContainerSize:containerSize];
    
    _playButtonModel.frame = CGRectMake(_backgroundModel.frame.origin.x + (_incomingAppearance ? 14.0f : 9.0f), _headerHeight + _backgroundModel.frame.origin.y + 9.0f + TGRetinaPixel, 28.0f, 28.0f);
    
    CGFloat trackOriginX = CGRectGetMaxX(_playButtonModel.frame) + 5.0f;
    CGRect sliderFrame = CGRectMake(trackOriginX, _playButtonModel.frame.origin.y + 7.0f, CGRectGetMaxX(_backgroundModel.frame) - trackOriginX - 13.0f + (_incomingAppearance ? 5.0f : 0.0f), 14.0f);
    _sliderModel.frame = sliderFrame;
}

- (void)inlineMediaPlaybackStateUpdated:(bool)isPaused playbackPosition:(float)playbackPosition timestamp:(MTAbsoluteTime)timestamp preciseDuration:(NSTimeInterval)preciseDuration
{
    _isPaused = isPaused;
    _audioPosition = playbackPosition;
    _audioPositionTimestamp = timestamp;
    _preciseDuration = preciseDuration;
    
    [self updateButtonText:false];
}

- (void)audioSliderViewDidBeginPositionAdjustment:(TGAudioSliderView *)__unused audioSliderView
{
    [_inlineMediaContext pause];
}

- (void)audioSliderViewDidEndPositionAdjustment:(TGAudioSliderView *)__unused audioSliderView atPosition:(CGFloat)position
{
    [_inlineMediaContext play:(float)position];
}

- (void)audioSliderViewDidCancelPositionAdjustment:(TGAudioSliderView *)__unused audioSliderView
{
    [_inlineMediaContext play];
}

- (int)gestureRecognizer:(TGDoubleTapGestureRecognizer *)__unused recognizer shouldFailTap:(CGPoint)__unused point
{
    if ((_replyHeaderModel && CGRectContainsPoint(_replyHeaderModel.frame, point)) ||
        (_forwardedHeaderModel && CGRectContainsPoint(_forwardedHeaderModel.frame, point)))
        return 3;
    return 0;
}

- (void)messageDoubleTapGesture:(TGDoubleTapGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan)
    {
        if (recognizer.state == UIGestureRecognizerStateRecognized)
        {
            CGPoint point = [recognizer locationInView:[_contentModel boundView]];
            
            if (recognizer.longTapped)
                [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
            else if (recognizer.doubleTapped)
                [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
            else if (_forwardedHeaderModel && CGRectContainsPoint(_forwardedHeaderModel.frame, point)) {
                if (TGPeerIdIsChannel(_forwardedPeerId)) {
                    [_context.companionHandle requestAction:@"peerAvatarTapped" options:@{@"peerId": @(_forwardedPeerId), @"messageId": @(_forwardedMessageId)}];
                } else {
                    [_context.companionHandle requestAction:@"userAvatarTapped" options:@{@"uid": @((int32_t)_forwardedPeerId)}];
                }
            }
            else if (_replyHeaderModel && CGRectContainsPoint(_replyHeaderModel.frame, point))
                [_context.companionHandle requestAction:@"navigateToMessage" options:@{@"mid": @(_replyMessageId), @"sourceMid": @(_mid)}];
            else if (!_isPlayerActive || _isPaused)
                [self playButtonPressed];
        }
    }
}

@end
