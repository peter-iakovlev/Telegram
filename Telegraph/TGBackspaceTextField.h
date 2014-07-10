/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGTextField.h"

@interface TGBackspaceTextField : TGTextField

@property (nonatomic, strong) UILabel *customPlaceholderLabel;

- (void)setShowPlaceholder:(bool)showPlaceholder animated:(bool)animated;

@end
