/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@class TGModernConversationInputPanel;

@protocol TGModernConversationInputPanelDelegate <NSObject>

- (void)inputPanelWillChangeHeight:(TGModernConversationInputPanel *)inputPanel height:(CGFloat)height duration:(NSTimeInterval)duration animationCurve:(int)animationCurve;

@end

@interface TGModernConversationInputPanel : UIView

@property (nonatomic, weak) id<TGModernConversationInputPanelDelegate> delegate;

- (void)setContentAreaHeight:(CGFloat)contentAreaHeight;
- (void)adjustForSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve contentAreaHeight:(CGFloat)contentAreaHeight;
- (void)changeToSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration contentAreaHeight:(CGFloat)contentAreaHeight;

- (CGFloat)currentHeight;

@end
