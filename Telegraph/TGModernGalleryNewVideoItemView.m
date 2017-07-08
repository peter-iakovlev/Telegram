#import "TGModernGalleryNewVideoItemView.h"

#import "TGImageUtils.h"

#import "ActionStage.h"
#import "TGVideoDownloadActor.h"
#import "TGDownloadManager.h"

#import "TGModernGalleryVideoItem.h"

#import "TGMessage.h"
#import "TGVideoMediaAttachment.h"
#import "TGPreparedLocalDocumentMessage.h"

#import "TGModernButton.h"
#import "TGMessageImageViewOverlayView.h"

#import "TGModernGalleryZoomableScrollView.h"
#import "TGModernGalleryVideoPlayerView.h"
#import "TGModernGalleryVideoScrubbingInterfaceView.h"
#import "TGModernGalleryVideoFooterView.h"
#import "TGModernGalleryDefaultFooterView.h"

#import "TGGenericPeerGalleryItem.h"

#import "TGPeerIdAdapter.h"
#import "TGGenericPeerMediaGalleryVideoItem.h"

@interface TGModernGalleryNewVideoItemView () <ASWatcher>
{
    TGMessageImageViewOverlayView *_progressView;
    TGModernGalleryVideoFooterView *_footerView;
    
    bool _mediaAvailable;
    bool _downloading;
    int32_t _transactionId;
    bool _autoplayAfterDownload;
    NSUInteger _currentLoopCount;
        
    SMetaDisposable *_stateDisposable;
    
    bool _scrubbing;
    bool _switchingToPIP;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGModernGalleryNewVideoItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        __weak TGModernGalleryNewVideoItemView *weakSelf = self;
        
        _scrubbingInterfaceView = [[TGModernGalleryVideoScrubbingInterfaceView alloc] init];
        _scrubbingInterfaceView.scrubbingBegan = ^
        {
            __strong TGModernGalleryNewVideoItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf pause];
                
                strongSelf->_scrubbing = true;
                [strongSelf updateInterface];
            }
        };
        _scrubbingInterfaceView.scrubbingChanged = ^(CGFloat position)
        {
            __strong TGModernGalleryNewVideoItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [[strongSelf _playerView] seekToFractPosition:position];
        };
        _scrubbingInterfaceView.scrubbingCancelled = ^
        {
            __strong TGModernGalleryNewVideoItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            strongSelf->_scrubbing = false;
            [strongSelf updateInterface];
            
            [strongSelf play];
        };
        _scrubbingInterfaceView.scrubbingFinished = ^(CGFloat position)
        {
            __strong TGModernGalleryNewVideoItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [[strongSelf _playerView] seekToFractPosition:position];
            
            strongSelf->_scrubbing = false;
            [strongSelf updateInterface];
            
            [strongSelf play];
        };
        
        _footerView = [[TGModernGalleryVideoFooterView alloc] init];
        _footerView.playPressed = ^
        {
            __strong TGModernGalleryNewVideoItemView *strongSelf = weakSelf;
            [strongSelf play];
        };
        _footerView.pausePressed = ^
        {
            __strong TGModernGalleryNewVideoItemView *strongSelf = weakSelf;
            [strongSelf pause];
        };
        
        _playerView = [[TGModernGalleryVideoPlayerView alloc] init];
        [self.scrollView addSubview:_playerView];
        
        _actionButton = [[TGModernButton alloc] initWithFrame:(CGRect){CGPointZero, {50.0f, 50.0f}}];
        _actionButton.modernHighlight = true;
        
        CGFloat circleDiameter = 50.0f;
        static UIImage *highlightImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(circleDiameter, circleDiameter), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGBA(0x000000, 0.4f).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, circleDiameter, circleDiameter));
            highlightImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        _actionButton.highlightImage = highlightImage;
        
        _progressView = [[TGMessageImageViewOverlayView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)];
        _progressView.userInteractionEnabled = false;
        [_actionButton addSubview:_progressView];
        
        [_actionButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_actionButton];
    }
    return self;
}

- (void)dealloc
{
    [self stop];
    
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    
    if (!_playerViewDetached)
        [_playerView disposeAudioSession];
}

- (void)prepareForRecycle
{
    [super prepareForRecycle];
    
    [ActionStageInstance() removeWatcher:self];
    
    if (!_playerViewDetached)
        [_playerView reset];
    
    _currentLoopCount = 0;
    
    _autoplayAfterDownload = false;
    
    [self footerView].hidden = true;
    
    [_stateDisposable dispose];
    _stateDisposable = nil;
}

- (void)_configurePlayerView
{
}

#pragma mark - 

- (void)setItem:(TGModernGalleryVideoItem *)item synchronously:(bool)synchronously
{
    _transactionId++;
    
    [super setItem:item synchronously:synchronously];
    
    [_playerView reset];
    
    [self footerView].hidden = true;
    
    CGSize dimensions = CGSizeZero;
    NSTimeInterval duration = 0.0;
    NSString *videoPath = nil;
    
    id media = ((TGModernGalleryVideoItem *)self.item).media;
    
    if ([media isKindOfClass:[TGVideoMediaAttachment class]])
    {
        TGVideoMediaAttachment *videoAttachment = media;
        dimensions = videoAttachment.dimensions;
        duration = videoAttachment.duration;
        videoPath = [TGVideoDownloadActor localPathForVideoUrl:[videoAttachment.videoInfo urlWithQuality:0 actualQuality:NULL actualSize:NULL]];
    }
    else if ([media isKindOfClass:[TGDocumentMediaAttachment class]])
    {
        TGDocumentMediaAttachment *document = media;
        dimensions = document.pictureSize;
        for (id attribute in document.attributes)
        {
            if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]])
                duration = ((TGDocumentAttributeVideo *)attribute).duration;
        }
        NSString *documentPath = document.localDocumentId != 0 ? [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:document.localDocumentId version:document.version] : [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId version:document.version];
        NSString *legacyVideoFilePath = [documentPath stringByAppendingPathComponent:[document safeFileName]];
        videoPath = legacyVideoFilePath;
        if (![videoPath.pathExtension isEqualToString:@"mp4"] && ![videoPath.pathExtension isEqualToString:@"mp4"])
        {
            NSString *movPath = [videoPath stringByAppendingString:@".mov"];
            [[NSFileManager defaultManager] linkItemAtPath:movPath toPath:[document safeFileName] error:NULL];
            videoPath = movPath;
        }
    }
    
    _videoDimensions = dimensions;
    
    _disablePictureInPicture = false;
    if ([item isKindOfClass:[TGGenericPeerMediaGalleryVideoItem class]] && TGPeerIdIsAdminLog(((TGGenericPeerMediaGalleryVideoItem *)item).peerId)) {
        _disablePictureInPicture = true;
    }
    [self _initializePlayerWithPath:videoPath duration:duration synchronously:synchronously];
    
    [self layoutSubviews];
    [self reset];
}

- (void)_initializePlayerWithPath:(NSString *)videoPath duration:(NSTimeInterval)duration synchronously:(bool)synchronously
{
    [_scrubbingInterfaceView setDuration:duration currentTime:0.0 isPlaying:false isPlayable:false animated:false];
    [_scrubbingInterfaceView setPictureInPictureEnabled:false];
    
    _playerView.initialFrame = CGRectMake(0, 0, _videoDimensions.width, _videoDimensions.height);
    
    [self _subscribeToStateOfPlayerView:_playerView];
    [_playerView loadImageWithUri:((TGModernGalleryVideoItem *)self.item).previewUri update:false synchronously:synchronously];
    
    if (videoPath == nil)
        return;
    
    [_playerView setVideoPath:videoPath duration:duration];
    
    int32_t transactionId = _transactionId;
    
    __weak TGModernGalleryNewVideoItemView *weakSelf = self;
    dispatch_block_t checkMediaAvailability = ^
    {
        __strong TGModernGalleryNewVideoItemView *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath isDirectory:NULL])
            {
                TGDispatchOnMainThread(^
                {
                    if (strongSelf->_transactionId == transactionId)
                        [strongSelf setMediaAvailable:true];
                });
            }
            else
            {
                TGDispatchOnMainThread(^
                {
                    if (strongSelf->_transactionId == transactionId)
                    {
                        [strongSelf setMediaAvailable:false];
                        [strongSelf _joinDownload];
                    }
                });
            }
        }
    };
    
    if (synchronously)
        checkMediaAvailability();
    else
        [ActionStageInstance() dispatchOnStageQueue:checkMediaAvailability];
}
- (void)_subscribeToStateOfPlayerView:(UIView<TGPIPAblePlayerView> *)playerView
{
    __weak TGModernGalleryNewVideoItemView *weakSelf = self;
    
    _stateDisposable = [[SMetaDisposable alloc] init];
    [_stateDisposable setDisposable:[playerView.stateSignal startWithNext:^(TGModernGalleryVideoPlayerState *next)
    {
        __strong TGModernGalleryNewVideoItemView *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf updateInterface];
            [strongSelf->_scrubbingInterfaceView setDuration:next.duration currentTime:next.position isPlaying:next.isPlaying isPlayable:true animated:false];
        }
    }]];
}

#pragma mark -

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _actionButton.frame = (CGRect){{CGFloor((frame.size.width - _actionButton.frame.size.width) / 2.0f), CGFloor((frame.size.height - _actionButton.frame.size.height) / 2.0f)}, _actionButton.frame.size};
}

#pragma mark - 

- (CGSize)contentSize
{
    return _videoDimensions;
}

- (UIView *)contentView
{
    return _playerView;
}

- (UIView *)transitionView
{
    return self.containerView;
}

- (CGRect)transitionViewContentRect
{
    return [_playerView convertRect:_playerView.bounds toView:[self transitionView]];
}

- (UIView *)headerView
{
    return _scrubbingInterfaceView;
}

- (UIView *)footerView
{
    return _footerView;
}

#pragma mark -

- (void)setFocused:(bool)isFocused
{
    if (!isFocused)
    {
        [self footerView].hidden = true;
        [self setDefaultFooterHidden:false];
    }
}

- (void)setIsVisible:(bool)isVisible
{
    [super setIsVisible:isVisible];
    
    if (!isVisible)
        [self stop];
}

- (void)updateInterface
{
    bool playing = [self _playerView].state.isPlaying;
    
    _actionButton.hidden = playing || _scrubbing;
    _footerView.isPlaying = playing;
}

- (void)setDefaultFooterHidden:(bool)hidden
{
    if ([[self defaultFooterView] respondsToSelector:@selector(setContentHidden:)])
        [[self defaultFooterView] setContentHidden:hidden];
    else
        [self defaultFooterView].hidden = hidden;
}

#pragma mark - 

- (UIView<TGPIPAblePlayerView> *)_playerView
{
    return _playerView;
}

- (bool)shouldLoopVideo:(NSUInteger)__unused currentLoopCount
{
    return false;
}

- (void)play
{
    if (_mediaAvailable)
    {
        [self _willPlay];
        
        [[self _playerView] playVideo];
    }
    else if (_downloading)
    {
        [self _cancelDownload];
    }
    else
    {
        [self _requestDownload];
    }
}

- (void)pause
{
    [[self _playerView] pauseVideo];
    
    _actionButton.hidden = true;
}

- (void)loadAndPlay
{
    if (!_mediaAvailable)
        _autoplayAfterDownload = true;
    
    [self play];
}

- (void)hidePlayButton
{
    _actionButton.hidden = true;
}

- (void)stop
{
    if (!_playerViewDetached)
        [_playerView stop];
}

- (void)stopForOutTransition
{
    if (_playerView.isLoaded)
    {
        [_playerView pauseVideo];
    
        UIView *snapshotView = [_playerView snapshotViewAfterScreenUpdates:false];
        [_playerView.superview insertSubview:snapshotView aboveSubview:_playerView];
        snapshotView.transform = _playerView.transform;
        snapshotView.frame = _playerView.frame;
    }
    
    [_actionButton removeFromSuperview];
    [_playerView stop];
}

- (void)_willPlay
{
    [self footerView].hidden = false;
    [self setDefaultFooterHidden:true];
}

#pragma mark -

- (void)setMediaAvailable:(bool)mediaAvailable
{
    [self _setMediaAvailable:mediaAvailable];
    
    if (_mediaAvailable)
        [_progressView setPlay];
    else
        [_progressView setDownload];
}

- (void)_setMediaAvailable:(bool)available
{
    _mediaAvailable = available;
    
    [_scrubbingInterfaceView setPictureInPictureEnabled:available && !_disablePictureInPicture];
}

- (void)setProgressVisible:(bool)progressVisible value:(float)value animated:(bool)animated
{
    if (progressVisible)
        [_progressView setProgress:value cancelEnabled:true animated:animated];
    else if (_mediaAvailable)
        [_progressView setPlay];
    else
        [_progressView setDownload];
}

- (void)_joinDownload
{
    id media = ((TGModernGalleryVideoItem *)self.item).media;
    if (media == nil)
        return;
    
    if ([media isKindOfClass:[TGVideoMediaAttachment class]])
    {
        TGVideoMediaAttachment *videoAttachment = media;
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            NSString *url = [videoAttachment.videoInfo urlWithQuality:1 actualQuality:NULL actualSize:NULL];
            NSString *path = [[NSString alloc] initWithFormat:@"/as/media/video/(%@)", url];
            if ([ActionStageInstance() requestActorStateNow:path])
            {
                TGDispatchOnMainThread(^
                {
                    _downloading = true;
                    [self setProgressVisible:true value:0.0f animated:false];
                });
                
                [ActionStageInstance() requestActor:path options:nil watcher:self];
            }
        }];
    }
    else if ([media isKindOfClass:[TGDocumentMediaAttachment class]])
    {
        TGDocumentMediaAttachment *document = media;
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            NSString *path = [NSString stringWithFormat:@"/tg/media/document/(%d:%" PRId64 ":%@)", document.datacenterId, document.documentId, document.documentUri.length != 0 ? document.documentUri : @""];
            
            if ([ActionStageInstance() requestActorStateNow:path])
            {
                TGDispatchOnMainThread(^
                {
                    _downloading = true;
                    [self setProgressVisible:true value:0.0f animated:false];
                });
                
                [ActionStageInstance() requestActor:path options:@{@"documentAttachment": document} watcher:self];
            }
        }];
    }
}

- (void)_cancelDownload
{
    [ActionStageInstance() removeWatcher:self];
    
    id media = ((TGModernGalleryVideoItem *)self.item).media;
    
    if ([media isKindOfClass:[TGDocumentMediaAttachment class]])
    {
        TGDocumentMediaAttachment *document = media;
        
        if (document.documentId != 0)
        {
            id itemId = [[TGMediaId alloc] initWithType:3 itemId:document.documentId];
            [[TGDownloadManager instance] cancelItem:itemId];
        }
        else if (document.localDocumentId != 0 && document.documentUri.length != 0)
        {
            id itemId = [[TGMediaId alloc] initWithType:3 itemId:document.localDocumentId];
            [[TGDownloadManager instance] cancelItem:itemId];
        }
    }
    else if ([media isKindOfClass:[TGVideoMediaAttachment class]])
    {
        TGVideoMediaAttachment *videoAttachment = media;
        
        id itemId = [[TGMediaId alloc] initWithType:1 itemId:videoAttachment.videoId];
        [[TGDownloadManager instance] cancelItem:itemId];
    }
    
    TGDispatchOnMainThread(^
    {
        _downloading = false;
        [self setProgressVisible:false value:0.0f animated:false];
    });
}

- (void)_requestDownload
{
    id media = ((TGModernGalleryVideoItem *)self.item).media;
    
    if ([media isKindOfClass:[TGDocumentMediaAttachment class]])
    {
        TGDocumentMediaAttachment *document = media;
        NSString *path = [NSString stringWithFormat:@"/tg/media/document/(%d:%" PRId64 ":%@)", document.datacenterId, document.documentId, document.documentUri.length != 0 ? document.documentUri : @""];
        [ActionStageInstance() requestActor:path options:@{@"documentAttachment": document} watcher:self];
    }
    else if ([media isKindOfClass:[TGVideoMediaAttachment class]])
    {
        TGVideoMediaAttachment *videoAttachment = media;
        NSString *url = [videoAttachment.videoInfo urlWithQuality:1 actualQuality:NULL actualSize:NULL];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[@"videoAttachment"] = videoAttachment;
        if (((TGModernGalleryVideoItem *)self.item).videoDownloadArguments != nil)
            dict[@"additionalOptions"] = ((TGModernGalleryVideoItem *)self.item).videoDownloadArguments;
        
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/as/media/video/(%@)", url] options:dict watcher:self];
    }
    
    TGDispatchOnMainThread(^
    {
        _downloading = true;
        [self setProgressVisible:true value:0.0f animated:false];
    });
}

#pragma mark - 

- (void)actorMessageReceived:(NSString *)path messageType:(NSString *)messageType message:(id)message
{
    if ([path hasPrefix:@"/as/media/video/"])
    {
        if ([messageType isEqualToString:@"progress"])
        {
            float progress = [message floatValue];
            TGDispatchOnMainThread(^
            {
                [self setProgressVisible:true value:progress animated:true];
            });
        }
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)__unused result
{
    if ([path hasPrefix:@"/as/media/video/"])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (status == ASStatusSuccess)
            {
                _downloading = false;
                [self _setMediaAvailable:true];
                
                [self setProgressVisible:false value:1.0f animated:false];
                
                [_playerView loadImageWithUri:((TGModernGalleryVideoItem *)self.item).previewUri update:true synchronously:false];
                
                if (_autoplayAfterDownload)
                {
                    _autoplayAfterDownload = false;
                    [self play];
                }
            }
        });
    }
}

@end
