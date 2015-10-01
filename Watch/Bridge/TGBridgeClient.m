#import "TGBridgeClient.h"
#import "TGBridgeCommon.h"
#import "TGBridgeChat.h"

#import <WatchConnectivity/WatchConnectivity.h>

#import "TGBridgeSubscription.h"
#import "TGBridgeResponse.h"
#import "TGBridgeContext.h"
#import "TGFileCache.h"

#import "TGBridgeChatMessageListSubscription.h"

#import "TGBridgeStickersSignals.h"

#import "TGExtensionDelegate.h"

#import <libkern/OSAtomic.h>

NSString *const TGBridgeContextDomain = @"com.telegram.BridgeContext";

const NSTimeInterval TGBridgeClientTimerInterval = 4.0;
const NSTimeInterval TGBridgeClientWakeInterval = 2.0;

@interface TGBridgeClient () <WCSessionDelegate>
{
    int32_t _sessionId;
    bool _reachable;
    
    bool _processingNotification;
    
    SMulticastSignalManager *_signalManager;
    SMulticastSignalManager *_fileSignalManager;
    SPipe *_contextPipe;

    SPipe *_actualReachabilityPipe;
    SPipe *_reachabilityPipe;
    
    SPipe *_userInfoPipe;
    
    dispatch_queue_t _contextQueue;
    
    OSSpinLock _outgoingQueueLock;
    NSMutableArray *_outgoingMessageQueue;
    
    NSURL *_startupDataURL;
    NSDictionary *_startupData;
    
    NSArray *_stickerPacks;
    OSSpinLock _stickerPacksLock;
    
    NSMutableDictionary *_subscriptions;
    
    NSTimeInterval _lastForegroundEntry;
    STimer *_timer;
    
    bool _sentFirstPing;
    bool _isActive;
}

@property (nonatomic, readonly) WCSession *session;

@end

@implementation TGBridgeClient

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        int32_t sessionId = 0;
        arc4random_buf(&sessionId, sizeof(int32_t));
        _sessionId = sessionId;
        
        _contextQueue = dispatch_queue_create(TGBridgeContextDomain.UTF8String, nil);
        
        _signalManager = [[SMulticastSignalManager alloc] init];
        _fileSignalManager = [[SMulticastSignalManager alloc] init];
        _contextPipe = [[SPipe alloc] init];
        _userInfoPipe = [[SPipe alloc] init];
        _actualReachabilityPipe = [[SPipe alloc] init];
        _reachabilityPipe = [[SPipe alloc] init];
        _reachable = true;
        
        _outgoingMessageQueue = [[NSMutableArray alloc] init];
        
        _subscriptions = [[NSMutableDictionary alloc] init];
        
        _startupData = [self loadStartupData];

        self.session.delegate = self;
        [self.session activateSession];
        
        TGLog(@"BridgeClient: initialized");
        
        [self ping];
    }
    return self;
}

- (void)transferUserInfo:(NSDictionary *)userInfo
{
    [self.session transferUserInfo:userInfo];
}

- (SSignal *)requestSignalWithSubscription:(TGBridgeSubscription *)subscription
{
    if ([subscription isKindOfClass:[TGBridgeChatMessageSubscription class]])
        _processingNotification = true;
    else if (!_sentFirstPing)
        [self ping];
    
    NSData *messageData = [NSKeyedArchiver archivedDataWithRootObject:subscription];
    
    void (^transcribe)(id, SSubscriber *, bool *) = ^(id message, SSubscriber *subscriber, bool *completed)
    {
        TGBridgeResponse *response = nil;
        if ([message isKindOfClass:[TGBridgeResponse class]])
        {
            response = message;
        }
        else if ([message isKindOfClass:[NSData class]])
        {
            @try
            {
                id unarchivedMessage = [NSKeyedUnarchiver unarchiveObjectWithData:message];
                if ([unarchivedMessage isKindOfClass:[TGBridgeResponse class]])
                    response = (TGBridgeResponse *)unarchivedMessage;
            }
            @catch (NSException *exception)
            {

            }
        }
        
        if (response == nil)
            return;
        
        switch (response.type)
        {
            case TGBridgeResponseTypeNext:
                [subscriber putNext:response.next];
                break;
                
            case TGBridgeResponseTypeFailed:
                [subscriber putError:response.error];
                break;
                
            case TGBridgeResponseTypeCompleted:
                if (completed != NULL)
                    *completed = true;
                
                [subscriber putCompletion];
                break;
                
            default:
                break;
        }
    };
    
    __weak TGBridgeClient *weakSelf = self;
    return [[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        SDisposableSet *combinedDisposable = [[SDisposableSet alloc] init];
        SMetaDisposable *currentDisposable = [[SMetaDisposable alloc] init];
        
        __block bool completed = false;
        [combinedDisposable add:currentDisposable];
        
        void (^afterSendMessage)(void) = ^
        {
            __strong TGBridgeClient *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [combinedDisposable add:[[strongSelf->_signalManager multicastedPipeForKey:[NSString stringWithFormat:@"%lld", subscription.identifier]] startWithNext:^(id next)
            {
                transcribe(next, subscriber, NULL);
            } error:^(id error)
            {
                [subscriber putError:error];
            } completed:^
            {
                [subscriber putCompletion];
            }]];
        };
        
        [currentDisposable setDisposable:[[[self sendMessageData:messageData] onStart:^
        {
            __strong TGBridgeClient *strongSelf = weakSelf;
            if (strongSelf != nil)
                strongSelf->_subscriptions[@(subscription.identifier)] = subscription;
        }] startWithNext:^(id next)
        {
            __strong TGBridgeClient *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if ([subscription isKindOfClass:[TGBridgeChatMessageSubscription class]])
                strongSelf->_processingNotification = false;
                
            transcribe(next, subscriber, &completed);
        } error:^(NSError *error)
        {
            if ([error isKindOfClass:[NSError class]] && error.domain == WCErrorDomain)
            {
                __strong TGBridgeClient *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf _enqueueMessage:messageData];
                
                afterSendMessage();
            }
            else
            {
                [subscriber putError:error];
            }
        } completed:^
        {
            if (completed)
                return;
            
            afterSendMessage();
        }]];
        
        return combinedDisposable;
    }] onCompletion:^
    {
        __strong TGBridgeClient *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf->_subscriptions removeObjectForKey:@(subscription.identifier)];
    }] onDispose:^
    {
        __strong TGBridgeClient *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf->_subscriptions removeObjectForKey:@(subscription.identifier)];
            [strongSelf unsubscribe:subscription.identifier];
        }
    }];
}

- (void)unsubscribe:(int64_t)identifier
{
    TGBridgeDisposal *disposal = [[TGBridgeDisposal alloc] initWithIdentifier:identifier];
    NSData *message = [NSKeyedArchiver archivedDataWithRootObject:disposal];
    [self.session sendMessageData:message replyHandler:nil errorHandler:^(NSError *error)
    {
        [self _logError:error];
    }];
}

- (SSignal *)sendMessageData:(NSData *)messageData
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [self.session sendMessageData:messageData replyHandler:^(NSData *replyMessageData)
        {
            if (replyMessageData.length > 0)
                [subscriber putNext:replyMessageData];
            [subscriber putCompletion];
        } errorHandler:^(NSError * _Nonnull error)
        {
            [self _logError:error];
            [subscriber putError:error];
        }];
        return nil;
    }];
}

- (void)sendRawMessageData:(NSData *)messageData replyHandler:(void (^)(NSData *))replyHandler errorHandler:(void (^)(NSError *))errorHandler
{
    [self.session sendMessageData:messageData replyHandler:replyHandler errorHandler:errorHandler];
}

#pragma mark -

- (SSignal *)contextSignal
{
    if (self.session.receivedApplicationContext.allKeys.count > 0)
    {
        SSignal *initialSignal = [SSignal single:[[TGBridgeContext alloc] initWithDictionary:self.session.receivedApplicationContext]];
        return [initialSignal then:_contextPipe.signalProducer()];
    }
    else
    {
        return _contextPipe.signalProducer();
    }
}

- (void)saveStartupData:(NSDictionary *)dataObject
{
    dispatch_async(_contextQueue, ^
    {
        if (dataObject != nil)
        {
            NSMutableDictionary *dict = [dataObject mutableCopy];
            NSArray *chatsArray = dict[TGBridgeChatsArrayKey];
            if (chatsArray.count > 4)
            {
                NSArray *trimmedArray = [chatsArray subarrayWithRange:NSMakeRange(0, 4)];
                dict[TGBridgeChatsArrayKey] = trimmedArray;
            }
            
            dict[TGBridgeContextStartupDataVersion] = @([TGBridgeContext versionWithCurrentDate]);
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
            [data writeToURL:[self startupDataURL] atomically:true];
        }
        else
        {
            [[NSFileManager defaultManager] removeItemAtURL:[self startupDataURL] error:NULL];
        }
    });
}

- (NSDictionary *)loadStartupData
{
    NSError *error;
    NSData *data = [[NSData alloc] initWithContentsOfURL:[self startupDataURL] options:kNilOptions error:&error];
    
    if (data == nil || error != nil)
        return nil;
    
    NSDictionary *dictionary = nil;
    @try
    {
        dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException *exception)
    {

    }
    
    if (![dictionary isKindOfClass:[NSDictionary class]])
        return nil;
    
    return dictionary;
}

- (NSURL *)startupDataURL
{
    if (_startupDataURL == nil)
    {
        NSString *cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true)[0];
        _startupDataURL = [[NSURL alloc] initFileURLWithPath:[cachesPath stringByAppendingPathComponent:@"startup.data"]];
    }
    
    return _startupDataURL;
}

#pragma mark -

- (SSignal *)fileSignalForKey:(NSString *)key
{
    return [_fileSignalManager multicastedPipeForKey:key];
}

- (void)sendFileWithURL:(NSURL *)url metadata:(NSDictionary *)metadata
{
    [self.session transferFile:url metadata:metadata];
}

#pragma mark - 

- (NSArray *)stickerPacks
{
    OSSpinLockLock(&_stickerPacksLock);
    if (_stickerPacks != nil)
    {
        NSArray *stickerPacks = [_stickerPacks copy];
        OSSpinLockUnlock(&_stickerPacksLock);

        return stickerPacks;
    }
    else
    {
        NSArray *stickerPacks = [self readStickerPacks];
        if (stickerPacks == nil)
            stickerPacks = [NSArray array];
        
        _stickerPacks = stickerPacks;
    
        OSSpinLockUnlock(&_stickerPacksLock);
        
        return stickerPacks;
    }
}

- (NSArray *)readStickerPacks
{
    NSURL *url = [TGBridgeStickersSignals stickerPacksURL];
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    if (data == nil)
        return nil;
    
    NSArray *stickerPacks = nil;
    @try
    {
        stickerPacks = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException *exception)
    {
        
    }
    
    if (![stickerPacks isKindOfClass:[NSArray class]])
        return nil;
    
    return stickerPacks;
}

#pragma mark - 

- (void)session:(WCSession *)session didReceiveMessageData:(NSData *)messageData
{
    [self handleReceivedData:messageData replyHandler:nil];
}

- (void)session:(WCSession *)session didReceiveMessageData:(NSData *)messageData replyHandler:(nonnull void (^)(NSData * _Nonnull))replyHandler
{
    [self handleReceivedData:messageData replyHandler:replyHandler];
}

- (void)handleReceivedData:(NSData *)messageData replyHandler:(void (^)(NSData *))replyHandler
{
    id message =  nil;
    @try
    {
        message = [NSKeyedUnarchiver unarchiveObjectWithData:messageData];
    }
    @catch (NSException *exception)
    {
        
    }
    
    if ([message isKindOfClass:[TGBridgeResponse class]])
    {
        TGBridgeResponse *response = (TGBridgeResponse *)message;
        [_signalManager putNext:response toMulticastedPipeForKey:[NSString stringWithFormat:@"%lld", response.subscriptionIdentifier]];
    }
    else if ([message isKindOfClass:[TGBridgeSubscriptionListRequest class]])
    {
        [self refreshSubscriptions];
    }
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary *)applicationContext
{
    _contextPipe.sink([[TGBridgeContext alloc] initWithDictionary:applicationContext]);
}

- (void)session:(WCSession *)session didReceiveFile:(WCSessionFile *)file
{
    NSString *key = file.metadata[TGBridgeFileKey];
    if (key == nil)
        return;
    
    if ([key isEqualToString:@"stickers"])
    {
        NSURL *stickerPacksURL = [TGBridgeStickersSignals stickerPacksURL];
        [[NSFileManager defaultManager] moveItemAtURL:file.fileURL toURL:stickerPacksURL error:nil];
        
        NSArray *stickerPacks = [self readStickerPacks];
        OSSpinLockLock(&_stickerPacksLock);
        _stickerPacks = stickerPacks;
        OSSpinLockUnlock(&_stickerPacksLock);
        
        [_fileSignalManager putNext:stickerPacks toMulticastedPipeForKey:key];
    }
    else
    {
        NSLog(@"Received file: %@", key);
        [[TGExtensionDelegate instance].imageCache cacheFileAtURL:file.fileURL key:key synchronous:true unserializeBlock:^id(NSData *data)
        {
            return data;
        } completion:^(NSURL *url)
        {
            [_fileSignalManager putNext:url toMulticastedPipeForKey:key];
        }];
    }
}

- (void)session:(WCSession *)session didFinishFileTransfer:(WCSessionFileTransfer *)fileTransfer error:(NSError *)error
{
    
}

- (void)sessionReachabilityDidChange:(WCSession *)session
{
    bool reachable = session.isReachable;
    if (!reachable)
    {
        TGDispatchAfter(4.5, dispatch_get_main_queue(), ^
        {
            bool newReachable = session.isReachable;
            if (newReachable == reachable && newReachable != _reachable)
            {
                _reachable = newReachable;
                _reachabilityPipe.sink(@(newReachable));
            }
        });
    }
    else if (_reachable != reachable)
    {
        _reachable = reachable;
        _reachabilityPipe.sink(@(reachable));
        
        [self ping];
    }
    
    if (reachable && !_processingNotification)
        [self sendQueuedMessages];
}

- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo
{
    _userInfoPipe.sink(userInfo);
}

- (SSignal *)userInfoSignal
{
    return _userInfoPipe.signalProducer();
}

#pragma mark - 

- (void)_enqueueMessage:(NSData *)message
{
    TGLog(@"[BridgeClient] Enqued failed message");
    
    OSSpinLockLock(&_outgoingQueueLock);
    [_outgoingMessageQueue addObject:message];
    OSSpinLockUnlock(&_outgoingQueueLock);
}

- (void)sendQueuedMessages
{
    OSSpinLockLock(&_outgoingQueueLock);
    
    if (_outgoingMessageQueue.count > 0)
    {
        TGLog(@"[BridgeClient] Sending queued messages");
        
        for (NSData *messageData in _outgoingMessageQueue)
            [self.session sendMessageData:messageData replyHandler:nil errorHandler:nil];
        
        [_outgoingMessageQueue removeAllObjects];
    }
    OSSpinLockUnlock(&_outgoingQueueLock);
}

#pragma mark -

- (void)ping
{
    if (!_isActive || _processingNotification)
        return;
    
    TGBridgePing *ping = [[TGBridgePing alloc] initWithSessionId:_sessionId];
    NSData *message = [NSKeyedArchiver archivedDataWithRootObject:ping];
    [self.session sendMessageData:message replyHandler:^(NSData *replyData)
    {
        _sentFirstPing = true;
    } errorHandler:^(NSError *error)
    {
        [self _logError:error];
    }];
}

- (void)refreshSubscriptions
{
    NSArray *activeSubscriptions = [_subscriptions allValues];
    NSMutableArray *subscriptions = [[NSMutableArray alloc] init];
    for (TGBridgeSubscription *subscription in activeSubscriptions)
    {
        if (subscription.renewable)
            [subscriptions addObject:subscription];
    }
    
    TGBridgeSubscriptionList *subscriptionsList = [[TGBridgeSubscriptionList alloc] initWithArray:subscriptions];
    NSData *message = [NSKeyedArchiver archivedDataWithRootObject:subscriptionsList];
    [self.session sendMessageData:message replyHandler:nil errorHandler:^(NSError *error)
    {
        [self _logError:error];
    }];
}

#pragma mark -

- (void)handleDidBecomeActive
{
    _isActive = true;

    NSTimeInterval currentTime = [[NSDate date] timeIntervalSinceReferenceDate];
    if (_lastForegroundEntry == 0 || currentTime - _lastForegroundEntry > TGBridgeClientWakeInterval)
    {
        if (_lastForegroundEntry != 0)
            [self ping];
        
        _lastForegroundEntry = currentTime;
    }
    
    if (_timer == nil)
    {
        __weak TGBridgeClient *weakSelf = self;
        NSTimeInterval interval = _lastForegroundEntry == 0 ? TGBridgeClientTimerInterval : MAX(MIN(TGBridgeClientTimerInterval - currentTime - _lastForegroundEntry, TGBridgeClientTimerInterval), 1);
        
        __block void (^completion)(void) = ^
        {
            __strong TGBridgeClient *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf ping];
            
            strongSelf->_lastForegroundEntry = [[NSDate date] timeIntervalSinceReferenceDate];
            strongSelf->_timer = [[STimer alloc] initWithTimeout:TGBridgeClientTimerInterval repeat:false completion:completion queue:[SQueue mainQueue]];
            [strongSelf->_timer start];
        };
        
        _timer = [[STimer alloc] initWithTimeout:interval repeat:false completion:completion queue:[SQueue mainQueue]];
        [_timer start];
    }
}

- (void)handleWillResignActive
{
    _isActive = false;
    
    [_timer invalidate];
    _timer = nil;
}

#pragma mark -

- (void)updateReachability
{
    if (self.session.isReachable && !_reachable)
        _reachable = true;
}

- (bool)isServerReachable
{
    return _reachable;
}

- (bool)isActuallyReachable
{
    return self.session.isReachable;
}

- (SSignal *)actualReachabilitySignal
{
    return [[SSignal single:@(self.session.isReachable)] then:_actualReachabilityPipe.signalProducer()];
}

- (SSignal *)reachabilitySignal
{
    return [[SSignal single:@(self.session.isReachable)] then:_reachabilityPipe.signalProducer()];
}

- (void)_logError:(NSError *)error
{
    NSLog(@"%@", error);
}

#pragma mark -

- (WCSession *)session
{
    return [WCSession defaultSession];
}

+ (instancetype)instance
{
    static dispatch_once_t onceToken;
    static TGBridgeClient *instance;
    dispatch_once(&onceToken, ^
    {
        instance = [[TGBridgeClient alloc] init];
    });
    return instance;
}

@end
