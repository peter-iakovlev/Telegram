#import "TGAnimatedMediaContextResultCell.h"

#import "ActionStage.h"

#import "TGBotContextExternalResult.h"
#import "TGBotContextDocumentResult.h"
#import "TGBotContextImageResult.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "TGImageView.h"
#import "TGVTAcceleratedVideoView.h"

#import "TGSharedPhotoSignals.h"
#import "TGSharedMediaUtils.h"

#import "TGPreparedLocalDocumentMessage.h"
#import "TGTelegraph.h"
#import "TGGifConverter.h"

#import "TGMediaStoreContext.h"

#import "TGMessageImageViewOverlayView.h"

#import "TGSharedMediaSignals.h"

@interface TGAnimatedMediaContextResultCellContents () <ASWatcher> {
    TGImageView *_imageView;
    TGVTAcceleratedVideoView *_videoView;
    TGMessageImageViewOverlayView *_overlayView;
    
    NSString *_downloadPath;
    SMetaDisposable *_converterDisposable;
#ifdef DEBUG
    UIView *_debugOverlayView;
#endif
    
    bool _isReady;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGAnimatedMediaContextResultCellContents

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _imageView = [[TGImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = true;
        [self addSubview:_imageView];
        
        _overlayView = [[TGMessageImageViewOverlayView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 24.0f, 24.0f)];
        [_overlayView setRadius:24.0f];
        _overlayView.hidden = true;
        [self addSubview:_overlayView];
        
        self.backgroundColor = UIColorRGB(0xdddddd);
        
        _converterDisposable = [[SMetaDisposable alloc] init];
        
#ifdef DEBUG
        _debugOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 5.0, 5.0f)];
        _debugOverlayView.backgroundColor = [UIColor greenColor];
        [self addSubview:_debugOverlayView];
#endif
    }
    return self;
}

- (void)dealloc {
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    [_converterDisposable dispose];
}

- (void)prepareForReuse {
    [_imageView reset];
    
    [_videoView setPath:nil];
    [_videoView removeFromSuperview];
    _videoView = nil;
    
    _result = nil;
    if (_downloadPath != nil) {
        [ActionStageInstance() removeWatcher:self fromPath:_downloadPath];
        _downloadPath = nil;
    }
    
    [_converterDisposable setDisposable:nil];
    [_overlayView setNone];
    _overlayView.hidden = true;
    
    _isReady = false;
}

- (void)setResult:(id)result {
    _result = result;
    _isReady = false;
    
    CGSize fitSize = CGSizeMake(128.0f, 128.0f);
    
    if ([result isKindOfClass:[TGBotContextDocumentResult class]]) {
#ifdef DEBUG
        _debugOverlayView.hidden = false;
#endif
        
        TGBotContextDocumentResult *concreteResult = (TGBotContextDocumentResult *)result;
        CGSize imageSize = [concreteResult.document pictureSize];
        if (imageSize.width <= FLT_EPSILON || imageSize.height <= FLT_EPSILON) {
            [concreteResult.document.thumbnailInfo imageUrlForLargestSize:&imageSize];
        }
        imageSize = TGFitSize(TGFillSizeF(imageSize, fitSize), fitSize);
        
        [_imageView setSignal:[TGSharedPhotoSignals cachedRemoteDocumentThumbnail:concreteResult.document size:imageSize pixelProcessingBlock:nil cacheVariantKey:@"mediaContextPanel" threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] diskCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache]]];
    } else if ([result isKindOfClass:[TGBotContextImageResult class]]) {
#ifdef DEBUG
        _debugOverlayView.hidden = false;
#endif
        
        TGBotContextImageResult *concreteResult = (TGBotContextImageResult *)result;
        CGSize imageSize = CGSizeMake(32.0f, 32.0f);
        [concreteResult.image.imageInfo imageUrlForLargestSize:&imageSize];
        imageSize = TGFitSize(TGFillSizeF(imageSize, fitSize), fitSize);
        
        [_imageView setSignal:[TGSharedPhotoSignals cachedRemoteThumbnail:concreteResult.image.imageInfo size:imageSize pixelProcessingBlock:nil cacheVariantKey:@"mediaContextPanel" threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] diskCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache]]];
    } else if ([result isKindOfClass:[TGBotContextExternalResult class]]) {
#ifdef DEBUG
        _debugOverlayView.hidden = true;
#endif
        TGBotContextExternalResult *concreteResult = result;
        
        CGSize imageSize = TGFitSize(concreteResult.size, fitSize);
        NSString *thumbnailUrl = concreteResult.thumbUrl;
        if (thumbnailUrl.length == 0) {
            if ([concreteResult.type isEqualToString:@"photo"]) {
                thumbnailUrl = concreteResult.originalUrl;
            }
        }
        [_imageView setSignal:[TGSharedPhotoSignals cachedExternalThumbnail:thumbnailUrl size:imageSize pixelProcessingBlock:nil cacheVariantKey:@"mediaContextPanel" threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] diskCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache]]];
    }
    
    [self checkAndPlay:true];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    _imageView.frame = bounds;
    _videoView.frame = bounds;
    
    _overlayView.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f);
}

- (void)checkAndPlay:(bool)download {
    if ([_result isKindOfClass:[TGBotContextDocumentResult class]]) {
        TGDocumentMediaAttachment *document = ((TGBotContextDocumentResult *)_result).document;
        if (document != nil) {
            __weak TGAnimatedMediaContextResultCellContents *weakSelf = self;
            [_converterDisposable setDisposable:nil];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *filePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId] stringByAppendingPathComponent:[TGDocumentMediaAttachment safeFileNameForFileName:document.fileName]];
                
                bool exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
                
                TGDispatchOnMainThread(^{
                    __strong TGAnimatedMediaContextResultCellContents *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        TGDocumentMediaAttachment *currentDocument = nil;
                        if ([strongSelf->_result isKindOfClass:[TGBotContextDocumentResult class]]) {
                            currentDocument = ((TGBotContextDocumentResult *)strongSelf->_result).document;
                        }
                        if ([document isEqual:currentDocument]) {
                            if (exists) {
                                if ([document.mimeType isEqualToString:@"video/mp4"]) {
                                    [strongSelf->_videoView removeFromSuperview];
                                    strongSelf->_videoView = [[TGVTAcceleratedVideoView alloc] initWithFrame:strongSelf.bounds];
                                    [strongSelf insertSubview:strongSelf->_videoView aboveSubview:strongSelf->_overlayView];
                                    [strongSelf->_videoView setPath:filePath];
                                    strongSelf->_isReady = true;
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
                                        __strong TGAnimatedMediaContextResultCellContents *strongSelf = weakSelf;
                                        if (strongSelf != nil) {
                                            TGDocumentMediaAttachment *currentDocument = nil;
                                            if ([strongSelf->_result isKindOfClass:[TGBotContextDocumentResult class]]) {
                                                currentDocument = ((TGBotContextDocumentResult *)strongSelf->_result).document;
                                            }
                                            
                                            if ([currentDocument isEqual:document]) {
                                                [strongSelf->_videoView removeFromSuperview];
                                                strongSelf->_videoView = [[TGVTAcceleratedVideoView alloc] initWithFrame:strongSelf.bounds];
                                                [strongSelf insertSubview:strongSelf->_videoView aboveSubview:strongSelf->_overlayView];
                                                [strongSelf->_videoView setPath:path];
                                                strongSelf->_isReady = true;
                                            }
                                        }
                                    }]];
                                }
                            } else if (download) {
                                [strongSelf download];
                            }
                        }
                    }
                });
            });
        } else {
            _isReady = true;
        }
    } else if ([_result isKindOfClass:[TGBotContextExternalResult class]]) {
        TGBotContextExternalResult *externalResult = (TGBotContextExternalResult *)_result;
        if ([externalResult.type isEqualToString:@"gif"] || [externalResult.type isEqualToString:@"gifv"]) {
            __weak TGAnimatedMediaContextResultCellContents *weakSelf = self;
            [[[TGMediaStoreContext instance] temporaryFilesCache] getValuePathForKey:[externalResult.originalUrl dataUsingEncoding:NSUTF8StringEncoding] completion:^(NSString *path) {
                TGDispatchOnMainThread(^{
                    __strong TGAnimatedMediaContextResultCellContents *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        TGBotContextExternalResult *currentExternalResult = nil;
                        if ([strongSelf->_result isKindOfClass:[TGBotContextExternalResult class]]) {
                            currentExternalResult = (TGBotContextExternalResult *)strongSelf->_result;
                        }
                        if ([externalResult.resultId isEqualToString:currentExternalResult.resultId]) {
                            if (path != nil) {
                                if ([externalResult.contentType isEqualToString:@"video/mp4"]) {
                                    [strongSelf->_videoView removeFromSuperview];
                                    strongSelf->_videoView = [[TGVTAcceleratedVideoView alloc] initWithFrame:strongSelf.bounds];
                                    [strongSelf insertSubview:strongSelf->_videoView aboveSubview:strongSelf->_overlayView];
                                    [strongSelf->_videoView setPath:path];
                                    strongSelf->_isReady = true;
                                }
                            } else if (download) {
                                [strongSelf download];
                            }
                        }
                    }
                });
            }];
        } else {
            _isReady = true;
        }
    }
}

- (void)download {
    if ([_result isKindOfClass:[TGBotContextDocumentResult class]]) {
        TGBotContextDocumentResult *webpageResult = (TGBotContextDocumentResult *)_result;
        if (webpageResult.document != nil) {
            TGDocumentMediaAttachment *document = webpageResult.document;
            _overlayView.hidden = false;
            [_overlayView setProgress:0.0f cancelEnabled:false animated:true];
            
            NSString *path = [NSString stringWithFormat:@"/tg/media/document/(%d:%" PRId64 ":%@)", document.datacenterId, document.documentId, document.documentUri.length != 0 ? document.documentUri : @""];
            _downloadPath = path;
            
            [ActionStageInstance() requestActor:path options:@{@"documentAttachment": document} flags:0 watcher:self];
        }
    } else if ([_result isKindOfClass:[TGBotContextExternalResult class]]) {
        TGBotContextExternalResult *externalResult = (TGBotContextExternalResult *)_result;
        
        _overlayView.hidden = false;
        [_overlayView setProgress:0.0f cancelEnabled:false animated:true];
        
        _downloadPath = [[NSString alloc] initWithFormat:@"/temporaryDownload/(%@,%@)", [TGStringUtils stringByEscapingForActorURL:externalResult.originalUrl], @"path"];
        [ActionStageInstance() requestActor:_downloadPath options:@{@"url": externalResult.originalUrl, @"cache": [[TGMediaStoreContext instance] temporaryFilesCache], @"returnPath": @true} flags:0 watcher:self];
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
        if ([path isEqualToString:_downloadPath]) {
            _downloadPath = nil;
            
            if (status == ASStatusSuccess) {
                _overlayView.hidden = true;
                [_overlayView setNone];
                
                [self checkAndPlay:false];
            } else {
                [_overlayView setDownload];
            }
        }
    });
}

@end

@interface TGAnimatedMediaContextResultCell () {
    TGAnimatedMediaContextResultCellContents *_content;
    UIView *_selectionView;
}

@end

@implementation TGAnimatedMediaContextResultCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.selectedBackgroundView = [[UIView alloc] init];
        
        _selectionView = [[UIView alloc] init];
        _selectionView.backgroundColor = UIColorRGB(0xc5c7d0);
        [self.selectedBackgroundView addSubview:_selectionView];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [_content prepareForReuse];
}

- (void)setHighlighted:(BOOL)__unused highlighted {
}

- (void)setResult:(TGBotContextResult *)result {
    if (_content == nil) {
        _content = [[TGAnimatedMediaContextResultCellContents alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_content];
    }
    
    [_content setResult:result];
}

- (TGAnimatedMediaContextResultCellContents *)_takeContent {
    TGAnimatedMediaContextResultCellContents *content = _content;
    [content removeFromSuperview];
    _content = nil;
    return content;
}

- (void)_putContent:(TGAnimatedMediaContextResultCellContents *)content {
    if (_content != nil) {
        [_content removeFromSuperview];
        _content = nil;
    }
    
    _content = content;
    if (_content != nil) {
        _content.frame = self.bounds;
        [self.contentView addSubview:_content];
    }
}

- (bool)hasContent {
    return _content != nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _content.frame = self.bounds;
    _selectionView.frame = CGRectInset(self.bounds, -3.5f, -3.5f);
}

@end
