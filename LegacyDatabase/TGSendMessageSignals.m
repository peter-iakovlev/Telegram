#import "TGSendMessageSignals.h"

#import "TGUserModel.h"
#import "TGChannelChatModel.h"

@implementation TGSendMessageSignals

+ (Api70_InputPeer *)inputPeerForPeerId:(TGPeerId)peerId users:(NSArray *)users isChannel:(bool *)isChannel
{
    switch (peerId.namespaceId)
    {
        case TGPeerIdPrivate:
        {
            for (id model in users)
            {
                if ([model isKindOfClass:[TGUserModel class]] && ((TGUserModel *)model).userId == peerId.peerId)
                {
                    TGUserModel *user = (TGUserModel *)model;
                    
                    if (user.accessHash == -1)
                        return [Api70_InputPeer inputPeerSelf];
                    else
                        return [Api70_InputPeer inputPeerUserWithUserId:@(user.userId) accessHash:@(user.accessHash)];
                }
            }
        }
            break;
            
        case TGPeerIdGroup:
        {
            return [Api70_InputPeer inputPeerChatWithChatId:@(peerId.peerId)];
        }
            break;
            
        case TGPeerIdChannel:
        {
            for (id model in users)
            {
                if ([model isKindOfClass:[TGChannelChatModel class]] && ((TGChannelChatModel *)model).peerId.peerId == peerId.peerId)
                {
                    TGChannelChatModel *channel = (TGChannelChatModel *)model;
                    if (isChannel != NULL)
                        *isChannel = !channel.isGroup;
                    
                    return [Api70_InputPeer inputPeerChannelWithChannelId:@(channel.peerId.peerId) accessHash:@(channel.accessHash)];
                }
            }
        }
            break;
            
        default:
            break;
    }
    return nil;
}

+ (SSignal *)sendTextMessageWithContext:(TGShareContext *)context peerId:(TGPeerId)peerId users:(NSArray *)users text:(NSString *)text
{
    bool isChannel = false;
    Api70_InputPeer *inputPeer = [self inputPeerForPeerId:peerId users:users isChannel:&isChannel];
    if (inputPeer == nil)
        return [SSignal fail:nil];
    
    int64_t randomId = 0;
    arc4random_buf(&randomId, 8);
    int32_t flags = 0;
    if (isChannel)
        flags |= 16;
    flags |= (1 << 6);
    
    return [context function:[Api70 messages_sendMessageWithFlags:@(flags) peer:inputPeer replyToMsgId:@(0) message:text randomId:@(randomId) replyMarkup:nil entities:@[]]];
}

+ (SSignal *)sendMediaWithContext:(TGShareContext *)context peerId:(TGPeerId)peerId users:(NSArray *)users inputMedia:(Api70_InputMedia *)inputMedia
{ 
    bool isChannel = false;
    Api70_InputPeer *inputPeer = [self inputPeerForPeerId:peerId users:users isChannel:&isChannel];
    if (inputPeer == nil)
        return [SSignal fail:nil];
    
    int64_t randomId = 0;
    arc4random_buf(&randomId, 8);
    int32_t flags = 0;
    if (isChannel)
        flags |= 16;
    flags |= (1 << 6);
    
    return [context function:[Api70 messages_sendMediaWithFlags:@(flags) peer:inputPeer replyToMsgId:@(0) media:inputMedia randomId:@(randomId) replyMarkup:nil]];
}

@end
