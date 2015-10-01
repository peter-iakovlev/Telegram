#import "TGPhotoMessageViewModel.h"

#import "TGModernViewContext.h"

#import "TGModernRemoteImageView.h"
#import "TGMessageImageViewModel.h"
#import "TGModernRemoteImageViewModel.h"
#import "TGModernImageViewModel.h"
#import "TGModernColorViewModel.h"
#import "TGModernButtonViewModel.h"

#import "TGMessage.h"

#import "TGStringUtils.h"

@interface TGPhotoMessageViewModel ()
{
    TGImageMediaAttachment *_imageMedia;
}

@end

@implementation TGPhotoMessageViewModel

- (instancetype)initWithMessage:(TGMessage *)message imageMedia:(TGImageMediaAttachment *)imageMedia authorPeer:(id)authorPeer context:(TGModernViewContext *)context forwardPeer:(id)forwardPeer forwardMessageId:(int32_t)forwardMessageId replyHeader:(TGMessage *)replyHeader replyAuthor:(id)replyAuthor
{
    TGImageInfo *previewImageInfo = imageMedia.imageInfo;
    
    CGSize largestSize = CGSizeZero;
    NSString *legacyCacheUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:&largestSize pickLargest:true];
    NSString *legacyThumbnailCacheUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
    
    int64_t localImageId = 0;
    if (imageMedia.imageId == 0 && legacyCacheUrl.length != 0)
    {
        localImageId = murMurHash32(legacyCacheUrl);
    }
    
    if (legacyCacheUrl != nil && (imageMedia.imageId != 0 || localImageId != 0))
    {
        previewImageInfo = [[TGImageInfo alloc] init];
        
        NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"photo-thumbnail://?"];
        if (imageMedia.imageId != 0)
            [previewUri appendFormat:@"id=%" PRId64 "", imageMedia.imageId];
        else
            [previewUri appendFormat:@"local-id=%" PRId64 "", localImageId];
        
        CGSize thumbnailSize = CGSizeZero;
        CGSize renderSize = CGSizeZero;
        [TGImageMessageViewModel calculateImageSizesForImageSize:largestSize thumbnailSize:&thumbnailSize renderSize:&renderSize squareAspect:message.messageLifetime > 0 && message.messageLifetime <= 60 && message.layer >= 17];
        
        [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
        
        NSString *legacyFilePath = nil;
        if ([legacyCacheUrl hasPrefix:@"file://"])
            legacyFilePath = [legacyCacheUrl substringFromIndex:@"file://".length];
        else
            legacyFilePath = [[TGRemoteImageView sharedCache] pathForCachedData:legacyCacheUrl];
        
        if (legacyFilePath != nil)
            [previewUri appendFormat:@"&legacy-file-path=%@", legacyFilePath];
        
        if (legacyThumbnailCacheUrl != nil)
            [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", [TGStringUtils stringByEscapingForURL:legacyThumbnailCacheUrl]];
        
        if (message.messageLifetime > 0 && message.messageLifetime <= 60 && message.layer >= 17)
            [previewUri appendString:@"&secret=1"];
        
        [previewImageInfo addImageWithSize:thumbnailSize url:previewUri];
    }
    
    self = [super initWithMessage:message imageInfo:previewImageInfo authorPeer:authorPeer context:context forwardPeer:forwardPeer forwardMessageId:forwardMessageId replyHeader:replyHeader replyAuthor:replyAuthor caption:imageMedia.caption textCheckingResults:imageMedia.textCheckingResults];
    if (self != nil)
    {
        _imageMedia = imageMedia;
        
        if (message.messageLifetime > 0 && message.messageLifetime <= 60 && message.layer >= 17)
        {
            self.isSecret = true;
            
            [self enableInstantPreview];
        }
        
        if (self.isSecret)
            [self.imageModel setAdditionalDataString:[self defaultAdditionalDataString]];
    }
    return self;
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage sizeUpdated:(bool *)sizeUpdated
{
    [super updateMessage:message viewStorage:viewStorage sizeUpdated:sizeUpdated];
    
    TGImageMediaAttachment *imageMedia = nil;
    for (id attachment in message.mediaAttachments)
    {
        if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
        {
            imageMedia = attachment;
            break;
        }
    }
    
    if (imageMedia != nil)
    {
        TGImageInfo *previewImageInfo = imageMedia.imageInfo;
        
        CGSize largestSize = CGSizeZero;
        NSString *legacyCacheUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:&largestSize pickLargest:true];
        NSString *legacyThumbnailCacheUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
        
        int64_t localImageId = 0;
        if (imageMedia.imageId == 0 && legacyCacheUrl.length != 0)
        {
            localImageId = murMurHash32(legacyCacheUrl);
        }
        
        if (legacyCacheUrl != nil && (imageMedia.imageId != 0 || localImageId != 0))
        {
            previewImageInfo = [[TGImageInfo alloc] init];
            
            NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"photo-thumbnail://?"];
            if (imageMedia.imageId != 0)
                [previewUri appendFormat:@"id=%" PRId64 "", imageMedia.imageId];
            else
                [previewUri appendFormat:@"local-id=%" PRId64 "", localImageId];
            
            CGSize thumbnailSize = CGSizeZero;
            CGSize renderSize = CGSizeZero;
            [TGImageMessageViewModel calculateImageSizesForImageSize:largestSize thumbnailSize:&thumbnailSize renderSize:&renderSize squareAspect:message.messageLifetime > 0 && message.messageLifetime <= 60 && message.layer >= 17];
            
            [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
            
            NSString *legacyFilePath = nil;
            if ([legacyCacheUrl hasPrefix:@"file://"])
                legacyFilePath = [legacyCacheUrl substringFromIndex:@"file://".length];
            else
                legacyFilePath = [[TGRemoteImageView sharedCache] pathForCachedData:legacyCacheUrl];
            
            if (legacyFilePath != nil)
                [previewUri appendFormat:@"&legacy-file-path=%@", legacyFilePath];
            
            if (legacyThumbnailCacheUrl != nil)
                [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", [TGStringUtils stringByEscapingForURL:legacyThumbnailCacheUrl]];
            
            if (message.messageLifetime > 0 && message.messageLifetime <= 60 && message.layer >= 17)
                [previewUri appendString:@"&secret=1"];
            
            [previewImageInfo addImageWithSize:renderSize url:previewUri];
        }
        
        [self updateImageInfo:previewImageInfo];
    }
}

- (void)updateMessageAttributes
{
    [super updateMessageAttributes];
    
    //_overlayIconModel.hidden = [_context isSecretMessageViewed:_mid];
    //_overlayIconMaskLeftModel.hidden = [_context isSecretMessageScreenshotted:_mid];
    //_overlayIconMaskRightModel.hidden = _overlayIconMaskLeftModel.hidden;
    //_overlayIconMaskTopModel.hidden = _overlayIconMaskLeftModel.hidden;
    //_overlayIconMaskBottomModel.hidden = _overlayIconMaskLeftModel.hidden;
}

- (bool)instantPreviewGesture
{
    return false;
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    [super bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:itemPosition];
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    [super layoutForContainerSize:containerSize];
}

@end
