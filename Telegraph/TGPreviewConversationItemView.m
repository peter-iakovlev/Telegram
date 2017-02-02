#import "TGPreviewConversationItemView.h"

@interface TGPreviewConversationItemView ()
{
    UIViewController *_controller;
}
@end

@implementation TGPreviewConversationItemView

- (instancetype)initWithConversationController:(UIViewController *)controller
{
    self = [self init];
    if (self != nil)
    {
        _controller = controller;
        self.userInteractionEnabled = false;
        [self addSubview:_controller.view];
    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)__unused width screenHeight:(CGFloat)screenHeight
{
    return screenHeight - 120;
}

- (void)layoutSubviews
{
    _controller.view.frame = self.bounds;
}

@end
