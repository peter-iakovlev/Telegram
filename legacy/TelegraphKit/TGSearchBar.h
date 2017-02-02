/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@class TGSearchBar;

typedef enum {
    TGSearchBarStyleDefault = 0,
    TGSearchBarStyleDark = 1,
    TGSearchBarStyleLight = 2,
    TGSearchBarStyleLightPlain = 3,
    TGSearchBarStyleLightAlwaysPlain = 4,
    TGSearchBarStyleHeader = 5,
} TGSearchBarStyle;

@protocol TGSearchBarDelegate <UISearchBarDelegate>

- (void)searchBar:(TGSearchBar *)searchBar willChangeHeight:(CGFloat)newHeight;

@end

@interface TGSearchBar : UIView

+ (CGFloat)searchBarBaseHeight;
+ (CGFloat)searchBarScopeHeight;
- (CGFloat)baseHeight;

@property (nonatomic, weak) id<TGSearchBarDelegate> delegate;
@property (nonatomic) bool highContrast;

@property (nonatomic, strong) UITextField *customTextField;
@property (nonatomic, readonly) UITextField *maybeCustomTextField;

@property (nonatomic, strong) UIImageView *customBackgroundView;
@property (nonatomic, strong) UIImageView *customActiveBackgroundView;

@property (nonatomic, strong) NSArray *customScopeButtonTitles;
@property (nonatomic) NSInteger selectedScopeButtonIndex;
@property (nonatomic) bool showsScopeBar;
@property (nonatomic) bool scopeBarCollapsed;

@property (nonatomic) bool searchBarShouldShowScopeControl;
@property (nonatomic) bool alwaysExtended;
@property (nonatomic) bool hidesCancelButton;

@property (nonatomic, strong) UIButton *customCancelButton;

@property (nonatomic) TGSearchBarStyle style;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *placeholder;

@property (nonatomic) bool showActivity;
@property (nonatomic) bool delayActivity;

- (instancetype)initWithFrame:(CGRect)frame style:(TGSearchBarStyle)style;

- (void)setShowsCancelButton:(bool)showsCancelButton animated:(bool)animated;

- (void)setCustomScopeBarHidden:(bool)hidden;

- (void)updateClipping:(CGFloat)clippedHeight;

- (void)localizationUpdated;

@end
