#import "TGAudioWebpageFooterModel.h"

#import "TGDocumentMessageIconModel.h"
#import "TGMusicPlayer.h"
#import "TGAudioSliderViewModel.h"

#import "TGWebPageMediaAttachment.h"

#import "TGMessageImageView.h"

#import "TGDocumentMessageIconView.h"

#import "TGModernViewContext.h"
#import "TGAudioSliderView.h"

#import "TGTelegraph.h"

#import "TGPreparedLocalDocumentMessage.h"
#import "TGAudioWaveformSignal.h"

@interface TGAudioWebpageFooterModel () <TGMessageImageViewDelegate, TGAudioSliderViewDelegate> {
    TGWebPageMediaAttachment *_webPage;
    bool _hasViews;
    bool _incoming;
    int32_t _mid;
    
    int32_t _duration;
    int32_t _size;
    NSString *_fileType;
    
    TGDocumentMessageIconModel *_iconModel;
    
    TGAudioSliderViewModel *_sliderModel;
    
    TGMusicPlayerStatus *_status;
    
    bool _updatedWaveform;
    
    id<SDisposable> _playingAudioMessageIdDisposable;
    
    bool _isSecret;
    bool _wasPausedBeforeScrubbing;
}

@end

@implementation TGAudioWebpageFooterModel

- (instancetype)initWithContext:(TGModernViewContext *)context messageId:(int32_t)messageId incoming:(bool)incoming webPage:(TGWebPageMediaAttachment *)webPage hasViews:(bool)hasViews {
    self = [super initWithContext:context incoming:incoming webpage:webPage];
    if (self != nil) {
        _webPage = webPage;
        _incoming = incoming;
        _hasViews = hasViews;
        _mid = messageId;
        
        TGDocumentMediaAttachment *document = webPage.document;
        
        _iconModel = [[TGDocumentMessageIconModel alloc] init];
        _iconModel.skipDrawInContext = true;
        _iconModel.frame = CGRectMake(0.0f, 0.0f, 37.0f, 37.0f);
        _iconModel.incoming = incoming;
        _iconModel.diameter = 37.0f;
        [self addSubmodel:_iconModel];
        
        for (id attribute in document.attributes) {
            if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                _duration = ((TGDocumentAttributeAudio *)attribute).duration;
            }
        }
        
        _size = document.size;
        
        _sliderModel = [[TGAudioSliderViewModel alloc] init];
        _sliderModel.audioId = document.documentId;
        _sliderModel.localAudioId = document.localDocumentId;
        _sliderModel.incoming = incoming;
        _sliderModel.duration = _duration;
        [self addSubmodel:_sliderModel];
        
        [self updateButtonText:false];
        
        bool listenedStatus = true;
        _sliderModel.listenedStatus = listenedStatus;
        
        [self updateWaveform];
    }
    return self;
}

- (void)updateButtonText:(bool)animated
{
    if (self.mediaProgressVisible)
    {
        _sliderModel.manualPositionAdjustmentEnabled = false;
    }
    else
    {
        _sliderModel.viewUserInteractionDisabled = _status == nil;
        
        [_sliderModel setStatus:_status];
        
        _sliderModel.manualPositionAdjustmentEnabled = _status != nil;
    }
    
    if (self.mediaProgressVisible)
    {
        [_iconModel setOverlayType:TGMessageImageViewOverlayProgress animated:false];
        [_iconModel setProgress:self.mediaProgress animated:animated];
    }
    else if (!self.mediaIsAvailable)
    {
        [_iconModel setOverlayType:TGMessageImageViewOverlayDownload animated:false];
        [_iconModel setProgress:0.0f animated:false];
    }
    else
    {
        [_iconModel setOverlayType:!(_status == nil || _status.paused) ? TGMessageImageViewOverlayPauseMedia : TGMessageImageViewOverlayPlayMedia animated:animated];
    }
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    _iconModel.parentOffset = itemPosition;
    [_iconModel bindViewToContainer:container viewStorage:viewStorage];
    ((TGDocumentMessageIconView *)[_iconModel boundView]).delegate = self;

    _sliderModel.parentOffset = itemPosition;
    [_sliderModel bindViewToContainer:container viewStorage:viewStorage];
    
    [self subscribeStatus];
}

- (void)subscribeStatus {
    [_playingAudioMessageIdDisposable dispose];
    if (self.context.playingAudioMessageStatus != nil)
    {
        __weak TGAudioWebpageFooterModel *weakSelf = self;
        _playingAudioMessageIdDisposable = [self.context.playingAudioMessageStatus startWithNext:^(TGMusicPlayerStatus *status)
        {
            __strong TGAudioWebpageFooterModel *strongSelf = weakSelf;
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

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage {
    [super bindViewToContainer:container viewStorage:viewStorage];
    ((TGDocumentMessageIconView *)[_iconModel boundView]).delegate = self;
    
    ((TGAudioSliderView *)[_sliderModel boundView]).delegate = self;
    
    [self subscribeStatus];
}

- (void)unbindView:(TGModernViewStorage *)viewStorage {
    UIView *iconView = [_iconModel boundView];
    ((TGDocumentMessageIconView *)iconView).delegate = nil;
    
    ((TGAudioSliderView *)[_sliderModel boundView]).delegate = nil;
    
    [super unbindView:viewStorage];
    
    [_playingAudioMessageIdDisposable dispose];
    _playingAudioMessageIdDisposable = nil;
}

- (void)updateSpecialViewsPositions:(CGPoint)itemPosition
{
    _iconModel.parentOffset = itemPosition;
    _sliderModel.parentOffset = itemPosition;
}

- (CGSize)contentSizeForContainerSize:(CGSize)__unused containerSize contentSize:(CGSize)__unused topContentSize infoWidth:(CGFloat)__unused infoWidth needsContentsUpdate:(bool *)__unused dneedsContentsUpdate
{
    return CGSizeMake(MAX(160, MIN(205, _duration * 30)), 51.0f);
}

- (bool)preferWebpageSize
{
    return false;
}

- (void)layoutContentInRect:(CGRect)rect bottomInset:(CGFloat *)__unused bottomInset
{
    rect.origin.y -= 9.0f;
    
    _iconModel.frame = CGRectMake(rect.origin.x + (_incoming ? 14.0f : 9.0f), rect.origin.y + 12.0f, 37.0f, 37.0f);
    
    CGFloat trackOriginX = CGRectGetMaxX(_iconModel.frame) + 5.0f;
    CGRect sliderFrame = CGRectMake(trackOriginX, _iconModel.frame.origin.y - 3.0f, CGRectGetMaxX(rect) - trackOriginX - 13.0f + (_incoming ? 5.0f : 0.0f), 14.0f);
    _sliderModel.frame = sliderFrame;
}

- (bool)webpageContentsActivated
{
    return false;
}

- (void)setMediaIsAvailable:(bool)mediaIsAvailable {
    //bool wasAvailable = self.mediaIsAvailable;
    
    [super setMediaIsAvailable:mediaIsAvailable];
    
    [self updateButtonText:false];
    
    [self updateWaveform];
}

- (void)updateMediaProgressVisible:(bool)mediaProgressVisible mediaProgress:(float)mediaProgress animated:(bool)animated {
    bool progressWasVisible = self.mediaProgressVisible;
    float previousProgress = self.mediaProgress;
    
    [super updateMediaProgressVisible:mediaProgressVisible mediaProgress:mediaProgress animated:animated];
    
    [self updateButtonText:((progressWasVisible && !self.mediaProgressVisible) || (self.mediaProgressVisible && ABS(self.mediaProgress - previousProgress) > FLT_EPSILON)) && animated];
}

- (TGWebpageFooterModelAction)webpageActionAtPoint:(CGPoint)__unused point
{
    if (!self.mediaIsAvailable) {
        if (self.mediaProgressVisible) {
            return TGWebpageFooterModelActionCancel;
        } else {
            return TGWebpageFooterModelActionDownload;
        }
    }
    return TGWebpageFooterModelActionCustom;
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

- (void)updateWaveform {
    TGAudioWaveform *waveform = nil;
    TGDocumentMediaAttachment *_documentMedia = _webPage.document;
    
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
    } else if (self.mediaIsAvailable) {
        if (_documentMedia != nil) {
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

- (void)updateMessageId:(int32_t)messageId {
    _mid = messageId;
}

- (void)activateMedia
{
    if (self.mediaIsAvailable)
    {
        if (_status != nil && !_status.paused)
        {
            if (self.context.pauseAudioMessage)
                self.context.pauseAudioMessage();
        }
        else if (_status != nil && _status.paused)
        {
            if (self.context.resumeAudioMessage)
                self.context.resumeAudioMessage();
        }
        else
        {
            if (self.context.playAudioMessageId)
                self.context.playAudioMessageId(_mid);
        }
    }
    else
        [self.context.companionHandle requestAction:@"mediaDownloadRequested" options:@{@"mid": @(_mid)}];
}

- (void)cancelMediaDownload
{
    [self.context.companionHandle requestAction:@"mediaProgressCancelRequested" options:@{@"mid": @(_mid)}];
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

- (bool)activateWebpageContents {
    if (self.mediaProgressVisible) {
        [self cancelMediaDownload];
    } else {
        [self activateMedia];
    }
    
    return true;
}

@end
