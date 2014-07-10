/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMenuItem.h"

#define TGButtonMenuItemType ((int)0x8D6839FC)

typedef enum {
    TGButtonMenuItemSubtypeRedButton = 0,
    TGButtonMenuItemSubtypeGrayButton = 1,
    TGButtonMenuItemSubtypeGreenButton = 2
} TGButtonMenuItemSubtype;

@interface TGButtonMenuItem : TGMenuItem

@property (nonatomic, strong) NSString *title;
@property (nonatomic) TGButtonMenuItemSubtype subtype;
@property (nonatomic) SEL action;
@property (nonatomic) bool enabled;
@property (nonatomic, strong) UIImage *titleIcon;

- (id)initWithTitle:(NSString *)title subtype:(TGButtonMenuItemSubtype)subtype;

@end
