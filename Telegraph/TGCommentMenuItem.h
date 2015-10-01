/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMenuItem.h"

#define TGCommentMenuItemType ((int)0x68CFA5DE)

@interface TGCommentMenuItem : TGMenuItem

@property (nonatomic, strong) NSString *comment;

- (id)initWithComment:(NSString *)comment;

- (CGFloat)heightForWidth:(float)width;

@end
