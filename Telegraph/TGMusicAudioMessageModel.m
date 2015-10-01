#import "TGMusicAudioMessageModel.h"

#import "TGPeerIdAdapter.h"

#import "TGDocumentMessageIconModel.h"

#import "TGDocumentMessageIconView.h"

#import "TGMessageImageView.h"
#import "TGModernLabelViewModel.h"

#import "TGFont.h"

#import "TGMessage.h"

#import "TGModernFlatteningViewModel.h"
#import "TGDoubleTapGestureRecognizer.h"
#import "TGModernTextViewModel.h"
#import "TGReplyHeaderModel.h"

#import "TGViewController.h"

@interface TGMusicAudioMessageModel () <TGMessageImageViewDelegate>
{
    TGDocumentMessageIconModel *_iconModel;
    TGModernLabelViewModel *_titleModel;
    TGModernLabelViewModel *_performerModel;
    
    bool _mediaIsAvailable;
    bool _progressVisible;
    float _progress;
    
    bool _isCurrent;
    bool _isPlaying;
    
    CGFloat _headerHeight;
    
    id<SDisposable> _playingAudioMessageIdDisposable;
}

@end

@implementation TGMusicAudioMessageModel

- (instancetype)initWithMessage:(TGMessage *)message authorPeer:(id)authorPeer context:(TGModernViewContext *)context
{
    self = [super initWithMessage:message authorPeer:authorPeer context:context];
    if (self != nil)
    {
        _iconModel = [[TGDocumentMessageIconModel alloc] init];
        _iconModel.skipDrawInContext = true;
        _iconModel.frame = CGRectMake(0.0f, 0.0f, 60.0f, 60.0f);
        _iconModel.incoming = _incomingAppearance;
        [self addSubmodel:_iconModel];
        
        static UIColor *incomingNameColor = nil;
        static UIColor *outgoingNameColor = nil;
        static UIColor *incomingSizeColor = nil;
        static UIColor *outgoingSizeColor = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            incomingNameColor = [UIColor blackColor];
            outgoingNameColor = UIColorRGB(0x3faa3c);
            incomingSizeColor = UIColorRGB(0x999999);
            outgoingSizeColor = UIColorRGB(0x3faa3c);
        });
        
        NSString *performer = @"";
        NSString *title = @"";
        NSString *fileName = @"";
        for (id attachment in message.mediaAttachments)
        {
            if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
            {
                fileName = ((TGDocumentMediaAttachment *)attachment).fileName;
                
                for (id attribute in ((TGDocumentMediaAttachment *)attachment).attributes)
                {
                    if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]])
                    {
                        TGDocumentAttributeAudio *audioAttribute = attribute;
                        performer = audioAttribute.performer;
                        title = audioAttribute.title;
                        
                        break;
                    }
                }
                break;
            }
        }
        
        if (title.length == 0)
        {
            title = fileName;
            if (title.length == 0)
                title = @"Unknown Track";
        }
        
        if (performer.length == 0)
            performer = @"Unknown Artist";
        
        CGFloat maxWidth = [TGViewController hasLargeScreen] ? 170.0f : 150.0f;
        
        _titleModel = [[TGModernLabelViewModel alloc] initWithText:title textColor:_incomingAppearance ? incomingNameColor : outgoingNameColor font:TGCoreTextSystemFontOfSize(16.0f) maxWidth:maxWidth truncateInTheMiddle:false];
        [_contentModel addSubmodel:_titleModel];
        
        _performerModel = [[TGModernLabelViewModel alloc] initWithText:performer textColor:_incomingAppearance ? incomingSizeColor : outgoingSizeColor font:TGCoreTextSystemFontOfSize(13.0f) maxWidth:maxWidth truncateInTheMiddle:false];
        [_contentModel addSubmodel:_performerModel];
    }
    return self;
}

- (void)updateMediaAvailability:(bool)mediaIsAvailable viewStorage:(TGModernViewStorage *)__unused viewStorage
{
    [super updateMediaAvailability:mediaIsAvailable viewStorage:viewStorage];
    
    _mediaIsAvailable = mediaIsAvailable;
    
    [self updateImageOverlay:false];
}

- (void)updateProgress:(bool)progressVisible progress:(float)progress viewStorage:(TGModernViewStorage *)viewStorage animated:(bool)animated
{
    [super updateProgress:progressVisible progress:progress viewStorage:viewStorage animated:animated];
    
    bool progressWasVisible = _progressVisible;
    float previousProgress = _progress;
    
    _progress = progress;
    _progressVisible = progressVisible;
    
    [self updateImageOverlay:((progressWasVisible && !_progressVisible) || (_progressVisible && ABS(_progress - previousProgress) > FLT_EPSILON)) && animated];
}

- (void)updateImageOverlay:(bool)animated
{
    //_iconModel.viewUserInteractionDisabled = (_incoming && _mediaIsAvailable) || !_progressVisible;
    
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
        [_iconModel setOverlayType:_isPlaying ? TGMessageImageViewOverlayPauseMedia : TGMessageImageViewOverlayPlayMedia animated:animated];
    }
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage sizeUpdated:(bool *)sizeUpdated
{
    [super updateMessage:message viewStorage:viewStorage sizeUpdated:sizeUpdated];
}

- (void)layoutContentForHeaderHeight:(CGFloat)headerHeight
{
    _headerHeight = headerHeight;
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    [super bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:itemPosition];
    
    [_iconModel bindViewToContainer:container viewStorage:viewStorage];
    [_iconModel boundView].frame = CGRectOffset([_iconModel boundView].frame, itemPosition.x, itemPosition.y);
    ((TGDocumentMessageIconView *)[_iconModel boundView]).delegate = self;
    
    [_playingAudioMessageIdDisposable dispose];
    if (_context.playingAudioMessageId != nil)
    {
        __weak TGMusicAudioMessageModel *weakSelf = self;
        _playingAudioMessageIdDisposable = [_context.playingAudioMessageId startWithNext:^(NSNumber *nPacked)
        {
            __strong TGMusicAudioMessageModel *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                int64_t packed = (int64_t)[nPacked longLongValue];
                int32_t mid = (packed >> 32) & 0xffffffff;
                int paused = packed & 1;
                
                bool isCurrent = mid == strongSelf->_mid;
                bool isPlaying = isCurrent && (paused == 0);
                
                if (isPlaying != strongSelf->_isPlaying || isCurrent != strongSelf->_isCurrent)
                {
                    strongSelf->_isPlaying = isPlaying;
                    strongSelf->_isCurrent = isCurrent;
                    [strongSelf updateImageOverlay:false];
                }
            }
        }];
    }
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    ((TGDocumentMessageIconView *)[_iconModel boundView]).delegate = self;
    
    [_playingAudioMessageIdDisposable dispose];
    if (_context.playingAudioMessageId != nil)
    {
        __weak TGMusicAudioMessageModel *weakSelf = self;
        _playingAudioMessageIdDisposable = [_context.playingAudioMessageId startWithNext:^(NSNumber *nPacked)
        {
            __strong TGMusicAudioMessageModel *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                int64_t packed = (int64_t)[nPacked longLongValue];
                int32_t mid = (packed >> 32) & 0xffffffff;
                int paused = packed & 1;
                
                bool isCurrent = mid == strongSelf->_mid;
                bool isPlaying = isCurrent && (paused == 0);
                
                if (isPlaying != strongSelf->_isPlaying || isCurrent != strongSelf->_isCurrent)
                {
                    strongSelf->_isPlaying = isPlaying;
                    strongSelf->_isCurrent = isCurrent;
                    [strongSelf updateImageOverlay:false];
                }
            }
        }];
    }
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    [_playingAudioMessageIdDisposable dispose];
    
    UIView *iconView = [_iconModel boundView];
    ((TGDocumentMessageIconView *)iconView).delegate = nil;
    
    [super unbindView:viewStorage];
    
    _isPlaying = false;
    _isCurrent = false;
    [self updateImageOverlay:false];
}

- (CGSize)contentSizeForContainerSize:(CGSize)__unused containerSize needsContentsUpdate:(bool *)__unused needsContentsUpdate hasDate:(bool)__unused hasDate hasViews:(bool)__unused hasViews
{
    CGFloat additionalWidth = 0.0f;
    if (_performerModel.frame.size.width < _titleModel.frame.size.width)
        additionalWidth += MAX(0.0f, 30.0f - _titleModel.frame.size.width - _performerModel.frame.size.width);
    
    return CGSizeMake(57.0f + 10.0f + MAX(_titleModel.frame.size.width, _performerModel.frame.size.width) + 30.0f, 59.0f);
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    [super layoutForContainerSize:containerSize];
    
    _iconModel.frame = CGRectMake(_contentModel.frame.origin.x - 5.0f, _headerHeight + _contentModel.frame.origin.y + 2.0f, _iconModel.frame.size.width, _iconModel.frame.size.height);
    _titleModel.frame = CGRectMake(57.0f, _headerHeight + 10.0f, _titleModel.frame.size.width, _titleModel.frame.size.height);
    _performerModel.frame = CGRectMake(57.0f, _headerHeight + 31.0f, _performerModel.frame.size.width, _performerModel.frame.size.height);
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

- (void)activateMedia
{
    if (_mediaIsAvailable)
    {
        if (_isPlaying)
        {
            if (_context.pauseAudioMessage)
                _context.pauseAudioMessage();
        }
        else if (_isCurrent)
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

- (int)gestureRecognizer:(TGDoubleTapGestureRecognizer *)__unused recognizer shouldFailTap:(CGPoint)__unused point
{
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
            else
                [self activateMedia];
        }
    }
}

@end
