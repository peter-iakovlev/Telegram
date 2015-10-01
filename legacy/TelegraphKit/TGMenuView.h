/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "ASWatcher.h"

@interface TGMenuView : UIView

- (void)setUserInfo:(NSDictionary *)userInfo;
- (void)setButtonsAndActions:(NSArray *)buttonsAndActions watcherHandle:(ASHandle *)watcherHandle;

@end

@interface TGMenuContainerView : UIView

@property (nonatomic, strong) TGMenuView *menuView;

@property (nonatomic, readonly) bool isShowingMenu;
@property (nonatomic) CGRect showingMenuFromRect;

- (void)showMenuFromRect:(CGRect)rect;
- (void)showMenuFromRect:(CGRect)rect animated:(bool)animated;
- (void)hideMenu;

@end
