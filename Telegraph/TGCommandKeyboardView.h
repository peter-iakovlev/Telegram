#import <UIKit/UIKit.h>

@class TGBotReplyMarkup;

@interface TGCommandKeyboardView : UIView

@property (nonatomic, copy) void (^commandActivated)(NSString *, int32_t userId, int32_t messageId);

- (void)setReplyMarkup:(TGBotReplyMarkup *)replyMarkup;
- (void)animateTransitionIn;

@end
