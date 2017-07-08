#import "TGCallKitAdapter.h"

#import <CallKit/Callkit.h>
#import "TGDatabase.h"

#import "TGCallSession.h"

@interface TGCallKitAdapter () <CXProviderDelegate>
{
    CXProvider *_provider;
    CXCallController *_callController;
    SQueue *_queue;
    
    SPipe *_audioSessionActivationPipe;
    SPipe *_audioSessionDeactivationPipe;

    NSMapTable *_sessions;
    NSMutableDictionary *_actionCompletionBlocks;
}
@end

@implementation TGCallKitAdapter

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _queue = [[SQueue alloc] init];
        _sessions = [[NSMapTable alloc] initWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory capacity:8];
        
        _audioSessionActivationPipe = [[SPipe alloc] init];
        _audioSessionDeactivationPipe = [[SPipe alloc] init];
        
        _provider = [[CXProvider alloc] initWithConfiguration:[TGCallKitAdapter configuration]];
        [_provider setDelegate:self queue:_queue._dispatch_queue];
        
        _callController = [[CXCallController alloc] initWithQueue:_queue._dispatch_queue];
        
        _actionCompletionBlocks = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (CXProviderConfiguration *)configuration
{
    CXProviderConfiguration *config = [[CXProviderConfiguration alloc] initWithLocalizedName:TGLocalized(@"Application.Name")];
    config.supportsVideo = false;
    config.maximumCallsPerCallGroup = 1;
    config.maximumCallGroups = 1;
    config.supportedHandleTypes = [NSSet setWithObjects:@(CXHandleTypeGeneric), @(CXHandleTypePhoneNumber), nil];
    config.iconTemplateImageData = UIImagePNGRepresentation([UIImage imageNamed:@"CallKitLogo"]);

    return config;
}

- (void)startCallWithPeerId:(int64_t)peerId uuid:(NSUUID *)uuid
{
    TGUser *user = nil;
    CXHandle *handle = [self _handleForPeerId:peerId outUser:&user];
    CXStartCallAction *action = [[CXStartCallAction alloc] initWithCallUUID:uuid handle:handle];
    action.contactIdentifier = user.displayName;
    
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:action];
    [self _requestTransaction:transaction completion:^(__unused bool succeed)
    {
        CXCallUpdate *update = [[CXCallUpdate alloc] init];
        update.remoteHandle = handle;
        update.localizedCallerName = user.displayName;
        update.supportsHolding = false;
        update.supportsGrouping = false;
        update.supportsUngrouping = false;
        update.supportsDTMF = false;
        
        [_provider reportCallWithUUID:uuid updated:update];
    }];
}

- (void)updateCallWithUUID:(NSUUID *)uuid connectingAtDate:(NSDate *)date
{
    [_provider reportOutgoingCallWithUUID:uuid startedConnectingAtDate:date];
}

- (void)updateCallWithUUID:(NSUUID *)uuid connectedAtDate:(NSDate *)date
{
    [_provider reportOutgoingCallWithUUID:uuid connectedAtDate:date];
}

- (void)endCallWithUUID:(NSUUID *)uuid reason:(TGCallDiscardReason)reason completion:(void (^)(void))completion
{
    if (true || reason == TGCallDiscardReasonHangup)
    {
        CXEndCallAction *action = [[CXEndCallAction alloc] initWithCallUUID:uuid];
        CXTransaction *transaction = [[CXTransaction alloc] initWithAction:action];
        
        TGDispatchOnMainThread(^
        {
            [self _requestTransaction:transaction completion:nil];
        });
        
        if (completion != nil)
            _actionCompletionBlocks[action.UUID] = completion;
    }
    else
    {
        CXCallEndedReason endedReason = CXCallEndedReasonFailed;
        switch (reason) {
            case TGCallDiscardReasonDisconnect:
                endedReason = CXCallEndedReasonFailed;
                break;
                
            case TGCallDiscardReasonBusy:
            case TGCallDiscardReasonMissed:
                endedReason = CXCallEndedReasonUnanswered;
                break;
                
            case TGCallDiscardReasonRemoteHangup:
                endedReason = CXCallEndedReasonRemoteEnded;
                break;
            
            default:
                break;
        }
        
        [_provider reportCallWithUUID:uuid endedAtDate:[NSDate date] reason:endedReason];
    }
}

- (void)_requestTransaction:(CXTransaction *)transaction completion:(void (^)(bool))completion
{
    [_callController requestTransaction:transaction completion:^(NSError *error)
    {
        if (error != nil)
        {
            TGLog(@"CALLKITERROR %@", error);
        }
        if (completion != nil)
            completion(error == nil);
    }];
}

- (void)reportIncomingCallWithPeerId:(int64_t)peerId session:(TGCallSession *)session uuid:(NSUUID *)uuid completion:(void (^)(bool))completion
{
    TGLog(@"CALLKIT REPORT INCOMING CALL %@", uuid);
    
    TGUser *user = nil;
    CXCallUpdate *update = [[CXCallUpdate alloc] init];
    update.remoteHandle = [self _handleForPeerId:peerId outUser:&user];
    update.localizedCallerName = user.displayName;
    update.supportsHolding = false;
    update.supportsGrouping = false;
    update.supportsUngrouping = false;
    update.supportsDTMF = false;
    
    SVariable *audioSessionActivated = [[SVariable alloc] init];
    [audioSessionActivated set:[SSignal single:@false]];
    [audioSessionActivated set:_audioSessionActivationPipe.signalProducer()];
    session.audioSessionActivated = audioSessionActivated;
    
    [session setupAudioSession:^
    {
        TGDispatchOnMainThread(^
        {
            [_provider reportNewIncomingCallWithUUID:uuid update:update completion:^(NSError *error)
            {
                bool silent = ([error.domain isEqualToString:CXErrorDomainIncomingCall] && error.code == CXErrorCodeIncomingCallErrorFilteredByDoNotDisturb);
                TGDispatchOnMainThread(^
                {
                    if (completion != nil)
                        completion(silent);
                });
            }];
        });
    }];
}

- (CXHandle *)_handleForPeerId:(int64_t)peerId outUser:(TGUser **)outUser
{
    TGUser *user = [TGDatabaseInstance() loadUser:(int32_t)peerId];
    if (outUser != NULL)
        *outUser = user;
    
    CXHandle *handle = nil;
    if (user.phoneNumber.length > 0)
        handle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:user.phoneNumber];
    else
        handle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:[NSString stringWithFormat:@"TGCA%d", user.uid]];

    return handle;
}

- (void)providerDidReset:(CXProvider *)__unused provider
{
    
}

- (void)provider:(CXProvider *)__unused provider performStartCallAction:(CXStartCallAction *)action
{
    TGCallSession *session = [self _sessionForUUID:action.callUUID];
    if (session == nil)
    {
        [action fail];
        return;
    }
    
    TGDispatchOnMainThread(^
    {
        [session markCallAcceptedTime];
        [session setupAudioSession:nil];
        [action fulfill];
    });
}

- (void)provider:(CXProvider *)__unused provider performAnswerCallAction:(CXAnswerCallAction *)action
{
    TGCallSession *session = [self _sessionForUUID:action.callUUID];
    if (session == nil)
    {
        [action fail];
        return;
    }
    
    TGDispatchOnMainThread(^
    {
        __weak TGCallKitAdapter *weakSelf = self;
        session.onStartedConnecting = ^{
            __strong TGCallKitAdapter *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf updateCallWithUUID:action.callUUID connectingAtDate:[NSDate date]];
            }
        };
        
        [session acceptIncomingCall];
        [action fulfill];
    });
}

- (void)provider:(CXProvider *)__unused provider performEndCallAction:(CXEndCallAction *)action
{
    TGCallSession *session = [self _sessionForUUID:action.callUUID];
    if (session == nil)
    {
        [action fail];
        return;
    }
    
    TGDispatchOnMainThread(^
    {
        if (!session.hungUpOutside)
            [session hangUpCurrentCall:true];

        [action fulfillWithDateEnded:[NSDate date]];
        
        if (_actionCompletionBlocks[action.UUID] != nil)
        {
            dispatch_block_t block = _actionCompletionBlocks[action.UUID];
            block();
            _actionCompletionBlocks[action.UUID] = nil;
        }
    });
}

- (void)provider:(CXProvider *)__unused provider performSetMutedCallAction:(CXSetMutedCallAction *)action
{
    TGCallSession *session = [self _sessionForUUID:action.callUUID];
    TGDispatchOnMainThread(^
    {
        [session setMuted:action.isMuted];
        [action fulfill];
    });
}

- (void)provider:(CXProvider *)__unused provider didActivateAudioSession:(AVAudioSession *)__unused audioSession
{
    TGLog(@"CallKitAdapter: did activate audio session");
    _audioSessionActivationPipe.sink(@true);
}

- (void)provider:(CXProvider *)__unused provider didDeactivateAudioSession:(AVAudioSession *)__unused audioSession
{
    TGLog(@"CallKitAdapter: did deactivate audio session");
    [TGCallSession resetAudioSession];
    _audioSessionDeactivationPipe.sink(@true);
}

- (void)addCallSession:(TGCallSession *)session uuid:(NSUUID *)uuid
{
    [_queue dispatch:^
    {
        [_sessions setObject:session forKey:uuid];
        
        SVariable *audioSessionDeactivated = [[SVariable alloc] init];
        [audioSessionDeactivated set:[SSignal single:@false]];
        [audioSessionDeactivated set:_audioSessionDeactivationPipe.signalProducer()];
        session.audioSessionDeactivated = audioSessionDeactivated;
    }];
}

- (TGCallSession *)_sessionForUUID:(NSUUID *)uuid
{
    if (uuid == nil)
        return nil;
    
    return [_sessions objectForKey:uuid];
}

+ (bool)callKitAvailable
{
    return iosMajorVersion() >= 10;
}

@end
