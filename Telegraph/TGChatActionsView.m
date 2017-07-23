#import "TGChatActionsView.h"
#import "TGChatActionsInfoView.h"
#import "TGChatActionsContainerView.h"

#import "TGAppDelegate.h"

const CGFloat TGChatActionsPeekScale = 0.95f;
const NSTimeInterval TGChatActionsPeekDuration = 0.22;

@interface TGChatActionsView ()
{
    UIVisualEffectView *_blurView;
    UIView *_dimView;
    __weak UIView *_rootView;
    
    UIView *_avatarSnapshotView;
    TGChatActionsInfoView *_infoView;
    TGChatActionsContainerView *_containerView;
}
@end

@implementation TGChatActionsView

- (instancetype)initWithAvatarSnapshotView:(UIView *)avatarSnapshotView
{
    self = [super initWithFrame:CGRectZero];
    if (self != nil)
    {
        _blurView = [[UIVisualEffectView alloc] initWithEffect:nil];
        _blurView.frame = self.bounds;
        [self addSubview:_blurView];
        
        _dimView = [[UIView alloc] initWithFrame:self.bounds];
        _dimView.alpha = 0.0f;
        _dimView.backgroundColor = UIColorRGBA(0x000000, 0.1f);
        [self addSubview:_dimView];
        
        _avatarSnapshotView = avatarSnapshotView;
        [self addSubview:_avatarSnapshotView];

        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 20, 200, 30)];
        [slider addTarget:self action:@selector(test:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:slider];
    }
    return self;
}

- (void)initializeAppearWithRect:(CGRect)rect
{
    _avatarSnapshotView.frame = CGRectMake(CGRectGetMidX(rect) - 55.0f / 2.0f, CGRectGetMidY(rect) - 55.0f / 2.0f, 55.0f, 55.0f);
    
    _rootView = TGAppDelegateInstance.rootController.view;
    _rootView.superview.backgroundColor = [UIColor whiteColor];
    
    _blurView.layer.speed = 0.0f;
}

- (void)test:(UISlider *)sender
{
    [self setTransitionProgress:sender.value];
    
}

- (void)setTransitionProgress:(CGFloat)progress
{
    _blurView.layer.timeOffset = TGChatActionsPeekDuration * progress;
    
    CGFloat scale = 1.0f - (1.0f - TGChatActionsPeekScale) * progress;
    _rootView.transform = CGAffineTransformMakeScale(scale, scale);

    _dimView.alpha = progress;
}

- (void)commitTransition
{
    
}

- (void)layoutSubviews
{
    _blurView.frame = self.bounds;
    _dimView.frame = self.bounds;
}

@end
