#import "TGLoginCountriesController.h"

#import "Freedom.h"

#import "TGLoginCountryCell.h"

#import "TGToolbarButton.h"
#import "TGSearchBar.h"

#import "TGHacks.h"
#import "TGImageUtils.h"

#import "TGSearchDisplayMixin.h"

#import <QuartzCore/QuartzCore.h>

#import "TGInterfaceAssets.h"

#import "TGListsTableView.h"

#import "TGFont.h"

static NSArray *countryCodes()
{
    static NSArray *list = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"PhoneCountries" ofType:@"txt"];
        NSData *stringData = [NSData dataWithContentsOfFile:filePath];
        NSString *data = nil;
        if (stringData != nil)
            data = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
        
        if (data == nil)
            return;
        
        NSString *delimiter = @";";
        NSString *endOfLine = @"\n";
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        int currentLocation = 0;
        while (true)
        {
            NSRange codeRange = [data rangeOfString:delimiter options:0 range:NSMakeRange(currentLocation, data.length - currentLocation)];
            if (codeRange.location == NSNotFound)
                break;
            
            int countryCode = [[data substringWithRange:NSMakeRange(currentLocation, codeRange.location - currentLocation)] intValue];
            
            NSRange idRange = [data rangeOfString:delimiter options:0 range:NSMakeRange(codeRange.location + 1, data.length - (codeRange.location + 1))];
            if (idRange.location == NSNotFound)
                break;
            
            NSString *countryId = [[data substringWithRange:NSMakeRange(codeRange.location + 1, idRange.location - (codeRange.location + 1))] lowercaseString];
            
            NSRange nameRange = [data rangeOfString:endOfLine options:0 range:NSMakeRange(idRange.location + 1, data.length - (idRange.location + 1))];
            if (nameRange.location == NSNotFound)
                nameRange = NSMakeRange(data.length, INT_MAX);
            
            NSString *countryName = [data substringWithRange:NSMakeRange(idRange.location + 1, nameRange.location - (idRange.location + 1))];
            if ([countryName hasSuffix:@"\r"])
                countryName = [countryName substringToIndex:countryName.length - 1];
            
            [array addObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:countryCode], countryId, countryName, nil]];
            //TGLog(@"%d, %@, %@", countryCode, countryId, countryName);
            
            currentLocation = (int)(nameRange.location + nameRange.length);
            if (nameRange.length > 1)
                break;
        }
        
        list = array;
    });
    return list;
}

@interface TGCountrySection : NSObject

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation TGCountrySection

@synthesize headerView = _titleView;
@synthesize title = _title;
@synthesize items = _items;

@end

@interface TGLoginCountriesController () <UITableViewDataSource, UITableViewDelegate, TGSearchDisplayMixinDelegate>
{
    CGFloat _draggingStartOffset;
    bool _displayCodes;
}

@property (nonatomic, strong) TGListsTableView *tableView;

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSMutableArray *sectionIndexTitles;

@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic, strong) TGSearchDisplayMixin *searchMixin;

@end

@implementation TGLoginCountriesController

+ (NSString *)countryNameByCode:(int)code
{
    for (NSArray *array in countryCodes())
    {
        NSNumber *countryCode = [array objectAtIndex:0];
        if ([countryCode intValue] == code)
            return [array objectAtIndex:2];
    }
    
    return nil;
}

+ (NSString *)countryIdByCode:(int)code
{
    for (NSArray *array in countryCodes())
    {
        NSNumber *countryCode = [array objectAtIndex:0];
        if ([countryCode intValue] == code)
            return [array objectAtIndex:1];
    }
    
    return nil;
}

+ (NSString *)countryNameByCountryId:(NSString *)countryId code:(int *)code
{
    NSString *normalizedCountryId = [countryId lowercaseString];
    for (NSArray *array in countryCodes())
    {
        NSString *itemCountryId = [array objectAtIndex:1];
        if ([itemCountryId isEqualToString:normalizedCountryId])
        {
            NSNumber *countryCode = [array objectAtIndex:0];
            if (code != nil)
                *code = [countryCode intValue];
            return [array objectAtIndex:2];
        }
    }
    return nil;
}

- (id)init {
    return [self initWithCodes:true];
}

- (id)initWithCodes:(bool)displayCodes
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _displayCodes = displayCodes;
        self.ignoreKeyboardWhenAdjustingScrollViewInsets = true;
        
        _searchResults = [[NSMutableArray alloc] init];
        
        self.titleText = TGLocalized(@"Login.SelectCountry.Title");
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)]];
    }
    return self;
}

- (void)dealloc
{
    _tableView.delegate = nil;
    
    _searchMixin.delegate = nil;
    [_searchMixin unload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return TGIsPad() ? true : (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    return TGIsPad();
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    if (_searchMixin != nil)
        [_searchMixin controllerInsetUpdated:self.controllerInset];
    
    [super controllerInsetUpdated:previousInset];
}

- (void)loadView
{
    [super loadView];
    
    if (_sections == nil)
    {
        _sections = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *sectionsDict = [[NSMutableDictionary alloc] init];
        
        for (NSArray *array in countryCodes())
        {
            NSString *countryName = [array objectAtIndex:2];
            NSNumber *countryKey = [[NSNumber alloc] initWithInt:[countryName characterAtIndex:0]];
            TGCountrySection *section = [sectionsDict objectForKey:countryKey];
            if (section == nil)
            {
                section = [[TGCountrySection alloc] init];
                section.items = [[NSMutableArray alloc] init];
                section.title = [countryName substringToIndex:1];
                [sectionsDict setObject:section forKey:countryKey];
                
                [_sections addObject:section];
            }
            [section.items addObject:array];
        }
        
        [_sections sortUsingComparator:^NSComparisonResult(TGCountrySection *section1, TGCountrySection *section2)
        {
            return [section1.title compare:section2.title options:NSDiacriticInsensitiveSearch | NSWidthInsensitiveSearch | NSForcedOrderingSearch];
        }];
        
        _sectionIndexTitles = [[NSMutableArray alloc] init];
        
        [_sectionIndexTitles addObject:UITableViewIndexSearch];
        
        int index = -1;
        for (TGCountrySection *section in _sections)
        {
            index++;
            
            section.headerView = [self generateSectionHeader:section.title first:index == 0];
            
            [_sectionIndexTitles addObject:section.title];
            [section.items sortUsingComparator:^NSComparisonResult(NSArray *item1, NSArray *item2)
            {
                NSString *name1 = [item1 objectAtIndex:2];
                NSString *name2 = [item2 objectAtIndex:2];
                return [name1 compare:name2 options:NSDiacriticInsensitiveSearch | NSWidthInsensitiveSearch | NSForcedOrderingSearch];
            }];
        }
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[TGListsTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.rowHeight = 44;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    TGSearchBar *_searchBar = [[TGSearchBar alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 44)];
    
    _tableView.tableHeaderView = _searchBar;
    
    [self.view addSubview:_tableView];
    
    _searchMixin = [[TGSearchDisplayMixin alloc] init];
    _searchMixin.searchBar = _searchBar;
    _searchMixin.delegate = self;
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (UIView *)generateSectionHeader:(NSString *)title first:(bool)first
{
    UIView *sectionContainer = nil;
    
    if (sectionContainer == nil)
    {
        sectionContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        
        sectionContainer.clipsToBounds = false;
        sectionContainer.opaque = false;
        
        UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, first ? 0 : -1, 10, first ? 10 : 11)];
        sectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        sectionView.backgroundColor = UIColorRGB(0xf7f7f7);
        [sectionContainer addSubview:sectionView];
        
        UILabel *sectionLabel = [[UILabel alloc] init];
        sectionLabel.tag = 100;
        sectionLabel.font = TGBoldSystemFontOfSize(17);
        sectionLabel.backgroundColor = sectionView.backgroundColor;
        sectionLabel.textColor = [UIColor blackColor];
        sectionLabel.numberOfLines = 1;
        
        sectionLabel.text = title;
        [sectionLabel sizeToFit];
        sectionLabel.frame = CGRectOffset(sectionLabel.frame, 14, TGRetinaPixel);
        
        [sectionContainer addSubview:sectionLabel];
    }
    else
    {
        UILabel *sectionLabel = (UILabel *)[sectionContainer viewWithTag:100];
        sectionLabel.text = title;
        [sectionLabel sizeToFit];
    }
    
    return sectionContainer;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _tableView)
        return _sections.count;
    else
        return 1;
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tableView)
        return ((TGCountrySection *)[_sections objectAtIndex:section]).items.count;
    else
        return _searchResults.count;
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == _tableView)
        return ((TGCountrySection *)[_sections objectAtIndex:section]).headerView;
    
    return nil;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _tableView)
        return ((TGCountrySection *)[_sections objectAtIndex:section]).headerView != nil ? 25 : 0;
    
    return 0;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == _tableView)
        return _sectionIndexTitles;
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)__unused title atIndex:(NSInteger)index
{
    if (tableView == _tableView)
    {
        if (index == 0)
        {
            [tableView scrollRectToVisible:tableView.tableHeaderView.frame animated:false];
            
            return -1;
        }
        else
            return index - 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CountryCellIdentifier = @"CC";
    TGLoginCountryCell *cell = (TGLoginCountryCell *)[tableView dequeueReusableCellWithIdentifier:CountryCellIdentifier];
    if (cell == nil)
    {
        cell = [[TGLoginCountryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CountryCellIdentifier];
        if (tableView == _tableView)
            [cell setUseIndex:true];
    }
    
    NSArray *item = nil;
    
    if (tableView == _tableView)
        item = [((TGCountrySection *)[_sections objectAtIndex:indexPath.section]).items objectAtIndex:indexPath.row];
    else
        item = [_searchResults objectAtIndex:indexPath.row];
    
    if (item != nil)
    {   
        [cell setTitle:[item objectAtIndex:2]];
        if (_displayCodes) {
            [cell setCode:[[NSString alloc] initWithFormat:@"+%d", [((NSNumber *)[item objectAtIndex:0]) intValue]]];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *item = nil;
    
    if (tableView == _tableView)
        item = [((TGCountrySection *)[_sections objectAtIndex:indexPath.section]).items objectAtIndex:indexPath.row];
    else
        item = [_searchResults objectAtIndex:indexPath.row];
    
    if (item != nil)
    {
        if (_countrySelected)
            _countrySelected([item[0] intValue], item[2], item[1]);
        
        id<ASWatcher> watcher = _watcherHandle.delegate;
        if (watcher != nil && [watcher respondsToSelector:@selector(actionStageActionRequested:options:)])
        {
            [watcher actionStageActionRequested:@"countryCodeSelected" options:[NSDictionary dictionaryWithObjectsAndKeys:[item objectAtIndex:0], @"code", [item objectAtIndex:2], @"name", nil]];
        }
        
        if (watcher == nil)
            [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
    }
}


- (UITableView *)createTableViewForSearchMixin:(TGSearchDisplayMixin *)__unused searchMixin
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.rowHeight = 44;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    return tableView;
}

- (UIView *)referenceViewForSearchResults
{
    return _tableView;
}

- (void)searchMixin:(TGSearchDisplayMixin *)searchMixin hasChangedSearchQuery:(NSString *)searchQuery withScope:(int)__unused scope
{
    [_searchResults removeAllObjects];
    
    NSString *string = [searchQuery lowercaseString];
    
    NSMutableString *mutableQuery = [[NSMutableString alloc] initWithString:string];
    CFStringTransform((CFMutableStringRef)mutableQuery, NULL, kCFStringTransformToLatin, false);
    CFStringTransform((CFMutableStringRef)mutableQuery, NULL, kCFStringTransformStripCombiningMarks, false);
    
    for (TGCountrySection *section in _sections)
    {
        for (NSArray *item in section.items)
        {
            NSString *countryName = [[item objectAtIndex:2] lowercaseString];
            if ([countryName hasPrefix:string] || [countryName hasPrefix:mutableQuery])
            {
                [_searchResults addObject:item];
            }
            else
            {
                for (NSString *substring in [countryName componentsSeparatedByString:@" "])
                {
                    if ([substring hasPrefix:string] || [substring hasPrefix:mutableQuery])
                    {
                        [_searchResults addObject:item];
                    }
                }
            }
        }
    }
    
    [searchMixin reloadSearchResults];
    [searchMixin setSearchResultsTableViewHidden:searchQuery.length == 0];
}

- (void)searchMixinWillActivate:(bool)animated
{
    _tableView.scrollEnabled = false;
    
    UIView *indexView = [_tableView valueForKey:TGEncodeText(@"`joefy", -1)];
    
    [UIView animateWithDuration:0.15f animations:^
    {
        indexView.alpha = 0.0f;
    }];
    
    [self setNavigationBarHidden:true animated:animated];
}

- (void)searchMixinWillDeactivate:(bool)animated
{
    _tableView.scrollEnabled = true;
    
    UIView *indexView = [_tableView valueForKey:TGEncodeText(@"`joefy", -1)];
    
    [UIView animateWithDuration:0.15f animations:^
    {
        indexView.alpha = 1.0f;
    }];
    
    [self setNavigationBarHidden:false animated:animated];
}

- (void)cancelButtonPressed
{
    id<ASWatcher> watcher = _watcherHandle.delegate;
    if (watcher != nil && [watcher respondsToSelector:@selector(actionStageActionRequested:options:)])
    {
        [watcher actionStageActionRequested:@"countryCodeSelected" options:[NSDictionary dictionary]];
    }
    
    if (watcher == nil)
        [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _tableView)
    {
        _draggingStartOffset = scrollView.contentOffset.y;
    }
    else
        [self.view endEditing:true];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)__unused velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView == _tableView)
    {
        if (targetContentOffset != NULL)
        {
            if (targetContentOffset->y > -_tableView.contentInset.top - FLT_EPSILON && targetContentOffset->y < -_tableView.contentInset.top + 44.0f + FLT_EPSILON)
            {
                if (_draggingStartOffset < -_tableView.contentInset.top + 22.0f)
                {
                    if (targetContentOffset->y < -_tableView.contentInset.top + 44.0f * 0.2)
                        targetContentOffset->y = -_tableView.contentInset.top;
                    else
                        targetContentOffset->y = -_tableView.contentInset.top + 44.0f;
                }
                else
                {
                    if (targetContentOffset->y < -_tableView.contentInset.top + 44.0f * 0.8)
                        targetContentOffset->y = -_tableView.contentInset.top;
                    else
                        targetContentOffset->y = -_tableView.contentInset.top + 44.0f;
                }
            }
        }
    }
}

@end
