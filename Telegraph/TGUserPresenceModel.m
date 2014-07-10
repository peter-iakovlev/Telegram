#import "TGUserPresenceModel.h"

#import "PSKeyValueCoder.h"

@implementation TGUserPresenceModel

- (instancetype)initWithUserId:(int32_t)userId lastSeen:(NSTimeInterval)lastSeen
{
    self = [super init];
    if (self != nil)
    {
        _uuid = [[TGUserUUID alloc] initWithUserId:userId];
        _lastSeen = lastSeen;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    int32_t userId = [coder decodeInt32ForCKey:"u"];
    NSTimeInterval lastSeen = [coder decodeInt32ForCKey:"l"];
    
    return [self initWithUserId:userId lastSeen:lastSeen];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeInt32:[_uuid userId] forCKey:"u"];
    [coder encodeInt32:(int32_t)_lastSeen forCKey:"l"];
}

@end
