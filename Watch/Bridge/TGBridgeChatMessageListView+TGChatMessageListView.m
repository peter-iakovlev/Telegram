#import "TGBridgeChatMessageListView+TGChatMessageListView.h"
#import "TGBridgeMessage+TGMessage.h"
#import "TGChatMessageListView.h"
#import "TGConversation.h"

@implementation TGBridgeChatMessageListView (TGChatMessageListView)

+ (TGBridgeChatMessageListView *)chatMessageListViewWithTGChatMessageListView:(TGChatMessageListView *)messageListView conversation:(TGConversation *)conversation
{
    TGBridgeChatMessageListView *bridgeMessageListView = [[TGBridgeChatMessageListView alloc] init];
    
    NSMutableArray *bridgeMessages = [[NSMutableArray alloc] init];
    NSArray *clippedMessages = messageListView.clippedMessages;
    for (TGMessage *message in clippedMessages)
    {
        TGBridgeMessage *bridgeMessage = (messageListView.isChannel && !messageListView.isChannelGroup) ? [TGBridgeMessage channelMessageWithTGMessage:message conversation:conversation] : [TGBridgeMessage messageWithTGMessage:message conversation:conversation];
        if (bridgeMessage != nil)
            [bridgeMessages addObject:bridgeMessage];
    }
    
    bridgeMessageListView->_messages = bridgeMessages;
    bridgeMessageListView->_earlierReferenceMessageId = messageListView.earlierReferenceMessageId;
    bridgeMessageListView->_laterReferenceMessageId = messageListView.laterReferenceMessageId;
    
    return bridgeMessageListView;
}

@end
