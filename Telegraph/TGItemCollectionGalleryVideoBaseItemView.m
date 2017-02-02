#import "TGItemCollectionGalleryVideoBaseItemView.h"

#import "TGImageUtils.h"
#import "TGTelegraph.h"

#import "ActionStage.h"
#import "TGVideoDownloadActor.h"
#import "TGDownloadManager.h"

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

#import "TGItemCollectionGalleryItem.h"

#import "PhotoResources.h"

@interface TGItemCollectionGalleryVideoBaseItemView () {
    TGMessageImageViewOverlayView *_progressView;
    TGModernGalleryVideoFooterView *_footerView;
    
    id<MediaResource> _resource;
    MediaResourceStatus *_resourceStatus;
    ResourceData *_resourceData;
    
    bool _autoplayAfterDownload;
    NSUInteger _currentLoopCount;
    
    SMetaDisposable *_stateDisposable;
    
    bool _scrubbing;
    bool _switchingToPIP;
    
    SMetaDisposable *_resourceStatusDisposable;
    SMetaDisposable *_resourceDataDisposable;
    SMetaDisposable *_resourceFetchDisposable;
    
    bool _keepProgressHidden;
}

@end

@implementation TGItemCollectionGalleryVideoBaseItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        __weak TGItemCollectionGalleryVideoBaseItemView *weakSelf = self;
        
        _scrubbingInterfaceView = [[TGModernGalleryVideoScrubbingInterfaceView alloc] init];
        _scrubbingInterfaceView.scrubbingBegan = ^
        {
            __strong TGItemCollectionGalleryVideoBaseItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf pause];
                
                strongSelf->_scrubbing = true;
                [strongSelf updateInterface];
            }
        };
        _scrubbingInterfaceView.scrubbingChanged = ^(CGFloat position)
        {
            __strong TGItemCollectionGalleryVideoBaseItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [[strongSelf _playerView] seekToFractPosition:position];
        };
        _scrubbingInterfaceView.scrubbingCancelled = ^
        {
            __strong TGItemCollectionGalleryVideoBaseItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            strongSelf->_scrubbing = false;
            [strongSelf updateInterface];
            
            [strongSelf play];
        };
        _scrubbingInterfaceView.scrubbingFinished = ^(CGFloat position)
        {
            __strong TGItemCollectionGalleryVideoBaseItemView *strongSelf = weakSelf;
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
            __strong TGItemCollectionGalleryVideoBaseItemView *strongSelf = weakSelf;
            [strongSelf play];
        };
        _footerView.pausePressed = ^
        {
            __strong TGItemCollectionGalleryVideoBaseItemView *strongSelf = weakSelf;
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
    [_resourceStatusDisposable dispose];
    [_resourceDataDisposable dispose];
    [_resourceFetchDisposable dispose];
    
    [self stop];
    
    if (!_playerViewDetached)
        [_playerView disposeAudioSession];
}

- (void)prepareForRecycle
{
    [super prepareForRecycle];
    
    if (!_playerViewDetached)
        [_playerView reset];
    
    _currentLoopCount = 0;
    
    _autoplayAfterDownload = false;
    
    [self footerView].hidden = true;
    
    [_stateDisposable dispose];
    _stateDisposable = nil;
    
    _resource = nil;
    _resourceStatus = nil;
    _resourceData = nil;
    
    [_resourceStatusDisposable setDisposable:nil];;
    [_resourceDataDisposable setDisposable:nil];
    [_resourceFetchDisposable setDisposable:nil];
}

- (void)_configurePlayerView
{
}

#pragma mark -

- (void)setItem:(TGItemCollectionGalleryItem *)item synchronously:(bool)synchronously
{
    [super setItem:item synchronously:synchronously];
    
    [_playerView reset];
    
    [self footerView].hidden = true;
    
    CGSize dimensions = CGSizeZero;
    NSTimeInterval duration = 0.0;
    
    id media = ((TGItemCollectionGalleryItem *)self.item).media.media;
    
    if ([media isKindOfClass:[TGVideoMediaAttachment class]])
    {
        TGVideoMediaAttachment *videoAttachment = media;
        dimensions = videoAttachment.dimensions;
        duration = videoAttachment.duration;
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
    }
    
    _videoDimensions = dimensions;
    
    [self _initializePlayerWithMedia:media synchronously:synchronously];
    
    [self layoutSubviews];
    [self reset];
}

- (void)_initializePlayerWithMedia:(id)media synchronously:(bool)__unused synchronously
{
    NSTimeInterval duration = 0.0;
    if ([media isKindOfClass:[TGVideoMediaAttachment class]]) {
        TGVideoMediaAttachment *videoAttachment = media;
        duration = videoAttachment.duration;
    } else if ([media isKindOfClass:[TGDocumentMediaAttachment class]]) {
        TGDocumentMediaAttachment *document = media;
        for (id attribute in document.attributes) {
            if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]])
                duration = ((TGDocumentAttributeVideo *)attribute).duration;
        }
    }
    
    [_scrubbingInterfaceView setDuration:duration currentTime:0.0 isPlaying:false isPlayable:false animated:false];
    [_scrubbingInterfaceView setPictureInPictureEnabled:false];
    
    _playerView.initialFrame = CGRectMake(0, 0, _videoDimensions.width, _videoDimensions.height);
    
    [self _subscribeToStateOfPlayerView:_playerView];
    //[_playerView loadImageWithUri:((TGModernGalleryVideoItem *)self.item).previewUri update:false synchronously:synchronously];
    if ([media isKindOfClass:[TGVideoMediaAttachment class]]) {
        [_playerView loadImageWithSignal:videoMediaTransform(TGTelegraphInstance.mediaBox, media)];
        _resource = videoFullSizeResource(media);
    }
    
    if (media == nil) {
        return;
    }
    
    __weak TGItemCollectionGalleryVideoBaseItemView *weakSelf = self;
    [_resourceStatusDisposable setDisposable:[[[TGTelegraphInstance.mediaBox resourceStatus:_resource] deliverOn:[SQueue mainQueue]] startWithNext:^(MediaResourceStatus *status) {
        __strong TGItemCollectionGalleryVideoBaseItemView *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (!TGObjectCompare(strongSelf->_resourceStatus, status)) {
                strongSelf->_resourceStatus = status;
                
                switch (status.status) {
                    case MediaResourceStatusRemote:
                        [strongSelf->_progressView setDownload];
                        break;
                    case MediaResourceStatusFetching:
                        [strongSelf->_progressView setProgress:status.progress cancelEnabled:true animated:true];
                        break;
                    case MediaResourceStatusLocal:
                        [strongSelf->_progressView setPlay];
                        break;
                }
                
                [strongSelf->_scrubbingInterfaceView setPictureInPictureEnabled:false];//status.status == MediaResourceStatusLocal];
            }
        }
    }]];
    
    [_resourceDataDisposable setDisposable:[[[TGTelegraphInstance.mediaBox resourceData:_resource pathExtension:@"mp4"] deliverOn:[SQueue mainQueue]] startWithNext:^(ResourceData *data) {
        __strong TGItemCollectionGalleryVideoBaseItemView *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (data.complete) {
                strongSelf->_resourceData = data;
                [strongSelf->_playerView setVideoPath:data.path duration:duration];
                if (strongSelf->_autoplayAfterDownload) {
                    strongSelf->_autoplayAfterDownload = false;
                    [strongSelf play];
                }
            }
        }
    }]];
}
- (void)_subscribeToStateOfPlayerView:(UIView<TGPIPAblePlayerView> *)playerView
{
    __weak TGItemCollectionGalleryVideoBaseItemView *weakSelf = self;
    
    _stateDisposable = [[SMetaDisposable alloc] init];
    [_stateDisposable setDisposable:[playerView.stateSignal startWithNext:^(TGModernGalleryVideoPlayerState *next) {
        __strong TGItemCollectionGalleryVideoBaseItemView *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf updateInterface];
            [strongSelf->_scrubbingInterfaceView setDuration:next.duration currentTime:next.position isPlaying:next.isPlaying isPlayable:true animated:false];
        }
    }]];
}

#pragma mark -

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    _actionButton.frame = (CGRect){{CGFloor((frame.size.width - _actionButton.frame.size.width) / 2.0f), CGFloor((frame.size.height - _actionButton.frame.size.height) / 2.0f)}, _actionButton.frame.size};
}

#pragma mark -

- (CGSize)contentSize {
    return _videoDimensions;
}

- (UIView *)contentView {
    return _playerView;
}

- (UIView *)transitionView {
    return self.containerView;
}

- (CGRect)transitionViewContentRect {
    return [_playerView convertRect:_playerView.bounds toView:[self transitionView]];
}

- (UIView *)headerView {
    return _scrubbingInterfaceView;
}

- (UIView *)footerView {
    return _footerView;
}

#pragma mark -

- (void)setFocused:(bool)isFocused {
    if (!isFocused) {
        [self footerView].hidden = true;
        [self setDefaultFooterHidden:false];
    }
}

- (void)setIsVisible:(bool)isVisible {
    [super setIsVisible:isVisible];
    
    if (!isVisible) {
        [self stop];
    }
}

- (void)updateInterface {
    bool playing = [self _playerView].state.isPlaying;
    
    _actionButton.hidden = _keepProgressHidden || playing || _scrubbing;
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

- (UIView<TGPIPAblePlayerView> *)_playerView {
    return _playerView;
}

- (bool)shouldLoopVideo:(NSUInteger)__unused currentLoopCount {
    return false;
}

- (void)play {
    if (_resource != nil && _resourceStatus != nil) {
        switch (_resourceStatus.status) {
            case MediaResourceStatusLocal:
                [self _willPlay];
                [[self _playerView] playVideo];
                break;
            case MediaResourceStatusFetching:
                [TGTelegraphInstance.mediaBox cancelInteractiveResourceFetch:_resource];
                break;
            case MediaResourceStatusRemote:
                [_resourceFetchDisposable setDisposable:[[TGTelegraphInstance.mediaBox fetchedResource:_resource] startWithNext:nil]];
                break;
        }
    }
}

- (void)pause {
    [[self _playerView] pauseVideo];
    
    _actionButton.hidden = true;
}

- (void)loadAndPlay {
    if (_resourceStatus != nil && _resourceStatus.status == MediaResourceStatusRemote) {
        _autoplayAfterDownload = true;
    }
    
    [self play];
}

- (void)hidePlayButton {
    _keepProgressHidden = true;
    _actionButton.hidden = true;
}

- (void)showPlayButton {
    _keepProgressHidden = false;
    [self updateInterface];
}

- (void)stop
{
    if (!_playerViewDetached) {
        [_playerView stop];
    }
}

- (void)stopForOutTransition {
    if (_playerView.isLoaded) {
        [_playerView pauseVideo];
        
        UIView *snapshotView = [_playerView snapshotViewAfterScreenUpdates:false];
        [_playerView.superview insertSubview:snapshotView aboveSubview:_playerView];
        snapshotView.transform = _playerView.transform;
        snapshotView.frame = _playerView.frame;
    }
    
    [_actionButton removeFromSuperview];
    [_playerView stop];
}

- (void)_willPlay {
    [self footerView].hidden = false;
    [self setDefaultFooterHidden:true];
}

@end
