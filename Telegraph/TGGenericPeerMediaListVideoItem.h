#import "TGModernMediaListVideoItem.h"

#import "TGGenericPeerMediaListItem.h"

@class TGVideoMediaAttachment;

@interface TGGenericPeerMediaListVideoItem : TGModernMediaListVideoItem <TGGenericPeerMediaListItem>

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) int32_t messageId;
@property (nonatomic, readonly) NSTimeInterval date;

- (instancetype)initWithVideoMedia:(TGVideoMediaAttachment *)videoMedia peerId:(int64_t)peerId messageId:(int32_t)messageId date:(NSTimeInterval)date;

@end
