/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGAnimatedImageMessageViewModel.h"

#import "ASQueue.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGTimerTarget.h"

#import "TGImageInfo.h"

#import "TGMessageImageViewModel.h"
#import "TGModernRemoteImageView.h"
#import "TGModernViewContext.h"

#import "TGMessage.h"
#import "TGMediaAttachment.h"
#import "TGDocumentMediaAttachment.h"
#import "TGPreparedLocalDocumentMessage.h"

#import "TGMessageImageView.h"

#import "TGModernAnimatedImagePlayer.h"

#import "TGImageBlur.h"

#import "TGInlineVideoModel.h"

#import "TGGifConverter.h"

#import "TGTelegraph.h"

@interface TGAnimatedImageMessageViewModel ()
{
    TGDocumentMediaAttachment *_document;
    
    bool _activatedMedia;
    
    bool _boundToContainer;
}

@end

@implementation TGAnimatedImageMessageViewModel

+ (ASQueue *)procesingQueue
{
    static ASQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        queue = [[ASQueue alloc] initWithName:"org.telegram.TGAnimatedImageMessageViewModel_processingQueue"];
    });
    
    return queue;
}

- (instancetype)initWithMessage:(TGMessage *)message imageInfo:(TGImageInfo *)imageInfo document:(TGDocumentMediaAttachment *)document authorPeer:(id)authorPeer context:(TGModernViewContext *)context forwardPeer:(id)forwardPeer forwardAuthor:(id)forwardAuthor forwardMessageId:(int32_t)forwardMessageId replyHeader:(TGMessage *)replyHeader replyAuthor:(id)replyAuthor viaUser:(TGUser *)viaUser caption:(NSString *)caption textCheckingResults:(NSArray *)textCheckingResults
{
    TGImageInfo *previewImageInfo = imageInfo;
    
    CGSize dimensions = CGSizeZero;
    NSString *legacyThumbnailCacheUri = [imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:&dimensions];
    dimensions.width *= 10.0f;
    dimensions.height *= 10.0f;
    CGSize renderSize = CGSizeZero;
    
    if ((document.documentId != 0 || document.localDocumentId != 0) && legacyThumbnailCacheUri.length != 0)
    {
        previewImageInfo = [[TGImageInfo alloc] init];
        
        NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"animation-thumbnail://?"];
        if (document.documentId != 0)
            [previewUri appendFormat:@"id=%" PRId64 "", document.documentId];
        else
            [previewUri appendFormat:@"local-id=%" PRId64 "", document.localDocumentId];
        
        [previewUri appendFormat:@"&file-name=%@", [document.safeFileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        CGSize thumbnailSize = CGSizeZero;
        [TGImageMessageViewModel calculateImageSizesForImageSize:dimensions thumbnailSize:&thumbnailSize renderSize:&renderSize squareAspect:false];
        
        [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
        
        if (legacyThumbnailCacheUri != nil)
        {
            [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", [TGStringUtils stringByEscapingForURL:legacyThumbnailCacheUri]];
        }
        
        if ([document.mimeType isEqualToString:@"video/mp4"]) {
            [previewUri appendFormat:@"&video-file-name=%@", [document.safeFileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [previewImageInfo addImageWithSize:renderSize url:previewUri];
    }
    
    self = [super initWithMessage:message imageInfo:previewImageInfo authorPeer:authorPeer context:context forwardPeer:forwardPeer forwardAuthor:forwardAuthor forwardMessageId:forwardMessageId replyHeader:replyHeader replyAuthor:replyAuthor viaUser:viaUser caption:caption textCheckingResults:textCheckingResults];
    if (self != nil)
    {
        _document = document;
        
        _canDownload = document.documentId != 0 || (document.documentUri != nil && ![document.documentUri hasPrefix:@"http"]);
        
        CGFloat scale = [UIScreen mainScreen].scale;
        self.imageModel.inlineVideoSize = CGSizeMake(renderSize.width * scale, renderSize.height * scale);
        self.imageModel.inlineVideoCornerRadius = 14.0f;
        if (_contentModel != nil) {
            self.imageModel.inlineVideoInsets = UIEdgeInsetsZero;
        } else {
            self.imageModel.inlineVideoInsets = UIEdgeInsetsMake(2.0f, 2.0f, 2.0f, 2.0f);
        }
        
        self.avatarOffset -= 1.0f;
    }
    return self;
}

- (void)dealloc
{
}

- (void)updateMediaAvailability:(bool)mediaIsAvailable viewStorage:(TGModernViewStorage *)viewStorage delayDisplay:(bool)delayDisplay
{
    bool wasAvailable = _mediaIsAvailable;
    [super updateMediaAvailability:mediaIsAvailable viewStorage:viewStorage delayDisplay:delayDisplay];
    
    if (!wasAvailable && mediaIsAvailable && _boundToContainer) {
        if ([self.imageModel boundView] != nil && _context.autoplayAnimations && _mediaIsAvailable) {
            [self activateMediaPlayback];
        }
    }
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage sizeUpdated:(bool *)sizeUpdated
{
    [super updateMessage:message viewStorage:viewStorage sizeUpdated:sizeUpdated];
    
    int64_t previousDocumentId = _document.documentId;
    
    for (TGMediaAttachment *attachment in message.mediaAttachments)
    {
        if (attachment.type == TGDocumentMediaAttachmentType)
            _document = (TGDocumentMediaAttachment *)attachment;
    }
    
    CGSize dimensions = CGSizeZero;
    NSString *legacyThumbnailCacheUri = [_document.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:&dimensions];
    dimensions.width *= 10.0f;
    dimensions.height *= 10.0f;
    
    if ((_document.documentId != 0 || _document.localDocumentId != 0) && legacyThumbnailCacheUri.length != 0)
    {
        TGImageInfo *previewImageInfo = [[TGImageInfo alloc] init];
        
        NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"animation-thumbnail://?"];
        if (_document.documentId != 0)
            [previewUri appendFormat:@"id=%" PRId64 "", _document.documentId];
        else
            [previewUri appendFormat:@"local-id=%" PRId64 "", _document.localDocumentId];
        
        [previewUri appendFormat:@"&file-name=%@", [_document.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        CGSize thumbnailSize = CGSizeZero;
        CGSize renderSize = CGSizeZero;
        [TGImageMessageViewModel calculateImageSizesForImageSize:dimensions thumbnailSize:&thumbnailSize renderSize:&renderSize squareAspect:false];
        
        [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
        
        if (legacyThumbnailCacheUri != nil)
        {
            [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", [TGStringUtils stringByEscapingForURL:legacyThumbnailCacheUri]];
        }
        
        if ([_document.mimeType isEqualToString:@"video/mp4"]) {
            [previewUri appendFormat:@"&video-file-name=%@", [_document.safeFileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [previewImageInfo addImageWithSize:renderSize url:previewUri];
        
        [self updateImageInfo:previewImageInfo];
    }
    
    _canDownload = _document.documentId != 0 || (_document.documentUri != nil && ![_document.documentUri hasPrefix:@"http"]);
    
    if ([self.imageModel boundView] != nil && _context.autoplayAnimations && _mediaIsAvailable && _activatedMedia && _document.documentId != previousDocumentId) {
        [self activateMediaPlayback];
    }
    
    [self updateImageOverlay:false];
    
    if (_backgroundModel != nil) {
        self.imageModel.inlineVideoInsets = UIEdgeInsetsZero;
    } else {
        self.imageModel.inlineVideoInsets = UIEdgeInsetsMake(2.0f, 2.0f, 2.0f, 2.0f);
    }
}

- (void)updateAnimationsEnabled
{
}

- (void)stopInlineMedia:(int32_t)__unused excludeMid
{
    bool wasActivated = _activatedMedia;
    _activatedMedia = false;
    
    if (wasActivated)
    {
        [((TGMessageImageViewContainer *)self.imageModel.boundView).imageView hideVideo];
        [((TGMessageImageViewContainer *)self.imageModel.boundView).imageView setVideoPathSignal:nil];
    }
    
    [self updateImageOverlay:false];
}

- (void)resumeInlineMedia {
    if (_context.autoplayAnimations && _mediaIsAvailable && !_activatedMedia) {
        [self activateMediaPlayback];
    }
}

- (CGSize)minimumImageSizeForMessage:(TGMessage *)__unused message
{
    return CGSizeMake(130, 130);
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage {
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    _boundToContainer = true;
    
    if (_context.autoplayAnimations && _mediaIsAvailable) {
        [self activateMediaPlayback];
    }
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition {
    [super bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:itemPosition];
    
    _boundToContainer = false;
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    _boundToContainer = false;
    
    [((TGMessageImageViewContainer *)self.imageModel.boundView).imageView setVideoPathSignal:nil];
    _activatedMedia = false;
    
    [super unbindView:viewStorage];
    
    [self updateImageOverlay:false];
}

- (void)activateMedia
{
    if (_activatedMedia)
        [_context.companionHandle requestAction:@"openMediaRequested" options:@{@"mid": @(_mid), @"instant": @(false)}];
    else
        [self activateMediaPlayback];
}

- (void)activateMediaPlayback
{
    _activatedMedia = true;
    [self updateImageOverlay:false];
    
    NSString *documentDirectory = nil;
    if (_document.localDocumentId != 0) {
        documentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:_document.localDocumentId version:_document.version];
    } else {
        documentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:_document.documentId version:_document.version];
    }
    
    NSString *videoPath = nil;
    
    if ([_document.mimeType isEqualToString:@"video/mp4"]) {
        if (_document.localDocumentId != 0)
        {
            videoPath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:_document.localDocumentId version:_document.version] stringByAppendingPathComponent:[_document safeFileName]];
        }
        else
        {
            videoPath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:_document.documentId version:_document.version] stringByAppendingPathComponent:[_document safeFileName]];
        }
    }
    
    if (videoPath != nil) {
        [((TGMessageImageViewContainer *)self.imageModel.boundView).imageView setVideoPathSignal:[SSignal single:videoPath]];
    } else {
        NSString *filePath = nil;
        NSString *videoPath = nil;
        
        if (_document.localDocumentId != 0)
        {
            filePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:_document.localDocumentId version:_document.version] stringByAppendingPathComponent:[_document safeFileName]];
            videoPath = [filePath stringByAppendingString:@".mov"];
        }
        else
        {
            filePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:_document.documentId version:_document.version] stringByAppendingPathComponent:[_document safeFileName]];
            videoPath = [filePath stringByAppendingString:@".mov"];
        }
        
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
        
        [((TGMessageImageViewContainer *)self.imageModel.boundView).imageView setVideoPathSignal:videoSignal];
    }
}

- (void)animationFrameReady:(UIImage *)frameImage
{
    [((TGMessageImageViewContainer *)[self.imageModel boundView]).imageView loadUri:@"embedded-image://" withOptions:@{TGImageViewOptionEmbeddedImage: frameImage}];
}

- (int)defaultOverlayActionType
{
    if (_context.autoplayAnimations) {
        return TGMessageImageViewOverlayNone;
    } else {
        return !_activatedMedia ? TGMessageImageViewOverlayPlay : TGMessageImageViewOverlayNone;
    }
}

- (bool)isPreviewableAtPoint:(CGPoint)point
{
    if (self.isSecret)
        return false;
    
    return CGRectContainsPoint(self.imageModel.frame, point);
}

@end
