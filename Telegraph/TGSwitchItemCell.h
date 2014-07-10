/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "ASWatcher.h"

#import "TGGroupedCell.h"

@interface TGSwitchItemCell : TGGroupedCell

@property (nonatomic, strong) ASHandle *watcherHandle;
@property (nonatomic, strong) id itemId;

@property (nonatomic, strong) NSString *title;
@property (nonatomic) bool isOn;

- (void)setCustomBackgroundColor:(UIColor *)color;

- (void)setIsOn:(bool)isOn animated:(bool)animated;

- (void)fireChangeEvent;

@end
