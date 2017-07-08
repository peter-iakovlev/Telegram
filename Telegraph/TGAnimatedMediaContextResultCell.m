#import "TGAnimatedMediaContextResultCell.h"

#import "ActionStage.h"

#import "TGBotContextExternalResult.h"
#import "TGBotContextMediaResult.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGFont.h"

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

#import "TGBotContextResultSendMessageGeo.h"

@interface TGAnimatedMediaContextResultCellContents () <ASWatcher> {
    TGImageView *_imageView;
    UIView<TGInlineVideoPlayerView> *_videoView;
    TGMessageImageViewOverlayView *_overlayView;
    
    NSString *_downloadPath;
    SMetaDisposable *_converterDisposable;
#ifdef DEBUG
    UIView *_debugOverlayView;
#endif
    
    bool _isReady;
    
    UIImageView *_durationBackground;
    UILabel *_durationLabel;
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
        
        static UIImage *durationImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            CGFloat diameter = 6.0f;
            UIGraphicsBeginImageContext(CGSizeMake(diameter, diameter));
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.0f alpha:0.5f].CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            durationImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)(diameter / 2.0f) topCapHeight:(NSInteger)(diameter / 2.0f)];
            UIGraphicsEndImageContext();
        });
        _durationBackground = [[UIImageView alloc] initWithImage:durationImage];
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.backgroundColor = [UIColor clearColor];
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.font = TGSystemFontOfSize(11.0f);
        
        [self addSubview:_durationBackground];
        [self addSubview:_durationLabel];
        
        //self.backgroundColor = UIColorRGB(0xdddddd);
        
        _converterDisposable = [[SMetaDisposable alloc] init];
        
#if defined(DEBUG) && false
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
    
    NSNumber *duration = nil;
    
    if ([result isKindOfClass:[TGBotContextMediaResult class]]) {
#ifdef DEBUG
        _debugOverlayView.hidden = false;
#endif
        
        TGBotContextMediaResult *concreteResult = (TGBotContextMediaResult *)result;
        CGSize imageSize = CGSizeMake(32.0f, 32.0f);
        
        if (concreteResult.photo != nil) {
            [concreteResult.photo.imageInfo imageUrlForLargestSize:&imageSize];
            imageSize = TGFitSize(TGFillSizeF(imageSize, fitSize), fitSize);
            
            [_imageView setSignal:[TGSharedPhotoSignals cachedRemoteThumbnail:concreteResult.photo.imageInfo size:imageSize pixelProcessingBlock:nil cacheVariantKey:@"mediaContextPanel" threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] diskCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache]]];
        } else if (concreteResult.document != nil) {
            bool isSticker = false;
            bool isAnimation = false;
            for (id attribute in concreteResult.document.attributes) {
                if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]]) {
                    isSticker = true;
                } else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                    duration = @(((TGDocumentAttributeVideo *)attribute).duration);
                } else if ([attribute isKindOfClass:[TGDocumentAttributeAnimated class]]) {
                    isAnimation = true;
                }
            }
            
            if (isAnimation) {
                duration = nil;
            }
            
            if (isSticker) {
                NSMutableString *uri = [[NSMutableString alloc] initWithString:@"sticker-preview://?"];
                if (concreteResult.document.documentId != 0)
                    [uri appendFormat:@"documentId=%" PRId64 "", concreteResult.document.documentId];
                else
                    [uri appendFormat:@"localDocumentId=%" PRId64 "", concreteResult.document.localDocumentId];
                [uri appendFormat:@"&accessHash=%" PRId64 "", concreteResult.document.accessHash];
                [uri appendFormat:@"&datacenterId=%" PRId32 "", (int32_t)concreteResult.document.datacenterId];
                
                NSString *legacyThumbnailUri = [concreteResult.document.thumbnailInfo imageUrlForLargestSize:NULL];
                if (legacyThumbnailUri != nil)
                    [uri appendFormat:@"&legacyThumbnailUri=%@", [TGStringUtils stringByEscapingForURL:legacyThumbnailUri]];
                
                [uri appendFormat:@"&width=128&height=128"];
                [uri appendFormat:@"&highQuality=1"];
                [_imageView loadUri:uri withOptions:@{}];
            } else {
                CGSize imageSize = [concreteResult.document pictureSize];
                if (imageSize.width <= FLT_EPSILON || imageSize.height <= FLT_EPSILON) {
                    [concreteResult.document.thumbnailInfo imageUrlForLargestSize:&imageSize];
                }
                imageSize = TGFitSize(TGFillSizeF(imageSize, fitSize), fitSize);
                
                [_imageView setSignal:[TGSharedPhotoSignals cachedRemoteDocumentThumbnail:concreteResult.document size:imageSize pixelProcessingBlock:nil cacheVariantKey:@"mediaContextPanel" threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] diskCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache]]];
            }
        }
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
        if ([concreteResult.type isEqualToString:@"video"]) {
            duration = @(concreteResult.duration);
        }
        [_imageView setSignal:[TGSharedPhotoSignals cachedExternalThumbnail:thumbnailUrl size:imageSize pixelProcessingBlock:nil cacheVariantKey:@"mediaContextPanel" threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] diskCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache]]];
    }
    
    if (duration != nil) {
        _durationLabel.hidden = false;
        _durationBackground.hidden = false;
        _durationLabel.text = [NSString stringWithFormat:@"%d:%02d", [duration intValue] / 60, [duration intValue] % 60];
    } else {
        _durationLabel.hidden = true;
        _durationBackground.hidden = true;
    }
    
    [self checkAndPlay:true];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    _imageView.frame = bounds;
    _videoView.frame = bounds;
    
    _overlayView.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f);
    
    if (!_durationLabel.hidden) {
        [_durationLabel sizeToFit];
        CGRect durationFrame = _durationLabel.frame;
        durationFrame.size = CGSizeMake(ceil(_durationLabel.frame.size.width), ceil(_durationLabel.frame.size.height));
        durationFrame.origin.x = bounds.size.width - durationFrame.size.width - 9.0f;
        durationFrame.origin.y = bounds.size.height - durationFrame.size.height - 7.0f;
        _durationLabel.frame = durationFrame;
        _durationBackground.frame = CGRectMake(durationFrame.origin.x - 4.0f, durationFrame.origin.y - 3.0f, durationFrame.size.width + 8.0f, durationFrame.size.height + 6.0f);
    }
}

- (void)checkAndPlay:(bool)download {
    if ([_result isKindOfClass:[TGBotContextMediaResult class]]) {
        TGDocumentMediaAttachment *document = ((TGBotContextMediaResult *)_result).document;
        if (document != nil) {
            bool isSticker = false;
            bool isVideo = false;
            bool isAnimation = false;
            
            for (id attribute in document.attributes) {
                if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]]) {
                    isSticker = true;
                } else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                    isVideo = true;
                } else if ([attribute isKindOfClass:[TGDocumentAttributeAnimated class]]) {
                    isAnimation = true;
                }
            }
            
            if (isAnimation) {
                __weak TGAnimatedMediaContextResultCellContents *weakSelf = self;
                [_converterDisposable setDisposable:nil];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSString *filePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId version:document.version] stringByAppendingPathComponent:[TGDocumentMediaAttachment safeFileNameForFileName:document.fileName]];
                    
                    bool exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
                    
                    TGDispatchOnMainThread(^{
                        __strong TGAnimatedMediaContextResultCellContents *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            TGDocumentMediaAttachment *currentDocument = nil;
                            if ([strongSelf->_result isKindOfClass:[TGBotContextMediaResult class]]) {
                                currentDocument = ((TGBotContextMediaResult *)strongSelf->_result).document;
                            }
                            if ([document isEqual:currentDocument]) {
                                if (exists) {
                                    if ([document.mimeType isEqualToString:@"video/mp4"]) {
                                        [strongSelf->_videoView removeFromSuperview];
                                        strongSelf->_videoView = [[[TGVTAcceleratedVideoView videoViewClass] alloc] initWithFrame:strongSelf.bounds];
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
                                                if ([strongSelf->_result isKindOfClass:[TGBotContextMediaResult class]]) {
                                                    currentDocument = ((TGBotContextMediaResult *)strongSelf->_result).document;
                                                }
                                                
                                                if ([currentDocument isEqual:document]) {
                                                    [strongSelf->_videoView removeFromSuperview];
                                                    strongSelf->_videoView = [[[TGVTAcceleratedVideoView videoViewClass] alloc] initWithFrame:strongSelf.bounds];
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
            }
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
                                    strongSelf->_videoView = [[[TGVTAcceleratedVideoView videoViewClass] alloc] initWithFrame:strongSelf.bounds];
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
            
            if ([externalResult.type isEqualToString:@"article"] || [externalResult.type isEqualToString:@"geo"] || [externalResult.type isEqualToString:@"venue"]) {
                SSignal *imageSignal = nil;
                NSString *imageUrl = nil;
                if (externalResult.thumbUrl.length != 0) {
                    imageSignal = [TGSharedPhotoSignals cachedExternalThumbnail:externalResult.thumbUrl size:CGSizeMake(48.0f, 48.0f) pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:0.0f] cacheVariantKey:@"genericContextCell" threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] diskCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache]];
                } else if ([externalResult.sendMessage isKindOfClass:[TGBotContextResultSendMessageGeo class]]) {
                    TGBotContextResultSendMessageGeo *concreteMessage = (TGBotContextResultSendMessageGeo *)externalResult.sendMessage;
                    CGSize mapImageSize = CGSizeMake(75.0f, 75.0f);
                    NSString *mapUri = [[NSString alloc] initWithFormat:@"map-thumbnail://?latitude=%f&longitude=%f&width=%d&height=%d&flat=1&cornerRadius=-1", concreteMessage.location.latitude, concreteMessage.location.longitude, (int)mapImageSize.width, (int)mapImageSize.height];
                    imageUrl = mapUri;
                }
                
                if (imageSignal != nil) {
                    [_imageView setSignal:imageSignal];
                } else if (imageUrl.length != 0) {
                    [_imageView loadUri:imageUrl withOptions:@{}];
                } else {
                    [_imageView setSignal:nil];
                }
            }
        }
    }
}

- (void)download {
    if ([_result isKindOfClass:[TGBotContextMediaResult class]]) {
        TGBotContextMediaResult *webpageResult = (TGBotContextMediaResult *)_result;
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
        [ActionStageInstance() requestActor:_downloadPath options:@{@"url": externalResult.originalUrl, @"cache": [[TGMediaStoreContext instance] temporaryFilesCache], @"returnPath": @true, @"mediaTypeTag": @(TGNetworkMediaTypeTagDocument)} flags:0 watcher:self];
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
    bool _highlighted;
}

@end

@implementation TGAnimatedMediaContextResultCell

@dynamic result;

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

- (TGBotContextResult *)result
{
    return _content.result;
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
                    _content.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
                else
                    _content.transform = CGAffineTransformIdentity;
            } completion:nil];
        }
    }
}

@end
