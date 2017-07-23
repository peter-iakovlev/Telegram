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

- (instancetype)initWithMessage:(TGMessage *)message imageMedia:(TGImageMediaAttachment *)imageMedia authorPeer:(id)authorPeer context:(TGModernViewContext *)context forwardPeer:(id)forwardPeer forwardAuthor:(id)forwardAuthor forwardMessageId:(int32_t)forwardMessageId replyHeader:(TGMessage *)replyHeader replyAuthor:(id)replyAuthor viaUser:(TGUser *)viaUser webPage:(TGWebPageMediaAttachment *)webPage
{
    TGImageInfo *previewImageInfo = imageMedia.imageInfo;
    
    CGSize largestSize = CGSizeZero;
    NSString *legacyCacheUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:&largestSize pickLargest:true];
    if (largestSize.width <= 90.0f + FLT_EPSILON || largestSize.height <= 90.0f + FLT_EPSILON) {
        legacyCacheUrl = [imageMedia.imageInfo imageUrlForSizeLargerThanSize:CGSizeMake(1000.0f, 1000.0f) actualSize:&largestSize];
    }
    
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
    
    self = [super initWithMessage:message imageInfo:previewImageInfo authorPeer:authorPeer context:context forwardPeer:forwardPeer forwardAuthor:forwardAuthor forwardMessageId:forwardMessageId replyHeader:replyHeader replyAuthor:replyAuthor viaUser:viaUser caption:imageMedia.caption textCheckingResults:imageMedia.textCheckingResults webPage:webPage];
    if (self != nil)
    {
        _imageMedia = imageMedia;
        
        _canDownload = _imageMedia.imageId != 0 || (![[imageMedia.imageInfo imageUrlForLargestSize:NULL] hasPrefix:@"http"]);
        
        if (message.messageLifetime > 0 && message.messageLifetime <= 60 && message.layer >= 17)
        {
            self.isSecret = true;
            
            //[self enableInstantPreview];
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
    
    _canDownload = _imageMedia.imageId != 0 || (![[imageMedia.imageInfo imageUrlForLargestSize:NULL] hasPrefix:@"http"]);
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

- (bool)isPreviewableAtPoint:(CGPoint)point
{
    if (self.isSecret)
        return false;
    
    return CGRectContainsPoint(self.imageModel.frame, point);
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    [super bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:itemPosition];
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    [super layoutForContainerSize:containerSize];
}

- (bool)isInstant {
    return self.isSecret;
}

@end
