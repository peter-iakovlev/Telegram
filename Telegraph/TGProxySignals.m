#import "TGProxySignals.h"

#import <MTProtoKit/MTProtoKit.h>

#import "TGAppDelegate.h"
#import "TGDatabase.h"
#import "TGTelegramNetworking.h"
#import "TGSynchronizationStateSignal.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#import "TGProxyItem.h"

@implementation TGProxyCachedAvailability

- (instancetype)initWithAvailability:(TGProxyAvailability)availability rtt:(NSTimeInterval)rtt timestamp:(NSTimeInterval)timestamp {
    self = [super init];
    if (self != nil) {
        _availability = availability;
        _rtt = rtt;
        _timestamp = timestamp;
    }
    return self;
}

@end

@implementation TGProxySignals

static SPipe *currentPipe;
static SPipe *listPipe;

+ (void)load
{
    currentPipe = [[SPipe alloc] init];
    listPipe = [[SPipe alloc] init];
}

+ (SSignal *)currentSignal
{
    SSignal *initialSignal = [[TGDatabaseInstance() modify:^id{ return nil; }] mapToSignal:^SSignal *(__unused id value)
    {
        bool inactive = false;
        TGProxyItem *current = [self currentProxy:&inactive];
        return [SSignal single:inactive ? nil : current];
    }];
    return [initialSignal then:currentPipe.signalProducer()];
}
   
+ (SSignal *)listSignal
{
    SSignal *initialSignal = [[TGDatabaseInstance() modify:^id{ return nil; }] mapToSignal:^SSignal *(__unused id value)
    {
        return [SSignal single:[self loadStoredProxies]];
    }];
    
    return [initialSignal then:listPipe.signalProducer()];
}

+ (SSignal *)stateSignal
{
    return [[self currentSignal] mapToSignal:^SSignal *(TGProxyItem *proxy)
    {
        if (proxy == nil)
            return [SSignal single:@(TGConnectionStateNotConnected)];
        else
            return [self connectionStatus];
    }];
}

+ (SAtomic *)availabilityCache
{
    static SAtomic *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[SAtomic alloc] initWithValue:[[NSMutableDictionary alloc] init]];
    });
    return result;
}

+ (NSString *)keyForProxy:(TGProxyItem *)proxy
{
    return [NSString stringWithFormat:@"%@\%d\%@\%@", proxy.server, proxy.port, proxy.username, proxy.password];
}

+ (TGProxyCachedAvailability *)cachedAvailabilityForProxy:(TGProxyItem *)proxy {
    NSString *key = [self keyForProxy:proxy];
    
    TGProxyCachedAvailability *result = [[self availabilityCache] with:^id (NSMutableDictionary *dict) {
        TGProxyCachedAvailability *result = dict[key];
        if (result != nil && result.timestamp > CFAbsoluteTimeGetCurrent() - 2.0 * 60.0) {
            return result;
        }
        return nil;
    }];
    
    return result;
}

+ (void)cacheAvailabilty:(TGProxyCachedAvailability *)availability forProxy:(TGProxyItem *)proxy
{
    NSString *key = [self keyForProxy:proxy];
    [[self availabilityCache] with:^id (NSMutableDictionary *dict) {
        dict[key] = availability;
        return nil;
    }];
}

+ (SSignal *)availabiltyForProxy:(TGProxyItem *)proxy withContext:(MTContext *)context datacenterId:(NSInteger)datacenterId
{
    TGProxyCachedAvailability *availability = [self cachedAvailabilityForProxy:proxy];
    if (availability != nil)
        return [SSignal single:availability];
    
    MTSocksProxySettings *settings = [[MTSocksProxySettings alloc] initWithIp:proxy.server port:proxy.port username:proxy.username password:proxy.password secret:proxy.secret.length > 0 && proxy.secret.length % 2 == 0 ? [NSData dataWithHexString:proxy.secret] : nil];
    
    return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        id<MTDisposable> disposable = [[[MTProxyConnectivity pingProxyWithContext:context datacenterId:datacenterId settings:settings] map:^id(MTProxyConnectivityStatus *next)
        {
            return [[TGProxyCachedAvailability alloc] initWithAvailability:next.reachable ? TGProxyAvailable : TGProxyUnavailable rtt:next.roundTripTime timestamp:CFAbsoluteTimeGetCurrent()];
        }] startWithNext:^(id next) {
            [subscriber putNext:next];
            [subscriber putCompletion];
        } error:^(id error) {
            [subscriber putError:error];
        } completed:^{
            [subscriber putCompletion];
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [disposable dispose];
        }];
    }] onNext:^(TGProxyCachedAvailability *next) {
        [self cacheAvailabilty:next forProxy:proxy];
    }];
}

+ (SSignal *)connectionStatus
{
    return [[[TGSynchronizationStateSignal synchronizationState] ignoreRepeated] mapToSignal:^SSignal *(NSNumber *value)
    {
        TGSynchronizationStateValue state = (TGSynchronizationStateValue)value.integerValue;
        switch (state) {
            case TGSynchronizationStateSynchronized:
                return [SSignal single:@(TGConnectionStateNormal)];
                
            case TGSynchronizationStateUpdating:
                return [SSignal single:@(TGConnectionStateUpdating)];
                
            case TGSynchronizationStateConnectingToProxy:
            case TGSynchronizationStateConnecting:
                return [SSignal single:@(TGConnectionStateConnecting)];
                
            case TGSynchronizationStateProxyIssues:
                return [SSignal single:@(TGConnectionStateTimedOut)];
                
            default:
                return [SSignal single:@(TGConnectionStateWaitingForNetwork)];
        }
    }];
}

+ (TGProxyItem *)currentProxy:(bool *)inactive
{
    TGProxyItem *proxy = nil;
    NSData *socksProxyData = [TGDatabaseInstance() customProperty:@"socksProxyData"];
    if (socksProxyData != nil) {
        NSDictionary *socksProxyDict = [NSKeyedUnarchiver unarchiveObjectWithData:socksProxyData];
        if (socksProxyDict[@"ip"] != nil && socksProxyDict[@"port"] != nil) {
            if (inactive != NULL)
                *inactive = [socksProxyDict[@"inactive"] boolValue];
            
            proxy = [[TGProxyItem alloc] initWithServer:socksProxyDict[@"ip"] port:(uint16_t)[socksProxyDict[@"port"] intValue] username:socksProxyDict[@"username"] password:socksProxyDict[@"password"] secret:socksProxyDict[@"secret"]];
        }
    }
    
    return proxy;
}

+ (MTSocksProxySettings *)applyProxy:(TGProxyItem *)proxy inactive:(bool)inactive
{
    NSData *data = nil;
    if (proxy != nil) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        if (proxy.server != nil && proxy.port != 0) {
            dict[@"ip"] = proxy.server;
            dict[@"port"] = @(proxy.port);
        }
        if (proxy.username.length != 0) {
            dict[@"username"] = proxy.username;
        }
        if (proxy.password.length != 0) {
            dict[@"password"] = proxy.password;
        }
        if (proxy.secret.length != 0) {
            dict[@"secret"] = proxy.secret;
        }
        dict[@"inactive"] = @(inactive);
        data = [NSKeyedArchiver archivedDataWithRootObject:dict];
    } else {
        data = [NSData data];
    }
    [TGDatabaseInstance() setCustomProperty:@"socksProxyData" value:data];
    
    MTSocksProxySettings *settings = [[MTSocksProxySettings alloc] initWithIp:proxy.server port:(uint16_t)proxy.port username:proxy.username password:proxy.password secret:proxy.secret.length > 0 && proxy.secret.length % 2 == 0 ? [NSData dataWithHexString:proxy.secret] : nil];
    [[[TGTelegramNetworking instance] context] updateApiEnvironment:^MTApiEnvironment *(MTApiEnvironment *apiEnvironment) {
        return [apiEnvironment withUpdatedSocksProxySettings:inactive ? nil : settings];
    }];
    
    currentPipe.sink(inactive ? nil : proxy);
    
    return inactive ? nil : settings;
}

+ (void)saveProxy:(TGProxyItem *)proxy
{
    NSArray<TGProxyItem *> *proxies = [[self loadStoredProxies] mutableCopy];
    
    NSUInteger existingIndex = [proxies indexOfObject:proxy];
    if (existingIndex != NSNotFound)
        [(NSMutableArray *)proxies removeObject:proxy];
    
    proxies = [@[proxy] arrayByAddingObjectsFromArray:proxies];
    
    [self storeProxies:proxies];
}

+ (void)storeProxies:(NSArray<TGProxyItem *> *)proxies
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:proxies];
    [data writeToFile:[self filePath] atomically:true];
    
    listPipe.sink(proxies);
}

+ (NSArray<TGProxyItem *> *)loadStoredProxies
{
    NSArray *proxies = @[];
    NSData *data = [NSData dataWithContentsOfFile:[self filePath]];
    if (data.length > 0)
    {
        @try
        {
            proxies = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        @catch (NSException *e)
        {  
        }
    }
    
    TGProxyItem *currentProxy = [self currentProxy:NULL];
    if (currentProxy != nil)
    {
        bool found = false;
        for (TGProxyItem *proxy in proxies)
        {
            if ([proxy isEqual:currentProxy])
            {
                found = true;
                break;
            }
        }
        
        if (!found)
            proxies = [@[currentProxy] arrayByAddingObjectsFromArray:proxies];
    }
    
    return proxies;
}

+ (NSString *)filePath
{
    return [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"proxies.data"];
}

@end
