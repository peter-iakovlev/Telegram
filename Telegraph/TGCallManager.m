#import "TGCallManager.h"

#import "TGCallContext.h"
#import "TGCallSignals.h"
#import "TGCallSession.h"
#import "TGCallKitAdapter.h"

#import <MTProtoKit/MTProtoKit.h>

#import "TL/TLMetaScheme.h"

@interface TGCallManager () {
    SQueue *_queue;
    int32_t _nextInternalId;
    
    NSMutableDictionary<NSNumber *, TGCallContext *> *_callContexts;
    
    SPipe *_incomingCallInternalIdsPipe;
    
    TGCallKitAdapter *_callKitAdapter;
}
@end

@implementation TGCallManager

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _queue = [[SQueue alloc] init];
        _callContexts = [[NSMutableDictionary alloc] init];
        _incomingCallInternalIdsPipe = [[SPipe alloc] init];
        
        if ([TGCallKitAdapter callKitAvailable])
            _callKitAdapter = [[TGCallKitAdapter alloc] init];
    }
    return self;
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
            [_callKitAdapter addCallSession:session uuid:uuid];
            
            __weak TGCallManager *weakSelf = self;
            _callContexts[@(internalId)] = context;
            context.context = [[TGCallRequestingContext alloc] init];
            
            void (^stateUpdated)(TGCallStateData *) = ^(TGCallStateData *state) {
                [subscriber putNext:state];
            };
            NSInteger index = [context.stateSubscribers addItem:[stateUpdated copy]];
            
            [self setContextState:internalId state:[[TGCallStateData alloc] initWithInternalId:@(internalId) callId:0 state:TGCallStateRequesting peerId:peerId connection:nil]];
            
            [_callKitAdapter startCallWithPeerId:peerId uuid:context.uuid];
            
            [context.disposable setDisposable:[[[TGCallSignals requestedOutgoingCallWithPeerId:peerId] deliverOn:_queue] startWithNext:^(id next) {
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
            if ([context.context isKindOfClass:[TGCallWaitingContext class]]) {
                if (((TGCallWaitingContext *)context.context).callId == callId) {
                    internalId = [key intValue];
                    *stop = true;
                }
            } else if ([context.context isKindOfClass:[TGCallRequestedContext class]]) {
                if (((TGCallRequestedContext *)context.context).callId == callId) {
                    internalId = [key intValue];
                    *stop = true;
                }
            } else if ([context.context isKindOfClass:[TGCallOngoingContext class]]) {
                if (((TGCallOngoingContext *)context.context).callId == callId) {
                    internalId = [key intValue];
                    *stop = true;
                }
            } else if ([context.context isKindOfClass:[TGCallReceivedContext class]]) {
                if (((TGCallReceivedContext *)context.context).callId == callId) {
                    internalId = [key intValue];
                    *stop = true;
                }
            } else if ([context.context isKindOfClass:[TGCallAcceptedContext class]]) {
                if (((TGCallAcceptedContext *)context.context).callId == callId) {
                    internalId = [key intValue];
                    *stop = true;
                }
            } else if ([context.context isKindOfClass:[TGCallDiscardedContext class]]) {
                if (((TGCallDiscardedContext *)context.context).callId == callId) {
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
                [_callKitAdapter addCallSession:context.session uuid:context.uuid];
                [self performCallContextTransitionWithInternalId:internalId toCallContext:callContext];
            }
            else
            {
                context.context = requestedContext;
                context.session = [[TGCallSession alloc] initWithSignal:[self discardCallWithInternalId:@(internalId) reason:TGCallDiscardReasonBusy] outgoing:false];
            }
        } else {
            TGLog(@"Unknown call context with id %lld", callId);
        }
    }];
}

- (void)performCallContextTransitionWithInternalId:(int32_t)internalId toCallContext:(id)toCallContext {
    NSAssert([_queue isCurrentQueue], @"[_queue isCurrentQueue]");
    
    TGCallContext *context = _callContexts[@(internalId)];
    NSAssert(context != nil, @"context != nil");
    
    if (context.context == nil) {
        if ([toCallContext isKindOfClass:[TGCallRequestedContext class]]) {
            TGCallRequestedContext *requestedContext = (TGCallRequestedContext *)toCallContext;
            context.context = toCallContext;
            [self setContextState:internalId state:[[TGCallStateData alloc] initWithInternalId:@(internalId) callId:requestedContext.callId state:TGCallStateHandshake peerId:requestedContext.adminId connection:nil]];
            _incomingCallInternalIdsPipe.sink(@(internalId));
            
            [_callKitAdapter reportIncomingCallWithPeerId:requestedContext.adminId uuid:context.uuid completion:nil];
            
            __weak TGCallManager *weakSelf = self;
            [context.disposable setDisposable:[[[TGCallSignals receivedIncomingCallWithCallId:requestedContext.callId accessHash:requestedContext.accessHash date:requestedContext.date adminId:requestedContext.adminId participantId:requestedContext.participantId gA:requestedContext.gA] deliverOn:_queue] startWithNext:^(TGCallOngoingContext *next) {
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
            TGLog(@"Invalid call context transition none -> %@", toCallContext);
            [self cleanupContext:internalId];
        }
    } else if ([toCallContext isKindOfClass:[TGCallDiscardedContext class]]) {
        if ([context.context isKindOfClass:[TGCallDiscardedContext class]]) {
        } else {
            TGCallDiscardedContext *discardedContext = (TGCallDiscardedContext *)toCallContext;
            context.context = discardedContext;
            TGCallState callState = discardedContext.reason == TGCallDiscardReasonBusy ? TGCallStateBusy : TGCallStateEnded;
            [self setContextState:internalId state:[[TGCallStateData alloc] initWithInternalId:@(internalId) callId:discardedContext.callId state:callState peerId:0 connection:nil]];
            
            if ([TGCallKitAdapter callKitAvailable]) {
                if (context.session.completed || discardedContext.reason == TGCallDiscardReasonBusy) {
                    [self cleanupContext:internalId];
                }
                else {
                    [_callKitAdapter endCallWithUUID:context.uuid reason:discardedContext.reason completion:^{
                        [_queue dispatch:^{
                            [self cleanupContext:internalId]; 
                        }];
                    }];
                }
            }
            else {
                [self cleanupContext:internalId];
            }
        }
    } else if ([context.context isKindOfClass:[TGCallRequestingContext class]]) {
        if ([toCallContext isKindOfClass:[TGCallWaitingContext class]]) {
            TGCallWaitingContext *waitingContext = (TGCallWaitingContext *)toCallContext;
            context.context = toCallContext;
            [self setContextState:internalId state:[[TGCallStateData alloc] initWithInternalId:@(internalId) callId:waitingContext.callId state:TGCallStateWaiting peerId:waitingContext.participantId connection:nil]];
        } else {
            TGLog(@"Invalid call context transition TGCallRequestingContext -> %@", toCallContext);
            [self cleanupContext:internalId];
        }
    } else if ([context.context isKindOfClass:[TGCallWaitingContext class]]) {
        if ([toCallContext isKindOfClass:[TGCallWaitingContext class]]) {
            TGCallWaitingContext *waitingContext = context.context;
            TGCallWaitingContext *updatedWaitingContext = toCallContext;
            if (updatedWaitingContext.receiveDate > waitingContext.receiveDate) {
                TGCallWaitingContext *newWaitingContext = [[TGCallWaitingContext alloc] initWithCallId:updatedWaitingContext.callId accessHash:updatedWaitingContext.accessHash date:updatedWaitingContext.date adminId:updatedWaitingContext.adminId participantId:updatedWaitingContext.participantId a:waitingContext.a dhConfig:waitingContext.dhConfig receiveDate:updatedWaitingContext.receiveDate];
                context.context = newWaitingContext;
                [self setContextState:internalId state:[[TGCallStateData alloc] initWithInternalId:@(internalId) callId:newWaitingContext.callId state:TGCallStateWaitingReceived peerId:newWaitingContext.participantId connection:nil]];
            }
        } else if ([toCallContext isKindOfClass:[TGCallAcceptedContext class]]) {
            TGCallWaitingContext *waitingContext = context.context;
            TGCallAcceptedContext *acceptedContext = toCallContext;
            
            TLmessages_DhConfig$messages_dhConfig *config = waitingContext.dhConfig;
            
            NSMutableData *key = [MTExp(acceptedContext.gAOrB, waitingContext.a, config.p) mutableCopy];
            
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
            
            if (keyId == acceptedContext.keyFingerprint) {
                context.context = [[TGCallOngoingContext alloc] initWithCallId:acceptedContext.callId accessHash:acceptedContext.accessHash date:acceptedContext.date adminId:acceptedContext.adminId participantId:acceptedContext.participantId key:key keyFingerprint:keyId defaultConnection:acceptedContext.defaultConnection alternativeConnections:acceptedContext.alternativeConnections];
                [self setContextState:internalId state:[[TGCallStateData alloc] initWithInternalId:@(internalId) callId:acceptedContext.callId state:TGCallStateOngoing peerId:acceptedContext.participantId connection:[[TGCallConnection alloc] initWithKey:key defaultConnection:acceptedContext.defaultConnection alternativeConnections:acceptedContext.alternativeConnections]]];
            } else {
                TGLog(@"Call key fingerprint mismatch");
                [self cleanupContext:internalId];
            }
        } else {
            TGLog(@"Invalid call context transition TGCallWaitingContext -> %@", toCallContext);
            [self cleanupContext:internalId];
        }
    } else if ([context.context isKindOfClass:[TGCallRequestedContext class]]) {
        if ([toCallContext isKindOfClass:[TGCallRequestedContext class]]) {
        } else if ([toCallContext isKindOfClass:[TGCallOngoingContext class]]) {
            TGCallOngoingContext *ongoingContext = toCallContext;
            context.context = toCallContext;
            [self setContextState:internalId state:[[TGCallStateData alloc] initWithInternalId:@(internalId) callId:ongoingContext.callId state:TGCallStateOngoing peerId:ongoingContext.participantId connection:[[TGCallConnection alloc] initWithKey:ongoingContext.key defaultConnection:ongoingContext.defaultConnection alternativeConnections:ongoingContext.alternativeConnections]]];
        } else if ([toCallContext isKindOfClass:[TGCallReceivedContext class]]) {
            TGCallReceivedContext *receivedContext = toCallContext;
            context.context = toCallContext;
            [self setContextState:internalId state:[[TGCallStateData alloc] initWithInternalId:@(internalId) callId:receivedContext.callId state:TGCallStateReady peerId:receivedContext.adminId connection:nil]];
        }
        else {
            TGLog(@"Invalid call context transition TGCallRequestedContext -> %@", toCallContext);
            [self cleanupContext:internalId];
        }
    } else if ([context.context isKindOfClass:[TGCallReceivedContext class]]) {
        if ([toCallContext isKindOfClass:[TGCallOngoingContext class]]) {
            TGCallOngoingContext *ongoingContext = toCallContext;
            context.context = toCallContext;
            [self setContextState:internalId state:[[TGCallStateData alloc] initWithInternalId:@(internalId) callId:ongoingContext.callId state:TGCallStateOngoing peerId:ongoingContext.adminId connection:[[TGCallConnection alloc] initWithKey:ongoingContext.key defaultConnection:ongoingContext.defaultConnection alternativeConnections:ongoingContext.alternativeConnections]]];
        }
    } else if ([context.context isKindOfClass:[TGCallOngoingContext class]]) {
        TGLog(@"Invalid call context transition TGCallOngoingContext -> %@", toCallContext);
        [self cleanupContext:internalId];
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

- (SSignal *)acceptCallWithInternalId:(id)internalId {
    if (internalId == nil)
        return [SSignal fail:nil];
    
    return [[[[[self callStateWithInternalId:internalId] mapToSignal:^SSignal *(TGCallStateData *state) {
        if (state.state != TGCallStateHandshake && state.state != TGCallStateReady)
            return [SSignal fail:nil];
        return [SSignal single:state];
    }] filter:^bool(TGCallStateData *state) {
        return state.state == TGCallStateReady;
    }] take:1] mapToSignal:^SSignal *(__unused TGCallStateData *state) {
        return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
        {
            int32_t internalIdVal = [internalId int32Value];
            SMetaDisposable *disposable = [[SMetaDisposable alloc] init];
            [_queue dispatch:^ {
                TGCallContext *context = _callContexts[internalId];
                __weak TGCallManager *weakSelf = self;
            
                void (^stateUpdated)(TGCallStateData *) = ^(TGCallStateData *state) {
                    [subscriber putNext:state];
                };
                NSInteger index = [context.stateSubscribers addItem:[stateUpdated copy]];
                
                TGCallReceivedContext *receivedContext = (TGCallReceivedContext *)context.context;
                [self setContextState:internalIdVal state:[[TGCallStateData alloc] initWithInternalId:internalId callId:receivedContext.callId state:TGCallStateAccepting peerId:state.peerId connection:[[TGCallConnection alloc] initWithKey:state.connection.key defaultConnection:state.connection.defaultConnection alternativeConnections:state.connection.alternativeConnections]]];
                
                [context.disposable setDisposable:[[[TGCallSignals acceptedIncomingCallWithCallId:receivedContext.callId accessHash:receivedContext.accessHash key:receivedContext.key gBBytes:receivedContext.gAOrB keyId:receivedContext.keyFingerprint] deliverOn:_queue] startWithNext:^(id next) {
                    __strong TGCallManager *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [strongSelf performCallContextTransitionWithInternalId:internalIdVal toCallContext:next];
                    }
                } error:^(__unused id error) {
                    __strong TGCallManager *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [strongSelf cleanupContext:internalIdVal];
                    }
                } completed:nil]];
                
                [disposable setDisposable:[[SBlockDisposable alloc] initWithBlock:^{
                    [_queue dispatch:^{
                        TGCallContext *context = _callContexts[internalId];
                        [context.stateSubscribers removeItem:index];
                        if ([context.stateSubscribers isEmpty]) {
                            [self cleanupContext:internalIdVal];
                        }
                    }];
                }]];
            }];
            return disposable;
        }];
    }];
}

- (SSignal *)discardCallWithInternalId:(id)internalId reason:(TGCallDiscardReason)reason {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        int32_t internalIdVal = [internalId int32Value];
        SMetaDisposable *disposable = [[SMetaDisposable alloc] init];
        [_queue dispatch:^{
            __weak TGCallManager *weakSelf = self;
            
            TGCallContext *context = _callContexts[internalId];
            void (^stateUpdated)(TGCallStateData *) = ^(TGCallStateData *state) {
                [subscriber putNext:state];
            };
            NSInteger index = [context.stateSubscribers addItem:[stateUpdated copy]];
            
            int64_t callId = 0;
            int64_t accessHash = 0;
            
            if ([context.context isKindOfClass:[TGCallWaitingContext class]]) {
                callId = ((TGCallWaitingContext *)context.context).callId;
                accessHash = ((TGCallWaitingContext *)context.context).accessHash;
            } else if ([context.context isKindOfClass:[TGCallRequestedContext class]]) {
                callId = ((TGCallRequestedContext *)context.context).callId;
                accessHash = ((TGCallRequestedContext *)context.context).accessHash;
            } else if ([context.context isKindOfClass:[TGCallOngoingContext class]]) {
                callId = ((TGCallOngoingContext *)context.context).callId;
                accessHash = ((TGCallOngoingContext *)context.context).accessHash;
            } else if ([context.context isKindOfClass:[TGCallReceivedContext class]]) {
                callId = ((TGCallReceivedContext *)context.context).callId;
                accessHash = ((TGCallReceivedContext *)context.context).accessHash;
            } else if ([context.context isKindOfClass:[TGCallAcceptedContext class]]) {
                callId = ((TGCallAcceptedContext *)context.context).callId;
                accessHash = ((TGCallAcceptedContext *)context.context).accessHash;
            }
            
            [self setContextState:internalIdVal state:[[TGCallStateData alloc] initWithInternalId:internalId callId:callId state:TGCallStateEnding peerId:context.state.peerId connection:nil]];
            
            if ([context.context isKindOfClass:[TGCallRequestingContext class]]) {
                TGCallDiscardedContext *callContext = [[TGCallDiscardedContext alloc] initWithCallId:callId reason:reason];
                [self performCallContextTransitionWithInternalId:internalIdVal toCallContext:callContext];
            } else {
    
                [context.disposable setDisposable:[[[TGCallSignals discardedCallWithCallId:callId accessHash:accessHash reason:reason duration:(int32_t)context.session.duration] deliverOn:_queue] startWithNext:^(id next) {
                    __strong TGCallManager *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [strongSelf performCallContextTransitionWithInternalId:internalIdVal toCallContext:next];
                    }
                } error:^(__unused id error) {
                    __strong TGCallManager *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        TGCallDiscardedContext *callContext = [[TGCallDiscardedContext alloc] initWithCallId:callId reason:reason];
                        [strongSelf performCallContextTransitionWithInternalId:internalIdVal toCallContext:callContext];
                    }
                } completed:nil]];
            }
            
            [disposable setDisposable:[[SBlockDisposable alloc] initWithBlock:^{
                [_queue dispatch:^{
                    TGCallContext *context = _callContexts[@(internalIdVal)];
                    [context.stateSubscribers removeItem:index];
                    if ([context.stateSubscribers isEmpty]) {
                        [self cleanupContext:internalIdVal];
                    }
                }];
            }]];
        }];
        return disposable;
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
    [_queue dispatch:^{
        [_callKitAdapter addCallSession:session uuid:uuid];
    }];
    return session;
}

@end
