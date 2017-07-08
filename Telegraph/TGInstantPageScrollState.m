#import "TGInstantPageScrollState.h"

#import "PSKeyValueCoder.h"

@implementation TGInstantPageScrollState

- (instancetype)initWithBlockId:(int32_t)blockId blockOffest:(int32_t)blockOffset {
    self = [super init];
    if (self != nil) {
        _blockId = blockId;
        _blockOffset = blockOffset;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder {
    return [self initWithBlockId:[coder decodeInt32ForCKey:"blockId"] blockOffest:[coder decodeInt32ForCKey:"blockOffset"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder {
    [coder encodeInt32:_blockId forCKey:"messageId"];
    [coder encodeInt32:_blockOffset forCKey:"messageOffset"];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[TGInstantPageScrollState class]] && ((TGInstantPageScrollState *)object)->_blockId == _blockId && ((TGInstantPageScrollState *)object)->_blockOffset == _blockOffset;
}

@end
