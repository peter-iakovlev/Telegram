#import <UIKit/UIKit.h>

@class TGConversation;

@interface TGChatActionsInfoView : UIButton

- (instancetype)initWithConversation:(TGConversation *)conversation;

@end
