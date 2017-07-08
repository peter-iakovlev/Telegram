#import "TGModernConversationKeyboardView.h"

@class TGBotReplyMarkup;
@class TGBotReplyMarkupButton;

@interface TGCommandKeyboardView : UIView <TGModernConversationKeyboardView>

@property (nonatomic, assign) bool matchDefaultHeight;

@property (nonatomic, copy) void (^commandActivated)(TGBotReplyMarkupButton *, int32_t userId, int32_t messageId);

- (void)setReplyMarkup:(TGBotReplyMarkup *)replyMarkup;
- (void)animateTransitionIn;

@end
