#import "TGBridgeChatMessageListView.h"

@class TGChatMessageListView;
@class TGConversation;

@interface TGBridgeChatMessageListView (TGChatMessageListView)

+ (TGBridgeChatMessageListView *)chatMessageListViewWithTGChatMessageListView:(TGChatMessageListView *)messageListView conversation:(TGConversation *)conversation;

@end
