#import <Foundation/Foundation.h>

#import <LegacyComponents/PSCoding.h>

@interface TGUnseenPeerMentionsMessageIdsState : NSObject <PSCoding>

@property (nonatomic, readonly) int32_t maxCachedId;

- (instancetype)initWithMaxCachedId:(int32_t)maxCachedId;

@end
