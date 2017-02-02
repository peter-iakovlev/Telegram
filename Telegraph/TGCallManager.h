#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

#import "TGCallState.h"

@class TGCallSession;

@interface TGCallManager : NSObject

- (void)reset;
- (SSignal *)requestCallWithPeerId:(int64_t)peerId;
- (void)updateCallContextWithCallId:(int64_t)callId callContext:(id)callContext;

- (SSignal *)callStateWithInternalId:(id)internalId;
- (SSignal *)incomingCallInternalIds;

- (SSignal *)acceptCallWithInternalId:(id)internalId;
- (SSignal *)discardCallWithInternalId:(id)internalId reason:(TGCallDiscardReason)reason;

- (TGCallSession *)sessionForIncomingCallWithInternalId:(id)internalId;
- (TGCallSession *)sessionForOutgoingCallWithPeerId:(int64_t)peerId;

@end
