#import <Foundation/Foundation.h>
#import "TGCallDiscardReason.h"

@class TGCallSession;

@interface TGCallKitAdapter : NSObject

- (void)startCallWithPeerId:(int64_t)peerId uuid:(NSUUID *)uuid;
- (void)endCallWithUUID:(NSUUID *)uuid reason:(TGCallDiscardReason)reason completion:(void (^)(void))completion;

- (void)reportIncomingCallWithPeerId:(int64_t)peerId session:(TGCallSession *)session uuid:(NSUUID *)uuid completion:(void (^)(bool))completion;

- (void)updateCallWithUUID:(NSUUID *)uuid connectingAtDate:(NSDate *)date;
- (void)updateCallWithUUID:(NSUUID *)uuid connectedAtDate:(NSDate *)date;

- (void)addCallSession:(TGCallSession *)session uuid:(NSUUID *)uuid;

+ (bool)callKitAvailable;

@end
