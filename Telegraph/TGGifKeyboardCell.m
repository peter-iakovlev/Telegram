#import "TGGifKeyboardCell.h"

#import "ActionStage.h"

#import "TGDocumentMediaAttachment.h"
#import "TGImageView.h"
#import "TGVTAcceleratedVideoView.h"

#import "TGPreparedLocalDocumentMessage.h"

#import "TGGifConverter.h"
#import "TGTelegraph.h"

#import "TGMessageImageViewOverlayView.h"

@interface TGGifKeyboardCellContents () <ASWatcher> {
    TGImageView *_imageView;
    UIView<TGInlineVideoPlayerView> *_videoView;
    SMetaDisposable *_converterDisposable;
    
    TGMessageImageViewOverlayView *_overlayView;
    
    NSString *_downloadPath;
}

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic) bool enableAnimation;

@end

@implementation TGGifKeyboardCellContents

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _imageView = [[TGImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = true;
        [self addSubview:_imageView];
        
        _overlayView = [[TGMessageImageViewOverlayView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 24.0f, 24.0f)];
        _overlayView.hidden = true;
        [_overlayView setRadius:24.0f];
        [self addSubview:_overlayView];
        
        _converterDisposable = [[SMetaDisposable alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    [_converterDisposable dispose];
}

- (void)prepareForReuse {
    _document = nil;
    
    [_imageView reset];
    
    [self stopAnimationAndDownload];
    
}

- (void)stopAnimationAndDownload {
    [_videoView setPath:nil];
    [_videoView removeFromSuperview];
    _videoView = nil;
    [_converterDisposable setDisposable:nil];
    
    if (_downloadPath != nil) {
        [ActionStageInstance() removeWatcher:self fromPath:_downloadPath];
        _downloadPath = nil;
    }
    
    _overlayView.hidden = true;
    [_overlayView setNone];
}

- (void)setDocument:(TGDocumentMediaAttachment *)document {
    _document = document;
    
    _overlayView.hidden = true;
    [_overlayView setNone];
    
    [self loadThumbnail];
    if (_enableAnimation) {
        [self checkAndPlay:true];
    }
}

- (void)setEnableAnimation:(bool)enableAnimation {
    if (_enableAnimation != enableAnimation) {
        _enableAnimation = enableAnimation;
        
        if (enableAnimation) {
            [self checkAndPlay:true];
        } else {
            [self stopAnimationAndDownload];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    _imageView.frame = bounds;
    _videoView.frame = bounds;
    
    _overlayView.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
}

- (void)loadThumbnail {
    CGSize dimensions = CGSizeZero;
    NSString *legacyThumbnailCacheUri = [_document.thumbnailInfo closestImageUrlWithSize:CGSizeMake(100.0f, 100.0f) resultingSize:&dimensions pickLargest:true];
    dimensions.width *= 100.0f;
    dimensions.height *= 100.0f;
    
    for (id attribute in _document.attributes) {
        if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]]) {
            dimensions = ((TGDocumentAttributeImageSize *)attribute).size;
            break;
        } else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
            dimensions = ((TGDocumentAttributeVideo *)attribute).size;
            break;
        }
    }
    
    CGSize thumbnailSize = CGSizeMake(120.0f, 120.0f);
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
    
    legacyThumbnailCacheUri = [_document.thumbnailInfo closestImageUrlWithSize:renderSize resultingSize:&dimensions pickLargest:true];
    
    NSString *filePreviewUri = nil;
    
    if ((_document.documentId != 0) && legacyThumbnailCacheUri.length != 0)
    {
        NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"file-thumbnail://?"];
        if (_document.documentId != 0) {
            [previewUri appendFormat:@"id=%" PRId64 "", _document.documentId];
        }
        
        [previewUri appendFormat:@"&file-name=%@", [_document.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [previewUri appendFormat:@"&video-file-name=%@", [_document.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)renderSize.width, (int)renderSize.height, (int)renderSize.width, (int)renderSize.height];
        
        if (legacyThumbnailCacheUri != nil)
            [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUri];
        
        filePreviewUri = previewUri;
    }
    
    [_imageView loadUri:filePreviewUri withOptions:@{TGImageViewOptionKeepCurrentImageAsPlaceholder: @true}];
}

- (void)checkAndPlay:(bool)download {
    __weak TGGifKeyboardCellContents *weakSelf = self;
    TGDocumentMediaAttachment *document = _document;
    [_converterDisposable setDisposable:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSString *filePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:_document.documentId version:_document.version] stringByAppendingPathComponent:[TGDocumentMediaAttachment safeFileNameForFileName:_document.fileName]];
        
        bool exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        
        TGDispatchOnMainThread(^
        {
            __strong TGGifKeyboardCellContents *strongSelf = weakSelf;
            if (strongSelf != nil && [document isEqual:strongSelf->_document])
            {
                if (exists) {
                    if ([document.mimeType isEqualToString:@"video/mp4"]) {
                        [strongSelf->_videoView removeFromSuperview];
                        strongSelf->_videoView = [[[TGVTAcceleratedVideoView videoViewClass] alloc] initWithFrame:strongSelf.bounds];
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
                            __strong TGGifKeyboardCellContents *strongSelf = weakSelf;
                            if (strongSelf != nil && [strongSelf->_document isEqual:document]) {
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

- (void)download
{
    if (_document != nil) {
        _overlayView.hidden = false;
        [_overlayView setProgress:0.0f cancelEnabled:false animated:true];
        
        NSString *path = [NSString stringWithFormat:@"/tg/media/document/(%d:%" PRId64 ":%@)", _document.datacenterId, _document.documentId, _document.documentUri.length != 0 ? _document.documentUri : @""];
        _downloadPath = path;
        
        [ActionStageInstance() requestActor:path options:@{@"documentAttachment": _document} flags:0 watcher:self];
    }
}

- (void)actorMessageReceived:(NSString *)path messageType:(NSString *)messageType message:(id)message {
    if ([messageType isEqualToString:@"progress"]) {
        TGDispatchOnMainThread(^{
            if ([path isEqualToString:_downloadPath]) {
                [_overlayView setProgress:[message floatValue] cancelEnabled:false animated:true];
            }
        });
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)__unused result {
    TGDispatchOnMainThread(^ {
        if ([path isEqualToString:_downloadPath])
        {
            _downloadPath = nil;
            
            if (status == ASStatusSuccess) {
                _overlayView.hidden = true;
                [_overlayView setNone];
                
                [self loadThumbnail];
                [self checkAndPlay:false];
            } else {
                [_overlayView setDownload];
            }
        }
    });
}

@end

@interface TGGifKeyboardCell () {
    bool _highlighted;
}

@end

@implementation TGGifKeyboardCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _contents = [[TGGifKeyboardCellContents alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_contents];
    }
    return self;
}

- (void)dealloc {
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [_contents prepareForReuse];
}

- (void)setDocument:(TGDocumentMediaAttachment *)document {
    if (_contents == nil) {
        _contents = [[TGGifKeyboardCellContents alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_contents];
    }
    [_contents setDocument:document];
}

- (TGGifKeyboardCellContents *)_takeContents {
    TGGifKeyboardCellContents *contents = _contents;
    [contents removeFromSuperview];
    _contents = nil;
    return contents;
}

- (void)_putContents:(TGGifKeyboardCellContents *)contents {
    [_contents prepareForReuse];
    [_contents removeFromSuperview];
    _contents = contents;
    if (_contents != nil) {
        _contents.frame = self.bounds;
        [self.contentView addSubview:_contents];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _contents.frame = self.bounds;
}

- (void)setEnableAnimation:(bool)enableAnimation {
    _enableAnimation = enableAnimation;
    _contents.enableAnimation = enableAnimation;
}

- (void)setHighlighted:(bool)highlighted animated:(bool)__unused animated
{
    if (_highlighted != highlighted)
    {
        _highlighted = highlighted;
        
        if (iosMajorVersion() >= 8)
        {
            [UIView animateWithDuration:0.6 delay:0.0 usingSpringWithDamping:0.6f initialSpringVelocity:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^
             {
                 if (_highlighted)
                     _contents.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
                 else
                     _contents.transform = CGAffineTransformIdentity;
             } completion:nil];
        }
    }
}

@end
