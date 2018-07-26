#import <UIKit/UIKit.h>

@class TGPresentation;

@protocol TGModernConversationKeyboardView <NSObject>

@property (nonatomic, assign) UIEdgeInsets safeAreaInset;
@property (nonatomic, strong) TGPresentation *presentation;

- (void)setVisible:(bool)visible animated:(bool)animated;
- (bool)isInteracting;
- (bool)isExpanded;
- (void)setExpanded:(bool)expanded;
- (CGFloat)preferredHeight:(bool)landscape;

@end

