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
    TGSearchBarStyleLightPlain = 3
} TGSearchBarStyle;

@protocol TGSearchBarDelegate <UISearchBarDelegate>

- (void)searchBar:(TGSearchBar *)searchBar willChangeHeight:(CGFloat)newHeight;

@end

@interface TGSearchBar : UIView

+ (CGFloat)searchBarBaseHeight;
+ (CGFloat)searchBarScopeHeight;

@property (nonatomic, weak) id<TGSearchBarDelegate> delegate;

@property (nonatomic, strong) NSArray *customScopeButtonTitles;
@property (nonatomic) NSInteger selectedScopeButtonIndex;
@property (nonatomic) bool showsScopeBar;

@property (nonatomic) bool searchBarShouldShowScopeControl;
@property (nonatomic) bool alwaysExtended;

@property (nonatomic) TGSearchBarStyle style;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *placeholder;

@property (nonatomic) bool showActivity;
@property (nonatomic) bool delayActivity;

- (instancetype)initWithFrame:(CGRect)frame style:(TGSearchBarStyle)style;

- (void)setShowsCancelButton:(bool)showsCancelButton animated:(bool)animated;

- (void)updateClipping:(CGFloat)clippedHeight;

- (void)localizationUpdated;

@end
