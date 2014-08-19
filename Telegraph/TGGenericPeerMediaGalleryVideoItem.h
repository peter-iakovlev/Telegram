#import "TGModernGalleryVideoItem.h"

#import "TGGenericPeerGalleryItem.h"

@class TGUser;

@interface TGGenericPeerMediaGalleryVideoItem : TGModernGalleryVideoItem <TGGenericPeerGalleryItem>

@property (nonatomic, strong) TGUser *author;
@property (nonatomic) NSTimeInterval date;
@property (nonatomic) int32_t messageId;
@property (nonatomic) int64_t peerId;

- (instancetype)initWithVideoMedia:(TGVideoMediaAttachment *)videoMedia peerId:(int64_t)peerId messageId:(int32_t)messageId;

- (NSString *)filePath;

@end
