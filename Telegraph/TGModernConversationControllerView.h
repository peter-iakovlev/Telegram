#import <UIKit/UIKit.h>

@interface TGModernConversationControllerView : UIView

@property (nonatomic, copy) void (^layoutForSize)(CGSize size);

@end
