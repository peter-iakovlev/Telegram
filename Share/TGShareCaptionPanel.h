#import "TGShareGrowingTextView.h"

@protocol TGShareCaptionPanelDelegate;


@interface TGShareCaptionPanel : UIView

@property (nonatomic, weak) id<TGShareCaptionPanelDelegate> delegate;

@property (nonatomic, strong) NSString *caption;
- (void)setCaption:(NSString *)caption animated:(bool)animated;

@property (nonatomic, readonly) TGShareGrowingTextView *inputField;

@property (nonatomic, assign, getter=isCollapsed) bool collapsed;
- (void)setCollapsed:(bool)collapsed animated:(bool)animated;

- (void)adjustForOrientation:(UIInterfaceOrientation)orientation keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(NSInteger)animationCurve;

- (void)dismiss;

- (CGFloat)heightForInputFieldHeight:(CGFloat)inputFieldHeight;
- (CGFloat)baseHeight;

- (void)setContentAreaHeight:(CGFloat)contentAreaHeight;

@end


@protocol TGShareCaptionPanelDelegate <NSObject>

- (bool)inputPanelShouldBecomeFirstResponder:(TGShareCaptionPanel *)inputPanel;
- (void)inputPanelFocused:(TGShareCaptionPanel *)inputPanel;
- (void)inputPanelRequestedSend:(TGShareCaptionPanel *)inputPanel text:(NSString *)text;
- (void)inputPanelWillChangeHeight:(TGShareCaptionPanel *)inputPanel height:(CGFloat)height duration:(NSTimeInterval)duration animationCurve:(int)animationCurve;

@optional
- (void)inputPanelTextChanged:(TGShareCaptionPanel *)inputTextPanel text:(NSString *)text;

@end
