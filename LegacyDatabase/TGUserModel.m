#import "TGUserModel.h"
#import "TGPrivateChatModel.h"

@implementation TGUserModel

- (instancetype)initWithUserId:(int32_t)userId accessHash:(int64_t)accessHash firstName:(NSString *)firstName lastName:(NSString *)lastName avatarLocation:(TGFileLocation *)avatarLocation
{
    self = [super init];
    if (self != nil)
    {
        _userId = userId;
        _accessHash = accessHash;
        _firstName = firstName;
        _lastName = lastName;
        _avatarLocation = avatarLocation;
    }
    return self;
}

- (NSString *)displayName
{
    if (_firstName.length != 0 && _lastName.length != 0)
        return [[NSString alloc] initWithFormat:@"%@ %@", _firstName, _lastName];
    else if (_firstName.length != 0)
        return _firstName;
    else if (_lastName.length != 0)
        return _lastName;
    return @"";
}

- (TGPrivateChatModel *)chatModel
{
    return [[TGPrivateChatModel alloc] initWithUserId:_userId];
}

@end
