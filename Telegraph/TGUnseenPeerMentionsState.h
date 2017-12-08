#import <Foundation/Foundation.h>

#import <LegacyComponents/PSCoding.h>

@interface TGUnseenPeerMentionsState : NSObject <PSCoding>

@property (nonatomic, readonly) int32_t version;
@property (nonatomic, readonly) int32_t count;
@property (nonatomic, readonly) int32_t maxIdWithPrecalculatedCount;

- (instancetype)init;
- (instancetype)initWithVersion:(int32_t)version count:(int32_t)count maxIdWithPrecalculatedCount:(int32_t)maxIdWithPrecalculatedCount;

- (TGUnseenPeerMentionsState *)withUpdatedCount:(int32_t)count;

@end
