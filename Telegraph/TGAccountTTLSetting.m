#import "TGAccountTTLSetting.h"

@implementation TGAccountTTLSetting

- (instancetype)initWithDefaultValues
{
    return [self initWithAccountTTL:@(60 * 60 * 24 * 182)];
}

- (instancetype)initWithAccountTTL:(NSNumber *)accountTTL
{
    self = [super init];
    if (self != nil)
    {
        _accountTTL = accountTTL;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithAccountTTL:[aDecoder decodeObjectForKey:@"accountTTL"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if (_accountTTL != nil)
        [aCoder encodeObject:_accountTTL forKey:@"accountTTL"];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGAccountTTLSetting class]] && TGObjectCompare(_accountTTL, ((TGAccountTTLSetting *)object)->_accountTTL);
}

@end
