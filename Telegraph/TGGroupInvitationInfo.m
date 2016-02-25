#import "TGGroupInvitationInfo.h"

@implementation TGGroupInvitationInfo

- (instancetype)initWithTitle:(NSString *)title alreadyAccepted:(bool)alreadyAccepted left:(bool)left isChannel:(bool)isChannel isChannelGroup:(bool)isChannelGroup peerId:(int64_t)peerId
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
    }
    return self;
}

@end
