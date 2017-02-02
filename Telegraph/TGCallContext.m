#import "TGCallContext.h"

@implementation TGCallRequestingContext

@end

@implementation TGCallWaitingContext

- (instancetype)initWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId a:(NSData *)a dhConfig:(id)dhConfig receiveDate:(int32_t)receiveDate {
    self = [super init];
    if (self != nil) {
        _callId = callId;
        _accessHash = accessHash;
        _date = date;
        _adminId = adminId;
        _participantId = participantId;
        _a = a;
        _dhConfig = dhConfig;
        _receiveDate = receiveDate;
    }
    return self;
}

@end

@implementation TGCallRequestedContext

- (instancetype)initWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId gA:(NSData *)gA {
    self = [super init];
    if (self != nil) {
        _callId = callId;
        _accessHash = accessHash;
        _date = date;
        _adminId = adminId;
        _participantId = participantId;
        _gA = gA;
    }
    return self;
}

@end

@implementation TGCallReceivedContext

- (instancetype)initWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId gAOrB:(NSData *)gAOrB key:(NSData *)key keyFingerprint:(int64_t)keyFingerprint {
    self = [super init];
    if (self != nil) {
        _callId = callId;
        _accessHash = accessHash;
        _date = date;
        _adminId = adminId;
        _participantId = participantId;
        _gAOrB = gAOrB;
        _key = key;
        _keyFingerprint = keyFingerprint;
    }
    return self;
}

@end

@implementation TGCallAcceptedContext

- (instancetype)initWithCallId:(int64_t)callId accessHash:(int64_t)accessHash date:(int32_t)date adminId:(int32_t)adminId participantId:(int32_t)participantId gAOrB:(NSData *)gAOrB keyFingerprint:(int64_t)keyFingerprint defaultConnection:(TGCallConnectionDescription *)defaultConnection alternativeConnections:(NSArray<TGCallConnectionDescription *> *)alternativeConnections {
    self = [super init];
    if (self != nil) {
        _callId = callId;
        _accessHash = accessHash;
        _date = date;
        _adminId = adminId;
        _participantId = participantId;
        _gAOrB = gAOrB;
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

- (instancetype)initWithCallId:(int64_t)callId reason:(TGCallDiscardReason)reason {
    self = [super init];
    if (self != 0) {
        _callId = callId;
        _reason = reason;
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
