/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "TGButtonMenuItem.h"

#import "ASWatcher.h"

@interface TGButtonMenuItemCell : UITableViewCell

@property (nonatomic, strong) ASHandle *watcherHandle;
@property (nonatomic, strong) id itemId;

- (void)setTitle:(NSString *)title;
- (void)setSubtype:(TGButtonMenuItemSubtype)subtype;
- (void)setEnabled:(bool)enabled;
- (void)setTitleIcon:(UIImage *)icon;

- (void)updateFrame;

- (void)setContentHidden:(bool)hidden;

@end
