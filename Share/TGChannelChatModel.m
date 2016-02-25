#import "TGChannelChatModel.h"

@implementation TGChannelChatModel

- (instancetype)initWithChannelId:(int32_t)channelId title:(NSString *)title avatarLocation:(TGFileLocation *)avatarLocation isGroup:(bool)isGroup accessHash:(int64_t)accessHash
{
    self = [super initWithPeerId:TGPeerIdChannelMake(channelId)];
    if (self != nil)
    {
        _title = title;
        _avatarLocation = avatarLocation;
        _isGroup = isGroup;
        _accessHash = accessHash;
    }
    return self;
}

@end
