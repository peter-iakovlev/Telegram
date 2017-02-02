#import "TGGroupInvitationInfo.h"

@implementation TGGroupInvitationInfo

- (instancetype)initWithTitle:(NSString *)title alreadyAccepted:(bool)alreadyAccepted left:(bool)left isChannel:(bool)isChannel isChannelGroup:(bool)isChannelGroup peerId:(int64_t)peerId avatarInfo:(TGImageInfo *)avatarInfo userCount:(NSInteger)userCount users:(NSArray *)users
{
    self = [super init];
    if (self != nil)
    {
        _title = title;
        _alreadyAccepted = alreadyAccepted;
        _left = left;
        _isChannel = isChannel;
        _isChannelGroup = isChannelGroup;
        _peerId = peerId;
        _avatarInfo = avatarInfo;
        _userCount = userCount;
        _users = users;
    }
    return self;
}

@end
