#import "TGModernGalleryImageItem.h"

#import "TGGenericPeerGalleryItem.h"

@class TGDocumentMediaAttachment;

@interface TGGenericPeerMediaGalleryGifItem : NSObject <TGGenericPeerGalleryItem>

@property (nonatomic, strong, readonly) TGDocumentMediaAttachment *media;
@property (nonatomic, strong, readonly) NSString *previewUri;

@property (nonatomic, strong) id authorPeer;
@property (nonatomic) NSTimeInterval date;
@property (nonatomic) int32_t messageId;
@property (nonatomic) int64_t peerId;
@property (nonatomic, strong) NSString *caption;

- (instancetype)initWithDocument:(TGDocumentMediaAttachment *)documentMedia peerId:(int64_t)peerId messageId:(int32_t)messageId;

@end
