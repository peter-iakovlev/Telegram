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

#import "TGReusableLabel.h"

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
    
    TGModernTextViewModel *_textModel;
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

static CTFontRef textFontForSize(CGFloat size)
{
    static CTFontRef font = NULL;
    static int cachedSize = 0;
    
    if ((int)size != cachedSize || font == NULL)
    {
        font = TGCoreTextSystemFontOfSize(size);
        cachedSize = (int)size;
    }
    
    return font;
}

@implementation TGAudioMessageViewModel

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
        
        static TGTelegraphConversationMessageAssetsSource *assetsSource = nil;
        static dispatch_once_t onceToken2;
        dispatch_once(&onceToken2, ^
        {
            assetsSource = [TGTelegraphConversationMessageAssetsSource instance];
        });

        
        _iconModel = [[TGDocumentMessageIconModel alloc] init];
        _iconModel.skipDrawInContext = true;
        _iconModel.frame = CGRectMake(0.0f, 0.0f, 37.0f, 37.0f);
        _iconModel.incoming = _incomingAppearance;
        _iconModel.diameter = 37.0f;
        [self addSubmodel:_iconModel];
        
        _textModel = [[TGModernTextViewModel alloc] initWithText:_documentMedia.caption font:textFontForSize(TGGetMessageViewModelLayoutConstants()->textFontSize)];
        _textModel.textColor = [assetsSource messageTextColor];
        if (message.isBroadcast)
            _textModel.additionalTrailingWidth += 10.0f;
        [_contentModel addSubmodel:_textModel];
        
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
    
    if (!TGStringCompare(_textModel.text, _documentMedia.caption)) {
        _textModel.text = _documentMedia.caption;
        if (sizeUpdated != NULL)
            *sizeUpdated = true;
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
                [strongSelf updateButtonText:false];
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
    
    if (_textModel.text.length != 0 && ![_textModel.text isEqualToString:@" "]) {
        CGRect textFrame = _textModel.frame;
        
        CGFloat textInset = 48.0f;
        textFrame.origin = CGPointMake(1, textInset + headerHeight);
        _textModel.frame = textFrame;
        headerHeight += textFrame.size.height;
    } else {
        _textModel.frame = CGRectZero;
    }
}

- (CGSize)contentSizeForContainerSize:(CGSize)__unused containerSize needsContentsUpdate:(bool *)__unused needsContentsUpdate infoWidth:(CGFloat)infoWidth
{
    CGSize textSize = CGSizeZero;
    
    int layoutFlags = TGReusableLabelLayoutMultiline | TGReusableLabelLayoutHighlightLinks;
    
    if (_context.commandsEnabled)
        layoutFlags |= TGReusableLabelLayoutHighlightCommands;
    
    bool updateContents = [_textModel layoutNeedsUpdatingForContainerSize:containerSize additionalTrailingWidth:infoWidth layoutFlags:layoutFlags];
    _textModel.layoutFlags = layoutFlags;
    _textModel.additionalTrailingWidth = infoWidth;
    if (updateContents)
        [_textModel layoutForContainerSize:containerSize];
    
    if (needsContentsUpdate != NULL && updateContents)
        *needsContentsUpdate = updateContents;
    
    CGFloat width = MAX(160, MIN(205, _duration * 30));
    CGFloat height = 50.0f;
    
    if (_textModel.text.length != 0 && ![_textModel.text isEqualToString:@" "]) {
        textSize = _textModel.frame.size;
        textSize.height += 10.0f;
        if (infoWidth < FLT_EPSILON) {
            height -= 10.0f;
        }
    } else {
        height += (infoWidth > (width - 80.0f) ? 12.0f : 0.0f);
        if (infoWidth < FLT_EPSILON) {
            height -= 2.0f;
        }
    }
        
    return CGSizeMake(width, height + textSize.height);
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
    if (_textModel.frame.size.height > FLT_EPSILON && point.y >= CGRectGetMinY(_textModel.frame)) {
        return false;
    }
    
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
                if (_viaUser != nil && [_forwardedHeaderModel linkAtPoint:CGPointMake(point.x - _forwardedHeaderModel.frame.origin.x, point.y - _forwardedHeaderModel.frame.origin.y) regionData:NULL]) {
                    [_context.companionHandle requestAction:@"useContextBot" options:@{@"uid": @((int32_t)_viaUser.uid), @"username": _viaUser.userName == nil ? @"" : _viaUser.userName}];
                } else {
                    if (TGPeerIdIsChannel(_forwardedPeerId)) {
                        [_context.companionHandle requestAction:@"peerAvatarTapped" options:@{@"peerId": @(_forwardedPeerId), @"messageId": @(_forwardedMessageId)}];
                    } else {
                        [_context.companionHandle requestAction:@"userAvatarTapped" options:@{@"uid": @((int32_t)_forwardedPeerId)}];
                    }
                }
            }
            else if (_viaUserModel != nil && CGRectContainsPoint(_viaUserModel.frame, point)) {
                [_context.companionHandle requestAction:@"useContextBot" options:@{@"uid": @((int32_t)_viaUser.uid), @"username": _viaUser.userName == nil ? @"" : _viaUser.userName}];
            }
            else if (_replyHeaderModel && CGRectContainsPoint(_replyHeaderModel.frame, point))
                [_context.companionHandle requestAction:@"navigateToMessage" options:@{@"mid": @(_replyMessageId), @"sourceMid": @(_mid)}];
            else if (_textModel.frame.size.height <= FLT_EPSILON || point.y < CGRectGetMinY(_textModel.frame)) {
                if (_status == nil) {
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
                localFilePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:_documentMedia.documentId version:_documentMedia.version] stringByAppendingPathComponent:[_documentMedia safeFileName]];
            } else {
                localFilePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:_documentMedia.localDocumentId version:_documentMedia.version] stringByAppendingPathComponent:[_documentMedia safeFileName]];
            }
            [_sliderModel setWaveformSignal:[TGAudioWaveformSignal audioWaveformForFileAtPath:localFilePath duration:_duration]];
        }
    }
}

@end
