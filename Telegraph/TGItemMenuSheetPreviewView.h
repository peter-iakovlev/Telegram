#import "TGItemPreviewView.h"

@interface TGItemMenuSheetPreviewView : TGItemPreviewView
{
    UIView *_containerView;
}

@property (nonatomic, assign) bool presentActionsImmediately;
@property (nonatomic, assign) bool dontBlurOnPresentation;
@property (nonatomic, readonly) bool actionsPresented;

- (instancetype)initWithMainItemViews:(NSArray *)mainItemViews actionItemViews:(NSArray *)actionItemViews;
- (void)setupWithMainItemViews:(NSArray *)mainItemViews actionItemViews:(NSArray *)actionItemViews;

- (void)setActionItemViews:(NSArray *)actionsView animated:(bool)animated;

- (void)performCommit;
- (void)performDismissal;

- (void)presentActions:(void (^)(void))animationBlock;

@end
