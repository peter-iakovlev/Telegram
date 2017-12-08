#import "TGShareSheetWindow.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGAppDelegate.h"

@interface TGShareSheetController : TGOverlayWindowViewController
{
}

@property (nonatomic, weak) TGShareSheetWindow *attachmentSheetWindow;
@property (nonatomic, strong) TGShareSheetView *attachmentSheetView;

@end

@implementation TGShareSheetController

- (void)loadView
{
    [super loadView];
    self.view.userInteractionEnabled = true;
    
    UIEdgeInsets safeAreaInset = [TGViewController safeAreaInsetForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    if (safeAreaInset.bottom > FLT_EPSILON)
        safeAreaInset.bottom -= 22;
    
    TGShareSheetView *attachmentSheetView = [[TGShareSheetView alloc] initWithFrame:CGRectZero];
    attachmentSheetView.safeAreaInset = safeAreaInset;
    [self setAttachmentSheetView:attachmentSheetView];
}

- (void)setAttachmentSheetView:(TGShareSheetView *)attachmentSheetView
{
    [self setAttachmentSheetView:attachmentSheetView stickToBottom:false];
}

- (void)setAttachmentSheetView:(TGShareSheetView *)attachmentSheetView stickToBottom:(bool)stickToBottom
{
    [_attachmentSheetView removeFromSuperview];
    
    UIEdgeInsets safeAreaInset = [TGViewController safeAreaInsetForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    if (safeAreaInset.bottom > FLT_EPSILON)
        safeAreaInset.bottom -= 22;
    
    attachmentSheetView.safeAreaInset = safeAreaInset;
    _attachmentSheetView = attachmentSheetView;
    _attachmentSheetView.frame = self.view.frame;
    _attachmentSheetView.attachmentSheetWindow = _attachmentSheetWindow;
    _attachmentSheetView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_attachmentSheetView];
 
    if (stickToBottom)
        [_attachmentSheetView scrollToBottomAnimated:false];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UIEdgeInsets safeAreaInset = [TGViewController safeAreaInsetForOrientation:toInterfaceOrientation];
    if (safeAreaInset.bottom > FLT_EPSILON)
        safeAreaInset.bottom -= 22;
    
    _attachmentSheetView.safeAreaInset = safeAreaInset;
    
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

@end

@implementation TGShareSheetWindow

- (instancetype)init
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self != nil)
    {
        self.windowLevel = UIWindowLevelStatusBar - 0.003f;
        TGShareSheetController *controller = [[TGShareSheetController alloc] init];
        controller.attachmentSheetWindow = self;
        self.rootViewController = controller;
    }
    return self;
}

- (TGShareSheetView *)view
{
    [self.controller view];
    return self.controller.attachmentSheetView;
}

- (TGShareSheetController *)controller
{
    return (TGShareSheetController *)self.rootViewController;
}

- (void)switchToSheetView:(TGShareSheetView *)sheetView
{
    [self switchToSheetView:sheetView stickToBottom:false];
}

- (void)switchToSheetView:(TGShareSheetView *)sheetView stickToBottom:(bool)stickToBottom
{
    TGShareSheetView *currentSheetView = self.view;
    [currentSheetView animateOutForInterchange:true completion:^
    {
        [currentSheetView removeFromSuperview];
        [self.controller setAttachmentSheetView:sheetView stickToBottom:stickToBottom];
        [sheetView animateInInitial:false];
    }];
}

- (void)showAnimated:(bool)animated completion:(void (^)(void))completion
{
    self.hidden = false;
    
    if (animated)
    {
        [[self view] animateIn];
        
        if (completion != nil)
            completion();
    }
    else
    {
        if (completion != nil)
            completion();
    }
}

- (void)dismissAnimated:(bool)animated completion:(void (^)(void))completion
{
    [self endEditing:true];
    
    if (animated)
    {
        [[self view] animateOut:^
        {
            self.hidden = true;
            
            if (completion != nil)
                completion();
            
            if (self.dismissalBlock != nil)
                self.dismissalBlock();
        }];
    }
    else
    {
        self.hidden = true;
        
        if (completion != nil)
            completion();
        
        if (self.dismissalBlock != nil)
            self.dismissalBlock();
    }
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    
    if (!hidden) {
        [TGAppDelegateInstance.window endEditing:true];
    }
}

@end
