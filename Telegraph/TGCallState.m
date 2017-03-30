#import "TGCallState.h"

@implementation TGCallStateData

- (instancetype)initWithInternalId:(NSNumber *)internalId callId:(int64_t)callId accessHash:(int64_t)accessHash state:(TGCallState)state peerId:(int64_t)peerId connection:(TGCallConnection *)connection hungUpOutside:(bool)hungUpOutside needsRating:(bool)needsRating needsDebug:(bool)needsDebug error:(NSString *)error {
    self = [super init];
    if (self != nil) {
        _internalId = internalId;
        _callId = callId;
        _state = state;
        _peerId = peerId;
        _accessHash = accessHash;
        _connection = connection;
        _hungUpOutside = hungUpOutside;
        _needsRating = needsRating;
        _needsDebug = needsDebug;
        _error = error;
    }
    return self;
}

@end
