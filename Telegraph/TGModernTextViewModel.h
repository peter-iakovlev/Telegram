/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernViewModel.h"

#import <CoreText/CoreText.h>

@interface TGModernTextViewModel : TGModernViewModel

@property (nonatomic, strong) NSString *text;
@property (nonatomic) CTFontRef font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic) int lineCount;
@property (nonatomic, strong) NSArray *textCheckingResults;
@property (nonatomic) NSTextAlignment alignment;
@property (nonatomic) int layoutFlags;
@property (nonatomic) CGFloat additionalTrailingWidth;
@property (nonatomic, strong) NSArray *additionalAttributes;
@property (nonatomic, readonly) bool isRTL;

- (instancetype)initWithText:(NSString *)text font:(CTFontRef)font;

- (bool)layoutNeedsUpdatingForContainerSize:(CGSize)containerSize;
- (void)layoutForContainerSize:(CGSize)containerSize;
- (NSString *)linkAtPoint:(CGPoint)point regionData:(__autoreleasing NSArray **)regionData;

@end
