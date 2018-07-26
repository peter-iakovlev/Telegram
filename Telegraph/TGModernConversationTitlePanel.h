#import <UIKit/UIKit.h>

@class TGPresentation;

@interface TGModernConversationTitlePanel : UIView

@property (nonatomic, strong) TGPresentation *presentation;
@property (nonatomic, assign) UIEdgeInsets safeAreaInset;

- (void)viewWillAppear;
- (void)viewDidDisappear;

@end
