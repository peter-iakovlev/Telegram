#import <MTProtoKit/MTMessageService.h>

@interface TGUpdateMessageService : NSObject <MTMessageService>

- (void)updatePts:(int)pts ptsCount:(int)ptsCount seq:(int)seq;
- (void)addUpdates:(id)body;

@end
