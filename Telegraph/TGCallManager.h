#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

#import "TGCallState.h"

@class TGCallSession;

@interface TGCallManager : NSObject

@property (nonatomic, readonly) bool hasActiveCall;

- (void)reset;
- (SSignal *)requestCallWithPeerId:(int64_t)peerId;
- (void)updateCallContextWithCallId:(int64_t)callId callContext:(id)callContext;

- (SSignal *)callStateWithInternalId:(id)internalId;
- (SSignal *)incomingCallInternalIds;

- (SSignal *)endedIncomingCallInternalIds;

- (SSignal *)acceptCallWithInternalId:(id)internalId;
- (SSignal *)discardCallWithInternalId:(id)internalId reason:(TGCallDiscardReason)reason;

- (TGCallSession *)sessionForIncomingCallWithInternalId:(id)internalId;
- (TGCallSession *)sessionForOutgoingCallWithPeerId:(int64_t)peerId;

@end
