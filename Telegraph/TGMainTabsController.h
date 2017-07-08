/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "TGViewController.h"

@interface TGMainTabsController : UITabBarController <TGViewControllerNavigationBarAppearance>

- (void)setUnreadCount:(int)unreadCount;
- (void)setMissedCallsCount:(int)callsCount;

- (void)setCallsHidden:(bool)hidden animated:(bool)animated;

- (void)localizationUpdated;

- (CGRect)frameForRightmostTab;
- (UIView *)viewForRightmostTab;

@end
