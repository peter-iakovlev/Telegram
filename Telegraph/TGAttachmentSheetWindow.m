#import "TGAttachmentSheetWindow.h"

#import "TGNotificationWindow.h"
#import "TGAppDelegate.h"

@interface TGAttachmentSheetController : TGOverlayWindowViewController
{
}

@property (nonatomic, weak) TGAttachmentSheetWindow *attachmentSheetWindow;
@property (nonatomic, strong) TGAttachmentSheetView *attachmentSheetView;

@end

@implementation TGAttachmentSheetController

- (void)loadView
{
    [super loadView];
    self.view.userInteractionEnabled = true;
    
    TGAttachmentSheetView *attachmentSheetView = [[TGAttachmentSheetView alloc] initWithFrame:CGRectZero];
    [self setAttachmentSheetView:attachmentSheetView];
}

- (void)setAttachmentSheetView:(TGAttachmentSheetView *)attachmentSheetView
{
    [self setAttachmentSheetView:attachmentSheetView stickToBottom:false];
}

- (void)setAttachmentSheetView:(TGAttachmentSheetView *)attachmentSheetView stickToBottom:(bool)stickToBottom
{
    [_attachmentSheetView removeFromSuperview];
    
    _attachmentSheetView = attachmentSheetView;
    _attachmentSheetView.frame = self.view.frame;
    _attachmentSheetView.attachmentSheetWindow = _attachmentSheetWindow;
    _attachmentSheetView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_attachmentSheetView];
    
    if (stickToBottom)
        [_attachmentSheetView scrollToBottomAnimated:false];
}

@end

@implementation TGAttachmentSheetWindow

- (instancetype)init
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self != nil)
    {
        self.windowLevel = UIWindowLevelStatusBar - 0.003f;
        TGAttachmentSheetController *controller = [[TGAttachmentSheetController alloc] init];
        controller.attachmentSheetWindow = self;
        self.rootViewController = controller;
    }
    return self;
}

- (TGAttachmentSheetView *)view
{
    [self.controller view];
    return self.controller.attachmentSheetView;
}

- (TGAttachmentSheetController *)controller
{
    return (TGAttachmentSheetController *)self.rootViewController;
}

- (void)switchToSheetView:(TGAttachmentSheetView *)sheetView
{
    [self switchToSheetView:sheetView stickToBottom:false];
}

- (void)switchToSheetView:(TGAttachmentSheetView *)sheetView stickToBottom:(bool)stickToBottom
{
    TGAttachmentSheetView *currentSheetView = self.view;
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
