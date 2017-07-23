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
    TGCallStateNoAnswer,
    TGCallStateMissed
} TGCallState;
    
@interface TGCallStateData : NSObject

@property (nonatomic, strong, readonly) NSNumber *internalId;
@property (nonatomic, readonly) int64_t callId;
@property (nonatomic, readonly) TGCallState state;
@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, strong, readonly) TGCallConnection *connection;
@property (nonatomic, readonly) bool hungUpOutside;
@property (nonatomic, readonly) bool needsRating;
@property (nonatomic, readonly) bool needsDebug;

@property (nonatomic, readonly) NSString *error;

- (instancetype)initWithInternalId:(NSNumber *)internalId callId:(int64_t)callId accessHash:(int64_t)accessHash state:(TGCallState)state peerId:(int64_t)peerId connection:(TGCallConnection *)connection hungUpOutside:(bool)hungUpOutside needsRating:(bool)needsRating needsDebug:(bool)needsDebug error:(NSString *)error;

@end

#ifdef __cplusplus
}
#endif
