#import "TGDocumentHttpFileReference.h"

#import <LegacyComponents/LegacyComponents.h>

@implementation TGDocumentHttpFileReference

- (instancetype)initWithUrl:(NSString *)url {
    self = [super init];
    if (self != nil) {
        _url = url;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithUrl:[aDecoder decodeObjectForKey:@"url"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_url forKey:@"url"];
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder {
    return [self initWithUrl:[coder decodeStringForCKey:"url"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder {
    [coder encodeString:_url forCKey:"url"];
}

@end
