#import <UIKit/UIKit.h>

@class TGReplyMessageMediaAttachment;

@interface TGNotificationReplyHeaderView : UIView

- (instancetype)initWithAttachment:(TGReplyMessageMediaAttachment *)attachment peers:(NSDictionary *)peers;

@end

extern const CGFloat TGNotificationReplyHeaderHeight;