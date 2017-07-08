/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@class TGSearchDisplayMixin;
@class TGSearchBar;

@protocol TGSearchDisplayMixinDelegate <NSObject>

@required

- (UITableView *)createTableViewForSearchMixin:(TGSearchDisplayMixin *)searchMixin;
- (UIView *)referenceViewForSearchResults;
- (void)searchMixin:(TGSearchDisplayMixin *)searchMixin hasChangedSearchQuery:(NSString *)searchQuery withScope:(int)scope;

@optional

- (void)searchMixinWillActivate:(bool)animated;
- (void)searchMixinWillDeactivate:(bool)animated;

@end

@interface TGSearchDisplayMixin : NSObject

@property (nonatomic, weak) id<TGSearchDisplayMixinDelegate> delegate;

@property (nonatomic, strong) TGSearchBar *searchBar;
@property (nonatomic) bool isActive;
@property (nonatomic, strong) UITableView *searchResultsTableView;
@property (nonatomic) bool alwaysShowsCancelButton;

@property (nonatomic) bool searchResultsTableViewHidden;

@property (nonatomic) bool simpleLayout;

- (void)setSearchResultsTableViewHidden:(bool)searchResultsTableViewHidden animated:(bool)animated;

- (void)setIsActive:(bool)isActive animated:(bool)animated;

- (void)controllerInsetUpdated:(UIEdgeInsets)controllerInset;
- (void)controllerLayoutUpdated:(CGSize)layoutSize;

- (void)reloadSearchResults;
- (void)resignResponderIfAny;

- (void)unload;

@end
