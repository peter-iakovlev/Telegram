/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCollectionItem.h"

@interface TGCommentCollectionItem : TGCollectionItem

@property (nonatomic) bool skipLastLineInSizeComputation;
@property (nonatomic) CGFloat topInset;
@property (nonatomic) CGFloat bottomInset;
@property (nonatomic) CGFloat alpha;
@property (nonatomic) bool hidden;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) NSString *text;
@property (nonatomic) bool showProgress;
@property (nonatomic, copy) void (^action)();

- (instancetype)initWithText:(NSString *)text;
- (instancetype)initWithFormattedText:(NSString *)text;
- (instancetype)initWithFormattedText:(NSString *)text paragraphSpacing:(CGFloat)paragraphSpacing clearFormatting:(bool)clearFormatting;
- (void)setFormattedText:(NSString *)formattedText;

+ (NSAttributedString *)attributedStringFromText:(NSString *)text allowFormatting:(bool)allowFormatting paragraphSpacing:(CGFloat)paragraphSpacing;
+ (NSAttributedString *)attributedStringFromText:(NSString *)text allowFormatting:(bool)allowFormatting paragraphSpacing:(CGFloat)paragraphSpacing alignment:(NSTextAlignment)alignment fontSize:(CGFloat)fontSize clearFormatting:(bool)clearFormatting;

@end
