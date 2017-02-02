/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGRTLScreenEdgePanGestureRecognizer.h"

#import "TGModernConversationInputMicButton.h"
#import "TGModernConversationInputAttachButton.h"

#import "Freedom.h"

const char *TGRTLScreenEdgePanGestureRecognizerDelegateEnableGestureKey = "TGRTLScreenEdgePanGestureRecognizerDelegateEnableGestureKey";

@implementation TGRTLScreenEdgePanGestureRecognizer

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch != nil) {
        CGPoint location = [touch locationInView:self.view];
        UIView *targetView = [self.view hitTest:location withEvent:event];
        if ([targetView isKindOfClass:[TGModernConversationInputMicButton class]] || [targetView isKindOfClass:[TGModernConversationInputAttachButton class]]) {
            self.state = UIGestureRecognizerStateFailed;
            return;
        }
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void)setState:(UIGestureRecognizerState)state {
    [super setState:state];
}

@end

@implementation TGRTLScreenEdgePanGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(id)arg1 shouldReceiveTouch:(id)arg2 {
    static BOOL (*nativeImpl)(id, SEL, id, id) = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nativeImpl = (BOOL (*)(id, SEL, id, id))freedomNativeImpl([[self class] superclass], _cmd);
    });
    
    if (nativeImpl != NULL) {
        return nativeImpl(self, _cmd, arg1, arg2);
    }
    
    return true;
}

@end
