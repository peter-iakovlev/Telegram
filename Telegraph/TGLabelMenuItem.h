/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMenuItem.h"

#define TGLabelMenuItemType ((int)0x1014A51A)
#define TGLabelMenuItemType ((int)0x1014A51A)

@interface TGLabelMenuItem : TGMenuItem

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) UIColor *color;

- (id)initWithLabel:(NSString *)label;

@end
