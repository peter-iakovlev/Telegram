#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

#import "TGCallState.h"

@interface TGCallSignals : NSObject

+ (SSignal *)requestedOutgoingCallWithPeerId:(int64_t)peerId;
+ (SSignal *)discardedCallWithCallId:(int64_t)callId accessHash:(int64_t)accessHash reason:(TGCallDiscardReason)reason duration:(int32_t)duration;
+ (SSignal *)receivedIncomingCallWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId gA:(NSData *)gA;
+ (SSignal *)acceptedIncomingCallWithCallId:(int64_t)callId accessHash:(int64_t)accessHash key:(NSData *)key gBBytes:(NSData *)gBBytes keyId:(int64_t)keyId;

@end
