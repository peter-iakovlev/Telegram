#import "TGGenericPeerGalleryGroupItem.h"

#import "TGGenericPeerMediaGalleryImageItem.h"
#import "TGGenericPeerMediaGalleryVideoItem.h"
#import "TGItemCollectionGalleryItem.h"

#import <LegacyComponents/TGImageMediaAttachment.h>
#import <LegacyComponents/TGVideoMediaAttachment.h>

@implementation TGGenericPeerGalleryGroupItem

- (instancetype)initWithKeyId:(int64_t)keyId peerId:(int64_t)peerId media:(id)media imageSize:(CGSize)imageSize isVideo:(bool)isVideo
{
    self = [super init];
    if (self != nil)
    {
        _keyId = keyId;
        _peerId = peerId;
        _media = media;
        _imageSize = imageSize;
        _isVideo = isVideo;
    }
    return self;
}

- (instancetype)initWithGalleryItem:(id<TGGenericPeerGalleryItem>)galleryItem
{
    CGSize imageSize = CGSizeZero;
    bool isVideo = false;
    
    if ([galleryItem isKindOfClass:[TGGenericPeerMediaGalleryImageItem class]])
    {
        imageSize = ((TGGenericPeerMediaGalleryImageItem *)galleryItem).imageSize;
    }
    else if ([galleryItem isKindOfClass:[TGGenericPeerMediaGalleryVideoItem class]])
    {
        imageSize = ((TGGenericPeerMediaGalleryVideoItem *)galleryItem).imageSize;
        isVideo = true;
    }
        
    return [self initWithKeyId:galleryItem.messageId peerId:galleryItem.peerId media:galleryItem.media imageSize:imageSize isVideo:isVideo];
}

- (instancetype)initWithItemCollectionItem:(TGItemCollectionGalleryItem *)galleryItem
{
    TGInstantPageMedia *itemMedia = galleryItem.media;
    TGMediaAttachment *media = itemMedia.media;
    
    CGSize imageSize = CGSizeZero;
    if ([media isKindOfClass:[TGImageMediaAttachment class]])
    {
        imageSize = ((TGImageMediaAttachment *)media).dimensions;
    }
    else if ([media isKindOfClass:[TGVideoMediaAttachment class]])
    {
        imageSize = ((TGVideoMediaAttachment *)media).dimensions;
    }
    
    return [self initWithKeyId:galleryItem.index peerId:0 media:media imageSize:imageSize isVideo:[media isKindOfClass:[TGVideoMediaAttachment class]]];
}

- (instancetype)initWithImageAttachment:(TGImageMediaAttachment *)attachment
{
    return [self initWithKeyId:attachment.imageId peerId:0 media:attachment imageSize:attachment.dimensions isVideo:false];
}

@end
