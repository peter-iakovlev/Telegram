#import "TGMessageEntityPre.h"

#import "PSKeyValueCoder.h"

@implementation TGMessageEntityPre

- (instancetype)initWithRange:(NSRange)range language:(NSString *)language {
    self = [super initWithRange:range];
    if (self != nil) {
        _language = language;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder {
    self = [super initWithKeyValueCoder:coder];
    if (self != nil) {
        _language = [coder decodeStringForCKey:"language"];
    }
    return self;
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder {
    [super encodeWithKeyValueCoder:coder];
    [coder encodeString:_language forCKey:"language"];
}

@end
