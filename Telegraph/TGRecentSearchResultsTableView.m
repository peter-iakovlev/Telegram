#import "TGRecentSearchResultsTableView.h"
#import "TGRecentSearchResultsCell.h"

#import "TGImageUtils.h"
#import "TGFont.h"
#import "TGModernButton.h"

@interface TGRecentSearchResultsTableView () <UITableViewDelegate, UITableViewDataSource>
{
}

@end

@implementation TGRecentSearchResultsTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self != nil)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForHeaderInSection:(NSInteger)__unused section
{
    return 28.0f;
}

- (UIView *)tableView:(UITableView *)__unused tableView viewForHeaderInSection:(NSInteger)__unused section
{
    UIView *sectionContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    
    sectionContainer.clipsToBounds = false;
    sectionContainer.opaque = false;
    
    bool first = true;
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, first ? 0 : -1, 10, first ? 10 : 11)];
    sectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    sectionView.backgroundColor = UIColorRGB(0xf7f7f7);
    [sectionContainer addSubview:sectionView];
    
    CGFloat separatorHeight = TGScreenPixel;
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, sectionView.frame.origin.y - (first ? separatorHeight : 0.0f), 10, separatorHeight)];
    separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    separatorView.backgroundColor = TGSeparatorColor();
    //[sectionContainer addSubview:separatorView];
    
    UILabel *sectionLabel = [[UILabel alloc] init];
    sectionLabel.tag = 100;
    sectionLabel.backgroundColor = sectionView.backgroundColor;
    sectionLabel.textColor = [UIColor blackColor];
    sectionLabel.numberOfLines = 1;
    
    [sectionContainer addSubview:sectionLabel];
    
    sectionLabel.font = TGMediumSystemFontOfSize(17);
    sectionLabel.text = TGLocalized(@"WebSearch.RecentSectionTitle");
    sectionLabel.textColor = [UIColor blackColor];
    [sectionLabel sizeToFit];
    sectionLabel.frame = CGRectMake(14.0f, 3.0f + TGRetinaPixel, sectionLabel.frame.size.width, sectionLabel.frame.size.height);
    
    TGModernButton *clearButton = [[TGModernButton alloc] init];
    [clearButton setTitle:TGLocalized(@"WebSearch.RecentSectionClear") forState:UIControlStateNormal];
    [clearButton setTitleColor:UIColorRGB(0x8e8e93)];
    clearButton.titleLabel.font = TGSystemFontOfSize(14.0f);
    [clearButton setContentEdgeInsets:UIEdgeInsetsMake(0.0f, 8.0f, 0.0f, 8.0f)];
    [clearButton addTarget:self action:@selector(clearButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [clearButton sizeToFit];
    clearButton.frame = CGRectMake(sectionContainer.frame.size.width - clearButton.frame.size.width, 0.0f, clearButton.frame.size.width, 28.0f);
    clearButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [sectionContainer addSubview:clearButton];
    
    return sectionContainer;
}

- (void)clearButtonPressed
{
    if (_clearPressed)
        _clearPressed();
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section
{
    return _items.count;
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGRecentSearchResultsCell *cell = (TGRecentSearchResultsCell *)[tableView dequeueReusableCellWithIdentifier:@"TGRecentSearchResultsCell"];
    if (cell == nil)
    {
        cell = [[TGRecentSearchResultsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TGRecentSearchResultsCell"];
    }
    
    [cell setTitle:_items[indexPath.row]];
    
    return cell;
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    
    if (hidden && self.indexPathForSelectedRow)
        [self deselectRowAtIndexPath:self.indexPathForSelectedRow animated:false];
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    self.alpha = _items.count != 0 ? 1.0f : 0.0f;
    [self reloadData];
}

- (void)tableView:(UITableView *)__unused tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_itemSelected)
        _itemSelected(_items[indexPath.row]);
}

@end
