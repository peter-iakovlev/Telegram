#import <Foundation/Foundation.h>

#import <LegacyComponents/LegacyComponents.h>

@interface TGConversationScrollState : NSObject <PSCoding>

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) int32_t messageId;
@property (nonatomic, readonly) int32_t messageOffset;

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId messageOffset:(int32_t)messageOffset;

@end
