#import "TGExternalGifSearchResultGalleryItemView.h"

#import "TGExternalGifSearchResultGalleryItem.h"

#import "TGImageView.h"
#import "TGModernAnimatedImagePlayer.h"
#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "ActionStage.h"

#import "TGMessageImageViewOverlayView.h"

#import "TGModernButton.h"

#import "ATQueue.h"

#import "TGMediaStoreContext.h"

#import "TGModernGalleryTransitionView.h"

#import "TGVTAcceleratedVideoView.h"
#import "TGWebpageSignals.h"

#import "TGMediaSelectionContext.h"

#import "TGTelegramNetworking.h"

@interface TGExternalGifSearchResultGalleryItemView () <ASWatcher> {
    UIView *_containerView;
    TGImageView *_imageView;
    UIView<TGInlineVideoPlayerView> *_acceleratedVideoView;
    TGModernAnimatedImagePlayer *_player;
    
    CGSize _imageSize;
    
    TGMessageImageViewOverlayView *_overlayView;
    
    NSString *_downloadPath;
    bool _isVideo;
    bool _downloaded;
    bool _isCurrent;
    NSData *_data;
    NSString *_path;
    
    SMetaDisposable *_prefetchDisposable;
    
    UITapGestureRecognizer *_tapGestureRecognizer;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGExternalGifSearchResultGalleryItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _containerView = [[UIView alloc] init];
        [self addSubview:_containerView];
        
        _imageView = [[TGImageView alloc] init];
        _imageView.userInteractionEnabled = true;
        [_containerView addSubview:_imageView];
        
        _overlayView = [[TGMessageImageViewOverlayView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)];
        [_imageView addSubview:_overlayView];
        
        self.clipsToBounds = true;
        
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
        [_containerView addGestureRecognizer:_tapGestureRecognizer];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    if (_downloadPath != nil)
        [ActionStageInstance() removeWatcher:self fromPath:_downloadPath];
    [_prefetchDisposable dispose];
}

- (void)prepareForRecycle
{
    [_acceleratedVideoView setPath:nil];
    [_acceleratedVideoView removeFromSuperview];
    _acceleratedVideoView = nil;
    
    [_imageView reset];
    [_player stop];
    _player = nil;
    
    if (_downloadPath != nil)
    {
        [ActionStageInstance() removeWatcher:self fromPath:_downloadPath];
        _downloadPath = nil;
    }
    
    _downloaded = false;
    _data = nil;
    _path = nil;
}

- (void)overlayButtonPressed
{
    if (!_downloaded && _downloadPath == nil)
        [self _download];
}

- (void)singleTap
{
    if ([self.item conformsToProtocol:@protocol(TGModernGallerySelectableItem)])
    {
        TGMediaSelectionContext *selectionContext = ((id<TGModernGallerySelectableItem>)self.item).selectionContext;
        id<TGMediaSelectableItem> item = ((id<TGModernGallerySelectableItem>)self.item).selectableMediaItem;
        
        [selectionContext toggleItemSelection:item animated:true sender:nil];
    }
}

- (void)setItem:(TGExternalGifSearchResultGalleryItem *)item synchronously:(bool)synchronously
{
    [super setItem:item synchronously:synchronously];
    
    _imageSize = item.webSearchResult.size;
    NSString *uri = [[NSString alloc] initWithFormat:@"web-search-thumbnail://?url=%@&width=%d&height=%d", [TGStringUtils stringByEscapingForURL:item.webSearchResult.thumbnailUrl], (int)_imageSize.width, (int)_imageSize.height];
    
    CGSize fittedSize = TGFitSize(_imageSize, self.frame.size);
    
    _containerView.frame = CGRectMake(CGFloor((_containerView.superview.frame.size.width - fittedSize.width) / 2.0f), CGFloor((_containerView.superview.frame.size.height - fittedSize.height) / 2.0f), fittedSize.width, fittedSize.height);
    CGRect imageFrame = CGRectMake(CGFloor((_imageView.superview.frame.size.width - fittedSize.width) / 2.0f), CGFloor((_imageView.superview.frame.size.height - fittedSize.height) / 2.0f), fittedSize.width, fittedSize.height);
    if (!CGRectEqualToRect(imageFrame, _imageView.frame))
        _imageView.frame = imageFrame;
    
    _overlayView.frame = CGRectMake(CGFloor((_imageView.frame.size.width - _overlayView.frame.size.width) / 2.0f), CGFloor((_imageView.frame.size.height - _overlayView.frame.size.height) / 2.0f), _overlayView.frame.size.height, _overlayView.frame.size.height);
    
    [_imageView loadUri:uri withOptions:@{TGImageViewOptionSynchronous: @(synchronously)}];
    
    _overlayView.hidden = true;
    
    _isVideo = true;
    
    if (_isVideo) {
        if (_acceleratedVideoView == nil) {
            _acceleratedVideoView = [[[TGVTAcceleratedVideoView videoViewClass] alloc] initWithFrame:_imageView.bounds];
            _acceleratedVideoView.userInteractionEnabled = false;
            _acceleratedVideoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [_imageView insertSubview:_acceleratedVideoView atIndex:0];
        }
    } else {
        [_acceleratedVideoView setPath:nil];
        [_acceleratedVideoView removeFromSuperview];
        _acceleratedVideoView = nil;
    }
    
    TGExternalGifSearchResultGalleryItem *checkingItem = item;
    __weak TGExternalGifSearchResultGalleryItemView *weakSelf = self;
    [[[TGMediaStoreContext instance] temporaryFilesCache] getValuePathForKey:[item.webSearchResult.originalUrl dataUsingEncoding:NSUTF8StringEncoding] completion:^(NSString *path)
    {
        TGDispatchOnMainThread(^
        {
            __strong TGExternalGifSearchResultGalleryItemView *strongSelf = weakSelf;
            if ([strongSelf.item isEqual:checkingItem])
            {
                if (strongSelf->_isVideo) {
                    if (path != nil) {
                        strongSelf->_path = path;
                        strongSelf->_downloaded = true;
                        strongSelf->_overlayView.hidden = true;
                        if (_isCurrent)
                            [strongSelf _playWithPath:path];
                    } else {
                        strongSelf->_downloaded = false;
                        strongSelf->_overlayView.hidden = false;
                        [strongSelf->_overlayView setProgress:0.0f cancelEnabled:false animated:true];
                    }
                } else {
                    NSData *data = [[NSData alloc] initWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
                    if (data != nil)
                    {
                        strongSelf->_data = data;
                        
                        strongSelf->_downloaded = true;
                        strongSelf->_overlayView.hidden = true;
                        if (_isCurrent)
                            [strongSelf _playWithData:data];
                    }
                    else
                    {
                        strongSelf->_downloaded = false;
                        strongSelf->_overlayView.hidden = false;
                        [strongSelf->_overlayView setProgress:0.0f cancelEnabled:false animated:true];
                    }
                }
            }
        });
    }];
}

- (void)_download
{
    [_overlayView setProgress:0.0f cancelEnabled:false animated:true];
    
    TGExternalGifSearchResultGalleryItem *item = (TGExternalGifSearchResultGalleryItem *)self.item;
    NSString *url = nil;
    url = item.webSearchResult.originalUrl;
    
    _downloadPath = [[NSString alloc] initWithFormat:@"/temporaryDownload/(%@,%@)", [TGStringUtils stringByEscapingForActorURL:url], _isVideo ? @"path" : @"data"];
    [ActionStageInstance() requestActor:_downloadPath options:@{@"url": url, @"cache": [[TGMediaStoreContext instance] temporaryFilesCache], @"returnPath": @(_isVideo), @"mediaTypeTag": @(TGNetworkMediaTypeTagDocument)} flags:0 watcher:self];
    
    if (_prefetchDisposable == nil) {
        _prefetchDisposable = [[SMetaDisposable alloc] init];
    }
#ifndef DEBUG
    [_prefetchDisposable setDisposable:[[TGWebpageSignals webpagePreview:item.webSearchResult.url] startWithNext:nil]];
#endif
}

- (void)_playWithData:(NSData *)data
{
    _player = [[TGModernAnimatedImagePlayer alloc] initWithSize:_imageSize data:data];
    __weak TGExternalGifSearchResultGalleryItemView *weakSelf = self;
    _player.frameReady = ^(UIImage *image)
    {
        __strong TGExternalGifSearchResultGalleryItemView *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf->_imageView loadUri:@"embedded-image://" withOptions:@{TGImageViewOptionEmbeddedImage: image}];
    };
    [_player play];
}

- (void)_playWithPath:(NSString *)path {
    [_acceleratedVideoView setPath:path];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGSize fittedSize = TGFitSize(_imageSize, self.frame.size);
    
    _containerView.frame = CGRectMake(CGFloor((_containerView.superview.frame.size.width - fittedSize.width) / 2.0f), CGFloor((_containerView.superview.frame.size.height - fittedSize.height) / 2.0f), fittedSize.width, fittedSize.height);
    CGRect imageFrame = CGRectMake(CGFloor((_imageView.superview.frame.size.width - fittedSize.width) / 2.0f), CGFloor((_imageView.superview.frame.size.height - fittedSize.height) / 2.0f), fittedSize.width, fittedSize.height);
    if (!CGRectEqualToRect(imageFrame, _imageView.frame))
        _imageView.frame = imageFrame;
    
    _overlayView.frame = CGRectMake(CGFloor((_imageView.frame.size.width - _overlayView.frame.size.width) / 2.0f), CGFloor((_imageView.frame.size.height - _overlayView.frame.size.height) / 2.0f), _overlayView.frame.size.height, _overlayView.frame.size.height);
}

- (UIView *)transitionView
{
    return _imageView;
}

- (CGRect)transitionViewContentRect
{
    return _imageView.bounds;
}

- (void)setIsCurrent:(bool)isCurrent
{
    if (isCurrent)
    {
        if (_downloaded)
        {
            if (_isVideo) {
                if (_path != nil) {
                    [self _playWithPath:_path];
                }
            } else {
                if (_player != nil)
                    [_player play];
                else if (_data != nil)
                    [self _playWithData:_data];
            }
        }
        else if (_downloadPath == nil)
        {
            [self _download];
        }
    }
    else
    {
        if (_isVideo) {
            [_acceleratedVideoView setPath:nil];
        } else {
            [_player pause];
        }
        
        if (_downloadPath != nil)
        {
            [ActionStageInstance() removeWatcher:self fromPath:_downloadPath];
            _downloadPath = nil;
            
            [_overlayView setProgress:0.0f cancelEnabled:false animated:true];
        }
    }
}


- (void)actorMessageReceived:(NSString *)path messageType:(NSString *)messageType message:(id)message
{
    if ([messageType isEqualToString:@"progress"])
    {
        TGDispatchOnMainThread(^
        {
            if ([path isEqualToString:_downloadPath])
            {
                [_overlayView setProgress:[message floatValue] cancelEnabled:false animated:true];
            }
        });
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    TGDispatchOnMainThread(^
    {
        if ([path isEqualToString:_downloadPath])
        {
            _downloadPath = nil;
            
            if (status == ASStatusSuccess)
            {
                _downloaded = true;
                _overlayView.hidden = true;
                
                if (_isVideo) {
                    _path = result;
                    [self _playWithPath:result];
                } else {
                    _data = result;
                    [self _playWithData:result];
                }
            }
            else
            {
                [_overlayView setDownload];
            }
        }
    });
}

@end
