#import <Foundation/Foundation.h>

#import <LegacyComponents/PSCoding.h>

@class TGFeedPosition;

@interface TGQueuedPeerPoll : NSObject <PSCoding>

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) TGFeedPosition *feedPosition;

- (instancetype)initWithPeerId:(int64_t)peerId feedPosition:(TGFeedPosition *)feedPosition;

@end

