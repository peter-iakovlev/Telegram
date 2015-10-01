/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@class TGButtonGroupView;

@protocol TGButtonGroupViewDelegate <NSObject>

- (void)buttonGroupViewButtonPressed:(TGButtonGroupView *)buttonGroupView index:(int)index;

@end

@interface TGButtonGroupView : UIView

@property (nonatomic, weak) id<TGButtonGroupViewDelegate> delegate;

@property (nonatomic) bool isLandscape;

@property (nonatomic) int selectedIndex;

@property (nonatomic, strong) UIImage *buttonLeftImage;
@property (nonatomic, strong) UIImage *buttonLeftHighlightedImage;
@property (nonatomic, strong) UIImage *buttonCenterImage;
@property (nonatomic, strong) UIImage *buttonCenterHighlightedImage;
@property (nonatomic, strong) UIImage *buttonRightImage;
@property (nonatomic, strong) UIImage *buttonRightHighlightedImage;
@property (nonatomic, strong) UIImage *buttonSeparatorImage;
@property (nonatomic, strong) UIImage *buttonSeparatorLeftHighlightedImage;
@property (nonatomic, strong) UIImage *buttonSeparatorRightHighlightedImage;

@property (nonatomic, strong) UIFont *buttonFont;
@property (nonatomic, strong) UIColor *buttonTextColor;
@property (nonatomic, strong) UIColor *buttonTextColorHighlighted;
@property (nonatomic, strong) UIColor *buttonShadowColor;
@property (nonatomic, strong) UIColor *buttonShadowColorHighlighted;
@property (nonatomic) CGSize buttonShadowOffset;

@property (nonatomic) float buttonSideTextInset;
@property (nonatomic) float buttonTopTextInset;

@property (nonatomic) bool buttonsAreAlwaysDeselected;

- (id)initWithFrame:(CGRect)frame buttonLeftImage:(UIImage *)buttonLeftImage buttonLeftHighlightedImage:(UIImage *)buttonLeftHighlightedImage buttonCenterImage:(UIImage *)buttonCenterImage buttonCenterHighlightedImage:(UIImage *)buttonCenterHighlightedImage buttonRightImage:(UIImage *)buttonRightImage buttonRightHighlightedImage:(UIImage *)buttonRightHighlightedImage buttonSeparatorImage:(UIImage *)buttonSeparatorImage buttonSeparatorLeftHighlightedImage:(UIImage *)buttonSeparatorLeftHighlightedImage buttonSeparatorRightHighlightedImage:(UIImage *)buttonSeparatorRightHighlightedImage;

- (void)addButton:(NSString *)text;

@end
