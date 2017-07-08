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
#import "TGBridgeAudioHandler.h"
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
#import "TGBridgeLocalizationService.h"
#import "TGBridgePresetsService.h"

@interface TGBridgeServer () <WCSessionDelegate>
{
    bool _pendingStart;
    bool _servicesRunning;

    bool _processingNotification;
    
    int32_t _sessionId;
    
    TGBridgeContext *_activeContext;
    
    NSMutableDictionary *_handlerMap;
    TGBridgeSignalManager *_signalManager;
    
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
    
    NSMutableArray *_services;
    SPipe *_appInstalledPipe;
    
    NSInteger _wakeupToken;
}

@property (nonatomic, readonly) WCSession *session;

@end

@implementation TGBridgeServer

+ (SQueue *)queue {
    static SQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[SQueue alloc] init];
    });
    return queue;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        NSAssert([[TGBridgeServer queue] isCurrentQueue], @"[[TGBridgeServer queue] isCurrentQueue]");
        _signalManager = [[TGBridgeSignalManager alloc] init];
        _handlerMap = [[NSMutableDictionary alloc] init];
        _incomingMessageQueue = [[NSMutableArray alloc] init];
        
        NSArray *handlerClasses = [TGBridgeServer handlerClasses];
        
        for (Class class in handlerClasses)
            [self registerHandlerClass:class];
        
        self.session.delegate = self;
        [self.session activateSession];
        
        _replyHandlerMap = [[NSMutableDictionary alloc] init];
        
        _lastServiceSignalState = [[NSMutableDictionary alloc] init];
        _serviceSignalManager = [[SMulticastSignalManager alloc] init];
        _appInstalledPipe = [[SPipe alloc] init];
        
        _activeContext = [[TGBridgeContext alloc] initWithDictionary:[self.session applicationContext]];
    }
    return  self;
}

+ (NSArray *)handlerClasses
{
    return @
    [
     [TGBridgeAudioHandler class],
     [TGBridgeChatListHandler class],
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
}

+ (NSArray *)serviceClasses
{
    return @
    [
     [TGBridgeContextService class],
     [TGBridgeStickersService class],
     [TGBridgeLocalizationService class],
     [TGBridgePresetsService class]
    ];
}

- (void)startRunning
{
    [[TGBridgeServer queue] dispatch:^{
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
    }];
}

- (void)startServices
{
    [[TGBridgeServer queue] dispatch:^{
        if (!self.session.isWatchAppInstalled)
            return;
        
        _services = [[NSMutableArray alloc] init];
        NSArray *serviceClasses = [TGBridgeServer serviceClasses];
        for (Class serviceClass in serviceClasses)
        {
            TGBridgeService *service = [[serviceClass alloc] initWithServer:self];
            [_services addObject:service];
        }
        
        _servicesRunning = true;
        if (_pendingStart)
            [self startRunning];
    }];
}

- (NSURL *)temporaryFilesURL
{
    return self.session.watchDirectoryURL;
}

- (bool)isPaired
{
    return self.session.isPaired;
}

- (bool)isWatchAppInstalled
{
    return self.session.isWatchAppInstalled;
}

- (SSignal *)watchAppInstalledSignal
{
    return [[[SSignal single:@(self.isWatchAppInstalled)] then:_appInstalledPipe.signalProducer()] startOn:[TGBridgeServer queue]];
}

#pragma mark - 

- (void)setAuthorized:(bool)authorized userId:(int32_t)userId
{
    [[TGBridgeServer queue] dispatch:^{
        _activeContext.authorized = authorized;
        _activeContext.userId = userId;
        
        if (!authorized)
            [_activeContext setStartupData:nil version:0];
        
        [self pushActiveContext];
    }];
}

- (void)setPasscodeEnabled:(bool)passcodeEnabled passcodeEncrypted:(bool)passcodeEncrypted
{
    [[TGBridgeServer queue] dispatch:^{
        _activeContext.passcodeEnabled = passcodeEnabled;
        _activeContext.passcodeEncrypted = passcodeEncrypted;
        
        [self pushActiveContext];
    }];
}

- (void)setMicAccessAllowed:(bool)allowed
{
    [[TGBridgeServer queue] dispatch:^{
        _activeContext.micAccessAllowed = allowed;
        
        [self pushActiveContext];
    }];
}

- (void)setCustomLocalizationEnabled:(bool)enabled
{
    [[TGBridgeServer queue] dispatch:^{
        _activeContext.customLocalizationEnabled = enabled;
        
        [self pushActiveContext];
    }];
}

- (void)setStartupData:(NSDictionary *)dataObject micAccessAllowed:(bool)micAccessAllowed
{
    [[TGBridgeServer queue] dispatch:^{
        [_activeContext setStartupData:dataObject version:[TGBridgeContext versionWithCurrentDate]];
        _activeContext.micAccessAllowed = micAccessAllowed;
        
        [self pushActiveContext];
    }];
}

- (void)pushActiveContext
{
    [[TGBridgeServer queue] dispatch:^{
        if (!self.isWatchAppInstalled)
            return;
        
        NSError *error;
        [self.session updateApplicationContext:[_activeContext encodeWithStartupData:true] error:&error];
        
        if (error != nil)
            TGLog(@"[BridgeServer][ERROR] Failed to push active application context: %@", error.localizedDescription);
    }];
}

#pragma mark -

- (void)handleMessageData:(NSData *)messageData backgroundTask:(UIBackgroundTaskIdentifier)backgroundTask replyHandler:(void (^)(NSData *))replyHandler completion:(void (^)(void))completion
{
    [[TGBridgeServer queue] dispatch:^{
        __block UIBackgroundTaskIdentifier runningTask = backgroundTask;
        void (^finishTask)(NSTimeInterval) = ^(NSTimeInterval delay)
        {
            if (runningTask == UIBackgroundTaskInvalid)
                return;
            
            void (^block)(void) = ^
            {
                [[UIApplication sharedApplication] endBackgroundTask:runningTask];
                TGLog(@"[BridgeRouter]: ended taskid: %d", runningTask);
                runningTask = UIBackgroundTaskInvalid;
            };
            
            if (delay > DBL_EPSILON)
                TGDispatchAfter(delay, dispatch_get_main_queue(), block);
            else
                block();
        };
        
        id message = [NSKeyedUnarchiver unarchiveObjectWithData:messageData];
        if ([message isKindOfClass:[TGBridgeChatMessageSubscription class]])
        {
            TGLog(@"[BridgeServer] Processing notification message request: %@", message);
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
    }];
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
    [[TGBridgeServer queue] dispatch:^{
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
    }];
}

- (void)_createSubscription:(TGBridgeSubscription *)subscription replyHandler:(void (^)(NSData *))replyHandler finishTask:(void (^)(NSTimeInterval))finishTask completion:(void (^)(void))completion
{
    [[TGBridgeServer queue] dispatch:^{
        Class subscriptionHandler = [self handlerForSubscription:subscription];
        
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
    }];
}

- (void)_responseToSubscription:(TGBridgeSubscription *)subscription message:(id<NSCoding>)message type:(TGBridgeResponseType)type completion:(void (^)(void))completion
{
    [[TGBridgeServer queue] dispatch:^{
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
    }];
}

- (void)_enqueueResponse:(TGBridgeResponse *)response forSubscription:(TGBridgeSubscription *)subscription
{
    [[TGBridgeServer queue] dispatch:^{
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
    }];
}

- (void)_sendQueuedResponses
{
    [[TGBridgeServer queue] dispatch:^{
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
    }];
}

- (void)_requestSubscriptionList
{
    [[TGBridgeServer queue] dispatch:^{
        TGBridgeSubscriptionListRequest *request = [[TGBridgeSubscriptionListRequest alloc] initWithSessionId:_sessionId];
        NSData *messageData = [NSKeyedArchiver archivedDataWithRootObject:request];
        [self.session sendMessageData:messageData replyHandler:nil errorHandler:nil];
    }];
}

- (void)sendFileWithURL:(NSURL *)url metadata:(NSDictionary *)metadata
{
    [[TGBridgeServer queue] dispatch:^{
        TGLog(@"[BridgeServer] Sent file with metadata %@", metadata);
        [self.session transferFile:url metadata:metadata];
    }];
}

#pragma mark - Session Delegate

- (void)handleReceivedData:(NSData *)messageData replyHandler:(void (^)(NSData *))replyHandler
{
    [[TGBridgeServer queue] dispatch:^{
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
    }];
}

- (void)session:(WCSession *)__unused session didReceiveMessageData:(NSData *)messageData
{
    [[TGBridgeServer queue] dispatch:^{
        [self handleReceivedData:messageData replyHandler:nil];
    }];
}

- (void)session:(WCSession *)__unused session didReceiveMessageData:(NSData *)messageData replyHandler:(void (^)(NSData *))replyHandler
{
    [[TGBridgeServer queue] dispatch:^{
        [self handleReceivedData:messageData replyHandler:replyHandler];
    }];
}

- (void)session:(WCSession *)__unused session didReceiveFile:(WCSessionFile *)file
{
    NSDictionary *metadata = file.metadata;
    if (metadata == nil || ![metadata[TGBridgeIncomingFileTypeKey] isEqualToString:TGBridgeIncomingFileTypeAudio])
        return;
    
    NSError *error;
    NSURL *tempURL = [NSURL URLWithString:file.fileURL.lastPathComponent relativeToURL:self.temporaryFilesURL];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.temporaryFilesURL.path withIntermediateDirectories:true attributes:nil error:&error];
    [[NSFileManager defaultManager] moveItemAtURL:file.fileURL toURL:tempURL error:&error];
    
    [[TGBridgeServer queue] dispatch:^{
        [TGBridgeAudioHandler handleIncomingAudioWithURL:tempURL metadata:metadata server:self];
    }];
}

- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo
{
    [[TGBridgeServer queue] dispatch:^{
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
    }];
}

- (void)session:(WCSession *)__unused session didFinishFileTransfer:(WCSessionFileTransfer *)__unused fileTransfer error:(NSError *)__unused error
{
    
}

- (void)sessionWatchStateDidChange:(WCSession *)session
{
    [[TGBridgeServer queue] dispatch:^{
        if (session.isWatchAppInstalled)
        {
            if (!_servicesRunning)
                [self startServices];
            
            [self pushActiveContext];
        }
        
        _appInstalledPipe.sink(@(session.isWatchAppInstalled));
    }];
}

- (void)sessionReachabilityDidChange:(WCSession *)session
{
    NSLog(@"[TGBridgeServer] Reachability changed: %d", session.isReachable);
}

#pragma mark -

- (void)registerHandlerClass:(Class)handlerClass
{
    [[TGBridgeServer queue] dispatch:^{
        NSArray *handledSubscriptions = [handlerClass handledSubscriptions];
        for (Class handledSubscription in handledSubscriptions)
        {
            NSAssert(_handlerMap[[handledSubscription subscriptionName]] == nil, @"Subscription can't have more than one handler");
            _handlerMap[[handledSubscription subscriptionName]] = handlerClass;
        }
    }];
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
    return [[SSignal defer:^SSignal *{
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
    }] startOn:[TGBridgeServer queue]];
}

- (void)startSignalForKey:(NSString *)key producer:(SSignal *(^)())producer
{
    [_serviceSignalManager startStandaloneSignalIfNotRunningForKey:key producer:producer];
}

- (SSignal *)pipeForKey:(NSString *)key
{
    return [_serviceSignalManager multicastedPipeForKey:key];
}

- (void)putNext:(id)next forKey:(NSString *)key
{
    [_serviceSignalManager putNext:next toMulticastedPipeForKey:key];
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

- (SSignal *)server {
    return [[SSignal single:self] startOn:[TGBridgeServer queue]];
}

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

+ (SSignal *)instanceSignal {
    return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        [subscriber putNext:[self instance]];
        [subscriber putCompletion];
        return nil;
    }] startOn:[TGBridgeServer queue]];
}

+ (bool)serverQueueIsCurrent {
    return [[TGBridgeServer queue] isCurrentQueue];
}

@end
