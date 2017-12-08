#import "TGNetworkTypeManager.h"

#import "Reachability.h"

#import <libkern/OSAtomic.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import <LegacyComponents/TGObserverProxy.h>

@interface TGObserverBlockProxy : TGObserverProxy

@property (nonatomic, copy) void (^block)(void);

- (instancetype)initWithName:(NSString *)name block:(void (^)(void))block;

@end


@interface TGNetworkTypeManager ()
{
    id<SDisposable> _disposable;
    SPipe *_pipe;
    OSSpinLock _lock;
    TGNetworkType _type;
}
@end

@implementation TGNetworkTypeManager

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _type = TGNetworkTypeNone;
        
        _pipe = [[SPipe alloc] init];
        
        __weak TGNetworkTypeManager *weakSelf = self;
        _disposable = [[[TGNetworkTypeManager networkTypeSignal] deliverOn:[SQueue mainQueue]] startWithNext:^(id next)
        {
            __strong TGNetworkTypeManager *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            OSSpinLockLock(&_lock);
            strongSelf->_type = (TGNetworkType)[next integerValue];
            OSSpinLockUnlock(&_lock);
            
            strongSelf->_pipe.sink(next);
        }];
    }
    return self;
}

- (TGNetworkType)networkType
{
    TGNetworkType type = TGNetworkTypeNone;
    OSSpinLockLock(&_lock);
    type = _type;
    OSSpinLockUnlock(&_lock);
    return type;
}

- (SSignal *)networkTypeSignal
{
    return [[SSignal single:@([self networkType])] then:_pipe.signalProducer()];
}

+ (SSignal *)networkTypeSignal
{
    SSignal *reachabilitySignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        
        [subscriber putNext:@(reachability.currentReachabilityStatus)];
        reachability.reachabilityChanged = ^(NetworkStatus status)
        {
            [subscriber putNext:@(status)];
        };
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            __strong Reachability *strongReachability = reachability;
            [strongReachability stopNotifier];
        }];
    }];
    
    
    SSignal *cellNetworkSignal = [SSignal complete];
    
    if (iosMajorVersion() >= 7)
    {
        cellNetworkSignal = [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
        {
            CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
            NSString *network = telephonyInfo.currentRadioAccessTechnology;
            if (network == nil)
                network = @"";
            [subscriber putNext:network];
            
            TGObserverBlockProxy *observer = [[TGObserverBlockProxy alloc] initWithName:CTRadioAccessTechnologyDidChangeNotification block:^
            {
                NSString *network = telephonyInfo.currentRadioAccessTechnology;
                if (network == nil)
                    network = @"";
                [subscriber putNext:network];
            }];
            
            return [[SBlockDisposable alloc] initWithBlock:^
            {
                [telephonyInfo description];
                [observer description];
            }];
        }] map:^id(NSString *networkType)
        {
            if ([networkType isEqualToString:CTRadioAccessTechnologyGPRS])
            {
                return @(TGNetworkTypeGPRS);
            }
            else if ([networkType isEqualToString:CTRadioAccessTechnologyEdge] || [networkType isEqualToString:CTRadioAccessTechnologyCDMA1x])
            {
                return @(TGNetworkTypeEdge);
            }
            else if ([networkType isEqualToString:CTRadioAccessTechnologyLTE])
            {
                return @(TGNetworkTypeLTE);
            }
            else if ([networkType isEqualToString:CTRadioAccessTechnologyWCDMA]
                     || [networkType isEqualToString:CTRadioAccessTechnologyHSDPA]
                     || [networkType isEqualToString:CTRadioAccessTechnologyHSUPA]
                     || [networkType isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]
                     || [networkType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]
                     || [networkType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]
                     || [networkType isEqualToString:CTRadioAccessTechnologyeHRPD])
            {
                return @(TGNetworkType3G);
            }
            
            return @(TGNetworkTypeUnknown);
        }];
    }
    else
    {
        cellNetworkSignal = [SSignal single:@(TGNetworkTypeEdge)];
    }
    
    return [[SSignal combineSignals:@[reachabilitySignal, cellNetworkSignal]] map:^NSNumber *(NSArray *values)
    {
        NSInteger reachability = [values.firstObject integerValue];
        NSNumber *networkType = values.lastObject;
        
        if (reachability == ReachableViaWWAN)
            return networkType;
        else if (reachability == ReachableViaWiFi)
            return @(TGNetworkTypeWiFi);
        else if (reachability == NotReachable)
            return @(TGNetworkTypeNone);
        
        return @(TGNetworkTypeUnknown);
    }];
}

@end


@implementation TGObserverBlockProxy

- (instancetype)initWithName:(NSString *)name block:(void (^)(void))block
{
    self = [self initWithTarget:self targetSelector:@selector(handleNotification) name:name];
    if (self != nil)
    {
        self.block = block;
    }
    return self;
}

- (void)handleNotification
{
    if (self.block != nil)
        self.block();
}

@end
