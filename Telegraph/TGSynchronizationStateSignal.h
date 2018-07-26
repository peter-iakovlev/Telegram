#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

typedef enum {
    TGSynchronizationStateSynchronized,
    TGSynchronizationStateWaitingForNetwork,
    TGSynchronizationStateConnecting,
    TGSynchronizationStateConnectingToProxy,
    TGSynchronizationStateUpdating,
    TGSynchronizationStateProxyIssues,
} TGSynchronizationStateValue;

@interface TGSynchronizationStateSignal : NSObject

+ (SSignal *)synchronizationState;

@end
