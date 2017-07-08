#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

#import "TGCallState.h"

@interface TGCallSignals : NSObject

+ (SSignal *)requestedOutgoingCallWithPeerId:(int64_t)peerId;
+ (SSignal *)discardedCallWithCallId:(int64_t)callId accessHash:(int64_t)accessHash reason:(TGCallDiscardReason)reason duration:(int32_t)duration;
+ (SSignal *)receivedIncomingCallWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId gAHash:(NSData *)gAHash;
+ (SSignal *)acceptedIncomingCallWithCallId:(int64_t)callId accessHash:(int64_t)accessHash dhConfig:(id)dhConfig bBytes:(NSData *)bBytes gBBytes:(NSData *)gBBytes gAHash:(NSData *)gAHash;
+ (SSignal *)confirmedCallWithCallId:(int64_t)callId accessHash:(int64_t)accessHash key:(NSData *)key gABytes:(NSData *)gABytes keyId:(int64_t)keyId;

+ (SSignal *)reportCallRatingWithCallId:(int64_t)callId accessHash:(int64_t)accessHash rating:(int32_t)rating comment:(NSString *)comment includeLogs:(bool)includeLogs;
+ (SSignal *)serverCallsConfig;
+ (SSignal *)saveCallDebug:(int64_t)callId accessHash:(int64_t)accessHash data:(NSString *)data;

@end
