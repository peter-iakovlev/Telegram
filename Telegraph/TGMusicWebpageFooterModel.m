#import "TGMusicWebpageFooterModel.h"

#import "TGWebPageMediaAttachment.h"

#import "TGDocumentMessageIconModel.h"
#import "TGModernLabelViewModel.h"
#import "TGTelegraph.h"
#import "TGMusicPlayer.h"

#import "TGViewController.h"

#import "TGFont.h"

#import "TGMessageImageView.h"
#import "TGDocumentMessageIconView.h"

#import "TGModernViewContext.h"

@interface TGMusicWebpageFooterModel () <TGMessageImageViewDelegate> {
    TGWebPageMediaAttachment *_webPage;
    bool _hasViews;
    bool _incoming;
    int32_t _mid;
    
    TGDocumentMessageIconModel *_iconModel;
    TGModernLabelViewModel *_titleModel;
    TGModernLabelViewModel *_performerModel;
    
    bool _isCurrent;
    bool _isPlaying;
    
    id<SDisposable> _playingAudioMessageIdDisposable;
}

@end

@implementation TGMusicWebpageFooterModel

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
        _iconModel.frame = CGRectMake(0.0f, 0.0f, 60.0f, 60.0f);
        _iconModel.incoming = incoming;
        [self addSubmodel:_iconModel];
        
        static UIColor *incomingNameColor = nil;
        static UIColor *outgoingNameColor = nil;
        static UIColor *incomingSizeColor = nil;
        static UIColor *outgoingSizeColor = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            incomingNameColor = [UIColor blackColor];
            outgoingNameColor = UIColorRGB(0x3faa3c);
            incomingSizeColor = UIColorRGB(0x999999);
            outgoingSizeColor = UIColorRGB(0x3faa3c);
        });
        
        NSString *performer = @"";
        NSString *title = @"";
        NSString *fileName = @"";
        
        fileName = document.fileName;
        
        for (id attribute in document.attributes)
        {
            if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]])
            {
                TGDocumentAttributeAudio *audioAttribute = attribute;
                performer = audioAttribute.performer;
                title = audioAttribute.title;
                
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
        
        _titleModel = [[TGModernLabelViewModel alloc] initWithText:title textColor:incoming ? incomingNameColor : outgoingNameColor font:TGCoreTextSystemFontOfSize(16.0f) maxWidth:maxWidth truncateInTheMiddle:false];
        [self addSubmodel:_titleModel];
        
        _performerModel = [[TGModernLabelViewModel alloc] initWithText:performer textColor:incoming ? incomingSizeColor : outgoingSizeColor font:TGCoreTextSystemFontOfSize(13.0f) maxWidth:maxWidth truncateInTheMiddle:false];
        [self addSubmodel:_performerModel];
    }
    return self;
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    _iconModel.parentOffset = itemPosition;
    [_iconModel bindViewToContainer:container viewStorage:viewStorage];
    ((TGDocumentMessageIconView *)[_iconModel boundView]).delegate = self;
    
    [self subscribeToStatus];
}

- (void)subscribeToStatus {
    [_playingAudioMessageIdDisposable dispose];
    if (self.context.playingAudioMessageStatus != nil) {
        __weak TGMusicWebpageFooterModel *weakSelf = self;
        _playingAudioMessageIdDisposable = [self.context.playingAudioMessageStatus startWithNext:^(TGMusicPlayerStatus *status)
        {
            __strong TGMusicWebpageFooterModel *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                int32_t mid = [(NSNumber *)status.item.key intValue];;
                int paused = status.paused;
                
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

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage {
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    ((TGDocumentMessageIconView *)[_iconModel boundView]).delegate = self;
    
    [self subscribeToStatus];
}

- (void)unbindView:(TGModernViewStorage *)viewStorage {
    [_playingAudioMessageIdDisposable dispose];
    
    UIView *iconView = [_iconModel boundView];
    ((TGDocumentMessageIconView *)iconView).delegate = nil;
    
    [super unbindView:viewStorage];
    
    _isPlaying = false;
    _isCurrent = false;
    [self updateImageOverlay:false];
}

- (void)updateSpecialViewsPositions:(CGPoint)itemPosition
{
    _iconModel.parentOffset = itemPosition;
}

- (CGSize)contentSizeForContainerSize:(CGSize)__unused containerSize contentSize:(CGSize)__unused topContentSize infoWidth:(CGFloat)infoWidth needsContentsUpdate:(bool *)__unused needsContentsUpdate
{
    //CGSize contentContainerSize = CGSizeMake(MAX(containerSize.width - 10.0f - 20.0f, topContentSize.width - 10.0f - 20.0f), containerSize.height);
    
    CGFloat additionalWidth = 0.0f;
    if (_performerModel.frame.size.width < _titleModel.frame.size.width)
        additionalWidth += MAX(0.0f, 30.0f - _titleModel.frame.size.width - _performerModel.frame.size.width);
    
    return CGSizeMake(57.0f + 10.0f + MAX(_titleModel.frame.size.width, _performerModel.frame.size.width) + 30.0f, 57.0f);
}

- (bool)preferWebpageSize
{
    return false;
}

- (void)layoutContentInRect:(CGRect)rect bottomInset:(CGFloat *)__unused bottomInset
{
    rect.origin.y -= 9.0f;
    rect.origin.x += 7.0f;
    
    _iconModel.frame = CGRectMake(rect.origin.x - 5.0f, rect.origin.y + 2.0f, _iconModel.frame.size.width, _iconModel.frame.size.height);
    _titleModel.frame = CGRectMake(rect.origin.x + 57.0f, rect.origin.y + 10.0f, _titleModel.frame.size.width, _titleModel.frame.size.height);
    _performerModel.frame = CGRectMake(rect.origin.x + 57.0f, rect.origin.y + 31.0f, _performerModel.frame.size.width, _performerModel.frame.size.height);
}

- (void)setMediaIsAvailable:(bool)mediaIsAvailable {
    //bool wasAvailable = self.mediaIsAvailable;
    
    [super setMediaIsAvailable:mediaIsAvailable];
    
    [self updateImageOverlay:false];
}

- (void)updateMediaProgressVisible:(bool)mediaProgressVisible mediaProgress:(float)mediaProgress animated:(bool)animated {
    bool progressWasVisible = self.mediaProgressVisible;
    float previousProgress = self.mediaProgress;
    
    [super updateMediaProgressVisible:mediaProgressVisible mediaProgress:mediaProgress animated:animated];
    
    [self updateImageOverlay:((progressWasVisible && !self.mediaProgressVisible) || (self.mediaProgressVisible && ABS(self.mediaProgress - previousProgress) > FLT_EPSILON)) && animated];
}

- (void)updateImageOverlay:(bool)animated
{
    //_iconModel.viewUserInteractionDisabled = (_incoming && _mediaIsAvailable) || !_progressVisible;
    
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
        [_iconModel setOverlayType:_isPlaying ? TGMessageImageViewOverlayPauseMedia : TGMessageImageViewOverlayPlayMedia animated:animated];
    }
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
    if (self.mediaIsAvailable)
    {
        if (_isPlaying)
        {
            if (self.context.pauseAudioMessage)
                self.context.pauseAudioMessage();
        }
        else if (_isCurrent)
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

- (bool)activateWebpageContents {
    if (self.mediaProgressVisible) {
        [self cancelMediaDownload];
    } else {
        [self activateMedia];
    }
    
    return true;
}

@end
