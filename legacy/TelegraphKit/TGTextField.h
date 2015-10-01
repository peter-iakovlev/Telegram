/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@interface TGTextField : UITextField

@property (nonatomic) CGFloat editingRectOffset;

@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, strong) UIFont *placeholderFont;

@property (nonatomic) CGFloat leftInset;
@property (nonatomic) CGFloat rightInset;

@property (nonatomic, copy) void (^movedToWindow)();

@end
