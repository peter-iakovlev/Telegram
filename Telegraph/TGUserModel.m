#import "TGUserModel.h"

#import "PSKeyValueCoder.h"

#import "TGMtFileLocation.h"

@implementation TGUserModel

- (instancetype)initWithUserId:(int32_t)userId firstName:(NSString *)firstName lastName:(NSString *)lastName avatarSmallLocation:(TGMtFileLocation *)avatarSmallLocation avatarLargeLocation:(TGMtFileLocation *)avatarLargeLocation
{
    self = [super init];
    if (self != nil)
    {
        _uuid = [[TGUserUUID alloc] initWithUserId:userId];
        _firstName = firstName;
        _lastName = lastName;
        _avatarSmallLocation = avatarSmallLocation;
        _avatarLargeLocation = avatarLargeLocation;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    int32_t userId = [coder decodeInt32ForCKey:"u"];
    NSString *firstName = [coder decodeStringForCKey:"f"];
    NSString *lastName = [coder decodeStringForCKey:"l"];
    TGMtFileLocation *avatarSmallLocation = [coder decodeObjectForCKey:"as"];
    TGMtFileLocation *avatarLargeLocation = [coder decodeObjectForCKey:"al"];
    
    return [self initWithUserId:userId firstName:firstName lastName:lastName avatarSmallLocation:avatarSmallLocation avatarLargeLocation:avatarLargeLocation];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeInt32:[_uuid userId] forCKey:"u"];
    [coder encodeString:_firstName forCKey:"f"];
    [coder encodeString:_lastName forCKey:"l"];
    [coder encodeObject:_avatarSmallLocation forCKey:"as"];
    [coder encodeObject:_avatarLargeLocation forCKey:"al"];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TGUserModel class]])
    {
        if ([((TGUserModel *)object)->_uuid isEqual:_uuid] &&
            TGStringCompare(((TGUserModel *)object)->_firstName, _firstName) &&
            TGStringCompare(((TGUserModel *)object)->_lastName, _lastName) &&
            TGObjectCompare(((TGUserModel *)object)->_avatarSmallLocation, _avatarSmallLocation) &&
            TGObjectCompare(((TGUserModel *)object)->_avatarLargeLocation, _avatarLargeLocation))
        {
            return true;
        }
    }
    
    return false;
}

@end
