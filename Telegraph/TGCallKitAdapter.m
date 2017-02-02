#import "TGCallKitAdapter.h"

#import <CallKit/Callkit.h>
#import "TGDatabase.h"

#import "TGCallSession.h"

@interface TGCallKitAdapter () <CXProviderDelegate>
{
    CXProvider *_provider;
    CXCallController *_callController;
    SQueue *_queue;
    
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
    //config.iconTemplateImageData = UIImagePNGRepresentation(nil);
    //config.ringtoneSoune = @"Ringtone.caf"
    
    return config;
}

- (void)startCallWithPeerId:(int64_t)peerId uuid:(NSUUID *)uuid
{
    TGUser *user = nil;
    CXStartCallAction *action = [[CXStartCallAction alloc] initWithCallUUID:uuid handle:[self _handleForPeerId:peerId outUser:&user]];
    action.contactIdentifier = user.displayName;
    
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:action];
    [self _requestTransaction:transaction completion:nil];
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
        [self _requestTransaction:transaction completion:nil];
        
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
        if (completion != nil)
            completion(error == nil);
    }];
}

- (void)reportIncomingCallWithPeerId:(int64_t)peerId uuid:(NSUUID *)uuid completion:(void (^)(bool))completion
{
    TGUser *user = nil;
    CXCallUpdate *update = [[CXCallUpdate alloc] init];
    update.remoteHandle = [self _handleForPeerId:peerId outUser:&user];
    update.localizedCallerName = user.displayName;
    
    TGCallSession *session = [self _sessionForUUID:uuid];
    TGDispatchOnMainThread(^
    {
        [session setupAudioSession];
    });
    
    [_provider reportNewIncomingCallWithUUID:uuid update:update completion:^(NSError *error)
    {
        if (completion != nil)
            completion(error == nil);
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
        [session setupAudioSession];
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
        [session hangUpCurrentCall:true];
        [action fulfill];
        
        if (_actionCompletionBlocks[action.UUID] != nil)
        {
            dispatch_block_t block = _actionCompletionBlocks[action.UUID];
            block();
            _actionCompletionBlocks[action.UUID] = nil;
        }
    });
}

- (void)provider:(CXProvider *)__unused provider performSetHeldCallAction:(CXSetHeldCallAction *)action
{
    TGCallSession *session = [self _sessionForUUID:action.callUUID];
    if (session == nil)
    {
        [action fail];
        return;
    }
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
}

- (void)provider:(CXProvider *)__unused provider didDeactivateAudioSession:(AVAudioSession *)__unused audioSession
{
    [TGCallSession resetAudioSession];
}

- (void)addCallSession:(TGCallSession *)session uuid:(NSUUID *)uuid
{
    [_queue dispatch:^
    {
        [_sessions setObject:session forKey:uuid];
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
#ifdef INTERNAL_RELEASE
    return iosMajorVersion() >= 10;
#else
    return false;
#endif
}

@end
