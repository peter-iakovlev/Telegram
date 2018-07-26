#import "TGDialogListItem.h"
#import <LegacyComponents/TGPeerIdAdapter.h>

@implementation TGFeed (TGDialogListItem)

@dynamic kind;

- (int64_t)conversationId
{
    return TGPeerIdFromAdminLogId(self.fid);
}

- (int64_t)feedId
{
    return 0;
}

- (int)channelRole
{
    return 0;
}

- (uint8_t)kind
{
    return 0;
}

- (bool)isChannel
{
    return false;
}

- (bool)isChannelGroup
{
    return false;
}

- (bool)isDeactivated
{
    return false;
}

- (bool)isBroadcast
{
    return false;
}

@end
