#import <UIKit/UIKit.h>

@class TGBotReplyMarkup;

@interface TGNotificationReplyButtonsView : UIView

@property (nonatomic, copy) void (^activateCommand)(id action, NSInteger index);

- (void)setReplyMarkup:(TGBotReplyMarkup *)replyMarkup;

- (CGFloat)heightForWidth:(CGFloat)width;

@end
