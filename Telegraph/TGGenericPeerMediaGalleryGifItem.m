#import "TGGenericPeerMediaGalleryGifItem.h"

#import "TGStringUtils.h"

#import "TGMessage.h"
#import "TGImageInfo.h"

#import "TGGenericPeerMediaGalleryGifItemView.h"

@implementation TGGenericPeerMediaGalleryGifItem

- (instancetype)initWithDocument:(TGDocumentMediaAttachment *)document peerId:(int64_t)peerId messageId:(int32_t)messageId
{
    self = [super init];
    if (self != nil)
    {
        _media = document;
        _peerId = peerId;
        _messageId = messageId;
        
        TGImageInfo *imageInfo = document.thumbnailInfo;
        NSString *legacyThumbnailCacheUri = [imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
        
        if ((document.documentId != 0 || document.localDocumentId != 0) && legacyThumbnailCacheUri.length != 0)
        {
            NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"animation-thumbnail://?"];
            if (document.documentId != 0)
                [previewUri appendFormat:@"id=%" PRId64 "", document.documentId];
            else
                [previewUri appendFormat:@"local-id=%" PRId64 "", document.localDocumentId];
            
            [previewUri appendFormat:@"&file-name=%@", [document.safeFileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            CGSize size = document.pictureSize;
            
            [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)size.width, (int)size.height, (int)size.width, (int)size.height];
            
            if (legacyThumbnailCacheUri != nil)
                [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", [TGStringUtils stringByEscapingForURL:legacyThumbnailCacheUri]];
            
            if ([document.mimeType isEqualToString:@"video/mp4"]) {
                [previewUri appendFormat:@"&video-file-name=%@", [document.safeFileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
            
            _previewUri = previewUri;
        }
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object])
        return false;
    
    if ([object isKindOfClass:[TGGenericPeerMediaGalleryGifItem class]])
    {
        return TGObjectCompare(_authorPeer, ((TGGenericPeerMediaGalleryGifItem *)object).authorPeer) && ABS(_date - ((TGGenericPeerMediaGalleryGifItem *)object).date) < DBL_EPSILON && _messageId == ((TGGenericPeerMediaGalleryGifItem *)object).messageId && _peerId == ((TGGenericPeerMediaGalleryGifItem *)object).peerId;
    }
    
    return false;
}

- (Class)viewClass
{
    return [TGGenericPeerMediaGalleryGifItemView class];
}

@end
