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

#import "TGAnimatedImagePlayer.h"

#import "TGImageBlur.h"

@interface TGAnimatedImageMessageViewModel () <TGAnimatedImagePlayerDelegate>
{
    TGDocumentMediaAttachment *_document;
    
    TGAnimatedImagePlayer *_player;
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

- (instancetype)initWithMessage:(TGMessage *)message imageInfo:(TGImageInfo *)imageInfo document:(TGDocumentMediaAttachment *)document author:(TGUser *)author context:(TGModernViewContext *)context
{
    TGImageInfo *previewImageInfo = imageInfo;
    
    CGSize dimensions = CGSizeZero;
    NSString *legacyThumbnailCacheUri = [imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:&dimensions];
    dimensions.width *= 10.0f;
    dimensions.height *= 10.0f;
    
    if ((document.documentId != 0 || document.localDocumentId != 0) && legacyThumbnailCacheUri.length != 0)
    {
        previewImageInfo = [[TGImageInfo alloc] init];
        
        NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"animation-thumbnail://?"];
        if (document.documentId != 0)
            [previewUri appendFormat:@"id=%" PRId64 "", document.documentId];
        else
            [previewUri appendFormat:@"local-id=%" PRId64 "", document.localDocumentId];
        
        [previewUri appendFormat:@"&file-name=%@", [document.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        CGSize thumbnailSize = CGSizeZero;
        CGSize renderSize = CGSizeZero;
        [TGImageMessageViewModel calculateImageSizesForImageSize:dimensions thumbnailSize:&thumbnailSize renderSize:&renderSize];
        
        [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
        
        if (legacyThumbnailCacheUri != nil)
            [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUri];
        
        [previewImageInfo addImageWithSize:renderSize url:previewUri];
    }
    
    self = [super initWithMessage:message imageInfo:previewImageInfo author:author context:context];
    if (self != nil)
    {
        _document = document;
    }
    return self;
}

- (void)dealloc
{
    _player.delegate = nil;
    [_player stop];
}

- (void)updateMediaAvailability:(bool)mediaIsAvailable viewStorage:(TGModernViewStorage *)viewStorage
{
    [super updateMediaAvailability:mediaIsAvailable viewStorage:viewStorage];
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage
{
    [super updateMessage:message viewStorage:viewStorage];
    
    for (TGMediaAttachment *attachment in message.mediaAttachments)
    {
        if (attachment.type == TGDocumentMediaAttachmentType)
            _document = (TGDocumentMediaAttachment *)attachment;
    }
}

- (void)updateAnimationsEnabled
{
}

- (void)stopInlineMedia
{
    if (_player != nil)
    {
        _player.delegate = nil;
        [_player stop];
        _player = nil;
        
        [self.imageModel setOverlayType:TGMessageImageViewOverlayPlay];
    }
}

- (CGSize)minimumImageSizeForMessage:(TGMessage *)__unused message
{
    return CGSizeMake(130, 130);
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    [super unbindView:viewStorage];
    
    if (_player != nil)
    {
        _player.delegate = nil;
        [_player stop];
        _player = nil;
        
        [self.imageModel setOverlayType:TGMessageImageViewOverlayPlay];
    }
}

- (void)activateMedia
{
    if (_player == nil)
    {
        NSString *filePath = nil;
        
        if (_document.localDocumentId != 0)
        {
            filePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:_document.localDocumentId] stringByAppendingPathComponent:[_document safeFileName]];
        }
        else
        {
            filePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:_document.documentId] stringByAppendingPathComponent:[_document safeFileName]];
        }
        
        [_context.companionHandle requestAction:@"stopInlineMedia" options:@{}];
        
        _player = [[TGAnimatedImagePlayer alloc] initWithDelegate:self path:filePath];
        
        CGSize imageSize = self.imageModel.frame.size;
        _player.filter = ^(UIImage *image)
        {
            return TGLoadedAttachmentImage(image, imageSize, NULL);
        };
        [_player play];
        
        [self.imageModel setOverlayType:TGMessageImageViewOverlayNone];
    }
    else
    {
        [self.imageModel reloadImage:true];
        
        _player.delegate = nil;
        [_player stop];
        _player = nil;
        
        [self.imageModel setOverlayType:TGMessageImageViewOverlayPlay];
    }
}

- (void)animationFrameReady:(UIImage *)frameImage
{
    [(TGMessageImageView *)[self.imageModel boundView] loadUri:@"embedded-image://" withOptions:@{TGImageViewOptionEmbeddedImage: frameImage}];
}

- (int)defaultOverlayActionType
{
    return _player == nil ? TGMessageImageViewOverlayPlay : TGMessageImageViewOverlayNone;
}

@end
