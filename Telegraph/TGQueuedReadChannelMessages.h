#import <Foundation/Foundation.h>

@class TGMessageIndex;

@interface TGReadPeerMessagesRequest : NSObject

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) TGMessageIndex *maxMessageIndex;
@property (nonatomic, readonly) int32_t date;
@property (nonatomic, readonly) int32_t length;
@property (nonatomic, readonly) bool unread;

- (instancetype)initWithPeerId:(int64_t)peerId maxMessageIndex:(TGMessageIndex *)maxMessageIndex date:(int32_t)date length:(int32_t)length unread:(bool)unread;

@end

@interface TGQueuedReadChannelMessages : NSObject

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, readonly) int32_t maxId;
@property (nonatomic, readonly) bool unread;

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash maxId:(int32_t)maxId unread:(bool)unread;

@end

@interface TGQueuedReadFeedMessages : NSObject

@property (nonatomic, readonly) int64_t feedPeerId;
@property (nonatomic, readonly) int64_t maxPeerId;
@property (nonatomic, readonly) int32_t maxId;
@property (nonatomic, readonly) int32_t maxDate;

- (instancetype)initWithFeedPeerId:(int64_t)feedPeerId maxPeerId:(int64_t)maxPeerId maxId:(int32_t)maxId maxDate:(int32_t)maxDate;

@end
