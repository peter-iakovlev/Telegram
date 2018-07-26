#import <SSignalKit/SSignalKit.h>
#import "TGProxyItem.h"

@class MTSocksProxySettings;
@class MTContext;

typedef enum
{
    TGProxyUnknown,
    TGProxyAvailable,
    TGProxyUnavailable
} TGProxyAvailability;

@interface TGProxyCachedAvailability : NSObject

@property (nonatomic) TGProxyAvailability availability;
@property (nonatomic) NSTimeInterval rtt;
@property (nonatomic) NSTimeInterval timestamp;

@end

typedef enum {
    TGConnectionStateNotConnected,
    TGConnectionStateNormal,
    TGConnectionStateConnecting,
    TGConnectionStateUpdating,
    TGConnectionStateWaitingForNetwork,
    TGConnectionStateTimedOut
} TGConnectionState;

@interface TGProxySignals : NSObject

+ (SSignal *)currentSignal;
+ (SSignal *)listSignal;
+ (SSignal *)stateSignal;

+ (SSignal *)availabiltyForProxy:(TGProxyItem *)proxy withContext:(MTContext *)context datacenterId:(NSInteger)datacenterId;
+ (SSignal *)connectionStatus;

+ (TGProxyItem *)currentProxy:(bool *)inactive;
+ (MTSocksProxySettings *)applyProxy:(TGProxyItem *)proxy inactive:(bool)inactive;

+ (void)storeProxies:(NSArray<TGProxyItem *> *)proxies;
+ (NSArray<TGProxyItem *> *)loadStoredProxies;

+ (void)saveProxy:(TGProxyItem *)proxy;

@end
