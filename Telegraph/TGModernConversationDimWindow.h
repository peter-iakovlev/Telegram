#import <UIKit/UIKit.h>

@interface TGModernConversationDimWindow : UIWindow

@property (nonatomic, copy) void (^dimTapped)(void);

- (void)setDimFrame:(CGRect)frame;
- (void)setDimAlpha:(CGFloat)alpha;

@end
