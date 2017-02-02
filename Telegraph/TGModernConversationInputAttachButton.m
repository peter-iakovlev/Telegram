#import "TGModernConversationInputAttachButton.h"

@interface TGModernConversationInputAttachButton () <UIGestureRecognizerDelegate>

@end

@implementation TGModernConversationInputAttachButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.exclusiveTouch = true;
        self.multipleTouchEnabled = false;
        
        UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        gestureRecognizer.delegate = self;
        gestureRecognizer.minimumPressDuration = 0.22;
        [self addGestureRecognizer:gestureRecognizer];
    }
    return self;
}

- (void)handleGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:nil];
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            if ([self.delegate respondsToSelector:@selector(attachButtonInteractionBegan)])
                [self.delegate attachButtonInteractionBegan];
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            if ([self.delegate respondsToSelector:@selector(attachButtonInteractionUpdate:)])
                [self.delegate attachButtonInteractionUpdate:location];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            if ([self.delegate respondsToSelector:@selector(attachButtonInteractionCompleted:)])
                [self.delegate attachButtonInteractionCompleted:location];
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)__unused gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)__unused otherGestureRecognizer
{
    return true;
}

@end
