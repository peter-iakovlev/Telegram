#import <Foundation/Foundation.h>

#import "TGGenericPeerGalleryItem.h"

@class TGImageMediaAttachment;
@class TGItemCollectionGalleryItem;

@interface TGGenericPeerGalleryGroupItem : NSObject

@property (nonatomic, readonly) int64_t keyId;
@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) id media;
@property (nonatomic, readonly) CGSize imageSize;
@property (nonatomic, readonly) bool isVideo;

- (instancetype)initWithGalleryItem:(id<TGGenericPeerGalleryItem>)galleryItem;
- (instancetype)initWithItemCollectionItem:(TGItemCollectionGalleryItem *)galleryItem;
- (instancetype)initWithImageAttachment:(TGImageMediaAttachment *)attachment;

@end
