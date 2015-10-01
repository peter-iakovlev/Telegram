/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCollectionItemView.h"

@interface TGCommentCollectionItemView : TGCollectionItemView

@property (nonatomic) CGFloat topInset;
@property (nonatomic) CGFloat labelAlpha;
@property (nonatomic) CGSize calculatedSize;
@property (nonatomic) bool showProgress;
@property (nonatomic, copy) void (^action)();

- (void)setTextColor:(UIColor *)textColor;
- (void)setAttributedText:(NSAttributedString *)text;

@end
