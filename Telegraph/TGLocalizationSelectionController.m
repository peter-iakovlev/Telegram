#import "TGLocalizationSelectionController.h"

#import "TGLocalizationSignals.h"
#import "TGLocalization.h"

#import "TGAppDelegate.h"

@interface TGLocalizationSelectionControllerAccessory : UIView {
    UIImageView *_check;
    UIActivityIndicatorView *_indicator;
}

@end

@implementation TGLocalizationSelectionControllerAccessory

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _check = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernMenuCheck.png"]];
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

- (void)setType:(int32_t)type {
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

@interface TGLocalizationSelectionController () <UISearchBarDelegate, UISearchDisplayDelegate> {
    UISearchDisplayController *_searchDisplayController;
    UISearchBar *_searchBar;
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
        [_disposable setDisposable:[[[TGLocalizationSignals availableLocalizations] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *localizations) {
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
                    [strongSelf.tableView reloadData];
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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_items == nil) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _activityIndicator.frame = CGRectMake(CGFloor((self.view.frame.size.width - _activityIndicator.frame.size.width) / 2.0f), CGFloor((self.view.frame.size.height - _activityIndicator.frame.size.height) / 2.0f), _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
        [self.view addSubview:_activityIndicator];
        [_activityIndicator startAnimating];
        _searchBar.hidden = true;
    }
    
    UISearchBar *tempSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    _searchBar = tempSearchBar;
    if (iosMajorVersion() >= 7)
        _searchBar.barTintColor = [UIColor whiteColor];
    _searchBar.placeholder = TGLocalized(@"ChatSearch.SearchPlaceholder");
    _searchBar.delegate = self;
    [_searchBar sizeToFit];
    self.tableView.tableHeaderView = _searchBar;
    
    CGSize size = CGSizeMake(28, 28);
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0f);
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.0f, 0.0f, 28.0f, 28.0f) cornerRadius:6.0f] addClip];
    [UIColorRGB(0xe8e8e8) setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [_searchBar setSearchFieldBackgroundImage:image forState:UIControlStateNormal];
    
    _searchBar.layer.borderWidth = 1;
    _searchBar.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    _searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _searchDisplayController.delegate = self;
    _searchDisplayController.searchResultsDataSource = self;
    _searchDisplayController.searchResultsDelegate = self;
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
        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section {
    return (NSInteger)_filteredItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.accessoryView = [[TGLocalizationSelectionControllerAccessory alloc] init];
        [cell.accessoryView sizeToFit];
    }
    
    cell.textLabel.text = _filteredItems[indexPath.row].title;
    cell.detailTextLabel.text = _filteredItems[indexPath.row].localizedTitle;
    
    TGLocalizationSelectionControllerAccessory *accessoryView = (TGLocalizationSelectionControllerAccessory *)cell.accessoryView;
    bool isCurrent = [_currentLocalization.code isEqualToString:_filteredItems[indexPath.row].code];
    if (_currentCustomLocalization != nil && _currentCustomLocalization.isActive) {
        isCurrent = [_filteredItems[indexPath.row].code isEqualToString:@"custom"];
    }
    
    if ([_filteredItems[indexPath.row].code isEqualToString:_applyingLocalizationCode]) {
        [accessoryView setType:2];
    } else if (isCurrent) {
        [accessoryView setType:1];
    } else {
        [accessoryView setType:0];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    if (_searchDisplayController.isActive) {
        [_searchDisplayController setActive:false animated:true];
    }
    
    bool isCurrent = [_currentLocalization.code isEqualToString:_filteredItems[indexPath.row].code];
    if (_currentCustomLocalization != nil && _currentCustomLocalization.isActive) {
        isCurrent = [_filteredItems[indexPath.row].code isEqualToString:@"custom"];
    }
    
    if (isCurrent) {
        if (_applyingLocalizationCode != nil) {
            _applyingLocalizationCode = nil;
            [_disposable setDisposable:nil];
            [self.tableView reloadData];
            [_searchDisplayController.searchResultsTableView reloadData];
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
                    [strongSelf.tableView reloadData];
                    [_searchDisplayController.searchResultsTableView reloadData];
                    [strongSelf localizationUpdated];
                }
            }]];
        }
        [self.tableView reloadData];
        [_searchDisplayController.searchResultsTableView reloadData];
    }
}

- (void)localizationUpdated {
    self.title = TGLocalized(@"Settings.AppLanguage");
    _searchBar.placeholder = TGLocalized(@"ChatSearch.SearchPlaceholder");
}

@end
