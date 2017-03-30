#import "TGStoredTmpPassword.h"

@implementation TGStoredTmpPassword

- (instancetype)initWithData:(NSData *)data validUntil:(int32_t)validUntil {
    self = [super init];
    if (self != nil) {
        _data = data;
        _validUntil = validUntil;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithData:[aDecoder decodeObjectForKey:@"data"] validUntil:[aDecoder decodeInt32ForKey:@"validUntil"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_data forKey:@"data"];
    [aCoder encodeInt32:_validUntil forKey:@"validUntil"];
}

@end
