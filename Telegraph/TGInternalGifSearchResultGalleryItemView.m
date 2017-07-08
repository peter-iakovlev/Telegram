#import "TGInternalGifSearchResultGalleryItemView.h"

#import "TGInternalGifSearchResultGalleryItem.h"

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

#import "TGPreparedLocalDocumentMessage.h"

#import "TGMediaSelectionContext.h"

@interface TGInternalGifSearchResultGalleryItemView () <ASWatcher> {
    UIView *_containerView;
    TGImageView *_imageView;
    TGModernAnimatedImagePlayer *_player;
    UIView<TGInlineVideoPlayerView> *_acceleratedVideoView;
    
    CGSize _imageSize;
    
    TGMessageImageViewOverlayView *_overlayView;
    
    NSString *_downloadPath;
    bool _downloaded;
    bool _isCurrent;
    bool _isVideo;
    NSData *_data;
    NSString *_path;
    
    UITapGestureRecognizer *_tapGestureRecognizer;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGInternalGifSearchResultGalleryItemView

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
        
        _acceleratedVideoView = [[[TGVTAcceleratedVideoView videoViewClass] alloc] init];
        _acceleratedVideoView.userInteractionEnabled = false;
        _acceleratedVideoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_imageView addSubview:_acceleratedVideoView];
        
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
}

- (void)prepareForRecycle
{
    [_acceleratedVideoView setPath:nil];
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

- (void)setItem:(TGInternalGifSearchResultGalleryItem *)item synchronously:(bool)synchronously
{
    [super setItem:item synchronously:synchronously];
    
    CGSize thumbnailSize = CGSizeZero;
    [item.webSearchResult.document.thumbnailInfo imageUrlForLargestSize:&thumbnailSize];
    thumbnailSize = TGFillSize(thumbnailSize, CGSizeMake(400, 400));
    
    _imageSize = TGFitSize(thumbnailSize, CGSizeMake(400, 400));
    
    NSString *filePreviewUri = nil;
    
    CGSize dimensions = CGSizeZero;
    NSString *legacyThumbnailCacheUri = [item.webSearchResult.document.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:&dimensions];
    dimensions.width *= 10.0f;
    dimensions.height *= 10.0f;
    
    _isVideo = false;
    
    if ([item.webSearchResult.document.mimeType isEqualToString:@"video/mp4"]) {
        _isVideo = true;
    }
    
    if ((item.webSearchResult.document.documentId != 0) && legacyThumbnailCacheUri.length != 0)
    {
        NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"file-thumbnail://?"];
        if (item.webSearchResult.document.documentId != 0)
            [previewUri appendFormat:@"id=%" PRId64 "", item.webSearchResult.document.documentId];
        
        [previewUri appendFormat:@"&file-name=%@", [item.webSearchResult.document.safeFileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        if (_isVideo) {
            [previewUri appendFormat:@"&video-file-name=%@", [item.webSearchResult.document.safeFileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        
        CGSize renderSize = CGSizeZero;
        if (dimensions.width < dimensions.height)
        {
            renderSize.height = CGCeil((dimensions.height * thumbnailSize.width / dimensions.width));
            renderSize.width = thumbnailSize.width;
        }
        else
        {
            renderSize.width = CGCeil((dimensions.width * thumbnailSize.height / dimensions.height));
            renderSize.height = thumbnailSize.height;
        }
        
        [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
        
        if (legacyThumbnailCacheUri != nil)
            [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUri];
        
        filePreviewUri = previewUri;
    }
    
    NSString *uri = filePreviewUri;
    
    CGSize fittedSize = TGFitSize(_imageSize, self.frame.size);
    
    _containerView.frame = CGRectMake(CGFloor((_containerView.superview.frame.size.width - fittedSize.width) / 2.0f), CGFloor((_containerView.superview.frame.size.height - fittedSize.height) / 2.0f), fittedSize.width, fittedSize.height);
    CGRect imageFrame = CGRectMake(CGFloor((_imageView.superview.frame.size.width - fittedSize.width) / 2.0f), CGFloor((_imageView.superview.frame.size.height - fittedSize.height) / 2.0f), fittedSize.width, fittedSize.height);
    if (!CGRectEqualToRect(imageFrame, _imageView.frame))
        _imageView.frame = imageFrame;
    
    _overlayView.frame = CGRectMake(CGFloor((_imageView.frame.size.width - _overlayView.frame.size.width) / 2.0f), CGFloor((_imageView.frame.size.height - _overlayView.frame.size.height) / 2.0f), _overlayView.frame.size.height, _overlayView.frame.size.height);
    
    [_imageView loadUri:uri withOptions:@{TGImageViewOptionSynchronous: @(true)}];
    
    _overlayView.hidden = true;
    
    _acceleratedVideoView.hidden = !_isVideo;
    
    NSString *filePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:item.webSearchResult.document.documentId version:item.webSearchResult.document.version] stringByAppendingPathComponent:[TGDocumentMediaAttachment safeFileNameForFileName:item.webSearchResult.document.fileName]];
    bool isVideo = _isVideo;
    
    TGInternalGifSearchResultGalleryItem *checkingItem = item;
    __weak TGInternalGifSearchResultGalleryItemView *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        bool exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        NSData *data = nil;
        
        if (!isVideo && exists) {
            data = [[NSData alloc] initWithContentsOfFile:filePath];
        }
        
        TGDispatchOnMainThread(^
        {
            __strong TGInternalGifSearchResultGalleryItemView *strongSelf = weakSelf;
            if ([strongSelf.item isEqual:checkingItem])
            {
                if (isVideo) {
                    if (exists) {
                        strongSelf->_path = filePath;
                        
                        strongSelf->_downloaded = true;
                        strongSelf->_overlayView.hidden = true;
                        if (strongSelf->_isCurrent)
                            [strongSelf _playWithPath:filePath];
                    } else {
                        strongSelf->_downloaded = false;
                        strongSelf->_overlayView.hidden = false;
                        [strongSelf->_overlayView setProgress:0.0f cancelEnabled:false animated:true];
                    }
                } else {
                    if (data != nil)
                    {
                        strongSelf->_data = data;
                        
                        strongSelf->_downloaded = true;
                        strongSelf->_overlayView.hidden = true;
                        if (strongSelf->_isCurrent)
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
    });
}

- (void)_download
{
    [_overlayView setProgress:0.0f cancelEnabled:false animated:true];
    
    TGInternalGifSearchResultGalleryItem *item = (TGInternalGifSearchResultGalleryItem *)self.item;
    if (item.webSearchResult.document != nil) {
        NSString *path = [NSString stringWithFormat:@"/tg/media/document/(%d:%" PRId64 ":%@)", item.webSearchResult.document.datacenterId, item.webSearchResult.document.documentId, item.webSearchResult.document.documentUri.length != 0 ? item.webSearchResult.document.documentUri : @""];
        _downloadPath = path;
        
        [ActionStageInstance() requestActor:path options:@{@"documentAttachment": item.webSearchResult.document} flags:TGActorRequestChangePriority watcher:self];
    }
}

- (void)_playWithData:(NSData *)data
{
    _player = [[TGModernAnimatedImagePlayer alloc] initWithSize:_imageSize data:data];
    __weak TGInternalGifSearchResultGalleryItemView *weakSelf = self;
    _player.frameReady = ^(UIImage *image)
    {
        __strong TGInternalGifSearchResultGalleryItemView *strongSelf = weakSelf;
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

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)__unused result
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
                
                TGInternalGifSearchResultGalleryItem *item = (TGInternalGifSearchResultGalleryItem *)self.item;
                
                if (_isVideo) {
                    NSString *filePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:item.webSearchResult.document.documentId version:item.webSearchResult.document.version] stringByAppendingPathComponent:item.webSearchResult.document.safeFileName];
                    _path = filePath;
                    
                    [self _playWithPath:filePath];
                } else {
                    NSString *filePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:item.webSearchResult.document.documentId version:item.webSearchResult.document.version] stringByAppendingPathComponent:[TGDocumentMediaAttachment safeFileNameForFileName:item.webSearchResult.document.fileName]];
                    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
                    _data = data;
                    
                    [self _playWithData:data];
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
