#import "TGUnseenPeerMentionsState.h"

#import <LegacyComponents/PSKeyValueCoder.h>

@implementation TGUnseenPeerMentionsState

- (instancetype)init {
    return [self initWithVersion:0 count:0 maxIdWithPrecalculatedCount:0];
}

- (instancetype)initWithVersion:(int32_t)version count:(int32_t)count maxIdWithPrecalculatedCount:(int32_t)maxIdWithPrecalculatedCount {
    self = [super init];
    if (self != nil) {
        _version = version;
        _count = count;
        _maxIdWithPrecalculatedCount = maxIdWithPrecalculatedCount;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder {
    return [self initWithVersion:[coder decodeInt32ForCKey:"v"] count:[coder decodeInt32ForCKey:"c"] maxIdWithPrecalculatedCount:[coder decodeInt32ForCKey:"i"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder {
    [coder encodeInt32:_version forCKey:"v"];
    [coder encodeInt32:_count forCKey:"c"];
    [coder encodeInt32:_maxIdWithPrecalculatedCount forCKey:"i"];
}

- (TGUnseenPeerMentionsState *)withUpdatedCount:(int32_t)count {
    return [[TGUnseenPeerMentionsState alloc] initWithVersion:_version count:count maxIdWithPrecalculatedCount:_maxIdWithPrecalculatedCount];
}

@end
