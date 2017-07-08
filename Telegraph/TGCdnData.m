#import "TGCdnData.h"

#import "TL/TLMetaScheme.h"

@implementation TGCdnData
    
- (instancetype)initWithPublicKey:(NSString *)publicKey {
    self = [super init];
    if (self != nil) {
        _publicKey = publicKey;
    }
    return self;
}
    
- (instancetype)initWithDesc:(TLCdnPublicKey *)desc {
    return [self initWithPublicKey:desc.public_key];
}
    
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithPublicKey:[aDecoder decodeObjectForKey:@"publicKey"]];
}
    
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_publicKey forKey:@"publicKey"];
}

@end
