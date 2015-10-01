#import "TGBridgeChatMessageListView.h"

@class TGChatMessageListView;

@interface TGBridgeChatMessageListView (TGChatMessageListView)

+ (TGBridgeChatMessageListView *)chatMessageListViewWithTGChatMessageListView:(TGChatMessageListView *)messageListView isChannel:(bool)isChannel;

@end
