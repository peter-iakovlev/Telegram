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

#import "TGAudioWaveformSignal.h"

#import "TGPreparedLocalDocumentMessage.h"

#import "TGTelegraph.h"

#import "TGMusicPlayer.h"

#import "TGDocumentMessageIconModel.h"
#import "TGMessageImageView.h"
#import "TGDocumentMessageIconView.h"

typedef enum {
    TGAudioMessageButtonPlay = 0,
    TGAudioMessageButtonPause = 1,
    TGAudioMessageButtonDownload = 2,
    TGAudioMessageButtonCancel = 3
} TGAudioMessageButtonType;

@interface TGAudioMessageViewModel () <TGModernViewInlineMediaContextDelegate, TGAudioSliderViewDelegate, TGMessageImageViewDelegate>
{
    bool _progressVisible;
    bool _mediaIsAvailable;
    float _progress;
    
    int32_t _duration;
    int32_t _size;
    NSString *_fileType;
    
    CGPoint _boundOffset;
    
    TGDocumentMessageIconModel *_iconModel;
    
    TGAudioSliderViewModel *_sliderModel;
    
    CGFloat _headerHeight;
    
    TGMusicPlayerStatus *_status;
    
    bool _updatedWaveform;
    TGAudioMediaAttachment *_audioMedia;
    TGDocumentMediaAttachment *_documentMedia;
    
    id<SDisposable> _playingAudioMessageIdDisposable;
    
    bool _isSecret;
    bool _wasPausedBeforeScrubbing;
}

@end

@implementation TGAudioMessageViewModel

static UIImage *playImageWithColor(UIColor *color)
{
    CGFloat radius = 37.0f;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius, radius), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, radius, radius));
    
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    
    CGContextTranslateCTM(context, -TGRetinaPixel, TGRetinaPixel);
    CGFloat factor = 28.0f / 34.0f;
    CGContextScaleCTM(context, 0.5f * factor, 0.5f * factor);
    
    TGDrawSvgPath(context, @"M39.4267651,27.0560591 C37.534215,25.920529 36,26.7818508 36,28.9948438 L36,59.0051562 C36,61.2114475 37.4877047,62.0081969 39.3251488,60.7832341 L62.6748512,45.2167659 C64.5112802,43.9924799 64.4710515,42.0826309 62.5732349,40.9439409 L39.4267651,27.0560591 Z");
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

static UIImage *pauseImageWithColor(UIColor *color)
{
    CGFloat radius = 37.0f;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius, radius), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, radius, radius));
    
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);

    CGFloat factor = 28.0f / 34.0f;
    CGContextTranslateCTM(context, TGRetinaPixel, TGRetinaPixel);
    CGContextScaleCTM(context, 0.5f * factor, 0.5f * factor);
    
    TGDrawSvgPath(context, @"M29,30.0017433 C29,28.896211 29.8874333,28 30.999615,28 L37.000385,28 C38.1047419,28 39,28.8892617 39,30.0017433 L39,57.9982567 C39,59.103789 38.1125667,60 37.000385,60 L30.999615,60 C29.8952581,60 29,59.1107383 29,57.9982567 L29,30.0017433 Z M49,30.0017433 C49,28.896211 49.8874333,28 50.999615,28 L57.000385,28 C58.1047419,28 59,28.8892617 59,30.0017433 L59,57.9982567 C59,59.103789 58.1125667,60 57.000385,60 L50.999615,60 C49.8952581,60 49,59.1107383 49,57.9982567 L49,30.0017433 Z");
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

static UIImage *downloadImageWithColor(UIColor *color, UIColor *backgroundColor)
{
    CGFloat radius = 37.0f;
    CGFloat diameter = radius;
    CGFloat lineWidth = 2.0f;
    CGFloat width = CGCeil(radius / 2.5f);
    CGFloat height = CGCeil(radius / 2.0f) - 1.0f;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius, radius), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, radius, radius));
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    CGPoint mainLine[] = {
        CGPointMake((diameter - lineWidth) / 2.0f + lineWidth / 2.0f, (diameter - height) / 2.0f + lineWidth / 2.0f),
        CGPointMake((diameter - lineWidth) / 2.0f + lineWidth / 2.0f, (diameter + height) / 2.0f - lineWidth / 2.0f)
    };
    
    CGPoint arrowLine[] = {
        CGPointMake((diameter - lineWidth) / 2.0f + lineWidth / 2.0f - width / 2.0f, (diameter + height) / 2.0f + lineWidth / 2.0f - width / 2.0f),
        CGPointMake((diameter - lineWidth) / 2.0f + lineWidth / 2.0f, (diameter + height) / 2.0f + lineWidth / 2.0f),
        CGPointMake((diameter - lineWidth) / 2.0f + lineWidth / 2.0f, (diameter + height) / 2.0f + lineWidth / 2.0f),
        CGPointMake((diameter - lineWidth) / 2.0f + lineWidth / 2.0f + width / 2.0f, (diameter + height) / 2.0f + lineWidth / 2.0f - width / 2.0f),
    };
    
    CGContextStrokeLineSegments(context, mainLine, sizeof(mainLine) / sizeof(mainLine[0]));
    CGContextStrokeLineSegments(context, arrowLine, sizeof(arrowLine) / sizeof(arrowLine[0]));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

static UIImage *cancelImageWithColor(UIColor *color, UIColor *backgroundColor)
{
    CGFloat radius = 37.0f;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius, radius), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat diameter = radius;
    //tgauCGFloat inset = 0.5f;
    CGFloat lineWidth = 2.0f;
    CGFloat crossSize = 16.0f;
    
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, radius, radius));
    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, lineWidth);
    
    CGPoint crossLine[] = {
        CGPointMake((diameter - crossSize) / 2.0f, (diameter - crossSize) / 2.0f),
        CGPointMake((diameter + crossSize) / 2.0f, (diameter + crossSize) / 2.0f),
        CGPointMake((diameter + crossSize) / 2.0f, (diameter - crossSize) / 2.0f),
        CGPointMake((diameter - crossSize) / 2.0f, (diameter + crossSize) / 2.0f),
    };
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextStrokeLineSegments(context, crossLine, sizeof(crossLine) / sizeof(crossLine[0]));
    
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
        incomingImage = downloadImageWithColor(UIColorRGB(0x4f9ef3), UIColorRGBA(0x85baf2, 0.15f));
        outgoingImage = downloadImageWithColor(UIColorRGB(0x64b15e), UIColorRGBA(0x4fb212, 0.15f));
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
        incomingImage = cancelImageWithColor(UIColorRGB(0x4f9ef3), UIColorRGBA(0x85baf2, 0.15f));
        outgoingImage = cancelImageWithColor(UIColorRGB(0x64b15e), UIColorRGBA(0x4fb212, 0.15f));
    });
    
    return incoming ? incomingImage : outgoingImage;
}

- (instancetype)initWithMessage:(TGMessage *)message duration:(int32_t)duration size:(int32_t)size fileType:(NSString *)fileType authorPeer:(id)authorPeer viaUser:(TGUser *)viaUser context:(TGModernViewContext *)context
{
    self = [super initWithMessage:message authorPeer:authorPeer viaUser:viaUser context:context];
    if (self != nil)
    {
        for (id attachment in message.mediaAttachments) {
            if ([attachment isKindOfClass:[TGAudioMediaAttachment class]]) {
                _audioMedia = attachment;
                break;
            } else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]) {
                _documentMedia = attachment;
                break;
            }
        }
        
        _iconModel = [[TGDocumentMessageIconModel alloc] init];
        _iconModel.skipDrawInContext = true;
        _iconModel.frame = CGRectMake(0.0f, 0.0f, 37.0f, 37.0f);
        _iconModel.incoming = _incomingAppearance;
        _iconModel.diameter = 37.0f;
        [self addSubmodel:_iconModel];
        
        _duration = duration;
        _size = size;
        _fileType = fileType;
        
        _sliderModel = [[TGAudioSliderViewModel alloc] init];
        if (_audioMedia != nil) {
            _sliderModel.audioId = _audioMedia.audioId;
            _sliderModel.localAudioId = _audioMedia.localAudioId;
        } else if (_documentMedia != nil) {
            _sliderModel.audioId = _documentMedia.documentId;
            _sliderModel.localAudioId = _documentMedia.localDocumentId;
        }
        _sliderModel.incoming = _incomingAppearance;
        _sliderModel.duration = _duration;
        [self addSubmodel:_sliderModel];
        
        [self updateButtonText:false];
        
        _isSecret = TGPeerIdIsSecretChat(message.cid);
        bool listenedStatus = true;
        if (_isSecret) {
            listenedStatus = [_context isSecretMessageViewed:message.mid];
        } else {
            listenedStatus = !_context.viewStatusEnabled || message.contentProperties[@"contentsRead"] != nil;
        }
        _sliderModel.listenedStatus = listenedStatus;
        
        [self updateWaveform];
    }
    return self;
}

- (void)updateButtonText:(bool)animated
{
    if (_progressVisible)
    {
        _sliderModel.manualPositionAdjustmentEnabled = false;
    }
    else
    {
        _sliderModel.viewUserInteractionDisabled = _status == nil;
        
        [_sliderModel setStatus:_status];
        
        _sliderModel.manualPositionAdjustmentEnabled = _status != nil;
    }
    
    if (_progressVisible)
    {
        [_iconModel setOverlayType:TGMessageImageViewOverlayProgress animated:false];
        [_iconModel setProgress:_progress animated:animated];
    }
    else if (!_mediaIsAvailable)
    {
        [_iconModel setOverlayType:TGMessageImageViewOverlayDownload animated:false];
        [_iconModel setProgress:0.0f animated:false];
    }
    else
    {
        [_iconModel setOverlayType:!(_status == nil || _status.paused) ? TGMessageImageViewOverlayPauseMedia : TGMessageImageViewOverlayPlayMedia animated:animated];
    }
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage sizeUpdated:(bool *)sizeUpdated
{
    [super updateMessage:message viewStorage:viewStorage sizeUpdated:sizeUpdated];
    
    [self updateButtonText:false];
    
    bool listenedStatus = true;
    if (TGPeerIdIsSecretChat(message.cid)) {
        listenedStatus = [_context isSecretMessageViewed:message.mid];
    } else {
        listenedStatus = !_context.viewStatusEnabled || message.contentProperties[@"contentsRead"] != nil;
    }
    _sliderModel.listenedStatus = listenedStatus;
    
    for (id attachment in message.mediaAttachments) {
        if ([attachment isKindOfClass:[TGAudioMediaAttachment class]]) {
            _audioMedia = attachment;
            break;
        } else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]) {
            _documentMedia = attachment;
            break;
        }
    }
    
    [self updateWaveform];
}

- (void)updateMessageAttributes
{
    [super updateMessageAttributes];
    
    if (_isSecret)
    {
        bool isMessageViewed = [_context isSecretMessageViewed:_mid];
        _sliderModel.listenedStatus = isMessageViewed;
    }
}

- (void)updateMediaAvailability:(bool)mediaIsAvailable viewStorage:(TGModernViewStorage *)__unused viewStorage delayDisplay:(bool)delayDisplay
{
    [super updateMediaAvailability:mediaIsAvailable viewStorage:viewStorage delayDisplay:delayDisplay];
    
    _mediaIsAvailable = mediaIsAvailable;
    
    [self updateButtonText:false];
    
    [self updateWaveform];
}
        
- (void)updateProgress:(bool)progressVisible progress:(float)progress viewStorage:(TGModernViewStorage *)viewStorage animated:(bool)animated
{
    bool progressWasVisible = _progressVisible;
    float previousProgress = _progress;
    
    [super updateProgress:progressVisible progress:progress viewStorage:viewStorage animated:animated];
    
    _progressVisible = progressVisible;
    _progress = progress;
    
    [self updateButtonText:((progressWasVisible && !_progressVisible) || (_progressVisible && ABS(_progress - previousProgress) > FLT_EPSILON)) && animated];
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    _boundOffset = itemPosition;
    
    [super bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:itemPosition];
    
    [_iconModel bindViewToContainer:container viewStorage:viewStorage];
    [_iconModel boundView].frame = CGRectOffset([_iconModel boundView].frame, itemPosition.x, itemPosition.y);
    ((TGDocumentMessageIconView *)[_iconModel boundView]).delegate = self;
    
    [_sliderModel bindViewToContainer:container viewStorage:viewStorage];
    [_sliderModel boundView].frame = CGRectOffset([_sliderModel boundView].frame, itemPosition.x, itemPosition.y);
    
    [self subscribeStatus];
}

- (void)subscribeStatus {
    [_playingAudioMessageIdDisposable dispose];
    if (_context.playingAudioMessageStatus != nil)
    {
        __weak TGAudioMessageViewModel *weakSelf = self;
        _playingAudioMessageIdDisposable = [_context.playingAudioMessageStatus startWithNext:^(TGMusicPlayerStatus *status)
        {
            __strong TGAudioMessageViewModel *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (status != nil && [(NSNumber *)status.item.key intValue] == strongSelf->_mid) {
                    strongSelf->_status = status;
                } else {
                    strongSelf->_status = nil;
                }
                [self updateButtonText:false];
            }
        }];
    }
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    _boundOffset = CGPointZero;
    
    [self updateInlineMediaContext];
    
    [self updateEditingState:nil viewStorage:nil animationDelay:-1.0];
    
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    ((TGDocumentMessageIconView *)[_iconModel boundView]).delegate = self;
    
    ((TGAudioSliderView *)[_sliderModel boundView]).delegate = self;
    
    [self subscribeStatus];
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    UIView *iconView = [_iconModel boundView];
    ((TGDocumentMessageIconView *)iconView).delegate = nil;
    
    ((TGAudioSliderView *)[_sliderModel boundView]).delegate = nil;
    
    [super unbindView:viewStorage];
    
    [_playingAudioMessageIdDisposable dispose];
    _playingAudioMessageIdDisposable = nil;
}

- (void)activateMedia
{
    if (_mediaIsAvailable)
    {
        if (_status != nil && !_status.paused)
        {
            if (_context.pauseAudioMessage)
                _context.pauseAudioMessage();
        }
        else if (_status != nil && _status.paused)
        {
            if (_context.resumeAudioMessage)
                _context.resumeAudioMessage();
        }
        else
        {
            if (_context.playAudioMessageId)
                _context.playAudioMessageId(_mid);
        }
    }
    else
        [_context.companionHandle requestAction:@"mediaDownloadRequested" options:@{@"mid": @(_mid)}];
}

- (void)cancelMediaDownload
{
    [_context.companionHandle requestAction:@"mediaProgressCancelRequested" options:@{@"mid": @(_mid)}];
}

- (void)messageImageViewActionButtonPressed:(TGMessageImageView *)messageImageView withAction:(TGMessageImageViewActionType)action
{
    if (messageImageView == [_iconModel boundView])
    {
        if (action == TGMessageImageViewActionCancelDownload)
            [self cancelMediaDownload];
        else
            [self activateMedia];
    }
}

- (void)layoutContentForHeaderHeight:(CGFloat)headerHeight
{
    _headerHeight = headerHeight;
}

- (CGSize)contentSizeForContainerSize:(CGSize)__unused containerSize needsContentsUpdate:(bool *)__unused needsContentsUpdate hasDate:(bool)__unused hasDate hasViews:(bool)__unused hasViews
{
    return CGSizeMake(MAX(160, MIN(205, _duration * 30)), 50.0f);
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    [super layoutForContainerSize:containerSize];
    
    _iconModel.frame = CGRectMake(_backgroundModel.frame.origin.x + (_incomingAppearance ? 14.0f : 9.0f), _headerHeight + _backgroundModel.frame.origin.y + 12.0f, 37.0f, 37.0f);
    
    CGFloat trackOriginX = CGRectGetMaxX(_iconModel.frame) + 5.0f;
    CGRect sliderFrame = CGRectMake(trackOriginX, _iconModel.frame.origin.y - 3.0f, CGRectGetMaxX(_backgroundModel.frame) - trackOriginX - 13.0f + (_incomingAppearance ? 5.0f : 0.0f), 14.0f);
    _sliderModel.frame = sliderFrame;
}

- (void)audioSliderViewDidBeginPositionAdjustment:(TGAudioSliderView *)__unused audioSliderView
{
    _wasPausedBeforeScrubbing = false;
    if (_status != nil) {
        _wasPausedBeforeScrubbing  = _status.paused;
        [TGTelegraphInstance.musicPlayer controlPause];
    }
}

- (void)audioSliderViewDidEndPositionAdjustment:(TGAudioSliderView *)__unused audioSliderView atPosition:(CGFloat)position smallChange:(bool)smallChange
{
    if (_status != nil) {
        if (smallChange && !_wasPausedBeforeScrubbing) {
            [TGTelegraphInstance.musicPlayer controlPause];
        } else {
            [TGTelegraphInstance.musicPlayer controlSeekToPosition:position];
            [TGTelegraphInstance.musicPlayer controlPlay];
        }
    }
    _wasPausedBeforeScrubbing = false;
}

- (void)audioSliderViewDidCancelPositionAdjustment:(TGAudioSliderView *)__unused audioSliderView
{
    _wasPausedBeforeScrubbing = false;
    if (_status != nil) {
        [TGTelegraphInstance.musicPlayer controlPlay];
    }
}

- (int)gestureRecognizer:(TGDoubleTapGestureRecognizer *)__unused recognizer shouldFailTap:(CGPoint)__unused point
{
    if ((_replyHeaderModel && CGRectContainsPoint(_replyHeaderModel.frame, point)) ||
        (_forwardedHeaderModel && CGRectContainsPoint(_forwardedHeaderModel.frame, point)))
        return 3;
    return 3;
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
            else if (_status == nil) {
                [self activateMedia];
            } else if (_status != nil) {
                if (!_status.paused) {
                    [self activateMedia];
                } else {
                    [self activateMedia];
                }
            }
        }
    }
}

- (void)updateWaveform {
    TGAudioWaveform *waveform = nil;
    if (_documentMedia != nil) {
        for (id attribute in _documentMedia.attributes) {
            if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                waveform = ((TGDocumentAttributeAudio *)attribute).waveform;
                break;
            }
        }
    }
    if (waveform != nil) {
        _updatedWaveform = true;
        [_sliderModel setWaveformSignal:[SSignal single:waveform]];
    } else if (_mediaIsAvailable) {
        if (_audioMedia != nil) {
            _updatedWaveform = true;
            
            NSString *localFilePath = _audioMedia.localFilePath;
            [_sliderModel setWaveformSignal:[TGAudioWaveformSignal audioWaveformForFileAtPath:localFilePath duration:_duration]];
        } else if (_documentMedia != nil) {
            _updatedWaveform = true;
            
            NSString *localFilePath = nil;
            if (_documentMedia.documentId != 0) {
                localFilePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:_documentMedia.documentId] stringByAppendingPathComponent:[_documentMedia safeFileName]];
            } else {
                localFilePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:_documentMedia.localDocumentId] stringByAppendingPathComponent:[_documentMedia safeFileName]];
            }
            [_sliderModel setWaveformSignal:[TGAudioWaveformSignal audioWaveformForFileAtPath:localFilePath duration:_duration]];
        }
    }
}

@end
