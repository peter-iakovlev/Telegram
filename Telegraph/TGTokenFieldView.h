/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@class TGTokenFieldView;

@protocol TGTokenFieldViewDelegate <NSObject>

- (void)tokenFieldView:(TGTokenFieldView *)tokenFieldView didChangeHeight:(float)height;
- (void)tokenFieldView:(TGTokenFieldView *)tokenFieldView didChangeText:(NSString *)text;
- (void)tokenFieldView:(TGTokenFieldView *)tokenFieldView didChangeSearchStatus:(bool)searchIsActive byClearingTextField:(bool)byClearingTextField;
- (void)tokenFieldView:(TGTokenFieldView *)tokenFieldView didDeleteTokenWithId:(id)tokenId;

@end

@interface TGTokenFieldView : UIView

@property (nonatomic, weak) id<TGTokenFieldViewDelegate> delegate;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSString *placeholder;

- (float)preferredHeight;
- (void)scrollToTextField:(bool)animated;

- (bool)searchIsActive;
- (void)clearText;
- (bool)hasFirstResponder;

- (void)beginTransition:(NSTimeInterval)duration;

- (void)addToken:(NSString *)title tokenId:(id)tokenId animated:(bool)animated;
- (NSArray *)tokenIds;
- (void)removeTokensAtIndexes:(NSIndexSet *)indexSet;

@end
