#import <UIKit/UIKit.h>

@protocol TGModernConversationKeyboardView <NSObject>

@property (nonatomic, assign) UIEdgeInsets safeAreaInset;

- (void)setVisible:(bool)visible animated:(bool)animated;
- (bool)isInteracting;
- (bool)isExpanded;
- (void)setExpanded:(bool)expanded;
- (CGFloat)preferredHeight:(bool)landscape;

@end

