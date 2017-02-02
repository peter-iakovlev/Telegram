/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernViewModel.h"

#import <CoreText/CoreText.h>

@interface TGModernTextViewLinesInset : NSObject

@property (nonatomic, readonly) NSUInteger numberOfLinesToInset;
@property (nonatomic, readonly) CGFloat inset;

- (instancetype)initWithNumberOfLinesToInset:(NSUInteger)numberOfLinesToInset inset:(CGFloat)inset;

@end

@interface TGModernTextViewModel : TGModernViewModel

@property (nonatomic, strong) NSString *text;
@property (nonatomic) CTFontRef font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic) NSUInteger maxNumberOfLines;
@property (nonatomic, strong) NSArray *textCheckingResults;
@property (nonatomic) NSTextAlignment alignment;
@property (nonatomic) int layoutFlags;
@property (nonatomic) CGFloat additionalTrailingWidth;
@property (nonatomic, strong) NSArray *additionalAttributes;
@property (nonatomic) CGFloat additionalLineSpacing;
@property (nonatomic, readonly) bool isRTL;
@property (nonatomic, strong) TGModernTextViewLinesInset *linesInset;
@property (nonatomic, readonly) bool containsEmptyNewline;
@property (nonatomic, strong) NSString *ellipsisString;

- (instancetype)initWithText:(NSString *)text font:(CTFontRef)font;

- (bool)layoutNeedsUpdatingForContainerSize:(CGSize)containerSize;
- (bool)layoutNeedsUpdatingForContainerSize:(CGSize)containerSize additionalTrailingWidth:(CGFloat)additionalTrailingWidth layoutFlags:(int)layoutFlags;
- (void)layoutForContainerSize:(CGSize)containerSize;
- (NSString *)linkAtPoint:(CGPoint)point regionData:(__autoreleasing NSArray **)regionData;
- (NSString *)linkAtPoint:(CGPoint)point regionData:(__autoreleasing NSArray **)regionData hiddenLink:(bool *)hiddenLink;
- (NSString *)linkAtPoint:(CGPoint)point regionData:(__autoreleasing NSArray **)regionData hiddenLink:(bool *)hiddenLink linkText:(__autoreleasing NSString **)linkText;
- (void)enumerateSearchRegionsForString:(NSString *)string withBlock:(void (^)(CGRect))block;

- (NSUInteger)measuredNumberOfLines;

@end
