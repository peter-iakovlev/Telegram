#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

#import "TGCallConnectionDescription.h"
#import "TGCallState.h"

@class TGCallSession;

@interface TGCallRequestingContext : NSObject

@end

@interface TGCallWaitingContext : NSObject

@property (nonatomic, readonly) int64_t callId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, readonly) int32_t date;
@property (nonatomic, readonly) int32_t adminId;
@property (nonatomic, readonly) int32_t participantId;
@property (nonatomic, strong, readonly) NSData *a;
@property (nonatomic, strong, readonly) id dhConfig;
@property (nonatomic, readonly) int32_t receiveDate;

- (instancetype)initWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId a:(NSData *)a dhConfig:(id)dhConfig receiveDate:(int32_t)receiveDate;

@end

@interface TGCallRequestedContext : NSObject

@property (nonatomic, readonly) int64_t callId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, readonly) int32_t date;
@property (nonatomic, readonly) int32_t adminId;
@property (nonatomic, readonly) int32_t participantId;
@property (nonatomic, strong, readonly) NSData *gA;

- (instancetype)initWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId gA:(NSData *)gA;

@end

@interface TGCallReceivedContext : NSObject

@property (nonatomic, readonly) int64_t callId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, readonly) int32_t date;
@property (nonatomic, readonly) int32_t adminId;
@property (nonatomic, readonly) int32_t participantId;
@property (nonatomic, strong, readonly) NSData *gAOrB;
@property (nonatomic, strong, readonly) NSData *key;
@property (nonatomic, readonly) int64_t keyFingerprint;

- (instancetype)initWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId gAOrB:(NSData *)gAOrB key:(NSData *)key keyFingerprint:(int64_t)keyFingerprint;

@end

@interface TGCallAcceptedContext : NSObject

@property (nonatomic, readonly) int64_t callId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, readonly) int32_t date;
@property (nonatomic, readonly) int32_t adminId;
@property (nonatomic, readonly) int32_t participantId;
@property (nonatomic, strong, readonly) NSData *gAOrB;
@property (nonatomic, readonly) int64_t keyFingerprint;
@property (nonatomic, strong, readonly) TGCallConnectionDescription *defaultConnection;
@property (nonatomic, strong, readonly) NSArray<TGCallConnectionDescription *> *alternativeConnections;

- (instancetype)initWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId gAOrB:(NSData *)gAOrB keyFingerprint:(int64_t)keyFingerprint defaultConnection:(TGCallConnectionDescription *)defaultConnection alternativeConnections:(NSArray<TGCallConnectionDescription *> *)alternativeConnections;

@end

@interface TGCallOngoingContext : NSObject

@property (nonatomic, readonly) int64_t callId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, readonly) int32_t date;
@property (nonatomic, readonly) int32_t adminId;
@property (nonatomic, readonly) int32_t participantId;
@property (nonatomic, strong, readonly) NSData *key;
@property (nonatomic, readonly) int64_t keyFingerprint;
@property (nonatomic, strong, readonly) TGCallConnectionDescription *defaultConnection;
@property (nonatomic, strong, readonly) NSArray<TGCallConnectionDescription *> *alternativeConnections;

- (instancetype)initWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId key:(NSData *)key keyFingerprint:(int64_t)keyFingerprint defaultConnection:(TGCallConnectionDescription *)defaultConnection alternativeConnections:(NSArray<TGCallConnectionDescription *> *)alternativeConnections;

@end

@interface TGCallDiscardedContext : NSObject

@property (nonatomic, readonly) int64_t callId;
@property (nonatomic, readonly) TGCallDiscardReason reason;

- (instancetype)initWithCallId:(int64_t)callId reason:(TGCallDiscardReason)reason;

@end

@interface TGCallContext : NSObject

@property (nonatomic, strong) id context;
@property (nonatomic, strong) NSUUID *uuid;
@property (nonatomic, strong) TGCallSession *session;
@property (nonatomic, strong, readonly) SMetaDisposable *disposable;
@property (nonatomic, strong) TGCallStateData *state;
@property (nonatomic, strong, readonly) SBag *stateSubscribers;

@end
