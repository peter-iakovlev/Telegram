/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@interface TGDateLabel : UILabel

@property (nonatomic, strong) NSString *dateText;
@property (nonatomic, strong) NSString *rawDateText;

@property (nonatomic, strong) UIFont *dateFont;
@property (nonatomic, strong) UIFont *dateTextFont;
@property (nonatomic, strong) UIFont *dateLabelFont;

@property (nonatomic, strong) UIColor *disabledColor;

@property (nonatomic) CGFloat amWidth;
@property (nonatomic) CGFloat pmWidth;
@property (nonatomic) CGFloat dstOffset;

@property (nonatomic) bool isDisabled;

- (CGSize)measureTextSize;

@end
