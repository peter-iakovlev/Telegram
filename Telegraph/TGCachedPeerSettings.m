#import "TGCachedPeerSettings.h"

#import "PSKeyValueCoder.h"

@implementation TGCachedPeerSettings

- (instancetype)initWithReportSpamState:(TGCachedPeerReportSpamState)reportSpamState {
    self = [super init];
    if (self != nil) {
        _reportSpamState = reportSpamState;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder {
    return [self initWithReportSpamState:(TGCachedPeerReportSpamState)[coder decodeInt32ForCKey:"reportSpamState"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder {
    [coder encodeInt32:_reportSpamState forCKey:"reportSpamState"];
}

- (TGCachedPeerSettings *)updateReportSpamState:(TGCachedPeerReportSpamState)reportSpamState {
    return [[TGCachedPeerSettings alloc] initWithReportSpamState:reportSpamState];
}

@end
