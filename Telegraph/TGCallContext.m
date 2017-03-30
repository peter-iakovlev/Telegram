#import "TGCallContext.h"

@implementation TGCallRequestingContext

@end

@implementation TGCallWaitingContext

- (instancetype)initWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId a:(NSData *)a gA:(NSData *)gA dhConfig:(id)dhConfig receiveDate:(int32_t)receiveDate {
    self = [super init];
    if (self != nil) {
        _callId = callId;
        _accessHash = accessHash;
        _date = date;
        _adminId = adminId;
        _participantId = participantId;
        _a = a;
        _gA = gA;
        _dhConfig = dhConfig;
        _receiveDate = receiveDate;
    }
    return self;
}

@end

@implementation TGCallWaitingConfirmContext

- (instancetype)initWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId b:(NSData *)b gAHash:(NSData *)gAHash dhConfig:(id)dhConfig receiveDate:(int32_t)receiveDate {
    self = [super init];
    if (self != nil) {
        _callId = callId;
        _accessHash = accessHash;
        _date = date;
        _adminId = adminId;
        _participantId = participantId;
        _b = b;
        _gAHash = gAHash;
        _dhConfig = dhConfig;
        _receiveDate = receiveDate;
    }
    return self;
}

@end

@implementation TGCallRequestedContext

- (instancetype)initWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId gAHash:(NSData *)gAHash declined:(bool)declined {
    self = [super init];
    if (self != nil) {
        _callId = callId;
        _accessHash = accessHash;
        _date = date;
        _adminId = adminId;
        _participantId = participantId;
        _gAHash = gAHash;
        _declined = declined;
    }
    return self;
}

@end

@implementation TGCallReceivedContext

- (instancetype)initWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId dhConfig:(id)dhConfig b:(NSData *)b gB:(NSData *)gB gAHash:(NSData *)gAHash {
    self = [super init];
    if (self != nil) {
        _callId = callId;
        _accessHash = accessHash;
        _date = date;
        _adminId = adminId;
        _participantId = participantId;
        _dhConfig = dhConfig;
        _b = b;
        _gB = gB;
        _gAHash = gAHash;
    }
    return self;
}

@end

@implementation TGCallAcceptedContext

- (instancetype)initWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId gA:(NSData *)gA gB:(NSData *)gB {
    self = [super init];
    if (self != nil) {
        _callId = callId;
        _accessHash = accessHash;
        _date = date;
        _adminId = adminId;
        _participantId = participantId;
        _gA = gA;
        _gB = gB;
    }
    return self;
}

@end

@implementation TGCallConfirmedContext

- (instancetype)initWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId gA:(NSData *)gA keyFingerprint:(int64_t)keyFingerprint defaultConnection:(TGCallConnectionDescription *)defaultConnection alternativeConnections:(NSArray<TGCallConnectionDescription *> *)alternativeConnections {
    self = [super init];
    if (self != nil) {
        _callId = callId;
        _accessHash = accessHash;
        _date = date;
        _adminId = adminId;
        _participantId = participantId;
        _gA = gA;
        _keyFingerprint = keyFingerprint;
        _defaultConnection = defaultConnection;
        _alternativeConnections = alternativeConnections;
    }
    return self;
}

@end

@implementation TGCallOngoingContext

- (instancetype)initWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId key:(NSData *)key keyFingerprint:(int64_t)keyFingerprint defaultConnection:(TGCallConnectionDescription *)defaultConnection alternativeConnections:(NSArray<TGCallConnectionDescription *> *)alternativeConnections {
    self = [super init];
    if (self != nil) {
        _callId = callId;
        _accessHash = accessHash;
        _date = date;
        _adminId = adminId;
        _participantId = participantId;
        _key = key;
        _keyFingerprint = keyFingerprint;
        _defaultConnection = defaultConnection;
        _alternativeConnections = alternativeConnections;
    }
    return self;
}

@end

@implementation TGCallDiscardedContext

- (instancetype)initWithCallId:(int64_t)callId reason:(TGCallDiscardReason)reason outside:(bool)outside needsRating:(bool)needsRating needsDebug:(bool)needsDebug error:(NSString *)error {
    self = [super init];
    if (self != nil) {
        _callId = callId;
        _reason = reason;
        _outside = outside;
        _needsRating = needsRating;
        _needsDebug = needsDebug;
        _error = error;
    }
    return self;
}

@end

@implementation TGCallContext

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _disposable = [[SMetaDisposable alloc] init];
        _stateSubscribers = [[SBag alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_disposable dispose];
}

@end
