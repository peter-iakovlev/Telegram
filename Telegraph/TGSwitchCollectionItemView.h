/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCollectionItemView.h"

@class TGSwitchCollectionItemView;

@protocol TGSwitchCollectionItemViewDelegate <NSObject>

@optional

- (void)switchCollectionItemViewChangedValue:(TGSwitchCollectionItemView *)switchItemView isOn:(bool)isOn;

@end

@interface TGSwitchCollectionItemView : TGCollectionItemView

@property (nonatomic, weak) id<TGSwitchCollectionItemViewDelegate> delegate;

- (void)setFullSeparator:(bool)fullSeparator;
- (void)setTitle:(NSString *)title;
- (void)setIsOn:(bool)isOn animated:(bool)animated;
- (void)setIsEnabled:(bool)isEnabled;

@end

@interface TGPermissionSwitchCollectionItemView : TGSwitchCollectionItemView

@end
