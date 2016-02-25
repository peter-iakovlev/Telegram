/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGRTLScreenEdgePanGestureRecognizer.h"

#import "TGModernConversationInputMicButton.h"

@implementation TGRTLScreenEdgePanGestureRecognizer

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch != nil) {
        CGPoint location = [touch locationInView:self.view];
        UIView *targetView = [self.view hitTest:location withEvent:event];
        if ([targetView isKindOfClass:[TGModernConversationInputMicButton class]]) {
            self.state = UIGestureRecognizerStateFailed;
            return;
        }
    }
    
    [super touchesBegan:touches withEvent:event];
}

@end
