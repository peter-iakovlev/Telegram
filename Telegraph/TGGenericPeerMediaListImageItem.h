#import "TGModernMediaListImageItem.h"

#import "TGGenericPeerMediaListItem.h"

@class TGImageInfo;

@interface TGGenericPeerMediaListImageItem : TGModernMediaListImageItem <TGGenericPeerMediaListItem>

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) int32_t messageId;
@property (nonatomic, readonly) NSTimeInterval date;

- (instancetype)initWithImageId:(int64_t)imageId orLocalId:(int64_t)localId peerId:(int64_t)peerId messageId:(int32_t)messageId date:(NSTimeInterval)date legacyImageInfo:(TGImageInfo *)legacyImageInfo;

@end
