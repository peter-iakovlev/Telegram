#import "TGUserUUID.h"

@interface TGUserUUID ()
{
    int32_t _userId;
}

@end

@implementation TGUserUUID

- (instancetype)initWithUserId:(int32_t)userId
{
    self = [super init];
    if (self != nil)
    {
        _userId = userId;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)__unused zone
{
    TGUserUUID *object = [[TGUserUUID alloc] initWithUserId:_userId];
    return object;
}

- (NSUInteger)hash
{
    return _userId;
}

- (int32_t)userId
{
    return _userId;
}

- (NSData *)bytes
{
    return [[NSData alloc] initWithBytes:&_userId length:4];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TGUserUUID class]])
        return ((TGUserUUID *)object)->_userId == _userId;
    
    return false;
}

@end
