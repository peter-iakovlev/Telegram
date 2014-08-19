#import "TGModernGalleryImageItem.h"

#import "TGGenericPeerGalleryItem.h"

@class TGUser;

@interface TGGenericPeerMediaGalleryImageItem : TGModernGalleryImageItem <TGGenericPeerGalleryItem>

@property (nonatomic, strong) TGUser *author;
@property (nonatomic) NSTimeInterval date;
@property (nonatomic) int32_t messageId;

- (instancetype)initWithImageId:(int64_t)imageId orLocalId:(int64_t)localId peerId:(int64_t)peerId messageId:(int32_t)messageId legacyImageInfo:(TGImageInfo *)legacyImageInfo;

- (NSString *)filePath;

@end
