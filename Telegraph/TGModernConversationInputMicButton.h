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
- (void)micButtonInteractionCancelled:(CGPoint)velocity;
- (void)micButtonInteractionCompleted:(CGPoint)velocity;
- (void)micButtonInteractionUpdate:(CGPoint)value;
- (void)micButtonInteractionLocked;
- (void)micButtonInteractionRequestedLockedAction;
- (void)micButtonInteractionStopped;

- (bool)micButtonShouldLock;

@end

@interface TGModernConversationInputMicButton : UIButton

@property (nonatomic, weak) id<TGModernConversationInputMicButtonDelegate> delegate;

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, assign) bool blocking;
@property (nonatomic, readonly) bool locked;
@property (nonatomic) bool fadeDisabled;

- (void)animateIn;
- (void)animateOut;
- (void)addMicLevel:(CGFloat)level;

- (void)updateOverlay;

- (void)_commitLocked;

@end
