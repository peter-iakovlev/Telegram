#import "TGMessageUniqueIdContentProperty.h"

#import "PSKeyValueEncoder.h"
#import "PSKeyValueDecoder.h"

@implementation TGMessageUniqueIdContentProperty

- (instancetype)initWithValue:(int32_t)value {
    self = [super init];
    if (self != nil) {
        _value = value;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder {
    return [self initWithValue:[coder decodeInt32ForCKey:"v"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder {
    [coder encodeInt32:_value forCKey:"v"];
}

@end
