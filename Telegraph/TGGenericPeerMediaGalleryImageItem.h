#import "TGModernGalleryImageItem.h"

#import "TGGenericPeerGalleryItem.h"

@class TGUser;

@interface TGGenericPeerMediaGalleryImageItem : TGModernGalleryImageItem <TGGenericPeerGalleryItem>

@property (nonatomic, strong) id authorPeer;
@property (nonatomic) NSTimeInterval date;
@property (nonatomic) int32_t messageId;
@property (nonatomic, strong) NSString *caption;

- (instancetype)initWithImageId:(int64_t)imageId accessHash:(int64_t)accessHash orLocalId:(int64_t)localId peerId:(int64_t)peerId messageId:(int32_t)messageId legacyImageInfo:(TGImageInfo *)legacyImageInfo embeddedStickerDocuments:(NSArray *)embeddedStickerDocuments hasStickers:(bool)hasStickers;

- (NSString *)filePath;

@end
