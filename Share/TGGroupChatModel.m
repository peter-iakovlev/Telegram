#import "TGGroupChatModel.h"

@implementation TGGroupChatModel

- (instancetype)initWithGroupId:(int32_t)groupId title:(NSString *)title avatarLocation:(TGFileLocation *)avatarLocation
{
    self = [super initWithPeerId:TGPeerIdGroupMake(groupId)];
    if (self != nil)
    {
        _title = title;
        _avatarLocation = avatarLocation;
    }
    return self;
}

@end
