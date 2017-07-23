#import "TGCallManager.h"

#import "TGAppDelegate.h"

#import "TGCallContext.h"
#import "TGCallSignals.h"
#import "TGCallSession.h"
#import "TGCallKitAdapter.h"
#import "TGBridgeServer.h"

#import <MTProtoKit/MTProtoKit.h>

#import "TL/TLMetaScheme.h"

@interface TGCallManager () {
    SQueue *_queue;
    int32_t _nextInternalId;
    
    NSMutableDictionary<NSNumber *, TGCallContext *> *_callContexts;
    
    SPipe *_incomingCallInternalIdsPipe;
    SPipe *_endedIncomingCallInternalIdsPipe;
    
    NSMutableArray<NSNumber *> *_discardedCallIds;
    
    TGCallKitAdapter *_callKitAdapter;
}
@end

@implementation TGCallManager

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _queue = [[SQueue alloc] init];
        _callContexts = [[NSMutableDictionary alloc] init];
        _discardedCallIds = [[NSMutableArray alloc] init];
        _incomingCallInternalIdsPipe = [[SPipe alloc] init];
        _endedIncomingCallInternalIdsPipe = [[SPipe alloc] init];
        
        if ([TGCallKitAdapter callKitAvailable])
            _callKitAdapter = [[TGCallKitAdapter alloc] init];
    }
    return self;
}

+ (bool)useCallKit {
    
    return [TGCallKitAdapter callKitAvailable] && !TGAppDelegateInstance.callsDisableCallKit;
}

- (void)reset {
    [_queue dispatch:^{
        [_callContexts enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *key, TGCallContext *context, __unused BOOL *stop) {
            [context.disposable dispose];
        }];
        _callContexts = [[NSMutableDictionary alloc] init];
    }];
}

- (SSignal *)requestCallWithPeerId:(int64_t)peerId {
    return [self requestCallWithPeerId:peerId uuid:[NSUUID UUID] session:nil];
}

- (SSignal *)requestCallWithPeerId:(int64_t)peerId uuid:(NSUUID *)uuid session:(TGCallSession *)session {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        SMetaDisposable *disposable = [[SMetaDisposable alloc] init];
        [_queue dispatch:^{
            int32_t internalId = _nextInternalId;
            _nextInternalId += 1;
            
            TGCallContext *context = [[TGCallContext alloc] init];
            context.uuid = uuid;
            context.session = session;
            context.session.hasCallKit = [TGCallManager useCallKit];
            if ([TGCallManager useCallKit])
                [_callKitAdapter addCallSession:session uuid:uuid];
            
            __weak TGCallManager *weakSelf = self;
            _callContexts[@(internalId)] = context;
            context.context = [[TGCallRequestingContext alloc] init];
            
            void (^stateUpdated)(TGCallStateData *) = ^(TGCallStateData *state) {
                [subscriber putNext:state];
            };
            NSInteger index = [context.stateSubscribers addItem:[stateUpdated copy]];
            
            [self setContextState:internalId state:[[TGCallStateData alloc] initWithInternalId:@(internalId) callId:0 accessHash:0 state:TGCallStateRequesting peerId:peerId connection:nil hungUpOutside:false needsRating:false needsDebug:false error:nil]];
            
            if ([TGCallManager useCallKit])
            {
                [_callKitAdapter startCallWithPeerId:peerId uuid:context.uuid];
                session.onStartedConnecting = ^{
                    __strong TGCallManager *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [strongSelf->_callKitAdapter updateCallWithUUID:uuid connectingAtDate:[NSDate date]];
                    }
                };
                session.onConnected = ^{
                    __strong TGCallManager *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [strongSelf->_callKitAdapter updateCallWithUUID:uuid connectedAtDate:[NSDate date]];
                    }
                };
            }
                
            [context.disposable setDisposable:[[[TGCallSignals requestedOutgoingCallWithPeerId:peerId] deliverOn:_queue] startWithNext:^(id next) {
                __strong TGCallManager *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf performCallContextTransitionWithInternalId:internalId toCallContext:next];
                }
            } error:^(id error) {
                __strong TGCallManager *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    NSString *rpcError = nil;
                    if ([error isKindOfClass:[MTRpcError class]])
                        rpcError = ((MTRpcError *)error).errorDescription;
                    
                    TGCallDiscardedContext *discardedContext = [[TGCallDiscardedContext alloc] initWithCallId:0 reason:TGCallDiscardReasonDisconnect outside:true needsRating:false needsDebug:false error:rpcError];
                    [strongSelf performCallContextTransitionWithInternalId:internalId toCallContext:discardedContext];
                }
            } completed:nil]];
            
            [disposable setDisposable:[[SBlockDisposable alloc] initWithBlock:^{
                [_queue dispatch:^{
                    TGCallContext *context = _callContexts[@(internalId)];
                    [context.stateSubscribers removeItem:index];
                    if ([context.stateSubscribers isEmpty]) {
                        [self cleanupContext:internalId];
                    }
                }];
            }]];
        }];
        return disposable;
    }];
}

- (void)updateCallContextWithCallId:(int64_t)callId callContext:(id)callContext {
    [_queue dispatch:^{
        __block int32_t internalId = -1;
        [_callContexts enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, TGCallContext *context, BOOL *stop) {
            if ([context.context conformsToProtocol:@protocol(TGCallIdentifiableContext)]) {
                id<TGCallIdentifiableContext> identifiableContext = context.context;
                if (identifiableContext.callId == callId) {
                    internalId = [key intValue];
                    *stop = true;
                }
            }
        }];
        if (internalId != -1) {
            TGCallContext *context = _callContexts[@(internalId)];
            if (context != nil) {
                [self performCallContextTransitionWithInternalId:internalId toCallContext:callContext];
            }
        } else if ([callContext isKindOfClass:[TGCallRequestedContext class]]) {
            if ([_discardedCallIds containsObject:@(callId)]) {
                TGLog(@"CallManager: ignoring incoming call id %lld, because it's already discarded", callId);
                return;
            }
            
            TGCallRequestedContext *requestedContext = (TGCallRequestedContext *)callContext;
            bool hasActiveCall = false;
            for (TGCallContext *context in [_callContexts allValues])
            {
                if (requestedContext.adminId == context.session.peerId || requestedContext.participantId == context.session.peerId)
                    [context.session hangUpCurrentCall];
                else
                    hasActiveCall = true;
            }
            
            int32_t internalId = _nextInternalId;
            _nextInternalId += 1;
            
            TGCallContext *context = [[TGCallContext alloc] init];
            context.uuid = [NSUUID UUID];
            _callContexts[@(internalId)] = context;
            
            if (!hasActiveCall)
            {
                context.session = [[TGCallSession alloc] initWithSignal:[self callStateWithInternalId:@(internalId)] outgoing:false];
                if ([TGCallManager useCallKit])
                    [_callKitAdapter addCallSession:context.session uuid:context.uuid];
                [self performCallContextTransitionWithInternalId:internalId toCallContext:callContext];
            }
            else
            {
                context.context = [[TGCallRequestedContext alloc] initWithCallId:requestedContext.callId accessHash:requestedContext.accessHash date:requestedContext.date adminId:requestedContext.adminId participantId:requestedContext.participantId gAHash:requestedContext.gAHash declined:true];
                context.session = [[TGCallSession alloc] initWithSignal:[self callStateWithInternalId:@(internalId)] outgoing:false];
                [self discardCallWithInternalId:@(internalId) reason:TGCallDiscardReasonBusy];
            }
        } else if ([callContext isKindOfClass:[TGCallDiscardedContext class]]) {
            [_discardedCallIds addObject:@(callId)];
            TGLog(@"CallManager: Added unknown discarded call with id %lld", callId);
        } else {
            TGLog(@"CallManager: Unknown call context with id %lld", callId);
        }
    }];
}

- (void)_dispatch:(dispatch_block_t)block
{
    [_queue dispatch:block];
}

- (void)performCallContextTransitionWithInternalId:(int32_t)internalId toCallContext:(id)toCallContext {
    NSAssert([_queue isCurrentQueue], @"[_queue isCurrentQueue]");
    
    TGCallContext *context = _callContexts[@(internalId)];
    NSAssert(context != nil, @"context != nil");
    
    void (^invalidTransition)(id, id) = ^(id from, id to)
    {
        [self setContextState:internalId state:[[TGCallStateData alloc] initWithInternalId:@(internalId) callId:0 accessHash:0 state:TGCallStateEnded peerId:0 connection:nil hungUpOutside:false needsRating:false needsDebug:false error:@"INVALID_TRANSITION"]];
        
        TGLog(@"CallManager: Invalid call context transition %@ -> %@", from, to);
        [self cleanupContext:internalId];
    };
    
    if (context.context == nil) {
        if ([toCallContext isKindOfClass:[TGCallRequestedContext class]]) {
            TGCallRequestedContext *requestedContext = (TGCallRequestedContext *)toCallContext;
            context.context = toCallContext;
            
            bool isSimulator = false;
#if TARGET_OS_SIMULATOR
            isSimulator = true;
#endif
            __weak TGCallManager *weakSelf = self;
            if (![TGCallManager useCallKit] || ![TGCallKitAdapter callKitAvailable] || ![TGCallSession hasMicrophoneAccess] || isSimulator) {
                [context.session presentCallNotification:requestedContext.adminId];
            } else {
                context.session.hasCallKit = true;
                
                [_callKitAdapter reportIncomingCallWithPeerId:requestedContext.adminId session:context.session uuid:context.uuid completion:^(bool silent) {
                    if (silent)
                        [context.session presentCallNotification:requestedContext.adminId];
                }];    
            }
            
            [self setContextState:internalId state:[[TGCallStateData alloc] initWithInternalId:@(internalId) callId:requestedContext.callId accessHash:requestedContext.accessHash state:TGCallStateHandshake peerId:requestedContext.adminId connection:nil hungUpOutside:false needsRating:false needsDebug:false error:nil]];
            _incomingCallInternalIdsPipe.sink(@(internalId));
            
            [context.disposable setDisposable:[[[TGCallSignals receivedIncomingCallWithCallId:requestedContext.callId accessHash:requestedContext.accessHash date:requestedContext.date adminId:requestedContext.adminId participantId:requestedContext.participantId gAHash:requestedContext.gAHash] deliverOn:_queue] startWithNext:^(TGCallOngoingContext *next) {
                __strong TGCallManager *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf performCallContextTransitionWithInternalId:internalId toCallContext:next];
                }
            } error:^(__unused id error) {
                __strong TGCallManager *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf cleanupContext:internalId];
                }
            } completed:nil]];
        } else {
            invalidTransition(nil, toCallContext);
        }
    } else if ([toCallContext isKindOfClass:[TGCallDiscardedContext class]]) {
        if ([context.context isKindOfClass:[TGCallDiscardedContext class]]) {
        } else {
            TGCallDiscardedContext *discardedContext = (TGCallDiscardedContext *)toCallContext;
            bool declined = false;
            if ([context.context isKindOfClass:[TGCallRequestedContext class]]) {
                declined = ((TGCallRequestedContext *)context.context).declined;
            }
            context.context = discardedContext;
            TGCallState callState = TGCallStateEnded;
            switch (discardedContext.reason) {
                case TGCallDiscardReasonBusy:
                    callState = TGCallStateBusy;
                    break;
                    
                case TGCallDiscardReasonMissed:
                    callState = TGCallStateMissed;
                    break;
                    
                case TGCallDiscardReasonMissedTimeout:
                    if (context.session.outgoing)
                        callState = TGCallStateNoAnswer;
                    else
                        callState = TGCallStateMissed;
                    break;
                    
                default:
                    break;
            }
            [self setContextState:internalId state:[[TGCallStateData alloc] initWithInternalId:@(internalId) callId:discardedContext.callId accessHash:0 state:callState peerId:0 connection:nil hungUpOutside:discardedContext.outside needsRating:discardedContext.needsRating needsDebug:discardedContext.needsDebug error:discardedContext.error]];
            
            _endedIncomingCallInternalIdsPipe.sink(@(internalId));
            
            if (!context.session.hasCallKit || declined || context.session.completed || (discardedContext.reason == TGCallDiscardReasonBusy && !discardedContext.outside)) {
                [self cleanupContext:internalId];
            } else {
                [_callKitAdapter endCallWithUUID:context.uuid reason:discardedContext.reason completion:^{
                    [_queue dispatch:^{
                        [self cleanupContext:internalId];
                    }];
                }];
            }
        }
    } else if ([context.context isKindOfClass:[TGCallRequestingContext class]]) {
        if ([toCallContext isKindOfClass:[TGCallWaitingContext class]]) {
            TGCallWaitingContext *waitingContext = (TGCallWaitingContext *)toCallContext;
            context.context = toCallContext;
            [self setContextState:internalId state:[[TGCallStateData alloc] initWithInternalId:@(internalId) callId:waitingContext.callId accessHash:waitingContext.accessHash state:TGCallStateWaiting peerId:waitingContext.participantId connection:nil hungUpOutside:false needsRating:false needsDebug:false error:nil]];
        } else {
            invalidTransition(context.context, toCallContext);
        }
    } else if ([context.context isKindOfClass:[TGCallWaitingContext class]]) {
        if ([toCallContext isKindOfClass:[TGCallWaitingContext class]]) {
            TGCallWaitingContext *waitingContext = context.context;
            TGCallWaitingContext *updatedWaitingContext = toCallContext;
            if (updatedWaitingContext.receiveDate > waitingContext.receiveDate) {
                TGCallWaitingContext *newWaitingContext = [[TGCallWaitingContext alloc] initWithCallId:updatedWaitingContext.callId accessHash:updatedWaitingContext.accessHash date:updatedWaitingContext.date adminId:updatedWaitingContext.adminId participantId:updatedWaitingContext.participantId a:waitingContext.a gA:waitingContext.gA dhConfig:waitingContext.dhConfig receiveDate:updatedWaitingContext.receiveDate];
                context.context = newWaitingContext;
                [self setContextState:internalId state:[[TGCallStateData alloc] initWithInternalId:@(internalId) callId:newWaitingContext.callId accessHash:newWaitingContext.accessHash state:TGCallStateWaitingReceived peerId:newWaitingContext.participantId connection:nil hungUpOutside:false needsRating:false needsDebug:false error:nil]];
            }
        } else if ([toCallContext isKindOfClass:[TGCallAcceptedContext class]]) {
            TGCallWaitingContext *waitingContext = context.context;
            TGCallAcceptedContext *acceptedContext = toCallContext;
            
            TLmessages_DhConfig$messages_dhConfig *config = waitingContext.dhConfig;

            NSMutableData *key = [MTExp(acceptedContext.gB, waitingContext.a, config.p) mutableCopy];
            
            if (key.length > 256) {
                [key replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:0];
            }
            while (key.length < 256) {
                uint8_t zero = 0;
                [key replaceBytesInRange:NSMakeRange(0, 0) withBytes:&zero length:1];
            }
            
            NSData *keyHash = MTSha1(key);
            NSData *nKeyId = [[NSData alloc] initWithBytes:(((uint8_t *)keyHash.bytes) + keyHash.length - 8) length:8];
            int64_t keyId = 0;
            [nKeyId getBytes:&keyId length:8];
            
            context.context = [[TGCallAcceptedContext alloc] initWithCallId:acceptedContext.callId accessHash:acceptedContext.accessHash date:acceptedContext.date adminId:acceptedContext.adminId participantId:acceptedContext.participantId gA:waitingContext.gA gB:acceptedContext.gB];
            
            __weak TGCallManager *weakSelf = self;
            [context.disposable setDisposable:[[[TGCallSignals confirmedCallWithCallId:acceptedContext.callId accessHash:acceptedContext.accessHash key:key gABytes:waitingContext.gA keyId:keyId] deliverOn:_queue] startWithNext:^(TGCallOngoingContext *next) {
                __strong TGCallManager *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf performCallContextTransitionWithInternalId:internalId toCallContext:next];
                }
            } error:^(__unused id error) {
                __strong TGCallManager *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf cleanupContext:internalId];
                }
            } completed:nil]];
        } else {
            invalidTransition(context.context, toCallContext);
        }
    } else if ([context.context isKindOfClass:[TGCallRequestedContext class]]) {
        if ([toCallContext isKindOfClass:[TGCallRequestedContext class]]) {
        } else if ([toCallContext isKindOfClass:[TGCallWaitingConfirmContext class]]) {
            TGCallWaitingConfirmContext *waitingConfirmContext = toCallContext;
            context.context = waitingConfirmContext;
            [self setContextState:internalId state:[[TGCallStateData alloc] initWithInternalId:@(internalId) callId:waitingConfirmContext.callId accessHash:waitingConfirmContext.accessHash state:TGCallStateAccepting peerId:waitingConfirmContext.adminId connection:nil hungUpOutside:false needsRating:false needsDebug:false error:nil]];
        } else if ([toCallContext isKindOfClass:[TGCallReceivedContext class]]) {
            TGCallReceivedContext *receivedContext = toCallContext;
            context.context = toCallContext;
            [self setContextState:internalId state:[[TGCallStateData alloc] initWithInternalId:@(internalId) callId:receivedContext.callId accessHash:receivedContext.accessHash state:TGCallStateReady peerId:receivedContext.adminId connection:nil hungUpOutside:false needsRating:false needsDebug:false error:nil]];
        }
        else {
            invalidTransition(context.context, toCallContext);
        }
    } else if ([context.context isKindOfClass:[TGCallReceivedContext class]]) {
        if ([toCallContext isKindOfClass:[TGCallWaitingConfirmContext class]]) {
            TGCallWaitingConfirmContext *waitingConfirmContext = toCallContext;
            context.context = waitingConfirmContext;
        }
        else {
            invalidTransition(context.context, toCallContext);
        }
    } else if ([context.context isKindOfClass:[TGCallWaitingConfirmContext class]]) {
        if ([toCallContext isKindOfClass:[TGCallConfirmedContext class]]) {
            TGCallWaitingConfirmContext *previousContext = context.context;
            TGCallConfirmedContext *confirmedContext = toCallContext;
            
            TLmessages_DhConfig$messages_dhConfig *config = previousContext.dhConfig;
            NSData *gA = confirmedContext.gA;
            NSData *gAHash = MTSha256(gA);
            NSData *b = previousContext.b;
            
            NSMutableData *key = [MTExp(gA, b, config.p) mutableCopy];
            
            if (key.length > 256) {
                [key replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:1];
            } while (key.length < 256) {
                uint8_t zero = 0;
                [key replaceBytesInRange:NSMakeRange(0, 0) withBytes:&zero length:1];
            }
            
            NSData *keyHash = MTSha1(key);
            NSData *nKeyId = [[NSData alloc] initWithBytes:(((uint8_t *)keyHash.bytes) + keyHash.length - 8) length:8];
            int64_t keyId = 0;
            [nKeyId getBytes:&keyId length:8];

            if (keyId == confirmedContext.keyFingerprint && [gAHash isEqual:previousContext.gAHash]) {
                NSMutableData *hashedData = [[NSMutableData alloc] initWithData:key];
                [hashedData appendData:gA];
                NSData *visKeyHash = MTSha256(hashedData);
                
                context.context = [[TGCallOngoingContext alloc] initWithCallId:confirmedContext.callId accessHash:confirmedContext.accessHash date:confirmedContext.date adminId:confirmedContext.adminId participantId:confirmedContext.participantId key:key keyFingerprint:keyId defaultConnection:confirmedContext.defaultConnection alternativeConnections:confirmedContext.alternativeConnections];
                [self setContextState:internalId state:[[TGCallStateData alloc] initWithInternalId:@(internalId) callId:confirmedContext.callId accessHash:confirmedContext.accessHash state:TGCallStateOngoing peerId:confirmedContext.participantId connection:[[TGCallConnection alloc] initWithKey:key keyHash:visKeyHash defaultConnection:confirmedContext.defaultConnection alternativeConnections:confirmedContext.alternativeConnections] hungUpOutside:false needsRating:false needsDebug:false error:nil]];
            } else {
                TGLog(@"Call key gA hash or fingerprint mismatch");
                [self cleanupContext:internalId];
            }
        }
    } else if ([context.context isKindOfClass:[TGCallAcceptedContext class]]) {
        if ([toCallContext isKindOfClass:[TGCallOngoingContext class]]) {
            TGCallAcceptedContext *previousContext = context.context;
            TGCallOngoingContext *ongoingContext = toCallContext;
            context.context = toCallContext;
            
            NSMutableData *hashedData = [[NSMutableData alloc] initWithData:ongoingContext.key];
            [hashedData appendData:previousContext.gA];
            NSData *visKeyHash = MTSha256(hashedData);
            
            [self setContextState:internalId state:[[TGCallStateData alloc] initWithInternalId:@(internalId) callId:ongoingContext.callId accessHash:ongoingContext.accessHash state:TGCallStateOngoing peerId:ongoingContext.participantId connection:[[TGCallConnection alloc] initWithKey:ongoingContext.key keyHash:visKeyHash defaultConnection:ongoingContext.defaultConnection alternativeConnections:ongoingContext.alternativeConnections] hungUpOutside:false needsRating:false needsDebug:false error:nil]];
        }
    } else if ([context.context isKindOfClass:[TGCallOngoingContext class]]) {
        if ([toCallContext isKindOfClass:[TGCallConfirmedContext class]])
            return;
        
        invalidTransition(context.context, toCallContext);
    }
}

- (void)setContextState:(int32_t)internalId state:(TGCallStateData *)state {
    NSAssert([_queue isCurrentQueue], @"[_queue isCurrentQueue]");
    TGCallContext *context = _callContexts[@(internalId)];
    if (context != nil) {
        context.state = state;
        for (void (^subscriber)(TGCallStateData *) in [context.stateSubscribers copyItems]) {
            subscriber(state);
        }
    }
}

- (void)cleanupContext:(int32_t)internalId {
    NSAssert([_queue isCurrentQueue], @"[_queue isCurrentQueue]");
    [_callContexts removeObjectForKey:@(internalId)];
    
    TGLog(@"CallManager: cleanup call context with internalId %ld", internalId);
}

- (SSignal *)callStateWithInternalId:(id)internalId {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        SMetaDisposable *disposable = [[SMetaDisposable alloc] init];
        [_queue dispatch:^{
            if ([internalId respondsToSelector:@selector(intValue)]) {
                TGCallContext *context = _callContexts[internalId];
                if (context == nil) {
                    context = [[TGCallContext alloc] init];
                    context.uuid = [NSUUID UUID];
                }
                void (^stateUpdated)(TGCallStateData *) = ^(TGCallStateData *state) {
                    [subscriber putNext:state];
                };
                NSInteger index = [context.stateSubscribers addItem:[stateUpdated copy]];
                [subscriber putNext:context.state];
                
                [disposable setDisposable:[[SBlockDisposable alloc] initWithBlock:^{
                    [_queue dispatch:^{
                        TGCallContext *context = _callContexts[internalId];
                        [context.stateSubscribers removeItem:index];
                        if ([context.stateSubscribers isEmpty]) {
                            [self cleanupContext:[internalId intValue]];
                        }
                    }];
                }]];
            } else {
                [subscriber putNext:nil];
                [subscriber putCompletion];
            }
        }];
        return disposable;
    }];
}

- (SSignal *)incomingCallInternalIds {
    return _incomingCallInternalIdsPipe.signalProducer();
}

- (SSignal *)endedIncomingCallInternalIds {
    return _endedIncomingCallInternalIdsPipe.signalProducer();
}

- (void)acceptCallWithInternalId:(id)internalId {
    if (internalId == nil)
        return;
    
    [[[[[self callStateWithInternalId:internalId] mapToSignal:^SSignal *(TGCallStateData *state) {
        if (state.state != TGCallStateHandshake && state.state != TGCallStateReady)
            return [SSignal fail:nil];
        return [SSignal single:state];
    }] filter:^bool(TGCallStateData *state) {
        return state.state == TGCallStateReady;
    }] take:1] startWithNext:^(TGCallStateData *state) {
        int32_t internalIdVal = [internalId int32Value];
        [_queue dispatch:^{
            TGCallContext *context = _callContexts[internalId];
            __weak TGCallManager *weakSelf = self;
            
            TGCallReceivedContext *receivedContext = (TGCallReceivedContext *)context.context;
            [self setContextState:internalIdVal state:[[TGCallStateData alloc] initWithInternalId:internalId callId:receivedContext.callId accessHash:receivedContext.accessHash state:TGCallStateAccepting peerId:state.peerId connection:nil hungUpOutside:false needsRating:false needsDebug:false error:nil]];
            
            [context.disposable setDisposable:[[[TGCallSignals acceptedIncomingCallWithCallId:receivedContext.callId accessHash:receivedContext.accessHash dhConfig:receivedContext.dhConfig bBytes:receivedContext.b gBBytes:receivedContext.gB gAHash:receivedContext.gAHash] deliverOn:_queue] startWithNext:^(id next) {
                __strong TGCallManager *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf performCallContextTransitionWithInternalId:internalIdVal toCallContext:next];
                }
            } error:^(id error) {
                __strong TGCallManager *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    NSString *rpcError = nil;
                    if ([error isKindOfClass:[MTRpcError class]])
                        rpcError = ((MTRpcError *)error).errorDescription;
                    TGCallDiscardedContext *discardedContext = [[TGCallDiscardedContext alloc] initWithCallId:receivedContext.callId reason:TGCallDiscardReasonDisconnect outside:false needsRating:false needsDebug:false error:rpcError];
                    [strongSelf->_queue dispatch:^{
                        [strongSelf performCallContextTransitionWithInternalId:internalIdVal toCallContext:discardedContext];
                    }];
                }
            } completed:nil]];
        }];
    }];
}

- (void)discardCallWithInternalId:(id)internalId reason:(TGCallDiscardReason)reason
{
    [self discardCallWithInternalId:internalId reason:reason error:nil];
}

- (void)discardCallWithInternalId:(id)internalId reason:(TGCallDiscardReason)reason error:(NSString *)error {
    int32_t internalIdVal = [internalId int32Value];
    [_queue dispatch:^{
        __weak TGCallManager *weakSelf = self;
        
        TGCallContext *context = _callContexts[internalId];
        if (context == nil)
            return;
        
        int64_t callId = 0;
        int64_t accessHash = 0;
        
        if ([context.context conformsToProtocol:@protocol(TGCallIdentifiableContext)]) {
            id<TGCallIdentifiableContext> identifiableContext = context.context;
            callId = identifiableContext.callId;
            if ([identifiableContext respondsToSelector:@selector(accessHash)])
                accessHash = identifiableContext.accessHash;
        }
        
        TGCallDiscardReason localReason = (reason == TGCallDiscardReasonBusy) ? TGCallDiscardReasonHangup : reason;
        if (reason != TGCallDiscardReasonMissedTimeout)
        {
            [self setContextState:internalIdVal state:[[TGCallStateData alloc] initWithInternalId:internalId callId:callId accessHash:accessHash state:TGCallStateEnding peerId:context.state.peerId connection:nil hungUpOutside:false needsRating:false needsDebug:false error:error]];
        }
        
        if (callId == 0 || accessHash == 0)
        {
            TGCallDiscardedContext *callContext = [[TGCallDiscardedContext alloc] initWithCallId:callId reason:localReason outside:false needsRating:false needsDebug:false error:nil];
            [self performCallContextTransitionWithInternalId:internalIdVal toCallContext:callContext];
            return;
        }
        
        if ([context.context isKindOfClass:[TGCallRequestingContext class]]) {
            TGCallDiscardedContext *callContext = [[TGCallDiscardedContext alloc] initWithCallId:callId reason:localReason outside:false needsRating:false needsDebug:false error:nil];
            [self performCallContextTransitionWithInternalId:internalIdVal toCallContext:callContext];
        } else {
            [context.disposable setDisposable:[[[[TGCallSignals discardedCallWithCallId:callId accessHash:accessHash reason:reason duration:(int32_t)context.session.duration] timeout:5.0 onQueue:_queue orSignal:[SSignal single:[[TGCallDiscardedContext alloc] initWithCallId:callId reason:localReason outside:false needsRating:false needsDebug:false error:nil]]] deliverOn:_queue] startWithNext:^(TGCallDiscardedContext *next) {
                __strong TGCallManager *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    if (next.reason != localReason)
                        next = [[TGCallDiscardedContext alloc] initWithCallId:next.callId reason:localReason outside:next.outside needsRating:next.needsRating needsDebug:next.needsDebug error:next.error];
                    [strongSelf performCallContextTransitionWithInternalId:internalIdVal toCallContext:next];
                }
            } error:^(__unused id error) {
                __strong TGCallManager *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    NSString *rpcError = nil;
                    if ([error isKindOfClass:[MTRpcError class]])
                        rpcError = ((MTRpcError *)error).errorDescription;
                    if ([rpcError isEqualToString:@"CALL_ALREADY_DECLINED"])
                        rpcError = nil;
                    
                    TGCallDiscardedContext *callContext = [[TGCallDiscardedContext alloc] initWithCallId:callId reason:localReason outside:false needsRating:false needsDebug:false error:rpcError];
                    [strongSelf->_queue dispatch:^{
                        [strongSelf performCallContextTransitionWithInternalId:internalIdVal toCallContext:callContext];
                    }];
                }
            } completed:nil]];
        }
     }];
}

- (TGCallSession *)sessionForIncomingCallWithInternalId:(id)internalId {
    __block TGCallSession *session;
    [_queue dispatchSync:^{
        session = [_callContexts[internalId] session];
    }];
    return session;
}

- (TGCallSession *)sessionForOutgoingCallWithPeerId:(int64_t)peerId {
    NSUUID *uuid = [NSUUID UUID];
    TGCallSession *session = [[TGCallSession alloc] initOutgoing:true];
    [session startWithSignal:[self requestCallWithPeerId:peerId uuid:uuid session:session]];
    if ([TGCallManager useCallKit])
    {
        [_queue dispatch:^{
            [_callKitAdapter addCallSession:session uuid:uuid];
        }];
    }
    return session;
}

- (bool)hasActiveCall
{
    __block bool hasActiveCall = false;
    [_queue dispatchSync:^{
        hasActiveCall = _callContexts.count > 0;
    }];
    return hasActiveCall;
}

@end
