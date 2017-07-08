#import <UIKit/UIKit.h>

@protocol TGModernConversationKeyboardView <NSObject>

- (bool)isInteracting;
- (bool)isExpanded;
- (void)setExpanded:(bool)expanded;
- (CGFloat)preferredHeight:(bool)landscape;

@end

