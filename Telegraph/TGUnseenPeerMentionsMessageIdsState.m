#import "TGUnseenPeerMentionsMessageIdsState.h"

#import <LegacyComponents/PSKeyValueCoder.h>

@implementation TGUnseenPeerMentionsMessageIdsState

- (instancetype)initWithMaxCachedId:(int32_t)maxCachedId {
    self = [super init];
    if (self != nil) {
        _maxCachedId = maxCachedId;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder {
    return [self initWithMaxCachedId:[coder decodeInt32ForCKey:"i"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder {
    [coder encodeInt32:_maxCachedId forCKey:"i"];
}

@end
