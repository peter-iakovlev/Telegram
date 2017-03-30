#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

#import "TGCallConnectionDescription.h"
#import "TGCallState.h"

@class TGCallSession;

@protocol TGCallIdentifiableContext <NSObject>

@property (nonatomic, readonly) int64_t callId;

@optional
@property (nonatomic, readonly) int64_t accessHash;

@end

@interface TGCallRequestingContext : NSObject

@end

@interface TGCallWaitingContext : NSObject <TGCallIdentifiableContext>

@property (nonatomic, readonly) int64_t callId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, readonly) int32_t date;
@property (nonatomic, readonly) int32_t adminId;
@property (nonatomic, readonly) int32_t participantId;
@property (nonatomic, strong, readonly) NSData *a;
@property (nonatomic, strong, readonly) NSData *gA;
@property (nonatomic, strong, readonly) id dhConfig;
@property (nonatomic, readonly) int32_t receiveDate;

- (instancetype)initWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId a:(NSData *)a gA:(NSData *)gA dhConfig:(id)dhConfig receiveDate:(int32_t)receiveDate;

@end

@interface TGCallWaitingConfirmContext : NSObject <TGCallIdentifiableContext>

@property (nonatomic, readonly) int64_t callId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, readonly) int32_t date;
@property (nonatomic, readonly) int32_t adminId;
@property (nonatomic, readonly) int32_t participantId;
@property (nonatomic, strong, readonly) NSData *b;
@property (nonatomic, strong, readonly) NSData *gAHash;
@property (nonatomic, strong, readonly) id dhConfig;
@property (nonatomic, readonly) int32_t receiveDate;

- (instancetype)initWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId b:(NSData *)b gAHash:(NSData *)gAHash dhConfig:(id)dhConfig receiveDate:(int32_t)receiveDate;

@end

@interface TGCallRequestedContext : NSObject <TGCallIdentifiableContext>

@property (nonatomic, readonly) int64_t callId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, readonly) int32_t date;
@property (nonatomic, readonly) int32_t adminId;
@property (nonatomic, readonly) int32_t participantId;
@property (nonatomic, strong, readonly) NSData *gAHash;
@property (nonatomic, readonly) bool declined;

- (instancetype)initWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId gAHash:(NSData *)gAHash declined:(bool)declined;

@end

@interface TGCallReceivedContext : NSObject <TGCallIdentifiableContext>

@property (nonatomic, readonly) int64_t callId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, readonly) int32_t date;
@property (nonatomic, readonly) int32_t adminId;
@property (nonatomic, readonly) int32_t participantId;
@property (nonatomic, strong, readonly) id dhConfig;
@property (nonatomic, strong, readonly) NSData *b;
@property (nonatomic, strong, readonly) NSData *gB;
@property (nonatomic, strong, readonly) NSData *gAHash;

- (instancetype)initWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId dhConfig:(id)dhConfig b:(NSData *)b gB:(NSData *)gB gAHash:(NSData *)gAHash;

@end

@interface TGCallAcceptedContext : NSObject <TGCallIdentifiableContext>

@property (nonatomic, readonly) int64_t callId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, readonly) int32_t date;
@property (nonatomic, readonly) int32_t adminId;
@property (nonatomic, readonly) int32_t participantId;
@property (nonatomic, strong, readonly) NSData *gA;
@property (nonatomic, strong, readonly) NSData *gB;

- (instancetype)initWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId gA:(NSData *)gA gB:(NSData *)gB;

@end


@interface TGCallConfirmedContext : NSObject <TGCallIdentifiableContext>

@property (nonatomic, readonly) int64_t callId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, readonly) int32_t date;
@property (nonatomic, readonly) int32_t adminId;
@property (nonatomic, readonly) int32_t participantId;
@property (nonatomic, strong, readonly) NSData *gA;
@property (nonatomic, readonly) int64_t keyFingerprint;
@property (nonatomic, strong, readonly) TGCallConnectionDescription *defaultConnection;
@property (nonatomic, strong, readonly) NSArray<TGCallConnectionDescription *> *alternativeConnections;

- (instancetype)initWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId gA:(NSData *)gA keyFingerprint:(int64_t)keyFingerprint defaultConnection:(TGCallConnectionDescription *)defaultConnection alternativeConnections:(NSArray<TGCallConnectionDescription *> *)alternativeConnections;

@end


@interface TGCallOngoingContext : NSObject <TGCallIdentifiableContext>

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

@interface TGCallDiscardedContext : NSObject <TGCallIdentifiableContext>

@property (nonatomic, readonly) int64_t callId;
@property (nonatomic, readonly) TGCallDiscardReason reason;
@property (nonatomic, readonly) bool outside;
@property (nonatomic, readonly) bool needsRating;
@property (nonatomic, readonly) bool needsDebug;
@property (nonatomic, readonly) NSString *error;

- (instancetype)initWithCallId:(int64_t)callId reason:(TGCallDiscardReason)reason outside:(bool)outside needsRating:(bool)needsRating needsDebug:(bool)needsDebug error:(NSString *)error;

@end

@interface TGCallContext : NSObject

@property (nonatomic, strong) id context;
@property (nonatomic, strong) NSUUID *uuid;
@property (nonatomic, strong) TGCallSession *session;
@property (nonatomic, strong, readonly) SMetaDisposable *disposable;
@property (nonatomic, strong) TGCallStateData *state;
@property (nonatomic, strong, readonly) SBag *stateSubscribers;

@end
