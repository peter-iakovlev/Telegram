#import "TGAlertView.h"

#import "TGAppDelegate.h"

@implementation TGAlertViewController

- (void)backgroundTapGesture:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (_backgroundTapped) {
            _backgroundTapped();
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_backgroundTapped && [self.view.superview.subviews.firstObject.backgroundColor isEqual:[UIColor colorWithWhite:0.0 alpha:0.4]]) {
        self.view.superview.subviews.firstObject.userInteractionEnabled = true;
        [self.view.superview.subviews.firstObject addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapGesture:)]];
    }
}

@end

@interface TGAlertView () <UIAlertViewDelegate>

@property (nonatomic, copy) void (^completionBlock)(bool okButtonPressed);

@end

@implementation TGAlertView

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle completionBlock:(void (^)(bool okButtonPressed))completionBlock
{
    return [self initWithTitle:title message:(title == nil && iosMajorVersion() < 9 && iosMajorVersion() >= 8 && iosMinorVersion() < 1) ? [@"\n" stringByAppendingString:message] : message cancelButtonTitle:cancelButtonTitle otherButtonTitles:okButtonTitle == nil ? nil : @[okButtonTitle] completionBlock:completionBlock];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles completionBlock:(void (^)(bool okButtonPressed))completionBlock
{
    self = [super initWithTitle:title message:(title == nil && iosMajorVersion() < 9 && iosMajorVersion() >= 8 && iosMinorVersion() < 1) ? [@"\n" stringByAppendingString:message] : message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    if (self != nil)
    {
        for (NSString *otherButtonTitle in otherButtonTitles)
            [self addButtonWithTitle:otherButtonTitle];
        
        _completionBlock = completionBlock;
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    return [super initWithTitle:title message:(title == nil && iosMajorVersion() < 9 && iosMajorVersion() >= 8 && iosMinorVersion() < 1) ? [@"\n" stringByAppendingString:message] : message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_completionBlock != nil)
        _completionBlock(buttonIndex != alertView.cancelButtonIndex);
}

+ (void)presentAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle completionBlock:(void (^)(bool okButtonPressed))completionBlock {
    [self presentAlertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle okButtonTitle:okButtonTitle completionBlock:completionBlock disableKeyboardWorkaround:false];
}

+ (void)presentAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle completionBlock:(void (^)(bool okButtonPressed))completionBlock disableKeyboardWorkaround:(bool)disableKeyboardWorkaround {
    if (iosMajorVersion() >= 8 && !disableKeyboardWorkaround) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title.length == 0 ? nil : title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        if (title != nil && message.length != 0) {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.alignment = NSTextAlignmentNatural;
            paragraphStyle.lineSpacing = 2.0f;
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:message attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0], NSParagraphStyleAttributeName: paragraphStyle}];
            [alertController setValue:attributedString forKey:@"attributedMessage"];
        }
        
        if (okButtonTitle != nil) {
            UIAlertAction* ok = [UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction * _Nonnull action) {
                if (completionBlock) {
                    completionBlock(true);
                }
            }];
            [alertController addAction:ok];
        }
        
        if (cancelButtonTitle != nil) {
            UIAlertAction* cancel = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(__unused UIAlertAction * _Nonnull action) {
                if (completionBlock) {
                    completionBlock(false);
                }
            }];
            [alertController addAction:cancel];
        }
        
        UIWindow *targetWindow = TGAppDelegateInstance.window;
        if (!disableKeyboardWorkaround) {
            for (UIWindow *window in [UIApplication sharedApplication].windows.reverseObjectEnumerator) {
                if (window.rootViewController != nil && ([NSStringFromClass([window class]) hasPrefix:@"UITextEffec"] || [NSStringFromClass([window class]) hasPrefix:@"UIRemoteKe"])) {
                    targetWindow = window;
                    break;
                }
            }
        }
        UIViewController *controller = targetWindow.rootViewController;
        if (controller.view.window == nil && controller.presentedViewController != nil && !disableKeyboardWorkaround) {
            controller = controller.presentedViewController;
        }
        [controller presentViewController:alertController animated:true completion:nil];
    } else {
        [[[TGAlertView alloc] initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle okButtonTitle:okButtonTitle completionBlock:completionBlock] show];
    }
}

@end
