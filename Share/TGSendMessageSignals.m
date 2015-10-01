#import "TGSendMessageSignals.h"

#import "TGUserModel.h"

@implementation TGSendMessageSignals

+ (Api38_InputPeer *)inputPeerForPeerId:(TGPeerId)peerId users:(NSArray *)users
{
    switch (peerId.namespaceId)
    {
        case TGPeerIdPrivate:
        {
            for (TGUserModel *user in users)
            {
                if (user.userId == peerId.peerId)
                {
                    if (user.accessHash == -1)
                        return [Api38_InputPeer inputPeerSelf];
                    else
                        return [Api38_InputPeer inputPeerUserWithUserId:@(user.userId) accessHash:@(user.accessHash)];
                }
            }
        }
        case TGPeerIdGroup:
            return [Api38_InputPeer inputPeerChatWithChatId:@(peerId.peerId)];
        default:
            break;
    }
    return nil;
}

+ (SSignal *)sendTextMessageWithContext:(TGShareContext *)context peerId:(TGPeerId)peerId users:(NSArray *)users text:(NSString *)text
{
    Api38_InputPeer *inputPeer = [self inputPeerForPeerId:peerId users:users];
    if (inputPeer == nil)
        return [SSignal fail:nil];
    
    int64_t randomId = 0;
    arc4random_buf(&randomId, 8);
    return [context function:[Api38 messages_sendMessageWithFlags:@(0) peer:inputPeer replyToMsgId:@(0) message:text randomId:@(randomId) replyMarkup:nil entities:@[]]];
}

+ (SSignal *)sendMediaWithContext:(TGShareContext *)context peerId:(TGPeerId)peerId users:(NSArray *)users inputMedia:(Api38_InputMedia *)inputMedia
{
    Api38_InputPeer *inputPeer = [self inputPeerForPeerId:peerId users:users];
    if (inputPeer == nil)
        return [SSignal fail:nil];
    
    int64_t randomId = 0;
    arc4random_buf(&randomId, 8);
    return [context function:[Api38 messages_sendMediaWithFlags:@(0) peer:inputPeer replyToMsgId:@(0) media:inputMedia randomId:@(randomId) replyMarkup:nil]];
}

@end
