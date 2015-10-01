#import "TGBridgeChatMessageListView+TGChatMessageListView.h"
#import "TGBridgeMessage+TGMessage.h"
#import "TGChatMessageListView.h"

@implementation TGBridgeChatMessageListView (TGChatMessageListView)

+ (TGBridgeChatMessageListView *)chatMessageListViewWithTGChatMessageListView:(TGChatMessageListView *)messageListView isChannel:(bool)isChannel
{
    TGBridgeChatMessageListView *bridgeMessageListView = [[TGBridgeChatMessageListView alloc] init];
    
    NSMutableArray *bridgeMessages = [[NSMutableArray alloc] init];
    for (TGMessage *message in messageListView.messages)
    {
        TGBridgeMessage *bridgeMessage = isChannel ? [TGBridgeMessage channelMessageWithTGMessage:message] : [TGBridgeMessage messageWithTGMessage:message];
        if (bridgeMessage != nil)
            [bridgeMessages addObject:bridgeMessage];
    }
    
    bridgeMessageListView->_messages = bridgeMessages;
    bridgeMessageListView->_earlierReferenceMessageId = messageListView.earlierReferenceMessageId;
    bridgeMessageListView->_laterReferenceMessageId = messageListView.laterReferenceMessageId;
    
    return bridgeMessageListView;
}

@end
