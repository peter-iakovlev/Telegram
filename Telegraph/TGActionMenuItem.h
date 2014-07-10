/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMenuItem.h"

#define TGActionMenuItemType ((int)0xD8B4CD4C)

@interface TGActionMenuItem : TGMenuItem

@property (nonatomic, strong) NSString *title;

@property (nonatomic) SEL action;

- (id)initWithTitle:(NSString *)title;

@end
