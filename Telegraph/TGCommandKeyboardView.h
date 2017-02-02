#import <UIKit/UIKit.h>

@class TGBotReplyMarkup;
@class TGBotReplyMarkupButton;

@interface TGCommandKeyboardView : UIView

@property (nonatomic, copy) void (^commandActivated)(TGBotReplyMarkupButton *, int32_t userId, int32_t messageId);

- (void)setReplyMarkup:(TGBotReplyMarkup *)replyMarkup;
- (void)animateTransitionIn;

@end
