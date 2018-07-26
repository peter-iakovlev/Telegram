#import "TGLocalizationSelectionController.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGLocalizationSignals.h"

#import "TGAppDelegate.h"
#import "TGLegacyComponentsContext.h"
#import "TGPresentation.h"

@interface TGLocalizationSelectionControllerAccessory : UIView {
    UIImageView *_check;
    UIActivityIndicatorView *_indicator;
}

@end

@implementation TGLocalizationSelectionControllerAccessory

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _check = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 14.0f, 11.0f)];
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [self addSubview:_check];
        [self addSubview:_indicator];
    }
    return self;
}

- (void)sizeToFit {
    self.frame = CGRectMake(0.0f, 0.0f, _check.bounds.size.width, _check.bounds.size.height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _check.frame = CGRectMake(CGFloor((self.bounds.size.width - _check.frame.size.width) / 2.0f), CGFloor((self.bounds.size.height - _check.frame.size.height) / 2.0f), _check.bounds.size.width, _check.bounds.size.height);
    _indicator.frame = CGRectMake(CGFloor((self.bounds.size.width - _indicator.frame.size.width) / 2.0f), CGFloor((self.bounds.size.height - _indicator.frame.size.height) / 2.0f), _indicator.bounds.size.width, _indicator.bounds.size.height);
}

- (void)setType:(int32_t)type presentation:(TGPresentation *) presentation {
    _indicator.color = presentation.pallete.collectionMenuSpinnerColor;
    _check.image = presentation.images.collectionMenuCheckImage;
    
    switch (type) {
        case 0:
            _check.hidden = true;
            _indicator.hidden = true;
            [_indicator stopAnimating];
            break;
        case 1:
            _check.hidden = false;
            _indicator.hidden = true;
            [_indicator stopAnimating];
            break;
        case 2:
            _check.hidden = true;
            _indicator.hidden = false;
            [_indicator startAnimating];
            break;
        default:
            break;
    }
}

@end

@interface TGLocalizationSelectionController () <TGSearchDisplayMixinDelegate, UITableViewDelegate, UITableViewDataSource> {
    UITableView *_tableView;
    TGSearchBar *_searchBar;
    UIView *_searchTopBackgroundView;
    TGSearchDisplayMixin *_searchMixin;
    
    UIActivityIndicatorView *_activityIndicator;
    
    SMetaDisposable *_disposable;
    
    NSArray<TGAvailableLocalization *> *_items;
    NSString *_filterString;
    NSArray<TGAvailableLocalization *> *_filteredItems;
    
    TGLocalization *_currentCustomLocalization;
    TGLocalization *_currentLocalization;
    NSString *_applyingLocalizationCode;
}

@end

@implementation TGLocalizationSelectionController
    
- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _disposable = [[SMetaDisposable alloc] init];
        __weak TGLocalizationSelectionController *weakSelf = self;
        [_disposable setDisposable:[[[[TGLocalizationSignals storedLocalizations] then:[TGLocalizationSignals availableLocalizations]] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *localizations) {
            __strong TGLocalizationSelectionController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                NSMutableArray *updatedLocalizations = [[NSMutableArray alloc] initWithArray:localizations];
                if (currentCustomLocalization() != nil) {
                    [updatedLocalizations insertObject:[[TGAvailableLocalization alloc] initWithTitle:TGLocalized(@"Localization.LanguageCustom") localizedTitle:@"Custom" code:@"custom"] atIndex:0];
                }
                strongSelf->_items = updatedLocalizations;
                [strongSelf filterItems];
                if ([strongSelf isViewLoaded]) {
                    [strongSelf->_activityIndicator removeFromSuperview];
                    strongSelf->_searchBar.hidden = false;
                    [strongSelf->_tableView reloadData];
                }
            }
        }]];
        
        self.title = TGLocalized(@"Settings.AppLanguage");
        
        _currentCustomLocalization = currentCustomLocalization();
        _currentLocalization = currentNativeLocalization();
    }
    return self;
}

- (void)dealloc {
    [_disposable dispose];
    
    _tableView.delegate = nil;
    
    _searchMixin.delegate = nil;
    [_searchMixin unload];
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    if (_searchMixin != nil)
        [_searchMixin controllerInsetUpdated:self.controllerInset];
    
    [super controllerInsetUpdated:previousInset];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = self.presentation.pallete.backgroundColor;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    if (iosMajorVersion() >= 11)
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.opaque = true;
    _tableView.backgroundColor = _presentation.pallete.backgroundColor;
    _tableView.separatorColor = self.presentation.pallete.separatorColor;
    [self.view addSubview:_tableView];
    
    if (_items == nil) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _activityIndicator.color = self.presentation.pallete.secondaryTextColor;
        _activityIndicator.frame = CGRectMake(CGFloor((self.view.frame.size.width - _activityIndicator.frame.size.width) / 2.0f), CGFloor((self.view.frame.size.height - _activityIndicator.frame.size.height) / 2.0f), _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
        [self.view addSubview:_activityIndicator];
        [_activityIndicator startAnimating];
        _searchBar.hidden = true;
    }
    
    _searchBar = [[TGSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [TGSearchBar searchBarBaseHeight]) style:TGSearchBarStyleLightPlain];
    _searchBar.pallete = self.presentation.searchBarPallete;
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.safeAreaInset = [self controllerSafeAreaInset];
    _searchBar.placeholder = TGLocalized(@"ChatSearch.SearchPlaceholder");
    
    _searchTopBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320.0f)];
    _searchTopBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_tableView insertSubview:_searchTopBackgroundView atIndex:0];
    
    _searchMixin = [[TGSearchDisplayMixin alloc] init];
    _searchMixin.searchBar = _searchBar;
    _searchMixin.delegate = self;
    
    _tableView.tableHeaderView = _searchBar;
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)filterItems {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (TGAvailableLocalization *item in _items) {
        if (_filterString.length == 0 || [[item.title lowercaseString] hasPrefix:_filterString] || [[item.localizedTitle lowercaseString] hasPrefix:_filterString]) {
            [items addObject:item];
        }
    }
    _filteredItems = items;
}

- (UITableView *)createTableViewForSearchMixin:(TGSearchDisplayMixin *)__unused searchMixin
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    tableView.backgroundColor = self.presentation.pallete.backgroundColor;
    tableView.separatorColor = self.presentation.pallete.separatorColor;
    
    return tableView;
}

- (UIView *)referenceViewForSearchResults
{
    return _tableView;
}

- (void)searchMixin:(TGSearchDisplayMixin *)searchMixin hasChangedSearchQuery:(NSString *)searchQuery withScope:(int)__unused scope
{
    _filterString = [searchQuery lowercaseString];
    [self filterItems];
    
    [searchMixin reloadSearchResults];
    [searchMixin setSearchResultsTableViewHidden:searchQuery.length == 0];
}

- (void)searchMixinWillActivate:(bool)animated
{
    _tableView.scrollEnabled = false;
    [self setNavigationBarHidden:true animated:animated];
}

- (void)searchMixinWillDeactivate:(bool)animated
{
    _tableView.scrollEnabled = true;
    [self setNavigationBarHidden:false animated:animated];
}








- (BOOL)searchDisplayController:(UISearchDisplayController *)__unused controller shouldReloadTableForSearchString:(NSString *)searchString
{
    _filterString = [searchString lowercaseString];
    [self filterItems];
    
    return true;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)__unused controller {
    if (_filterString.length != 0) {
        _filterString = nil;
        [self filterItems];
        [_tableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)__unused section {
    if (tableView == _tableView)
        return (NSInteger)_items.count;
    else
        return (NSInteger)_filteredItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.accessoryView = [[TGLocalizationSelectionControllerAccessory alloc] init];
        [cell.accessoryView sizeToFit];
        cell.backgroundColor = self.presentation.pallete.backgroundColor;
        
        cell.selectedBackgroundView = [[UIView alloc] init];
        cell.selectedBackgroundView.backgroundColor = self.presentation.pallete.selectionColor;
    }
    
    TGAvailableLocalization *localization = nil;
    if (tableView == _tableView)
        localization = _items[indexPath.row];
    else
        localization = _filteredItems[indexPath.row];
    
    cell.textLabel.text = localization.title;
    cell.textLabel.textColor = self.presentation.pallete.textColor;
    cell.detailTextLabel.text = localization.localizedTitle;
    cell.detailTextLabel.textColor = self.presentation.pallete.textColor;
    
    TGLocalizationSelectionControllerAccessory *accessoryView = (TGLocalizationSelectionControllerAccessory *)cell.accessoryView;
    bool isCurrent = [_currentLocalization.code isEqualToString:localization.code];
    if (_currentCustomLocalization != nil && _currentCustomLocalization.isActive) {
        isCurrent = [localization.code isEqualToString:@"custom"];
    }

    if ([localization.code isEqualToString:_applyingLocalizationCode]) {
        [accessoryView setType:2 presentation:self.presentation];
    } else if (isCurrent) {
        [accessoryView setType:1 presentation:self.presentation];
    } else {
        [accessoryView setType:0 presentation:self.presentation];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];

    TGAvailableLocalization *localization = nil;
    if (tableView == _tableView)
        localization = _items[indexPath.row];
    else
        localization = _filteredItems[indexPath.row];
    
    bool isCurrent = [_currentLocalization.code isEqualToString:localization.code];
    if (_currentCustomLocalization != nil && _currentCustomLocalization.isActive) {
        isCurrent = [localization.code isEqualToString:@"custom"];
    }
    
    if (isCurrent) {
        if (_applyingLocalizationCode != nil) {
            _applyingLocalizationCode = nil;
            [_disposable setDisposable:nil];
            [_tableView reloadData];
            [_searchMixin.searchResultsTableView reloadData];
        }
    } else {
        if ([_filteredItems[indexPath.row].code isEqualToString:@"custom"]) {
            if (_applyingLocalizationCode != nil) {
                _applyingLocalizationCode = nil;
                [_disposable setDisposable:nil];
            }
            
            setCurrentCustomLocalization([currentCustomLocalization() withUpdatedIsActive:true]);
            _currentCustomLocalization = currentCustomLocalization();
            
            TGDispatchOnMainThread(^{
                [TGAppDelegateInstance resetLocalization];
                [TGAppDelegateInstance updatePushRegistration];
            });
            
            [self localizationUpdated];
        } else {
            _applyingLocalizationCode = _filteredItems[indexPath.row].code;
            __weak TGLocalizationSelectionController *weakSelf = self;
            [_disposable setDisposable:[[[TGLocalizationSignals applyLocalization:_applyingLocalizationCode] deliverOn:[SQueue mainQueue]] startWithNext:nil completed:^{
                __strong TGLocalizationSelectionController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    strongSelf->_currentCustomLocalization = currentCustomLocalization();
                    strongSelf->_currentLocalization = currentNativeLocalization();
                    strongSelf->_applyingLocalizationCode = nil;
                    [strongSelf->_tableView reloadData];
                    [strongSelf->_searchMixin.searchResultsTableView reloadData];
                    [strongSelf localizationUpdated];
                }
            }]];
        }
        [_tableView reloadData];
        [_searchMixin.searchResultsTableView reloadData];
    }
    
    if (_searchMixin.isActive) {
        [_searchMixin setIsActive:false animated:true];
    }
}

- (void)localizationUpdated {
    self.title = TGLocalized(@"Settings.AppLanguage");
    _searchBar.placeholder = TGLocalized(@"ChatSearch.SearchPlaceholder");
    if (iosMajorVersion() >= 9) {
        if ([effectiveLocalization().code isEqualToString:@"ar"]) {
            [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        } else {
            [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
        }
    }
}

@end
