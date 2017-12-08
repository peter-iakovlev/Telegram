#import "TGConversationScrollButton.h"

@interface TGConversationScrollButtonContainer : UIView

@property (nonatomic) bool displayDownButton;
@property (nonatomic) int32_t unreadMessageCount;
@property (nonatomic) int32_t unseenMentionCount;

@property (nonatomic, copy) void (^onDown)();
@property (nonatomic, copy) void (^onMentions)();
@property (nonatomic, copy) void (^onMentionsMenu)();

@property (nonatomic, strong, readonly) TGConversationScrollButton *downButton;
@property (nonatomic, strong, readonly) TGConversationScrollButton *mentionsButton;

@end
