#import "TGRoundVideoWebpageFooterModel.h"

#import "TGWebPageMediaAttachment.h"

#import "TGModernTextViewModel.h"
#import "TGSignalImageViewModel.h"
#import "TGModernFlatteningViewModel.h"
#import "TGModernImageViewModel.h"
#import "TGModernTextViewModel.h"
#import "TGModernLabelViewModel.h"
#import "TGRoundMessageRingViewModel.h"
#import "TGRoundMessageTimeViewModel.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGSharedMediaUtils.h"
#import "TGSharedMediaSignals.h"
#import "TGSharedPhotoSignals.h"
#import "TGSharedFileSignals.h"

#import "TGReusableLabel.h"

#import "TGMessage.h"

#import "TGImageManager.h"

#import "TGPreparedLocalDocumentMessage.h"
#import "TGTelegraph.h"

#import "TGViewController.h"

#import "TGAppDelegate.h"

#import "TGTextCheckingResult.h"

#import "TGAnimationUtils.h"

#import "TGSignalImageView.h"

#import "TGTelegraphConversationMessageAssetsSource.h"

#import "TGVideoMessagePIPController.h"

@interface TGRoundVideoWebpageFooterModel ()
{
    TGWebPageMediaAttachment *_webPage;
    TGModernTextViewModel *_siteModel;
    TGModernTextViewModel *_titleModel;
    TGModernTextViewModel *_textModel;
    TGSignalImageViewModel *_imageViewModel;
    TGRoundMessageTimeViewModel *_durationLabelModel;
    TGRoundMessageRingViewModel *_ringModel;
    TGModernImageViewModel *_muteButtonModel;
    
    NSString *_imageDataInvalidationUrl;
    void (^_imageDataInvalidationBlock)();
    
    bool _activatedMedia;
    
    int32_t _mid;
    bool _muted;
    
    int32_t _duration;
    id<SDisposable> _playingVideoMessageIdDisposable;
    TGMusicPlayerStatus *_status;
}

@end

@implementation TGRoundVideoWebpageFooterModel

static CTFontRef titleFont()
{
    static CTFontRef font = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        font = TGCoreTextMediumFontOfSize(14.0f);
    });
    
    return font;
}

static UIFont *durationFont()
{
    static UIFont *font = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        font = TGSystemFontOfSize(11.0f);
    });
    
    return font;
}

- (instancetype)initWithContext:(TGModernViewContext *)context messageId:(int32_t)messageId incoming:(bool)incoming webPage:(TGWebPageMediaAttachment *)webPage
{
    self = [super initWithContext:context incoming:incoming webpage:webPage];
    if (self != nil)
    {
        _mid = messageId;
        _webPage = webPage;
        
        if (webPage.siteName.length != 0)
        {
            _siteModel = [[TGModernTextViewModel alloc] initWithText:webPage.siteName font:titleFont()];
            _siteModel.textColor = [TGWebpageFooterModel colorForAccentText:incoming];
            [self addSubmodel:_siteModel];
        }
        
        if (webPage.document != nil) {
            for (id attribute in webPage.document.attributes) {
                if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                    _duration = ((TGDocumentAttributeVideo *)attribute).duration;
                }
            }
        }
        
        NSString *title = webPage.title;
        if (title.length == 0)
            title = webPage.author;
        
        if (title.length != 0)
        {
            _titleModel = [[TGModernTextViewModel alloc] initWithText:title font:titleFont()];
            _titleModel.layoutFlags = TGReusableLabelLayoutMultiline;
            _titleModel.maxNumberOfLines = 4;
            _titleModel.textColor = [UIColor blackColor];
            [self addSubmodel:_titleModel];
        }
        

        CGSize imageSize = CGSizeZero;
        
        bool hasSize = false;
        
        for (id attribute in webPage.document.attributes) {
            if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]]) {
                imageSize = ((TGDocumentAttributeImageSize *)attribute).size;
                hasSize = imageSize.width > 1.0f && imageSize.height >= 1.0f;
                break;
            } else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                imageSize = ((TGDocumentAttributeVideo *)attribute).size;
                hasSize = imageSize.width > 1.0f && imageSize.height >= 1.0f;
                break;
            }
        }
        
        _imageDataInvalidationUrl = [webPage.document.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
        
        if (imageSize.width > FLT_EPSILON)
        {
            CGRect contentFrame = CGRectZero;
            CGSize currentFitSize = CGSizeMake(200.0f, 200.0f);
            imageSize = currentFitSize;
            contentFrame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
            
            _imageViewModel = [[TGSignalImageViewModel alloc] init];
            _imageViewModel.viewUserInteractionDisabled = false;
            _imageViewModel.transitionContentRect = contentFrame;
            
            CGFloat scale = TGScreenScaling();
            _imageViewModel.inlineVideoSize = CGSizeMake(200.0f * scale, 200.0f * scale);
            _imageViewModel.inlineVideoCornerRadius = 100.0f;
            _imageViewModel.inlineVideoInsets = UIEdgeInsetsZero;
            
            NSString *key = [[NSString alloc] initWithFormat:@"webpage-animation-thumbnail-%" PRId64 "", webPage.document.documentId];
            __weak TGRoundVideoWebpageFooterModel *weakSelf = self;
            _imageDataInvalidationBlock = ^{
                __strong TGRoundVideoWebpageFooterModel *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf->_imageViewModel reload];
                }
            };
            
            CGFloat radius = 100.0f * TGScreenScaling();
            [_imageViewModel setSignalGenerator:^SSignal *{
                return [TGSharedFileSignals squareFileThumbnail:webPage.document ofSize:imageSize threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:radius]];
            } identifier:key];
            
            _imageViewModel.frame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
            _imageViewModel.skipDrawInContext = true;
            [_imageViewModel setManualProgress:true];
            [_imageViewModel setNone];
            
            [self addSubmodel:_imageViewModel];
            
            _muteButtonModel = [[TGModernImageViewModel alloc] init];
            _muteButtonModel.accountForTransform = true;
            _muteButtonModel.skipDrawInContext = true;
            [_muteButtonModel setImage:[[TGTelegraphConversationMessageAssetsSource instance] systemUnmuteButton]];
            [self addSubmodel:_muteButtonModel];
            
            [self _updateMuted:true];
            
            _ringModel = [[TGRoundMessageRingViewModel alloc] init];
            _ringModel.viewUserInteractionDisabled = true;
            [self addSubmodel:_ringModel];
            
            UIColor *labelColor = nil;
            if (incoming) {
                labelColor = UIColorRGBA(0x525252, 0.6f);
            } else {
                labelColor = UIColorRGBA(0x008c09, 0.8f);
            }
            
            _durationLabelModel = [[TGRoundMessageTimeViewModel alloc] initWithFont:durationFont() textColor:labelColor];
            [_durationLabelModel layoutForContainerSize:CGSizeMake(200.0f, 200.0f)];
            [self addSubmodel:_durationLabelModel];
            
            [self updateDurationString];
        }
    }
    return self;
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    _imageViewModel.parentOffset = itemPosition;
    [_imageViewModel bindViewToContainer:container viewStorage:viewStorage];
    
    _ringModel.parentOffset = itemPosition;
    [_ringModel bindViewToContainer:container viewStorage:viewStorage];
    
    _muteButtonModel.parentOffset = itemPosition;
    [_muteButtonModel bindViewToContainer:container viewStorage:viewStorage];
    
    _durationLabelModel.parentOffset = itemPosition;
    [_durationLabelModel bindViewToContainer:container viewStorage:viewStorage];
    
    if (self.mediaIsAvailable && self.boundToContainer) {
        [self activateWebpageContents];
    }
    
    [self subscribeStatus];
}

- (void)unbindView:(TGModernViewStorage *)viewStorage {
    [super unbindView:viewStorage];
    
    [self _updateMuted:true];
    
    [_imageViewModel setVideoPathSignal:nil];
    _activatedMedia = false;
    [self updateOverlayAnimated:false];
    
    [_playingVideoMessageIdDisposable dispose];
    _playingVideoMessageIdDisposable = nil;
}

- (void)updateMessageId:(int32_t)messageId
{
    _mid = messageId;
}

- (void)_updateMuted:(bool)muted
{
    if (muted == _muted)
        return;
    
    _muted = muted;
    
    if (_muteButtonModel.boundView != nil)
    {
        UIView *muteButtonView = _muteButtonModel.boundView;
        [muteButtonView.layer removeAllAnimations];
                
        if ((muteButtonView.transform.a < 0.3f || muteButtonView.transform.a > 1.0f) || muteButtonView.alpha < FLT_EPSILON)
        {
            muteButtonView.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
            muteButtonView.alpha = 0.0f;
        }
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | 7 << 16 animations:^
        {
            muteButtonView.transform = muted ? CGAffineTransformIdentity : CGAffineTransformMakeScale(0.001f, 0.001f);
        } completion:nil];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            muteButtonView.alpha = muted ? 1.0f : 0.0f;
        } completion:nil];
    }
    else
    {
        [_muteButtonModel setAlpha:_muted ? 1.0f : 0.0f];
    }
}

- (void)updateSpecialViewsPositions:(CGPoint)itemPosition
{
    _imageViewModel.parentOffset = itemPosition;
    _ringModel.parentOffset = itemPosition;
    _muteButtonModel.parentOffset = itemPosition;
    _durationLabelModel.parentOffset = itemPosition;
}

- (CGSize)contentSizeForContainerSize:(CGSize)containerSize contentSize:(CGSize)topContentSize infoWidth:(CGFloat)infoWidth needsContentsUpdate:(bool *)needsContentsUpdate
{
    CGSize contentContainerSize = CGSizeMake(MAX(containerSize.width - 10.0f - 20.0f, topContentSize.width - 10.0f - 20.0f), containerSize.height);
    
    CGFloat imageInset = 0.0f;
    if (_imageViewModel.frame.size.width >= 180.0f)
    {
        contentContainerSize.width = _imageViewModel.frame.size.width;
    }
    
    CGSize textContainerSize = CGSizeMake(contentContainerSize.width - imageInset, contentContainerSize.height);
    
    if (_titleModel == nil && _textModel == nil) {
        _siteModel.additionalTrailingWidth = infoWidth;
    } else if (_textModel == nil && _imageViewModel == nil) {
        _titleModel.additionalTrailingWidth = infoWidth;
    } else {
        _textModel.additionalTrailingWidth = infoWidth;
    }
    
    if (_siteModel != nil && [_siteModel layoutNeedsUpdatingForContainerSize:textContainerSize])
    {
        if (needsContentsUpdate)
            *needsContentsUpdate = true;
        [_siteModel layoutForContainerSize:textContainerSize];
    }
    
    if ([_titleModel layoutNeedsUpdatingForContainerSize:textContainerSize])
    {
        if (needsContentsUpdate)
            *needsContentsUpdate = true;
        [_titleModel layoutForContainerSize:textContainerSize];
    }
    
    CGSize adjustedTextContainerSize = contentContainerSize;
    if (_textModel != nil && [_textModel layoutNeedsUpdatingForContainerSize:adjustedTextContainerSize])
    {
        if (needsContentsUpdate)
            *needsContentsUpdate = true;
        NSInteger numberOfLines = 3;
        numberOfLines = MAX(0, numberOfLines - (NSInteger)_titleModel.measuredNumberOfLines);
        numberOfLines = 0;
        
        if (numberOfLines != 0)
            _textModel.linesInset = [[TGModernTextViewLinesInset alloc] initWithNumberOfLinesToInset:numberOfLines inset:60.0f];
        else
            _textModel.linesInset = nil;
        [_textModel layoutForContainerSize:adjustedTextContainerSize];
    }
    
    CGSize contentSize = CGSizeZero;
    
    contentSize.height += 2.0 + 2.0f;
    
    if (_siteModel != nil)
    {
        contentSize.width = MAX(contentSize.width, _siteModel.frame.size.width + 10.0f + imageInset);
        contentSize.height += _siteModel.frame.size.height;
        
        if (_titleModel == nil && _textModel == nil && _imageViewModel == nil) {
            contentSize.height += 14.0f;
        }
    }
    
    if (_titleModel != nil)
    {
        if (_siteModel != nil)
            contentSize.height += 3.0f;
        contentSize.width = MAX(contentSize.width, _titleModel.frame.size.width + 10.0f + imageInset);
        contentSize.height += _titleModel.frame.size.height;
    }
    
    if (_textModel != nil)
    {
        if (_siteModel != nil || _titleModel != nil)
            contentSize.height += 3.0f;
        contentSize.width = MAX(contentSize.width, _textModel.frame.size.width + 10.0f);
        contentSize.height += _textModel.frame.size.height;
    }
    
    if (_imageViewModel != nil)
    {
        if (_siteModel != nil || _titleModel != nil || _textModel != nil) {
            contentSize.height += 9.0f;
        } else {
            contentSize.height += 17.0f;
        }
        
        contentSize.width = MAX(contentSize.width, _imageViewModel.frame.size.width + 10.0f);
        contentSize.height += _imageViewModel.frame.size.height + 6.0f;
    }
    return contentSize;
}

- (bool)preferWebpageSize
{
    return _imageViewModel.frame.size.width >= 190.0f;
}

- (bool)fitContentToWebpage {
    return [_webPage.pageType isEqualToString:@"game"];
}

- (TGWebpageFooterModelAction)webpageActionAtPoint:(CGPoint)point
{
    bool result = _imageViewModel != nil && CGRectContainsPoint(_imageViewModel.frame, point);
    
    if (result) {
        if (!self.mediaIsAvailable) {
            return self.mediaProgressVisible ? TGWebpageFooterModelActionCancel : TGWebpageFooterModelActionDownload;
        } else {
            return TGWebpageFooterModelActionPlay;
        }
        
        return TGWebpageFooterModelActionGeneric;
    }
    
    return TGWebpageFooterModelActionNone;
}

- (void)activateMediaPlayback
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
}

- (NSString *)linkAtPoint:(CGPoint)__unused point regionData:(NSArray *__autoreleasing *)__unused regionData
{
    return nil;
}

- (UIView *)referenceViewForImageTransition
{
    return _imageViewModel.boundView;
}

- (void)setMediaVisible:(bool)__unused mediaVisible
{
}

- (void)layoutContentInRect:(CGRect)rect bottomInset:(CGFloat *)bottomInset
{
    CGFloat currentOffset = -4.0f;
    _siteModel.frame = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + currentOffset, _siteModel.frame.size.width, _siteModel.frame.size.height);
    
    if (_siteModel != nil)
        currentOffset += 2.0f + _siteModel.frame.size.height;
    
    _titleModel.frame = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + currentOffset, _titleModel.frame.size.width, _titleModel.frame.size.height);
    if (_titleModel != nil)
        currentOffset += 2.0f + _titleModel.frame.size.height;
    
    if (_imageViewModel != nil)
    {
        if (_siteModel != nil) {
            currentOffset += 4.0f;
        }
        _imageViewModel.frame = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + currentOffset, _imageViewModel.frame.size.width, _imageViewModel.frame.size.height);
        
        if (_titleModel != nil || _textModel != nil) {
            currentOffset += 3.0f;
            if (bottomInset)
                *bottomInset = 9.0f;
        } else {
            if (bottomInset)
                *bottomInset = 11.0f;
        }
        
        _ringModel.frame = _imageViewModel.frame;
        
        CGFloat pixel = MIN(0.5f, TGScreenPixel);
        _muteButtonModel.frame = CGRectMake(floor(CGRectGetMidX(_imageViewModel.frame) - 12.0f), CGRectGetMaxY(_imageViewModel.frame) - 24.0f - 8.0f - pixel, 24.0f, 24.0f);
        
        currentOffset += _imageViewModel.frame.size.height;
    }
    
    CGRect durationModelFrame = CGRectMake(rect.origin.x + 10.0f, currentOffset - _durationLabelModel.frame.size.height + 6.0f, _durationLabelModel.frame.size.width, _durationLabelModel.frame.size.height);
    _durationLabelModel.frame = durationModelFrame;
}

- (void)updateDurationString
{
    int32_t value = _status ? (int32_t)(_status.duration - _status.offset * _status.duration) : _duration;
    int32_t minutes = value / 60;
    int32_t seconds = value % 60;
    
    NSString *string = [[NSString alloc] initWithFormat:@"%d:%02d", minutes, seconds];
    [_durationLabelModel setTime:string];
}

- (void)subscribeStatus {
    [_playingVideoMessageIdDisposable dispose];
    if (self.context.playingAudioMessageStatus != nil)
    {
        __weak TGRoundVideoWebpageFooterModel *weakSelf = self;
        _playingVideoMessageIdDisposable = [self.context.playingAudioMessageStatus startWithNext:^(TGMusicPlayerStatus *status)
        {
            __strong TGRoundVideoWebpageFooterModel *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                TGSignalImageView *imageView = (TGSignalImageView *)strongSelf->_imageViewModel.boundView;
                if (status == nil || !status.isVoice)
                {
                    strongSelf->_status = nil;
                    
                    [strongSelf activateWebpageContents];
                    
                    [imageView setVideoView:nil];
                    [strongSelf->_ringModel setStatus:nil];
                    
                    [strongSelf _updateMuted:true];
                }
                else
                {
                    [strongSelf stopInlineMedia:0];
                    
                    if ([(NSNumber *)status.item.key intValue] == strongSelf->_mid)
                    {
                        strongSelf->_status = status;
                        
                        [imageView setVideoView:[TGVideoMessagePIPController videoViewForStatus:status]];
                        [strongSelf->_ringModel setStatus:status];
                        
                        [strongSelf _updateMuted:false];
                    }
                    else
                    {
                        strongSelf->_status = nil;
                        
                        [imageView setVideoView:nil];
                        [strongSelf->_ringModel setStatus:nil];
                        
                        [strongSelf _updateMuted:true];
                    }
                }
                [strongSelf updateDurationString];
            }
        }];
    }
}

- (bool)activateWebpageContents
{
    if (self.mediaIsAvailable) {
        _activatedMedia = true;
        [self updateOverlayAnimated:false];
        
        TGDocumentMediaAttachment *document = _webPage.document;

        NSString *documentDirectory = nil;
        if (document.localDocumentId != 0) {
            documentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:document.localDocumentId version:document.version];
        } else {
            documentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId version:document.version];
        }
        
        NSString *videoPath = nil;
        
        if ([document.mimeType isEqualToString:@"video/mp4"]) {
            if (document.localDocumentId != 0) {
                videoPath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:document.localDocumentId version:document.version] stringByAppendingPathComponent:[document safeFileName]];
            } else {
                videoPath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId version:document.version] stringByAppendingPathComponent:[document safeFileName]];
            }
        }
        
        if (videoPath != nil) {
            [_imageViewModel setVideoPathSignal:[SSignal single:videoPath]];
        } else {
            NSString *filePath = nil;
            NSString *videoPath = nil;
            
            if (document.localDocumentId != 0)
            {
                filePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:document.localDocumentId version:document.version] stringByAppendingPathComponent:[document safeFileName]];
                videoPath = [filePath stringByAppendingString:@".mov"];
            }
            else
            {
                filePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId version:document.version] stringByAppendingPathComponent:[document safeFileName]];
                videoPath = [filePath stringByAppendingString:@".mov"];
            }
            
            [_imageViewModel setVideoPathSignal:[SSignal single:videoPath]];
        }
    }
    
    return false;
}

- (bool)webpageContentsActivated
{
    return false;
}

- (void)setMediaIsAvailable:(bool)mediaIsAvailable {
    bool wasAvailable = self.mediaIsAvailable;
    
    [super setMediaIsAvailable:mediaIsAvailable];
    
    if (!wasAvailable && mediaIsAvailable && self.boundToContainer) {
        if ([_imageViewModel boundView] != nil && mediaIsAvailable) {
            [self activateWebpageContents];
        }
    }
    
    [self updateOverlayAnimated:false];
}

- (void)updateMediaProgressVisible:(bool)mediaProgressVisible mediaProgress:(float)mediaProgress animated:(bool)animated {
    [super updateMediaProgressVisible:mediaProgressVisible mediaProgress:mediaProgress animated:animated];
    
    [self updateOverlayAnimated:animated];
}

- (void)imageDataInvalidated:(NSString *)imageUrl {
    if ([_imageDataInvalidationUrl isEqualToString:imageUrl]) {
        if (_imageDataInvalidationBlock) {
            _imageDataInvalidationBlock();
        }
    }
}

- (void)stopInlineMedia:(int32_t)__unused excludeMid
{
    bool wasActivated = _activatedMedia;
    _activatedMedia = false;
    
    if (wasActivated)
    {
        [((TGSignalImageView *)_imageViewModel.boundView) hideVideo];
        [((TGSignalImageView *)_imageViewModel.boundView) setVideoPathSignal:nil];
    }
    
    [self updateOverlayAnimated:false];
}

- (void)updateOverlayAnimated:(bool)animated {
   if (_imageViewModel.manualProgress) {
        if (self.mediaProgressVisible) {
            [_imageViewModel setProgress:self.mediaProgress animated:animated];
        } else if (self.mediaIsAvailable) {
            if (_activatedMedia) {
                [_imageViewModel setNone];
            } else {
                [_imageViewModel setNone];
            }
        } else {
            [_imageViewModel setDownload];
        }
    }
}

- (void)resumeInlineMedia {
    if (self.mediaIsAvailable && !_activatedMedia) {
        [self activateWebpageContents];
    }
}

- (bool)isPreviewableAtPoint:(CGPoint)__unused point
{
    return false;
}

@end
