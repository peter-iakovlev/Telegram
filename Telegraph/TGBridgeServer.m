#import "TGBridgeServer.h"
#import "TGBridgeCommon.h"

#import <WatchConnectivity/WatchConnectivity.h>
#import <libkern/OSAtomic.h>

#import "TGAppDelegate.h"
#import "TGTelegramNetworking.h"

#import "TGBridgeSignalManager.h"

#import "TGBridgeContext.h"
#import "TGBridgeResponse.h"
#import "TGBridgeSubscription.h"
#import "TGBridgeChatListHandler.h"
#import "TGBridgeChatMessageListHandler.h"
#import "TGBridgeContactsHandler.h"
#import "TGBridgeSendMessageHandler.h"
#import "TGBridgeConversationHandler.h"
#import "TGBridgeUserInfoHandler.h"
#import "TGBridgeMediaHandler.h"
#import "TGBridgeLocationHandler.h"
#import "TGBridgeStickersHandler.h"
#import "TGBridgePeerSettingsHandler.h"
#import "TGBridgeRemoteHandler.h"
#import "TGBridgeStateHandler.h"

#import "TGBridgeChatMessageListSubscription.h"

#import "TGBridgeContextService.h"
#import "TGBridgeStickersService.h"

#import "TGBridgeAudioConverter.h"

@interface TGBridgeServer () <WCSessionDelegate>
{
    bool _pendingStart;
    bool _servicesRunning;

    bool _processingNotification;
    
    int32_t _sessionId;
    
    TGBridgeContext *_activeContext;
    
    TGBridgeSignalManager *_signalManager;
    NSMutableDictionary *_handlerMap;
    
    OSSpinLock _incomingQueueLock;
    NSMutableArray *_incomingMessageQueue;
    
    bool _requestSubscriptionList;
    NSArray *_initialSubscriptionList;
    
    OSSpinLock _outgoingQueueLock;
    NSMutableArray *_outgoingMessageQueue;
    
    OSSpinLock _replyHandlerMapLock;
    NSMutableDictionary *_replyHandlerMap;
    
    OSSpinLock _lastServiceSignalStateLock;
    NSMutableDictionary *_lastServiceSignalState;
    SMulticastSignalManager *_serviceSignalManager;
    
    TGBridgeContextService *_contextService;
    TGBridgeStickersService *_stickersService;
    
    NSInteger _wakeupToken;
}

@property (nonatomic, readonly) WCSession *session;

@end

@implementation TGBridgeServer

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _signalManager = [[TGBridgeSignalManager alloc] init];
        _handlerMap = [[NSMutableDictionary alloc] init];
        _incomingMessageQueue = [[NSMutableArray alloc] init];
        
        NSArray *handlerClasses = @[ [TGBridgeChatListHandler class],
                                     [TGBridgeChatMessageListHandler class],
                                     [TGBridgeConversationHandler class],
                                     [TGBridgeContactsHandler class],
                                     [TGBridgeSendMessageHandler class],
                                     [TGBridgeUserInfoHandler class],
                                     [TGBridgeMediaHandler class],
                                     [TGBridgeLocationHandler class],
                                     [TGBridgeStickersHandler class],
                                     [TGBridgePeerSettingsHandler class],
                                     [TGBridgeRemoteHandler class],
                                     [TGBridgeStateHandler class]
                                     ];
        
        for (Class class in handlerClasses)
            [self registerHandlerClass:class];
        
        self.session.delegate = self;
        [self.session activateSession];
        
        _replyHandlerMap = [[NSMutableDictionary alloc] init];
        
        _lastServiceSignalState = [[NSMutableDictionary alloc] init];
        _serviceSignalManager = [[SMulticastSignalManager alloc] init];
        
        _activeContext = [[TGBridgeContext alloc] initWithDictionary:[self.session applicationContext]];
    }
    return  self;
}

- (void)startRunning
{
    if (!_servicesRunning)
    {
        _pendingStart = true;
        return;
    }
    
    if (self.isRunning)
        return;
    
    OSSpinLockLock(&_incomingQueueLock);
    _isRunning = true;
    
    for (id message in _incomingMessageQueue)
        [self handleMessage:message replyHandler:nil finishTask:nil completion:nil];
    
    [_incomingMessageQueue removeAllObjects];
    OSSpinLockUnlock(&_incomingQueueLock);
}

- (void)startServices
{
    if (!self.session.isWatchAppInstalled)
        return;
    
    _contextService = [[TGBridgeContextService alloc] initWithServer:self];
    _stickersService = [[TGBridgeStickersService alloc] initWithServer:self];
    
    _servicesRunning = true;
    if (_pendingStart)
        [self startRunning];
}

- (NSURL *)temporaryFilesURL
{
    return self.session.watchDirectoryURL;
}

- (bool)isWatchAppInstalled
{
    return self.session.isWatchAppInstalled;
}

#pragma mark - 

- (void)setAuthorized:(bool)authorized userId:(int32_t)userId
{
    _activeContext.authorized = authorized;
    _activeContext.userId = userId;
    
    if (!authorized)
        [_activeContext setStartupData:nil version:0];
    
    [self pushActiveContext];
}

- (void)setPasscodeEnabled:(bool)passcodeEnabled passcodeEncrypted:(bool)passcodeEncrypted
{
    _activeContext.passcodeEnabled = passcodeEnabled;
    _activeContext.passcodeEncrypted = passcodeEncrypted;
    
    [self pushActiveContext];
}

- (void)setStartupData:(NSDictionary *)dataObject
{
    [_activeContext setStartupData:dataObject version:[TGBridgeContext versionWithCurrentDate]];

    if (!self.session.isReachable)
        [self pushActiveContext];
}

- (void)pushActiveContext
{
    if (!self.isWatchAppInstalled)
        return;
    
    NSError *error;
    [self.session updateApplicationContext:[_activeContext encodeWithStartupData:!self.session.isReachable] error:&error];
    
    if (error != nil)
        TGLog(@"[BridgeServer][ERROR] Failed to push active application context: %@", error.localizedDescription);
}

#pragma mark -

- (void)handleMessageData:(NSData *)messageData backgroundTask:(UIBackgroundTaskIdentifier)backgroundTask replyHandler:(void (^)(NSData *))replyHandler completion:(void (^)(void))completion
{
    __block UIBackgroundTaskIdentifier runningTask = backgroundTask;
    void (^finishTask)(NSTimeInterval) = ^(NSTimeInterval delay)
    {
        if (runningTask != UIBackgroundTaskInvalid)
        {
            if (delay > DBL_EPSILON)
            {
                TGDispatchAfter(delay, dispatch_get_main_queue(), ^
                {
                    [[UIApplication sharedApplication] endBackgroundTask:runningTask];
                    TGLog(@"[BridgeRouter]: ended taskid: %d", runningTask);
                    runningTask = UIBackgroundTaskInvalid;
                });
            }
            else
            {
                [[UIApplication sharedApplication] endBackgroundTask:runningTask];
                TGLog(@"[BridgeRouter]: ended taskid: %d", runningTask);
                runningTask = UIBackgroundTaskInvalid;
            }
        }
    };
    
    id message = [NSKeyedUnarchiver unarchiveObjectWithData:messageData];
    if ([message isKindOfClass:[TGBridgeChatMessageSubscription class]])
    {
        TGLog(@"!!!!!!!!!!![BridgeServer] Processing notification message request: %@", message);
        [self processNotificationRequest:message replyHandler:replyHandler];
        finishTask(4.0);
        return;
    }
    
    OSSpinLockLock(&_incomingQueueLock);
    if (!self.isRunning)
    {
        [_incomingMessageQueue addObject:message];
        
        if (replyHandler != nil)
            replyHandler([NSData data]);
        
        finishTask(4.0);
        
        OSSpinLockUnlock(&_incomingQueueLock);
        return;
    }
    OSSpinLockUnlock(&_incomingQueueLock);
    
    [self handleMessage:message replyHandler:replyHandler finishTask:finishTask completion:completion];
}

- (void)processNotificationRequest:(TGBridgeChatMessageSubscription *)subscription replyHandler:(void (^)(NSData *))replyHandler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        Class subscriptionHandler = [self handlerForSubscription:subscription];
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block NSData *result = nil;
        [[subscriptionHandler handlingSignalForSubscription:subscription server:self] startWithNext:^(id next)
        {
            TGBridgeResponse *response = [TGBridgeResponse single:next forSubscription:subscription];
            result = [NSKeyedArchiver archivedDataWithRootObject:response];
             
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        if (result != nil)
        {
            replyHandler(result);
        }
        else
        {
            replyHandler([NSData data]);
        }
    });
}

- (void)handleMessage:(id)message replyHandler:(void (^)(NSData *))replyHandler finishTask:(void (^)(NSTimeInterval))finishTask completion:(void (^)(void))completion
{
    if ([message isKindOfClass:[TGBridgeSubscription class]])
    {
        TGBridgeSubscription *subcription = (TGBridgeSubscription *)message;
        [self _createSubscription:subcription replyHandler:replyHandler finishTask:finishTask completion:completion];
        
        TGLog(@"[BridgeServer] Create subscription: %@", subcription);
    }
    else if ([message isKindOfClass:[TGBridgeDisposal class]])
    {
        TGBridgeDisposal *disposal = (TGBridgeDisposal *)message;
        [_signalManager haltSignalForKey:[NSString stringWithFormat:@"%lld", disposal.identifier]];
        
        if (replyHandler != nil)
            replyHandler([NSData data]);
        
        if (completion != nil)
            completion();
        
        TGLog(@"[BridgeServer] Dispose subscription %lld", disposal.identifier);
        
        if (finishTask != nil)
            finishTask(0);
    }
    else if ([message isKindOfClass:[TGBridgeSubscriptionList class]])
    {
        TGBridgeSubscriptionList *list = (TGBridgeSubscriptionList *)message;
        for (TGBridgeSubscription *subscription in list.subscriptions)
            [self _createSubscription:subscription replyHandler:nil finishTask:nil completion:nil];
        
        TGLog(@"[BridgeServer] Received required subscription list, applying");
        
        if (replyHandler != nil)
            replyHandler([NSData data]);
        
        if (finishTask != nil)
            finishTask(4.0);
        
        if (completion != nil)
            completion();
    }
    else if ([message isKindOfClass:[TGBridgePing class]])
    {
        TGBridgePing *ping = (TGBridgePing *)message;
        if (_sessionId != ping.sessionId)
        {
            TGLog(@"[BridgeServer] Session id mismatch");
            
            if (_sessionId != 0)
            {
                TGLog(@"[BridgeServer] Halt all active subscriptions");
                [_signalManager haltAllSignals];
                
                OSSpinLockLock(&_outgoingQueueLock);
                [_outgoingMessageQueue removeAllObjects];
                OSSpinLockUnlock(&_outgoingQueueLock);
            }
            
            _sessionId = ping.sessionId;
            
            if (self.session.isReachable)
                [self _requestSubscriptionList];
            else
                _requestSubscriptionList = true;
        }
        else
        {
            if (_requestSubscriptionList)
            {
                _requestSubscriptionList = false;
                [self _requestSubscriptionList];
            }
            
            [self _sendQueuedResponses];
            
            if (replyHandler != nil)
                replyHandler([NSData data]);
        }
        
        if (completion != nil)
            completion();
        
        if (finishTask != nil)
            finishTask(4.0);
    }
}

- (void)_createSubscription:(TGBridgeSubscription *)subscription replyHandler:(void (^)(NSData *))replyHandler finishTask:(void (^)(NSTimeInterval))finishTask completion:(void (^)(void))completion
{
    Class subscriptionHandler = [self handlerForSubscription:subscription];
    
    if (subscription.synchronous)
    {
        replyHandler([NSData data]);
        
        [self.session transferUserInfo:@{ @"info": @"lolka" }];
        return;
        
        if ([subscription isKindOfClass:[TGBridgeChatMessageSubscription class]])
            _processingNotification = true;
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block NSData *result = nil;
        [[subscriptionHandler handlingSignalForSubscription:subscription server:self] startWithNext:^(id next)
        {
            TGBridgeResponse *response = [TGBridgeResponse single:next forSubscription:subscription];
            result = [NSKeyedArchiver archivedDataWithRootObject:response];
            
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        //NSString *key = [NSString stringWithFormat:@"%lld", subscription.identifier];
        //NSURL *tmpurl = [NSURL URLWithString:key relativeToURL:self.temporaryFilesURL];
        //[result writeToURL:tmpurl atomically:true];
        
        if (result != nil)
        {
            //[self sendFileWithURL:tmpurl key:key];
            replyHandler([NSKeyedArchiver archivedDataWithRootObject:@"smth"]);
        }
        else
        {
//            replyHandler([NSData data]);
        }
        
        if ([subscription isKindOfClass:[TGBridgeChatMessageSubscription class]])
            _processingNotification = false;
        
        return;
    }
    
    if (replyHandler != nil)
    {
        OSSpinLockLock(&_replyHandlerMapLock);
        _replyHandlerMap[@(subscription.identifier)] = replyHandler;
        OSSpinLockUnlock(&_replyHandlerMapLock);
    }
    
    if (subscriptionHandler != nil)
    {
        [_signalManager startSignalForKey:[NSString stringWithFormat:@"%lld", subscription.identifier] producer:^SSignal *
        {
            STimer *timer = [[STimer alloc] initWithTimeout:2.0 repeat:false completion:^
            {
                OSSpinLockLock(&_replyHandlerMapLock);
                void (^reply)(NSData *) = _replyHandlerMap[@(subscription.identifier)];
                if (reply == nil)
                {
                    OSSpinLockUnlock(&_replyHandlerMapLock);
                    return;
                }
                
                reply([NSData data]);
                [_replyHandlerMap removeObjectForKey:@(subscription.identifier)];
                OSSpinLockUnlock(&_replyHandlerMapLock);
                
                if (finishTask != nil)
                    finishTask(4.0);
                
                TGLog(@"[BridgeServer]: subscription 0x%x hit 2.0s timeout, releasing reply handler", subscription.identifier);
            } queue:[SQueue mainQueue]];
            [timer start];
            
            return [[SSignal alloc] initWithGenerator:^id<SDisposable>(__unused SSubscriber *subscriber)
            {
                return [[subscriptionHandler handlingSignalForSubscription:subscription server:self] startWithNext:^(id next)
                {
                    [timer invalidate];
                    [self _responseToSubscription:subscription message:next type:TGBridgeResponseTypeNext completion:completion];
                } error:^(id error)
                {
                    [timer invalidate];
                    [self _responseToSubscription:subscription message:error type:TGBridgeResponseTypeFailed completion:completion];
                } completed:^
                {
                    [timer invalidate];
                    [self _responseToSubscription:subscription message:nil type:TGBridgeResponseTypeCompleted completion:completion];
                }];
            }];
        }];
    }
}

- (void)_responseToSubscription:(TGBridgeSubscription *)subscription message:(id<NSCoding>)message type:(TGBridgeResponseType)type completion:(void (^)(void))completion
{
    TGBridgeResponse *response = nil;
    switch (type)
    {
        case TGBridgeResponseTypeNext:
            response = [TGBridgeResponse single:message forSubscription:subscription];
            break;
            
        case TGBridgeResponseTypeFailed:
            response = [TGBridgeResponse fail:message forSubscription:subscription];
            break;
            
        case TGBridgeResponseTypeCompleted:
            response = [TGBridgeResponse completeForSubscription:subscription];
            break;
            
        default:
            break;
    }
    
    OSSpinLockLock(&_replyHandlerMapLock);
    void (^reply)(NSData *) = _replyHandlerMap[@(subscription.identifier)];
    if (reply != nil)
        [_replyHandlerMap removeObjectForKey:@(subscription.identifier)];
    OSSpinLockUnlock(&_replyHandlerMapLock);
    
    if (_processingNotification)
    {
        [self _enqueueResponse:response forSubscription:subscription];
        
        if (completion != nil)
            completion();
        
        return;
    }
    
    NSData *messageData = [NSKeyedArchiver archivedDataWithRootObject:response];
    if (reply != nil && messageData.length < 64000)
    {
        reply(messageData);
        
        if (completion != nil)
            completion();
    }
    else
    {
        if (reply != nil)
            reply([NSData data]);
        
        if (self.session.isReachable)
        {
            [self.session sendMessageData:messageData replyHandler:nil errorHandler:^(NSError *error)
            {
                 if (error != nil)
                     TGLog(@"[BridgeServer]: send response for subscription %lld failed with error %@", subscription.identifier, error);
            }];
        }
        else
        {
            TGLog(@"[BridgeServer]: client out of reach, queueing response for subscription %lld", subscription.identifier);
            [self _enqueueResponse:response forSubscription:subscription];
        }
        
        if (completion != nil)
            completion();
    }
}

- (void)_enqueueResponse:(TGBridgeResponse *)response forSubscription:(TGBridgeSubscription *)subscription
{
    OSSpinLockLock(&_outgoingQueueLock);
    NSMutableArray *updatedResponses = (_outgoingMessageQueue != nil) ? [_outgoingMessageQueue mutableCopy] : [[NSMutableArray alloc] init];
    
    if (subscription.dropPreviouslyQueued)
    {
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        
        [updatedResponses enumerateObjectsUsingBlock:^(TGBridgeResponse *queuedResponse, NSUInteger index, __unused BOOL *stop)
        {
            if (queuedResponse.subscriptionIdentifier == subscription.identifier)
                [indexSet addIndex:index];
        }];
        
        [updatedResponses removeObjectsAtIndexes:indexSet];
    }
    
    [updatedResponses addObject:response];
    
    _outgoingMessageQueue = updatedResponses;
    OSSpinLockUnlock(&_outgoingQueueLock);
}

- (void)_sendQueuedResponses
{
    if (_processingNotification)
        return;
    
    OSSpinLockLock(&_outgoingQueueLock);
    
    if (_outgoingMessageQueue.count > 0)
    {
        TGLog(@"[BridgeServer] Sending queued responses");
        
        for (TGBridgeResponse *response in _outgoingMessageQueue)
        {
            NSData *messageData = [NSKeyedArchiver archivedDataWithRootObject:response];
            [self.session sendMessageData:messageData replyHandler:nil errorHandler:nil];
        }
        
        [_outgoingMessageQueue removeAllObjects];
    }
    OSSpinLockUnlock(&_outgoingQueueLock);
}

- (void)_requestSubscriptionList
{
    TGBridgeSubscriptionListRequest *request = [[TGBridgeSubscriptionListRequest alloc] initWithSessionId:_sessionId];
    NSData *messageData = [NSKeyedArchiver archivedDataWithRootObject:request];
    [self.session sendMessageData:messageData replyHandler:nil errorHandler:nil];
}

- (void)sendFileWithURL:(NSURL *)url key:(NSString *)key
{
    if (key == nil)
        return;
    
    TGLog(@"[BridgeServer] Sent file with key %@", key);
    [self.session transferFile:url metadata:@{ TGBridgeFileKey: key }];
}

#pragma mark - Session Delegate

- (void)handleReceivedData:(NSData *)messageData replyHandler:(void (^)(NSData *))replyHandler
{
    if (messageData.length == 0)
    {
        if (replyHandler != nil)
            replyHandler([NSData data]);
        
        return;
    }
    
    __block UIBackgroundTaskIdentifier backgroundTask;
    backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^
    {
        if (replyHandler != nil)
            replyHandler([NSData data]);
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
    }];
    
    __block NSInteger token = 0;
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
        token = [self wakeupNetwork];
    
    [self handleMessageData:messageData backgroundTask:backgroundTask replyHandler:replyHandler completion:^
    {
        [self suspendNetworkIfReady:token];
    }];
}

- (void)session:(WCSession *)__unused session didReceiveMessageData:(NSData *)messageData
{
    [self handleReceivedData:messageData replyHandler:nil];
}

- (void)session:(WCSession *)__unused session didReceiveMessageData:(NSData *)messageData replyHandler:(void (^)(NSData *))replyHandler
{
    [self handleReceivedData:messageData replyHandler:replyHandler];
}

- (void)session:(WCSession *)__unused session didReceiveFile:(WCSessionFile *)file
{
    NSDictionary *metadata = file.metadata;
    if (metadata == nil)
        return;
    
    if ([metadata[TGBridgeIncomingFileTypeKey] isEqualToString:TGBridgeIncomingFileTypeAudio])
        [self handleIncomingAudioWithURL:file.fileURL metadata:metadata];
}

- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo
{
    int64_t peerId = [userInfo[@"peerId"] int64Value];
    int32_t messageId = [userInfo[@"messageId"] int32Value];
    if (peerId != 0 && messageId != 0)
    {
        TGBridgeSubscription *subscription = [[TGBridgeChatMessageSubscription alloc] initWithPeerId:peerId messageId:messageId];
        Class subscriptionHandler = [self handlerForSubscription:subscription];
        
        [[subscriptionHandler handlingSignalForSubscription:subscription server:self] startWithNext:^(NSDictionary *next)
        {
            NSData *response = [NSKeyedArchiver archivedDataWithRootObject:next];
            [session transferUserInfo:@{ @"identifier": @(subscription.identifier),  @"data": response }];
        }];
    }
}

- (void)session:(WCSession *)__unused session didFinishFileTransfer:(WCSessionFileTransfer *)__unused fileTransfer error:(NSError *)__unused error
{
    
}

- (void)sessionWatchStateDidChange:(WCSession *)session
{
    if (session.isWatchAppInstalled)
    {
        if (!_servicesRunning)
            [self startServices];
        
        [self pushActiveContext];
    }
}

- (void)sessionReachabilityDidChange:(WCSession *)session
{
    NSLog(@"[TGBridgeServer] Reachability changed: %d", session.isReachable);
}

#pragma mark -

- (void)handleIncomingAudioWithURL:(NSURL *)url metadata:(NSDictionary *)metadata
{
    NSString *uniqueId = metadata[TGBridgeIncomingFileRandomIdKey];
    int64_t peerId = [metadata[TGBridgeIncomingFilePeerIdKey] int64Value];
    int32_t replyToMid = [metadata[TGBridgeIncomingFileReplyToMidKey] int32Value];
    
    NSURL *tempURL = [NSURL URLWithString:url.lastPathComponent relativeToURL:self.session.watchDirectoryURL];
    
    NSError *error;
    [[NSFileManager defaultManager] moveItemAtURL:url toURL:tempURL error:&error];
    
    NSString *signalKey = [[NSString alloc] initWithFormat:@"convertAudio_%@", uniqueId];
    [_serviceSignalManager startStandaloneSignalIfNotRunningForKey:signalKey producer:^SSignal *
    {
        SSignal *convertSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
        {
            TGBridgeAudioConverter *converter = [[TGBridgeAudioConverter alloc] initWithURL:tempURL];
            [converter startWithCompletion:^(TGDataItem *dataItem, int32_t duration, TGLiveUploadActorData *liveData)
            {
                if (dataItem != nil)
                {
                    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
                    result[@"dataItem"] = dataItem;
                    result[@"duration"] = @(duration);
                    if (liveData != nil)
                        result[@"liveData"] = liveData;
                    
                    [subscriber putNext:result];
                    [subscriber putCompletion];
                }
                else
                {
                    [subscriber putError:nil];
                }
            }];
            
            return nil;
        }];
        
        return [convertSignal mapToSignal:^SSignal *(NSDictionary *result)
        {
            return [TGSendAudioSignal sendAudioWithPeerId:peerId tempDataItem:result[@"dataItem"] liveData:result[@"liveData"] duration:[result[@"duration"] int32Value] replyToMid:replyToMid];
        }];
    }];
}



#pragma mark -

- (void)registerHandlerClass:(Class)handlerClass
{
    NSArray *handledSubscriptions = [handlerClass handledSubscriptions];
    for (Class handledSubscription in handledSubscriptions)
    {
        NSAssert(_handlerMap[[handledSubscription subscriptionName]] == nil, @"Subscription can't have more than one handler");
        _handlerMap[[handledSubscription subscriptionName]] = handlerClass;
    }
}

- (Class)handlerForSubscription:(TGBridgeSubscription *)subscription
{
    if (subscription.name == nil)
        return nil;
    
    return _handlerMap[subscription.name];
}

#pragma mark -

- (SSignal *)serviceSignalForKey:(NSString *)key producer:(SSignal *(^)())producer
{
    __weak TGBridgeServer *weakSelf = self;
    SSignal *(^finalProducer)(void) = ^SSignal *
    {
        SSignal *signal = producer();
        return [signal onNext:^(id next)
        {
            __strong TGBridgeServer *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            OSSpinLockLock(&(strongSelf->_lastServiceSignalStateLock));
            strongSelf->_lastServiceSignalState[key] = next ?: [NSNull null];
            OSSpinLockUnlock(&(strongSelf->_lastServiceSignalStateLock));
        }];
    };
    
    SSignal *signal = [_serviceSignalManager multicastedSignalForKey:key producer:finalProducer];
    
    OSSpinLockLock(&_lastServiceSignalStateLock);
    id lastServiceSignalState = _lastServiceSignalState[key];
    if (lastServiceSignalState != nil)
        signal = [[SSignal single:([lastServiceSignalState isKindOfClass:[NSNull class]]) ? nil : lastServiceSignalState] then:signal];
    OSSpinLockUnlock(&_lastServiceSignalStateLock);
    
    return signal;
}

#pragma mark - 

- (NSInteger)wakeupNetwork
{
    [[TGTelegramNetworking instance] resume];
    
    _wakeupToken++;
    NSInteger token = _wakeupToken;
    
    return token;
}

- (void)suspendNetworkIfReady:(NSInteger)token
{
    if ([TGAppDelegateInstance inBackground] && ![TGAppDelegateInstance backgroundTaskOngoing])
    {
        TGDispatchAfter(15.0, dispatch_get_main_queue(), ^
        {
            if (token == _wakeupToken)
            {
                if ([[TGTelegramNetworking instance] _isReadyToBeSuspended])
                {
                    [[TGTelegramNetworking instance] pause];
                }
                else
                {
                    TGDispatchAfter(10.0, dispatch_get_main_queue(), ^
                    {
                        if (token == _wakeupToken)
                            [[TGTelegramNetworking instance] pause];
                    });
                }
            }
        });
    }
}

#pragma mark -

- (WCSession *)session
{
    return [WCSession defaultSession];
}

#pragma mark - 

+ (instancetype)instance
{
    static dispatch_once_t onceToken;
    static TGBridgeServer *instance;
    dispatch_once(&onceToken, ^
    {
        if (iosMajorVersion() >= 9 && [WCSession isSupported])
            instance = [[TGBridgeServer alloc] init];
    });
    return instance;
}

@end
