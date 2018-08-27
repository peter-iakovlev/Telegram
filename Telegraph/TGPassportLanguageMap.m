#import "TGPassportLanguageMap.h"

@implementation TGPassportLanguageMap

- (instancetype)initWithMap:(NSDictionary *)map hash:(int32_t)hash
{
    self = [super init];
    if (self != nil)
    {
        _map = map;
        _n_hash = hash;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithMap:[aDecoder decodeObjectForKey:@"map"] hash:[aDecoder decodeInt32ForKey:@"hash"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.map forKey:@"map"];
    [aCoder encodeInt32:self.n_hash forKey:@"hash"];
}

@end
