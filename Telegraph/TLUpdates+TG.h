#import "TLUpdates.h"
#import "TLUpdate.h"

#import "TLMessage.h"

@interface TLUpdates (TG)

- (NSArray *)users;
- (NSArray *)chats;
- (NSArray *)messages;
- (TLMessage *)messageAtIndex:(NSUInteger)index pts:(int32_t *)pts pts_count:(int32_t *)pts_count;
- (bool)maxPtsAndCount:(int32_t *)pts ptsCount:(int32_t *)ptsCount;
- (int32_t)maxSeq;
- (NSArray *)updatesList;

@end

@interface TLUpdate (TG)

- (bool)hasPts;

@end
