#import "TGBridgeClient.h"
#import <WatchKit/WatchKit.h>
#import <WatchConnectivity/WatchConnectivity.h>

#import "TGBridgeSubscription.h"
#import "TGBridgePacket.h"
#import "TGBridgeResponse.h"


const NSTimeInterval TGBridgeClientTimerInterval = 10.0;
const NSTimeInterval TGBridgeClientWakeInterval = 5.0;

@interface TGBridgeClientold () <WCSessionDelegate>
{
    SMulticastSignalManager *_signalManager;
    NSMutableDictionary *_activeSubscriptions;
    
    NSTimeInterval _lastForegroundEntry;
    STimer *_timer;
    
    WCSession *_session;
    
    bool _inForeground;
}
@end

@implementation TGBridgeClientold

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _signalManager = [[SMulticastSignalManager alloc] init];
        _activeSubscriptions = [[NSMutableDictionary alloc] init];
        
        _session = [WCSession defaultSession];
        _session.delegate = self;
        [_session activateSession];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground:) name:NSExtensionHostWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground:) name:NSExtensionHostDidEnterBackgroundNotification object:nil];
    }
    return self;
}

+ (void)load
{
    [[self sharedInstance] _registerForGlobalNotifications];
}

- (void)enterForeground:(NSNotification *)notification
{
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSinceReferenceDate];
    if (_lastForegroundEntry == 0 || currentTime - _lastForegroundEntry > TGBridgeClientWakeInterval)
    {
        if (_lastForegroundEntry != 0)
            [self _handleGlobalNotification];

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
            
            [strongSelf _handleGlobalNotification];
            
            strongSelf->_lastForegroundEntry = [[NSDate date] timeIntervalSinceReferenceDate];
            strongSelf->_timer = [[STimer alloc] initWithTimeout:TGBridgeClientTimerInterval repeat:false completion:completion queue:[SQueue mainQueue]];
            [strongSelf->_timer start];
        };
        
        _timer = [[STimer alloc] initWithTimeout:interval repeat:false completion:completion queue:[SQueue mainQueue]];
        [_timer start];
    }
    
    [self _announceWatchIsActive:true force:false];
}

- (void)enterBackground:(NSNotification *)notification
{
    [_timer invalidate];
    _timer = nil;
    
    [self _announceWatchIsActive:false force:false];
}

- (void)_announceWatchIsActive:(bool)isActive force:(bool)force
{
    bool wasInForeground = _inForeground;
    _inForeground = isActive;
    
    if (!force && wasInForeground == _inForeground)
        return;
    
    if (isActive)
    {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)TGWatchEnteredForegroundNotificationKey, NULL, NULL, true);
    }
    else
    {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)TGWatchEnteredBackgroundNotificationKey, NULL, NULL, true);
    }
}

- (void)_registerForGlobalNotifications
{
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    (__bridge const void *)(self),
                                    globalNotificationCallback,
                                    (__bridge CFStringRef)TGWatchRequestStatusNotificationKey, NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}

- (void)_unregisterForGlobalNotifications
{
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self), (__bridge CFStringRef)TGWatchRequestStatusNotificationKey, NULL);
}

- (void)_handleGlobalNotification
{
//    TGBridgeUpdateSubscription *subscription = [[TGBridgeUpdateSubscription alloc] initWithActiveSubscriptions:[_activeSubscriptions allValues]];
//    NSDictionary *serializedSubscription = [subscription serialize];
//    
//    [_signalManager startStandaloneSignalIfNotRunningForKey:subscription.identifier producer:^SSignal *
//    {
//        return [[self applicationRequestSignalWithDictionary:serializedSubscription] mapToSignal:^SSignal *(TGBridgePacket *next)
//        {
//            for (TGBridgeResponse *response in next.responses)
//                [_signalManager putNext:response toMulticastedPipeForKey:response.subscriptionIdentifier];
//            
//            return [SSignal complete];
//        }];
//    }];
}

- (void)session:(WCSession *)session didReceiveMessageData:(NSData *)messageData
{
    TGBridgePacket *packet = [NSKeyedUnarchiver unarchiveObjectWithData:messageData];
    if (packet == nil)
        return;
    
    for (TGBridgeResponse *response in packet.responses)
    {
        [_signalManager putNext:response toMulticastedPipeForKey:response.subscriptionIdentifier];
    }
}

- (void)_handleActiveNotification
{
    [self _announceWatchIsActive:_inForeground force:true];
}

void globalNotificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, void const * object, CFDictionaryRef userInfo)
{
    NSString *string = (__bridge NSString *)name;
    if ([string isEqualToString:TGWatchRequestStatusNotificationKey])
        [(__bridge TGBridgeClient *)observer _handleActiveNotification];
}

- (SSignal *)requestSignalWithSubscription:(TGBridgeSubscription *)subscription
{
    NSData *serializedSubscription = [NSKeyedArchiver archivedDataWithRootObject:subscription];
    if (serializedSubscription == nil)
        return [SSignal fail:nil];
    
    __weak TGBridgeClient *weakSelf = self;
    void (^translateResponse)(SSubscriber *, TGBridgeResponse *, bool *) = ^(SSubscriber *subscriber, TGBridgeResponse *next, bool *finished)
    {
        if (next.completed)
        {
            [subscriber putCompletion];
            if (finished != NULL)
                *finished = true;
        }
        else if (next.failed)
        {
            [subscriber putError:next.error];
        }
        else
        {
            [subscriber putNext:next.next];
        }
    };
    
    SSignal *updateSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        return [[_signalManager multicastedPipeForKey:subscription.identifier] startWithNext:^(TGBridgeResponse *next)
        {
            translateResponse(subscriber, next, NULL);
        }];
    }];
    
    SSignal *combinedSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        SDisposableSet *compositeDisposable = [[SDisposableSet alloc] init];
        
        SMetaDisposable *currentDisposable = [[SMetaDisposable alloc] init];
        [compositeDisposable add:currentDisposable];
        
        __block bool complete = false;
        [currentDisposable setDisposable:[[[self applicationRequestSignalWithData:serializedSubscription] onStart:^
        {
            __strong TGBridgeClient *strongSelf = weakSelf;
            if (strongSelf != nil)
                strongSelf->_activeSubscriptions[subscription.identifier] = subscription;
        }] startWithNext:^(TGBridgePacket *next)
        {
            TGBridgeResponse *response = next.responses.firstObject;
            translateResponse(subscriber, response, &complete);
        } error:^(id error)
        {
            [subscriber putError:error];
        } completed:^
        {
            if (complete)
                return;
            
            [compositeDisposable add:[updateSignal startWithNext:^(id next)
            {
                [subscriber putNext:next];
            } error:^(id error)
            {
                [subscriber putError:error];
            } completed:^
            {
                [subscriber putCompletion];
            }]];
        }]];
        
        return compositeDisposable;
    }];
    
    return [[combinedSignal onCompletion:^
    {
        __strong TGBridgeClient *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf->_activeSubscriptions removeObjectForKey:subscription.identifier];
    }] onDispose:^
    {
        __strong TGBridgeClient *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf->_activeSubscriptions removeObjectForKey:subscription.identifier];
        
        [_session sendMessage:@{ @"dispose":subscription.identifier } replyHandler:nil errorHandler:nil];
    }];
}

- (SSignal *)applicationRequestSignalWithData:(NSData *)data
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [_session sendMessageData:data replyHandler:^(NSData *replyMessage)
        {
            if (replyMessage == nil)
            {
                [subscriber putCompletion];
                return;
            }
            
            TGBridgePacket *packet = [NSKeyedUnarchiver unarchiveObjectWithData:replyMessage];
            [subscriber putNext:packet];
            [subscriber putCompletion];
            
        } errorHandler:^(NSError * __nonnull error)
        {
            [subscriber putError:error.localizedDescription];
        }];
        
        return nil;
    }];
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static TGBridgeClient *instance;
    dispatch_once(&once, ^
    {
        instance = [[self alloc] init];
    });
    
    return instance;
}

@end
