#import "TGLiveLocationManager.h"

#import <CoreLocation/CoreLocation.h>

#import "TGAppDelegate.h"
#import "TGDatabase.h"
#import "TGTelegramNetworking.h"
#import "TGLiveLocationSignals.h"
#import "TGLiveLocationSession.h"

@interface TGLiveLocationSessionContext : NSObject

@property (nonatomic, strong) TGLiveLocationSession *session;
@property (nonatomic, strong) SMetaDisposable *disposable;

@end


@interface TGLiveLocationManager () <CLLocationManagerDelegate>
{
    SQueue *_queue;
    CLLocationManager *_locationManager;
    bool _locationManagerActive;
    
    SPipe *_locationPipe;
    SVariable *_location;
    SPipe *_locationUpdatePipe;
    
    bool _performingInfrequentUpdate;
    NSInteger _infrequentToken;
    
    bool _inhibitFrequentUpdates;
    NSMutableSet<NSNumber *> *_frequentUpdateSubscribers;
    bool _updatingFrequentLocation;
    int32_t _previousInfrequentSinkTime;
    
    NSMutableDictionary<NSNumber *, TGLiveLocationSessionContext *> *_sessions;
    SPipe *_sessionPipe;
    SPipe *_sessionRemovalPipe;
    
    NSInteger _backgroundToken;
    UIBackgroundTaskIdentifier _currentBackgroundTask;
    NSMutableSet *_infrequentUpdateAnticipants;
    
    TGObserverProxy *_didBecomeActiveObserver;
    TGObserverProxy *_didEnterBackgroundObserver;
}
@end

@implementation TGLiveLocationManager

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _queue = [[SQueue alloc] init];
        _locationPipe = [[SPipe alloc] init];
        _location = [[SVariable alloc] init];
        [_location set:[SSignal single:nil]];
        _locationUpdatePipe = [[SPipe alloc] init];
        
        _sessions = [[NSMutableDictionary alloc] init];
        _sessionPipe = [[SPipe alloc] init];
        _sessionRemovalPipe = [[SPipe alloc] init];
        
        _frequentUpdateSubscribers = [[NSMutableSet alloc] init];
        
        _currentBackgroundTask = UIBackgroundTaskInvalid;
        _infrequentUpdateAnticipants = [[NSMutableSet alloc] init];
        _previousInfrequentSinkTime = 0;
        
        _didBecomeActiveObserver = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(handleDidBecomeActive) name:UIApplicationDidBecomeActiveNotification];
        _didEnterBackgroundObserver = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(handleDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification];
    }
    return self;
}

- (void)handleDidBecomeActive
{
    [_queue dispatch:^
    {
        _inhibitFrequentUpdates = false;
        [self maybeStartLocationUpdates:true];
    }];
}

- (void)handleDidEnterBackground
{
    [_queue dispatch:^
    {
        _inhibitFrequentUpdates = true;
        [self maybeStopLocationUpdates];
    }];
}

- (void)restoreSessions
{
    [_queue dispatch:^
    {
        int32_t currentTime = (int32_t)[[TGTelegramNetworking instance] globalTime];
        NSArray<TGLiveLocationSession *> *storedSessions = [TGDatabaseInstance() loadLiveLocationSessions];
        for (TGLiveLocationSession *session in storedSessions)
        {
            if (session.expires > currentTime)
                [self _startWithLiveSession:session restore:true];
            else
                [TGDatabaseInstance() removeLiveLocationSession:session];
        }
    }];
}

- (void)maybeStartLocationUpdates
{
    [self maybeStartLocationUpdates:false];
}

- (void)maybeStartLocationUpdates:(bool)force
{
    bool hasActiveFrequentSubscribers = false;
    for (NSNumber *sessionPeerId in _sessions)
    {
        if ([_frequentUpdateSubscribers containsObject:sessionPeerId])
        {
            hasActiveFrequentSubscribers = true;
            break;
        }
    }

    if (!_inhibitFrequentUpdates && (hasActiveFrequentSubscribers || (force && _sessions.count > 0)))
        [self startLocationUpdates:force];
}

- (void)startLocationUpdates:(bool)singleRequest
{
    TGDispatchOnMainThread(^
    {
        [_location set:_locationPipe.signalProducer()];
        if (_locationManager == nil)
        {
            _locationManager = [[CLLocationManager alloc] init];
            if (iosMajorVersion() >= 9)
                _locationManager.allowsBackgroundLocationUpdates = true;
            _locationManager.delegate = self;
            _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            _locationManager.distanceFilter = 20;
            _locationManager.activityType = CLActivityTypeOther;
            _locationManager.pausesLocationUpdatesAutomatically = false;
            
            if (iosMajorVersion() >= 8)
                [_locationManager requestAlwaysAuthorization];
            
            TGLog(@"LiveLocationManager: created location manager with accuracy %lf, distance filter %f", _locationManager.desiredAccuracy, _locationManager.distanceFilter);
        }
        
        TGLog(@"LiveLocationManager: start location manager, single request %d", singleRequest);
        if (iosMajorVersion() >= 9 && singleRequest)
            [_locationManager requestLocation];
        else
            [_locationManager startUpdatingLocation];
    });
    
    _locationManagerActive = true;
    if (!singleRequest)
        _updatingFrequentLocation = true;
}

- (void)stopLocationUpdates
{
    TGLog(@"LiveLocationManager: stop location manager");
    _locationManagerActive = false;
    TGDispatchOnMainThread(^
    {
        [_locationManager stopUpdatingLocation];
    });
    
    _locationPipe.sink(nil);
}

- (void)maybeStopLocationUpdates
{
    if (_performingInfrequentUpdate)
        return;
    
    bool hasActiveFrequentSubscribers = false;
    for (NSNumber *sessionPeerId in _sessions)
    {
        if ([_frequentUpdateSubscribers containsObject:sessionPeerId])
        {
            hasActiveFrequentSubscribers = true;
            break;
        }
    }
    
    if (_inhibitFrequentUpdates || !hasActiveFrequentSubscribers)
    {
        TGLog(@"LiveLocationManager: no more active live location subscribers, stopping location updates");
        [self stopLocationUpdates];
    }
}

- (SSignal *)sessionForPeerId:(int64_t)peerId
{
    SSignal *updateSignal = [SSignal mergeSignals:@[[_sessionPipe.signalProducer() filter:^bool(TGLiveLocationSession *session)
    {
        return session.peerId == peerId;
    }], [[_sessionRemovalPipe.signalProducer() filter:^bool(NSNumber *sessionId)
    {
        return sessionId.int64Value == peerId;
    }] map:^id(__unused id removedSessionPeerId)
    {
        return nil;
    }]]];
    
    SSignal *initialSignal = [[SSignal defer:^SSignal *
    {
        return [SSignal single:[_sessions[@(peerId)] session]];
    }] startOn:_queue];
    
    return [initialSignal then:updateSignal];
}

- (SSignal *)sessions
{
    SSignal *initialSignal = [[SSignal defer:^SSignal *
    {
        NSMutableArray *initialSessions = [[NSMutableArray alloc] init];
        for (TGLiveLocationSessionContext *context in _sessions.allValues)
        {
            [initialSessions addObject:context.session];
        }
       return [SSignal single:initialSessions];
    }] startOn:_queue];
    
    SSignal *updateSignal = [[SSignal mergeSignals:@[_sessionPipe.signalProducer(), _sessionRemovalPipe.signalProducer()]] mapToSignal:^SSignal *(__unused id value)
    {
        return initialSignal;
    }];
    
    return [initialSignal then:updateSignal];
}

- (void)startWithPeerId:(int64_t)peerId messageId:(int32_t)messageId period:(int32_t)period started:(int32_t)started
{
    [_queue dispatch:^
    {
        TGLiveLocationSessionContext *existingSession = _sessions[@(peerId)];
        if (_sessions[@(peerId)] != nil)
        {
            [existingSession.disposable dispose];
            [_sessions removeObjectForKey:@(peerId)];
        }
        
        TGLiveLocationSession *session = [[TGLiveLocationSession alloc] initWithPeerId:peerId messageId:messageId expires:started + period];
        [self _startWithLiveSession:session restore:false];
        
        [TGDatabaseInstance() storeLiveLocationSession:session];
    }];
}

- (void)_startWithLiveSession:(TGLiveLocationSession *)session restore:(bool)restore
{
    TGLiveLocationSessionContext *context = [[TGLiveLocationSessionContext alloc] init];
    context.session = session;
    
    [self startLocationUpdates:restore];
    
    SSignal *messageSignal = [[TGLiveLocationSignals liveLocationsForPeerId:session.peerId includeExpired:false onlyLocal:true] mapToSignal:^SSignal *(NSArray *messages)
    {
        int32_t currentTime = (int32_t)[[TGTelegramNetworking instance] globalTime];
        for (TGMessage *message in messages)
        {
            if (message.mid == session.messageId)
            {
                TGLocationMediaAttachment *location = message.locationAttachment;
                if (location.period > 0 && (currentTime < message.date + location.period))
                    return [SSignal single:@true];
                break;
            }
        }
        return [SSignal single:@false];
    }];
    
    SSignal *combinedSignal = [[[SSignal combineSignals:@[[_location.signal map:^id(id value)
    {
        return value ? : [NSNull null];
    }], _locationUpdatePipe.signalProducer()] withInitialStates:@[ [NSNull null], @false ]] filter:^bool(NSArray *results)
    {
        return ![results.firstObject isKindOfClass:[NSNull class]];
    }] map:^id(NSArray *results) {
        return results.firstObject;
    }];
    
    SSignal *updateSignal = [combinedSignal mapToSignal:^SSignal *(CLLocation *location)
    {
        int32_t currentTime = (int32_t)[[TGTelegramNetworking instance] globalTime];
        if (currentTime >= session.expires)
        {
            return [SSignal fail:nil];
        }
        else if (location != nil)
        {
            return [[TGLiveLocationSignals updateLiveLocationWithPeerId:session.peerId messageId:session.messageId coordinate:location.coordinate] catch:^SSignal *(id error)
            {
                NSString *rpcError = nil;
                if ([error isKindOfClass:[MTRpcError class]])
                    rpcError = ((MTRpcError *)error).errorDescription;
                if ([rpcError isEqualToString:@"MESSAGE_NOT_MODIFIED"])
                {
                    [self performedLocationUpdateForPeerId:session.peerId];
                    TGLog(@"LiveLocationManager: MESSAGE_NOT_MODIFIED for peerId: %lld", session.peerId);
                    error = nil;
                }
                
                if (error != nil)
                    return [SSignal fail:error];
                else
                    return [SSignal complete];
            }];
        }
        else
        {
            return [SSignal complete];
        }
    }];
    
    SSignal *finalSignal = [[[messageSignal ignoreRepeated] mapToSignal:^SSignal *(NSNumber *exists)
    {
        if (exists.boolValue)
            return updateSignal;
        else
            return [SSignal fail:nil];
    }] onDispose:^
    {
        [_queue dispatch:^
        {
            [_sessions removeObjectForKey:@(session.peerId)];
            _sessionRemovalPipe.sink(@(session.peerId));
            [TGDatabaseInstance() removeLiveLocationSession:session];
            
            [self maybeStopLocationUpdates];
        }];
    }];
    
    [context.disposable setDisposable:[finalSignal startWithNext:^(__unused id next)
    {
        TGLog(@"LiveLocationManager: successfully sent new location for peerId: %lld", session.peerId);
        
        [self performedLocationUpdateForPeerId:session.peerId];
    } error:^(__unused id error)
    {
        TGLog(@"LiveLocationManager: error %@ for peerId: %lld", error, session.peerId);
    } completed:^{
        TGLog(@"LiveLocationManager: completed for peerId: %lld", session.peerId);
    }]];
    
    _sessions[@(session.peerId)] = context;
    _sessionPipe.sink(session);
}

- (void)stopWithPeerId:(int64_t)peerId
{
    [_queue dispatch:^
    {
        TGLiveLocationSessionContext *session = _sessions[@(peerId)];
        if (!session)
            return;
 
        TGLog(@"LiveLocationManager: stop with peerId: %lld", peerId);
        [session.disposable setDisposable:[[TGLiveLocationSignals stopLiveLocationWithPeerId:session.session.peerId messageId:session.session.messageId] startWithNext:^(__unused id next)
        {
            
        }]];
    }];
}

- (id<SDisposable>)subscribeForFrequentLocationUpdatesWithPeerId:(int64_t)peerId
{
    TGLog(@"LiveLocationManager: subscribed for frequent location updates with peerId %lld", peerId);
    [_queue dispatch:^
    {
        [_frequentUpdateSubscribers addObject:@(peerId)];
        [self maybeStartLocationUpdates];
    }];
    
    return [[SBlockDisposable alloc] initWithBlock:^
    {
        [_queue dispatch:^
        {
            TGLog(@"LiveLocationManager: unsubscribed from frequent location updates with peerId %lld", peerId);
            [_frequentUpdateSubscribers removeObject:@(peerId)];
            if (_frequentUpdateSubscribers.count == 0)
            {
                _updatingFrequentLocation = false;
                TGLog(@"LiveLocationManager: no more frequent location subscribers");
            }
            
            TGDispatchAfter(10.0, _queue._dispatch_queue, ^
            {
                [self maybeStopLocationUpdates];
            });
        }];
    }];
}

- (void)performInfrequentLocationUpdate:(void (^)(bool))willPerform
{
    TGLog(@"LiveLocationManager: infrequent location request received");
    
    [_queue dispatch:^
    {
        if (_sessions.count == 0)
        {
            TGLog(@"LiveLocationManager: no live location sessions, ignoring infrequent location update");
            willPerform(false);
            return;
        }
        
        if (!_updatingFrequentLocation || TGAppDelegateInstance.inBackground)
        {
            if (!_performingInfrequentUpdate)
            {
                _backgroundToken = -1;
                _infrequentToken++;
                
                _infrequentUpdateAnticipants = [[NSMutableSet alloc] init];
                for (NSNumber *sessionPeerId in _sessions)
                    [_infrequentUpdateAnticipants addObject:sessionPeerId];
                
                if (!TGAppDelegateInstance.inBackground && _locationManagerActive)
                {
                    TGLog(@"LiveLocationManager: maybe has active location manager, asking for update");
                    _locationUpdatePipe.sink(@true);
                }
                
                _currentBackgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                
                TGLog(@"LiveLocationManager: performing exclusive infrequent update, taskid: %d", _currentBackgroundTask);
                _performingInfrequentUpdate = true;
                [self startLocationUpdates:true];
                
                TGDispatchAfter(1.0, dispatch_get_main_queue(), ^
                {
                    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
                        [self wakeupNetwork];
                });
                
                NSInteger token = _infrequentToken;
                TGDispatchAfter(55.0, _queue._dispatch_queue, ^
                {
                    if (token != _infrequentToken)
                        return;
                    
                    [_infrequentUpdateAnticipants removeAllObjects];
                    [self finishInfrequentLocationUpdate:true];
                });
            }
            else
            {
                TGLog(@"LiveLocationManager: already performing infrequent location update");
            }
        }
        else
        {
            int32_t currentTime = (int32_t)[[TGTelegramNetworking instance] globalTime];
            if (_previousInfrequentSinkTime == 0 || abs(currentTime - _previousInfrequentSinkTime) > 30)
            {
                TGLog(@"LiveLocationManager: has frequent location subscriber, asking to share for infrequent update");
                _locationUpdatePipe.sink(@true);
                _previousInfrequentSinkTime = currentTime;
            }
            else
            {
                TGLog(@"LiveLocationManager: too soon for asking of frequent-infrequent update, must be push mash");
            }
        }
        
        willPerform(true);
    }];
}

- (void)finishInfrequentLocationUpdate:(bool)timeout
{
    if (!_performingInfrequentUpdate)
        return;
    
    _infrequentToken++;
    
    _performingInfrequentUpdate = false;
    [_infrequentUpdateAnticipants removeAllObjects];
    TGLog(@"LiveLocationManager: finished infrequent location update timeout %d", timeout);

    [self maybeStopLocationUpdates];
    
    UIBackgroundTaskIdentifier identifier = _currentBackgroundTask;
    [self suspendNetworkIfNeeded:^
    {
        [[UIApplication sharedApplication] endBackgroundTask:identifier];
        TGLog(@"[LiveLocationManager]: ended taskid: %d", identifier);
        if (_currentBackgroundTask == identifier)
            _currentBackgroundTask = UIBackgroundTaskInvalid;
    }];
}

- (void)performedLocationUpdateForPeerId:(int64_t)peerId
{
    [_queue dispatch:^
    {
        if ([_infrequentUpdateAnticipants containsObject:@(peerId)])
        {
            [_infrequentUpdateAnticipants removeObject:@(peerId)];
            TGLog(@"LiveLocationManager: performed location update for anticipant with peerId %lld", peerId);
            
            if (_infrequentUpdateAnticipants.count == 0)
                [self finishInfrequentLocationUpdate:false];
        }
    }];
}

#pragma mark -

- (void)wakeupNetwork
{
    [[TGTelegramNetworking instance] resume];
    _backgroundToken++;
}

- (void)suspendNetworkIfNeeded:(void (^)(void))completion
{
    NSInteger token = _backgroundToken;
    if ([TGAppDelegateInstance inBackground] && ![TGAppDelegateInstance backgroundTaskOngoing])
    {
        TGDispatchAfter(5.0, dispatch_get_main_queue(), ^
        {
            if (!_performingInfrequentUpdate && token == _backgroundToken)
            {
                if ([[TGTelegramNetworking instance] _isReadyToBeSuspended])
                {
                    [[TGTelegramNetworking instance] pause];
                    completion();
                }
                else
                {
                    TGDispatchAfter(10.0, dispatch_get_main_queue(), ^
                    {
                        if ([[TGTelegramNetworking instance] _isReadyToBeSuspended])
                            [[TGTelegramNetworking instance] pause];
                        
                        completion();
                    });
                }
            }
            else
            {
                completion();
            }
        });
    }
    else
    {
        completion();
    }
}

#pragma mark -

- (void)locationManager:(CLLocationManager *)__unused manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    TGLog(@"LiveLocationManager: location manager updated location");
    _locationPipe.sink(locations.firstObject);
    
    [_queue dispatch:^
    {
        [self maybeStopLocationUpdates];
    }];
}

- (void)locationManager:(CLLocationManager *)__unused manager didFailWithError:(NSError *)error
{
    TGLog(@"LiveLocationManager: location manager failed with error %@", error);
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)__unused manager
{
    TGLog(@"LiveLocationManager: location manager did pause updates");
}

- (void)reset
{
    TGLog(@"LiveLocationManager: reset live location sessions");
    
    [_queue dispatch:^
    {
        [self stopLocationUpdates];
        for (TGLiveLocationSessionContext *session in _sessions.allValues)
        {
            [session.disposable dispose];
            [TGDatabaseInstance() removeLiveLocationSession:session.session];
        }
        [_sessions removeAllObjects];
    }];
}

@end


@implementation TGLiveLocationSessionContext

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _disposable = [[SMetaDisposable alloc] init];
    }
    return self;
}

@end

