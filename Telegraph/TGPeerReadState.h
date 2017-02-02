#import <Foundation/Foundation.h>

@interface TGPeerReadState : NSObject

@property (nonatomic, readonly) int32_t maxReadMessageId;
@property (nonatomic, readonly) int32_t maxOutgoingReadMessageId;
@property (nonatomic, readonly) int32_t maxKnownMessageId;
@property (nonatomic, readonly) int32_t unreadCount;

- (instancetype)initWithMaxReadMessageId:(int32_t)maxReadMessageId maxOutgoingReadMessageId:(int32_t)maxOutgoingReadMessageId maxKnownMessageId:(int32_t)maxKnownMessageId unreadCount:(int32_t)unreadCount;

@end
