#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

typedef enum {
    TGSynchronizationStateSynchronized,
    TGSynchronizationStateWaitingForNetwork,
    TGSynchronizationStateConnecting,
    TGSynchronizationStateUpdating
} TGSynchronizationStateValue;

@interface TGSynchronizationStateSignal : NSObject

+ (SSignal *)synchronizationState;

@end
