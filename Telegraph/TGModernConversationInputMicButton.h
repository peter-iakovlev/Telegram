/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@class TGModernConversationInputMicButton;

@protocol TGModernConversationInputMicButtonDelegate <NSObject>

@optional

- (void)micButtonInteractionBegan;
- (void)micButtonInteractionCancelled:(CGFloat)velocity;
- (void)micButtonInteractionCompleted:(CGFloat)velocity;
- (void)micButtonInteractionUpdate:(CGFloat)value;

@end

@interface TGModernConversationInputMicButton : UIButton

@property (nonatomic, weak) id<TGModernConversationInputMicButtonDelegate> delegate;

@property (nonatomic, strong) UIImageView *iconView;

- (void)animateIn;
- (void)animateOut;
- (void)addMicLevel:(CGFloat)level;

@end
