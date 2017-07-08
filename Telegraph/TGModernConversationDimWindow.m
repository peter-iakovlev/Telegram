#import "TGModernConversationDimWindow.h"

#import "TGOverlayController.h"

@interface TGModernConversationDimController : TGOverlayController

@property (nonatomic, readonly) UIButton *dimView;
@property (nonatomic, copy) void (^dimTapped)(void);

@end

@implementation TGModernConversationDimController

- (void)loadView
{
    [super loadView];
    
    _dimView = [[UIButton alloc] initWithFrame:self.view.bounds];
    _dimView.alpha = 0.0f;
    _dimView.backgroundColor = UIColorRGBA(0x000000, 0.6f);
    [_dimView addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_dimView];
}

- (void)tapped
{
    if (self.dimTapped != nil)
        self.dimTapped();
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self.view.window.layer removeAnimationForKey:@"backgroundColor"];
    [CATransaction begin];
    [CATransaction setDisableActions:true];
    self.view.window.layer.backgroundColor = [UIColor clearColor].CGColor;
    [CATransaction commit];
    
    for (UIView *view in self.view.window.subviews)
    {
        if (view != self.view)
        {
            [view removeFromSuperview];
            break;
        }
    }
}

@end

@implementation TGModernConversationDimWindow

@dynamic dimTapped;

- (instancetype)init
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self != nil)
    {
        self.rootViewController = [[TGModernConversationDimController alloc] init];
        self.windowLevel = 100000000.0f - 0.001f;
        self.hidden = false;
    }
    return self;
}

- (void)setDimFrame:(CGRect)frame
{
    ((TGModernConversationDimController *)self.rootViewController).dimView.frame = frame;
}

- (void)setDimAlpha:(CGFloat)alpha
{
    ((TGModernConversationDimController *)self.rootViewController).dimView.alpha = alpha;
}

- (void)setDimTapped:(void (^)(void))dimTapped
{
    ((TGModernConversationDimController *)self.rootViewController).dimTapped = [dimTapped copy];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *result = [super hitTest:point withEvent:event];
    if (result == self.rootViewController.view)
        return nil;
    
    return result;
}

@end
