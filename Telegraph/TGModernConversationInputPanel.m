/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernConversationInputPanel.h"

@implementation TGModernConversationInputPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
    }
    return self;
}

- (void)setContentAreaHeight:(CGFloat)__unused contentAreaHeight {
}

- (void)adjustForSize:(CGSize)__unused size keyboardHeight:(CGFloat)__unused keyboardHeight duration:(NSTimeInterval)__unused duration animationCurve:(int)__unused animationCurve contentAreaHeight:(CGFloat)__unused contentAreaHeight {
}

- (void)changeToSize:(CGSize)__unused size keyboardHeight:(CGFloat)__unused keyboardHeight duration:(NSTimeInterval)__unused duration contentAreaHeight:(CGFloat)__unused contentAreaHeight {
}

- (CGFloat)currentHeight
{
    return self.frame.size.height;
}

@end
