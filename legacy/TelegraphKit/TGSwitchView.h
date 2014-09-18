/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@class TGSwitchView;

@protocol TGSwitchViewDelegate <NSObject>

- (void)switchView:(TGSwitchView *)switchView didChangeIsOn:(bool)isOn;

@end

@interface TGSwitchView : UIView

@property (nonatomic, weak) id<TGSwitchViewDelegate> delegate;

@property (nonatomic) bool isOn;

- (void)setOn:(bool)on animated:(bool)animated;
- (void)setOn:(bool)on animated:(bool)animated notifyOnCompletion:(bool)notifyOnCompletion;

@end
