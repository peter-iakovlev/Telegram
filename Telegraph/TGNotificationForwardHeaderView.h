#import <UIKit/UIKit.h>

@class TGForwardedMessageMediaAttachment;

@interface TGNotificationForwardHeaderView : UIView

- (instancetype)initWithAttachment:(TGForwardedMessageMediaAttachment *)attachment peers:(NSDictionary *)peers;

@end

extern const CGFloat TGNotificationForwardHeaderHeight;
