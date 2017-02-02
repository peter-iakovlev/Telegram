#import "TGChatActionsController.h"
#import "TGAppDelegate.h"
#import "TGOverlayControllerWindow.h"

#import "TGViewController.h"
#import "TGForceTouchGestureRecognizer.h"

#import "TGChatActionsView.h"

NSString *const TGChatActionsSourceRectKey = @"sourceRect";
NSString *const TGChatActionsAvatarSnapshotKey = @"avatarSnapshot";

@interface TGChatActionsHandle ()
{
    __weak TGViewController *_parentController;
    UIView *_view;
    TGChatActionsController *_controller;
    TGForceTouchGestureRecognizer *_gestureRecognizer;
}

@property (nonatomic, copy) TGConversation *(^conversationBlock)(CGPoint gestureLocation);
@property (nonatomic, copy) NSDictionary *(^parametersBlock)(TGConversation *conversation);

- (instancetype)initWithParentController:(TGViewController *)controller view:(UIView *)view;

@end


@interface TGChatActionsController ()
{
    TGConversation *_conversation;
    
    CGRect _initialFrame;
    TGChatActionsView *_actionsView;
}

@property (nonatomic, copy) NSDictionary *(^parametersBlock)(TGConversation *conversation);

@end

@implementation TGChatActionsController

- (instancetype)initWithParentController:(TGViewController *)parentController conversation:(TGConversation *)conversation parametersBlock:(NSDictionary *(^)(TGConversation *))parametersBlock
{
    self = [super init];
    if (self != nil)
    {
        _conversation = conversation;
        self.parametersBlock = parametersBlock;
        
        TGOverlayControllerWindow *window = [[TGOverlayControllerWindow alloc] initWithParentController:parentController contentController:self keepKeyboard:true];
        window.windowLevel = 100000000.0f;
        window.hidden = false;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    NSDictionary *parameters = self.parametersBlock(_conversation);
    _initialFrame = [parameters[TGChatActionsSourceRectKey] CGRectValue];
    
    _actionsView = [[TGChatActionsView alloc] initWithAvatarSnapshotView:parameters[TGChatActionsAvatarSnapshotKey]];
    _actionsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _actionsView.frame = self.view.bounds;
    [self.view addSubview:_actionsView];
}

- (void)viewDidLayoutSubviews
{
    self.view.frame = TGAppDelegateInstance.rootController.applicationBounds;
}

- (void)viewDidAppear:(BOOL)__unused animated
{
    [_actionsView initializeAppearWithRect:_initialFrame];
}

+ (TGChatActionsHandle *)setupActionsControllerForParentController:(TGViewController *)parentController view:(UIView *)view conversationForLocation:(TGConversation *(^)(CGPoint gestureLocation))conversationBlock parametersForConversation:(NSDictionary *(^)(TGConversation *))parametersBlock
{
    TGChatActionsHandle *handle = [[TGChatActionsHandle alloc] initWithParentController:parentController view:view];
    handle.conversationBlock = conversationBlock;
    handle.parametersBlock = parametersBlock;
    
    return handle;
}

@end


@implementation TGChatActionsHandle

- (instancetype)initWithParentController:(TGViewController *)controller view:(UIView *)view
{
    self = [super init];
    if (self != nil)
    {
        _parentController = controller;
        _view = view;
        
        _gestureRecognizer = [[TGForceTouchGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouch:)];
        [_view addGestureRecognizer:_gestureRecognizer];
    }
    return self;
}

- (void)dealloc
{
    [_view removeGestureRecognizer:_gestureRecognizer];
}

- (void)handleTouch:(TGForceTouchGestureRecognizer *)__unused gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:_view];
    
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            TGConversation *conversation = self.conversationBlock(location);
            if (conversation == nil)
                return;
            
            _controller = [[TGChatActionsController alloc] initWithParentController:_parentController conversation:conversation parametersBlock:self.parametersBlock];
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            
        }
            break;
            
        case UIGestureRecognizerStateRecognized:
        {
            [_controller presentAnimated:true];
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
        {
            
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:_view];
    if (self.conversationBlock(location) == nil)
        return false;
    
    return true;
}

@end

