#import <UIKit/UIKit.h>

typedef void (^TGSharePasscodeViewVerifyBlock)(NSString *, void (^)(bool));

@interface TGSharePasscodeView : UIView

- (instancetype)initWithSimpleMode:(bool)simpleMode cancel:(void (^)())cancel verify:(TGSharePasscodeViewVerifyBlock)verify alertPresentationController:(UIViewController *)alertPresentationController;

- (void)showKeyboard;

@end
