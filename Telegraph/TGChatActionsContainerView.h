#import <UIKit/UIKit.h>

@interface TGChatActionsContainerView : UIView

@property (nonatomic, assign) bool invertOrder;

- (instancetype)initWithItems:(NSArray *)items;

- (CGFloat)preferredHeight;

@end
