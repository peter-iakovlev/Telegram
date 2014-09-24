#import "TGPhotoMessageViewModel.h"

#import "TGModernViewContext.h"

#import "TGModernRemoteImageView.h"
#import "TGMessageImageViewModel.h"
#import "TGModernRemoteImageViewModel.h"
#import "TGModernImageViewModel.h"
#import "TGModernColorViewModel.h"
#import "TGInstantPreviewTouchAreaModel.h"
#import "TGModernButtonViewModel.h"

#import "TGMessage.h"

#import "TGStringUtils.h"

@interface TGPhotoMessageViewModel ()
{
    TGImageMediaAttachment *_imageMedia;
}

@end

@implementation TGPhotoMessageViewModel

- (instancetype)initWithMessage:(TGMessage *)message imageMedia:(TGImageMediaAttachment *)imageMedia author:(TGUser *)author context:(TGModernViewContext *)context
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
        [TGImageMessageViewModel calculateImageSizesForImageSize:largestSize thumbnailSize:&thumbnailSize renderSize:&renderSize];
        
        [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
        
        NSString *legacyFilePath = nil;
        if ([legacyCacheUrl hasPrefix:@"file://"])
            legacyFilePath = [legacyCacheUrl substringFromIndex:@"file://".length];
        else
            legacyFilePath = [[TGRemoteImageView sharedCache] pathForCachedData:legacyCacheUrl];
        
        if (legacyFilePath != nil)
            [previewUri appendFormat:@"&legacy-file-path=%@", legacyFilePath];
        
        if (legacyThumbnailCacheUrl != nil)
            [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUrl];
        
        [previewImageInfo addImageWithSize:renderSize url:previewUri];
    }
    
    self = [super initWithMessage:message imageInfo:previewImageInfo author:author context:context];
    if (self != nil)
    {
        _imageMedia = imageMedia;
    }
    return self;
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage
{
    [super updateMessage:message viewStorage:viewStorage];
    
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
            [TGImageMessageViewModel calculateImageSizesForImageSize:largestSize thumbnailSize:&thumbnailSize renderSize:&renderSize];
            
            [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
            
            NSString *legacyFilePath = nil;
            if ([legacyCacheUrl hasPrefix:@"file://"])
                legacyFilePath = [legacyCacheUrl substringFromIndex:@"file://".length];
            else
                legacyFilePath = [[TGRemoteImageView sharedCache] pathForCachedData:legacyCacheUrl];
            
            if (legacyFilePath != nil)
                [previewUri appendFormat:@"&legacy-file-path=%@", legacyFilePath];
            
            if (legacyThumbnailCacheUrl != nil)
                [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUrl];
            
            [previewImageInfo addImageWithSize:renderSize url:previewUri];
        }
        
        [self updateImageInfo:previewImageInfo];
    }
}

- (void)updateMessageAttributes
{
    [super updateMessageAttributes];
}

- (NSString *)filterForMessage:(TGMessage *)message imageSize:(CGSize)imageSize sourceSize:(CGSize)sourceSize
{
    if (message.messageLifetime == 0)
        return [super filterForMessage:message imageSize:imageSize sourceSize:sourceSize];
    
    return [[NSString alloc] initWithFormat:@"%@:%dx%d,%dx%d", @"secretAttachmentImageOutgoing", (int)imageSize.width, (int)imageSize.height, (int)sourceSize.width, (int)sourceSize.height];
}

- (CGSize)minimumImageSizeForMessage:(TGMessage *)message
{
    if (message.messageLifetime == 0)
        return [super minimumImageSizeForMessage:message];
    
    return CGSizeMake(120, 120);
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
