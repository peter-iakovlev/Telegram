#import "TGModernViewModel.h"

#import "TGModernViewContext.h"

@class TGBotReplyMarkup;
@class TGBotReplyMarkupButton;

@interface TGMessageReplyButtonsModel : TGModernViewModel

@property (nonatomic, copy) void (^buttonActivated)(TGBotReplyMarkupButton *, NSInteger);
@property (nonatomic) NSUInteger buttonIndexInProgress;

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition;
- (CGFloat)minimumWidth;

- (void)setReplyMarkup:(TGBotReplyMarkup *)replyMarkup hasReceipt:(bool)hasReceipt;

@end
