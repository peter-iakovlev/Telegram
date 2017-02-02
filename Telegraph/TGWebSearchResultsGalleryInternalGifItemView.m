#import "TGWebSearchResultsGalleryInternalGifItemView.h"

#import "TGWebSearchResultsGalleryInternalGifItem.h"

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

#import "TGImageInfo.h"

#import "TGPreparedLocalDocumentMessage.h"
#import "TGDocumentMediaAttachment.h"

@interface TGWebSearchResultsGalleryInternalGifItemView () <ASWatcher>
{
    UIView *_containerView;
    TGImageView *_imageView;
    TGModernAnimatedImagePlayer *_player;
    
    CGSize _imageSize;
    
    TGMessageImageViewOverlayView *_overlayView;
    
    NSString *_downloadPath;
    bool _downloaded;
    bool _isCurrent;
    NSData *_data;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGWebSearchResultsGalleryInternalGifItemView

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

- (void)setItem:(TGWebSearchResultsGalleryInternalGifItem *)item synchronously:(bool)synchronously
{
    [super setItem:item synchronously:synchronously];
    
    CGSize thumbnailSize = CGSizeZero;
    [item.webSearchResult.thumbnailInfo imageUrlForLargestSize:&thumbnailSize];
    thumbnailSize = TGFillSize(thumbnailSize, CGSizeMake(400, 400));
    
    _imageSize = TGFitSize(thumbnailSize, CGSizeMake(400, 400));
    
    NSString *filePreviewUri = nil;
    
    CGSize dimensions = CGSizeZero;
    NSString *legacyThumbnailCacheUri = [item.webSearchResult.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:&dimensions];
    dimensions.width *= 10.0f;
    dimensions.height *= 10.0f;
    
    if ((item.webSearchResult.documentId != 0) && legacyThumbnailCacheUri.length != 0)
    {
        NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"file-thumbnail://?"];
        if (item.webSearchResult.documentId != 0)
            [previewUri appendFormat:@"id=%" PRId64 "", item.webSearchResult.documentId];
        
        [previewUri appendFormat:@"&file-name=%@", [item.webSearchResult.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        CGSize renderSize = CGSizeZero;
        if (dimensions.width < dimensions.height)
        {
            renderSize.height = CGFloor((dimensions.height * thumbnailSize.width / dimensions.width));
            renderSize.width = thumbnailSize.width;
        }
        else
        {
            renderSize.width = CGFloor((dimensions.width * thumbnailSize.height / dimensions.height));
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
    
    [_imageView loadUri:uri withOptions:@{}];
    
    _overlayView.hidden = true;
    
    TGWebSearchResultsGalleryInternalGifItem *checkingItem = item;
    __weak TGWebSearchResultsGalleryInternalGifItemView *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSString *filePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:checkingItem.webSearchResult.documentId version:0] stringByAppendingPathComponent:[TGDocumentMediaAttachment safeFileNameForFileName:checkingItem.webSearchResult.fileName]];
        NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
        
        TGDispatchOnMainThread(^
        {
            __strong TGWebSearchResultsGalleryInternalGifItemView *strongSelf = weakSelf;
            if ([strongSelf.item isEqual:checkingItem])
            {
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
                    _downloaded = false;
                    strongSelf->_overlayView.hidden = false;
                    [strongSelf->_overlayView setProgress:0.0f cancelEnabled:false animated:true];
                }
            }
        });
    });
}

- (void)_download
{
    [_overlayView setProgress:0.0f cancelEnabled:false animated:true];
}

- (void)_playWithData:(NSData *)data
{
    _player = [[TGModernAnimatedImagePlayer alloc] initWithSize:_imageSize data:data];
    __weak TGWebSearchResultsGalleryInternalGifItemView *weakSelf = self;
    _player.frameReady = ^(UIImage *image)
    {
        __strong TGWebSearchResultsGalleryInternalGifItemView *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf->_imageView loadUri:@"embedded-image://" withOptions:@{TGImageViewOptionEmbeddedImage: image}];
    };
    [_player play];
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
            if (_player != nil)
                [_player play];
            else if (_data != nil)
                [self _playWithData:_data];
        }
        else if (_downloadPath == nil)
        {
            [self _download];
        }
    }
    else
    {
        [_player pause];
        
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
                _data = result;
                _overlayView.hidden = true;
                [self _playWithData:result];
            }
            else
            {
                [_overlayView setDownload];
            }
        }
    });
}

@end
