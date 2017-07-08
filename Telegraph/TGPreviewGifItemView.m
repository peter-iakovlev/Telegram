#import "TGPreviewGifItemView.h"

#import "ActionStage.h"

#import "TGStringUtils.h"
#import "TGImageUtils.h"
#import "TGPhotoEditorUtils.h"

#import "TGSharedPhotoSignals.h"
#import "TGSharedMediaUtils.h"
#import "TGMediaStoreContext.h"

#import "TGImageView.h"
#import "TGVTAcceleratedVideoView.h"
#import "TGMessageImageViewOverlayView.h"

#import "TGDocumentMediaAttachment.h"
#import "TGPreparedLocalDocumentMessage.h"
#import "TGBotContextExternalResult.h"

#import "TGTelegraph.h"
#import "TGGifConverter.h"

#import "TGTelegramNetworking.h"

@interface TGPreviewGifItemView () <ASWatcher>
{
    TGDocumentMediaAttachment *_document;
    TGBotContextExternalResult *_result;
    
    TGImageView *_imageView;
    UIView<TGInlineVideoPlayerView> *_videoView;
    TGMessageImageViewOverlayView *_overlayView;
    
    NSString *_downloadPath;
    SMetaDisposable *_converterDisposable;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGPreviewGifItemView

- (instancetype)init
{
    self = [super initWithType:TGMenuSheetItemTypeDefault];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _imageView = [[TGImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = true;
        [self addSubview:_imageView];
        
        _overlayView = [[TGMessageImageViewOverlayView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 24.0f, 24.0f)];
        _overlayView.hidden = true;
        [_overlayView setRadius:24.0f];
        [self addSubview:_overlayView];
    }
    return self;
}

- (instancetype)initWithDocument:(TGDocumentMediaAttachment *)document
{
    self = [self init];
    if (self != nil)
    {
        _document = document;
    }
    return self;
}

- (instancetype)initWithBotContextExternalResult:(TGBotContextExternalResult *)result
{
    self = [self init];
    if (self != nil)
    {
        _result = result;
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    [_converterDisposable dispose];
}

#pragma mark - 


- (void)menuView:(TGMenuSheetView *)menuView willAppearAnimated:(bool)animated
{
    [super menuView:menuView willAppearAnimated:animated];
    
    [self loadThumbnail];
    [self setNeedsLayout];
    [self checkAndPlay:true];
}

- (void)menuView:(TGMenuSheetView *)__unused menuView didDisappearAnimated:(bool)__unused animated
{
    [super menuView:menuView didDisappearAnimated:animated];
    
    [self stopAnimationAndDownload];
}

#pragma mark -

- (CGSize)_dimensions
{
    if (_document != nil)
    {
        CGSize dimensions = CGSizeZero;
        [_document.thumbnailInfo closestImageUrlWithSize:CGSizeMake(100.0f, 100.0f) resultingSize:&dimensions pickLargest:true];
        dimensions.width *= 100.0f;
        dimensions.height *= 100.0f;
        
        for (id attribute in _document.attributes)
        {
            if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]])
            {
                dimensions = ((TGDocumentAttributeImageSize *)attribute).size;
                break;
            }
            else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]])
            {
                dimensions = ((TGDocumentAttributeVideo *)attribute).size;
                break;
            }
        }
        
        return dimensions;
    }
    else if (_result != nil)
    {
        return _result.size;
    }
    
    return CGSizeZero;
}

- (void)stopAnimationAndDownload
{
    [_videoView setPath:nil];
    [_videoView removeFromSuperview];
    _videoView = nil;
    [_converterDisposable setDisposable:nil];
    
    if (_downloadPath != nil)
    {
        [ActionStageInstance() removeWatcher:self fromPath:_downloadPath];
        _downloadPath = nil;
    }
    
    _overlayView.hidden = true;
    [_overlayView setNone];
}

- (void)loadThumbnail
{
    CGSize fitSize = CGSizeMake(128.0f, 128.0f);
    if (_document != nil)
    {
        CGSize dimensions = [self _dimensions];
        NSString *legacyThumbnailCacheUri = [_document.thumbnailInfo closestImageUrlWithSize:CGSizeMake(100.0f, 100.0f) resultingSize:&dimensions pickLargest:true];
        
        CGSize renderSize = CGSizeZero;
        if (dimensions.width < dimensions.height)
        {
            renderSize.height = CGFloor((dimensions.height * fitSize.width / dimensions.width));
            renderSize.width = fitSize.width;
        }
        else
        {
            renderSize.width = CGFloor((dimensions.width * fitSize.height / dimensions.height));
            renderSize.height = fitSize.height;
        }
        
        legacyThumbnailCacheUri = [_document.thumbnailInfo closestImageUrlWithSize:renderSize resultingSize:&dimensions pickLargest:true];
        
        NSString *filePreviewUri = nil;
        
        if ((_document.documentId != 0) && legacyThumbnailCacheUri.length != 0)
        {
            NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"file-thumbnail://?"];
            if (_document.documentId != 0)
                [previewUri appendFormat:@"id=%" PRId64 "", _document.documentId];
            
            [previewUri appendFormat:@"&file-name=%@", [_document.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [previewUri appendFormat:@"&video-file-name=%@", [_document.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)renderSize.width, (int)renderSize.height, (int)renderSize.width, (int)renderSize.height];
            
            if (legacyThumbnailCacheUri != nil)
                [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUri];
            
            filePreviewUri = previewUri;
        }
        
        [_imageView loadUri:filePreviewUri withOptions:@{TGImageViewOptionKeepCurrentImageAsPlaceholder: @true}];
    }
    else
    {
        CGSize imageSize = TGFitSize(_result.size, fitSize);
        NSString *thumbnailUrl = _result.thumbUrl;
        if (thumbnailUrl.length == 0)
        {
            if ([_result.type isEqualToString:@"photo"])
                thumbnailUrl = _result.originalUrl;
        }
        
        [_imageView setSignal:[TGSharedPhotoSignals cachedExternalThumbnail:thumbnailUrl size:imageSize pixelProcessingBlock:nil cacheVariantKey:@"mediaContextPanel" threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] diskCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache]]];
    }
}

- (void)checkAndPlay:(bool)download
{
    __weak TGPreviewGifItemView *weakSelf = self;
    
    if (_document != nil)
    {
        TGDocumentMediaAttachment *document = _document;
        [_converterDisposable setDisposable:nil];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
        {
            NSString *filePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:_document.documentId version:_document.version] stringByAppendingPathComponent:[TGDocumentMediaAttachment safeFileNameForFileName:_document.fileName]];
            
            bool exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
            
            TGDispatchOnMainThread(^
            {
                __strong TGPreviewGifItemView *strongSelf = weakSelf;
                if (strongSelf != nil && [document isEqual:strongSelf->_document])
                {
                    if (exists) {
                        if ([document.mimeType isEqualToString:@"video/mp4"]) {
                            [strongSelf->_videoView removeFromSuperview];
                            strongSelf->_videoView = [[[TGVTAcceleratedVideoView videoViewClass] alloc] initWithFrame:strongSelf->_imageView.bounds];
                            [strongSelf addSubview:strongSelf->_videoView];
                            [strongSelf->_videoView setPath:filePath];
                        } else if ([document.mimeType isEqualToString:@"image/gif"]) {
                            NSString *videoPath = [filePath stringByAppendingString:@".mov"];
                            
                            NSString *key = [@"gif-video-path:" stringByAppendingString:filePath];
                            
                            SSignal *videoSignal = [[SSignal defer:^SSignal *{
                                if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath isDirectory:NULL]) {
                                    return [SSignal single:videoPath];
                                } else {
                                    return [TGTelegraphInstance.genericTasksSignalManager multicastedSignalForKey:key producer:^SSignal *{
                                        SSignal *dataSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
                                            NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
                                            if (data != nil) {
                                                [subscriber putNext:data];
                                                [subscriber putCompletion];
                                            } else {
                                                [subscriber putError:nil];
                                            }
                                            return nil;
                                        }];
                                        return [dataSignal mapToSignal:^SSignal *(NSData *data) {
                                            return [[TGGifConverter convertGifToMp4:data] mapToSignal:^SSignal *(NSString *tempPath) {
                                                return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subsctiber) {
                                                    NSError *error = nil;
                                                    [[NSFileManager defaultManager] moveItemAtPath:tempPath toPath:videoPath error:&error];
                                                    if (error != nil) {
                                                        [subsctiber putError:nil];
                                                    } else {
                                                        [subsctiber putNext:videoPath];
                                                        [subsctiber putCompletion];
                                                    }
                                                    return nil;
                                                }];
                                            }];
                                        }];
                                    }];
                                }
                            }] startOn:[SQueue concurrentDefaultQueue]];
                            
                            [strongSelf->_converterDisposable setDisposable:[[videoSignal deliverOn:[SQueue mainQueue]] startWithNext:^(NSString *path) {
                                __strong TGPreviewGifItemView *strongSelf = weakSelf;
                                if (strongSelf != nil && [strongSelf->_document isEqual:document])
                                {
                                    [strongSelf->_videoView removeFromSuperview];
                                    strongSelf->_videoView = [[[TGVTAcceleratedVideoView videoViewClass] alloc] initWithFrame:strongSelf.bounds];
                                    [strongSelf addSubview:strongSelf->_videoView];
                                    [strongSelf->_videoView setPath:path];
                                }
                            }]];
                        }
                    } else if (download) {
                        [strongSelf download];
                    }
                }
            });
        });
    }
    else if (_result != nil)
    {
        TGBotContextExternalResult *externalResult = (TGBotContextExternalResult *)_result;
        if ([externalResult.type isEqualToString:@"gif"] || [externalResult.type isEqualToString:@"gifv"]) {
            [[[TGMediaStoreContext instance] temporaryFilesCache] getValuePathForKey:[externalResult.originalUrl dataUsingEncoding:NSUTF8StringEncoding] completion:^(NSString *path) {
                TGDispatchOnMainThread(^{
                    __strong TGPreviewGifItemView *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        TGBotContextExternalResult *currentExternalResult = nil;
                        if ([strongSelf->_result isKindOfClass:[TGBotContextExternalResult class]]) {
                            currentExternalResult = (TGBotContextExternalResult *)strongSelf->_result;
                        }
                        if ([externalResult.resultId isEqualToString:currentExternalResult.resultId]) {
                            if (path != nil) {
                                if ([externalResult.contentType isEqualToString:@"video/mp4"]) {
                                    [strongSelf->_videoView removeFromSuperview];
                                    strongSelf->_videoView = [[[TGVTAcceleratedVideoView videoViewClass] alloc] initWithFrame:strongSelf.bounds];
                                    [strongSelf insertSubview:strongSelf->_videoView aboveSubview:strongSelf->_overlayView];
                                    [strongSelf->_videoView setPath:path];
                                }
                            } else if (download) {
                                [strongSelf download];
                            }
                        }
                    }
                });
            }];
        }
    }
}

- (void)download
{
    _overlayView.hidden = false;
    [_overlayView setProgress:0.0f cancelEnabled:false animated:true];
 
    if (_document != nil)
    {
        NSString *path = [NSString stringWithFormat:@"/tg/media/document/(%d:%" PRId64 ":%@)", _document.datacenterId, _document.documentId, _document.documentUri.length != 0 ? _document.documentUri : @""];
        _downloadPath = path;
        
        [ActionStageInstance() requestActor:path options:@{@"documentAttachment": _document} flags:0 watcher:self];
    }
    else if (_result != nil)
    {
        _overlayView.hidden = false;
        [_overlayView setProgress:0.0f cancelEnabled:false animated:true];
        
        _downloadPath = [[NSString alloc] initWithFormat:@"/temporaryDownload/(%@,%@)", [TGStringUtils stringByEscapingForActorURL:_result.originalUrl], @"path"];
        [ActionStageInstance() requestActor:_downloadPath options:@{@"url": _result.originalUrl, @"cache": [[TGMediaStoreContext instance] temporaryFilesCache], @"returnPath": @true, @"mediaTypeTag": @(TGNetworkMediaTypeTagDocument)} flags:0 watcher:self];
    }
}

- (void)actorMessageReceived:(NSString *)path messageType:(NSString *)messageType message:(id)message
{
    if ([messageType isEqualToString:@"progress"])
    {
        TGDispatchOnMainThread(^
        {
            if ([path isEqualToString:_downloadPath])
                [_overlayView setProgress:[message floatValue] cancelEnabled:false animated:true];
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
                _overlayView.hidden = true;
                [_overlayView setNone];
                
                [self loadThumbnail];
                [self checkAndPlay:false];
            }
            else
            {
                [_overlayView setDownload];
            }
        }
    });
}

#pragma mark - 

- (CGFloat)preferredHeightForWidth:(CGFloat)width screenHeight:(CGFloat)__unused screenHeight
{
    CGSize size = TGScaleToSize([self _dimensions], CGSizeMake(width, width * 1.33f));
    return size.height;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _imageView.frame = self.bounds;
    _videoView.frame = self.bounds;
    _overlayView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

@end
