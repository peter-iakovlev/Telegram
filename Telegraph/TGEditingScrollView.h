/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@class TGEditingScrollView;

@protocol TGEditingScrollViewDelegate <NSObject>

@required

- (void)editingScrollViewOptionsOffsetChanged:(TGEditingScrollView *)editingScrollView;

@optional

- (void)editingScrollViewWillRevealOptions:(TGEditingScrollView *)editingScrollView;
- (void)editingScrollViewDidHideOptions:(TGEditingScrollView *)editingScrollView;

@end

@interface TGEditingScrollView : UIScrollView

@property (nonatomic, weak) id<TGEditingScrollViewDelegate> editingDelegate;

@property (nonatomic) bool optionsAreRevealed;
@property (nonatomic) bool lockScroll;
@property (nonatomic) bool disableScroll;

- (void)setOptionsAreRevealed:(bool)optionsAreRevealed animated:(bool)animated;

- (CGFloat)optionsWidth;

@end
