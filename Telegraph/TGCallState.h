#import <Foundation/Foundation.h>

#import "TGCallConnectionDescription.h"
#import "TGCallDiscardReason.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    TGCallStateRequesting,
    TGCallStateWaiting,
    TGCallStateWaitingReceived,
    TGCallStateHandshake,
    TGCallStateReady,
    TGCallStateAccepting,
    TGCallStateOngoing,
    TGCallStateEnding,
    TGCallStateEnded,
    TGCallStateBusy,
    TGCallStateInterrupted
} TGCallState;
    
@interface TGCallStateData : NSObject

@property (nonatomic, strong, readonly) NSNumber *internalId;
@property (nonatomic, readonly) int64_t callId;
@property (nonatomic, readonly) TGCallState state;
@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, strong, readonly) TGCallConnection *connection;

- (instancetype)initWithInternalId:(NSNumber *)internalId callId:(int64_t)callId state:(TGCallState)state peerId:(int64_t)peerId connection:(TGCallConnection *)connection;

@end

#ifdef __cplusplus
}
#endif
