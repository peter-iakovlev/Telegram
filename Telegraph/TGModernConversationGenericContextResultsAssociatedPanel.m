#import "TGModernConversationGenericContextResultsAssociatedPanel.h"

#import "TGBotContextResults.h"
#import "TGGenericContextResultCell.h"

#import "TGImageUtils.h"

#import "TGBotContextExternalResult.h"
#import "TGBotContextDocumentResult.h"
#import "TGBotContextImageResult.h"

#import "TGBotContextResultAttachment.h"

#import "TGBotSignals.h"

#import "TGViewController.h"

@interface TGModernConversationGenericContextResultsAssociatedPanel () <UITableViewDelegate, UITableViewDataSource> {
    TGBotContextResults *_results;
    
    UIView *_backgroundView;
    UIView *_effectView;
    
    UITableView *_tableView;
    UIView *_stripeView;
    UIView *_separatorView;
    
    UIView *_bottomView;
    
    bool _doNotBindContent;
    
    SMetaDisposable *_loadMoreDisposable;
    bool _loadingMore;
}

@end

@implementation TGModernConversationGenericContextResultsAssociatedPanel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _loadMoreDisposable = [[SMetaDisposable alloc] init];
        
        UIColor *backgroundColor = [UIColor whiteColor];
        UIColor *bottomColor = UIColorRGBA(0xfafafa, 0.98f);
        UIColor *separatorColor = UIColorRGB(0xc5c7d0);
        UIColor *cellSeparatorColor = UIColorRGB(0xdbdbdb);
        
        if (self.style == TGModernConversationAssociatedInputPanelDarkStyle)
        {
            backgroundColor = UIColorRGB(0x171717);
            bottomColor = backgroundColor;
            separatorColor = UIColorRGB(0x292929);
            cellSeparatorColor = separatorColor;
        }
        else if (self.style == TGModernConversationAssociatedInputPanelDarkBlurredStyle)
        {
            backgroundColor = [UIColor clearColor];
            bottomColor = [UIColor clearColor];
            separatorColor = UIColorRGBA(0xb2b2b2, 0.7f);
            cellSeparatorColor = separatorColor;
            
            CGFloat backgroundAlpha = 0.8f;
            if (iosMajorVersion() >= 8)
            {
                UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
                blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                blurEffectView.frame = self.bounds;
                [self addSubview:blurEffectView];
                _effectView = blurEffectView;
                
                backgroundAlpha = 0.4f;
            }
            
            _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
            _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _backgroundView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:backgroundAlpha];
            [self addSubview:_backgroundView];
        }
        
        self.backgroundColor = backgroundColor;
        
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = bottomColor;
        [self addSubview:_bottomView];
        
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.tableFooterView = [[UIView alloc] init];
        if (iosMajorVersion() >= 7)
        {
            _tableView.separatorColor = cellSeparatorColor;
            _tableView.separatorInset = UIEdgeInsetsMake(0.0f, 78.0f, 0.0f, 0.0f);
        }
        _tableView.backgroundColor = nil;
        _tableView.rowHeight = 68.0f;
        _tableView.opaque = false;
        
        [self addSubview:_tableView];
        
        _stripeView = [[UIView alloc] init];
        _stripeView.backgroundColor = separatorColor;
        [self addSubview:_stripeView];
        
        if (self.style != TGModernConversationAssociatedInputPanelDarkBlurredStyle)
        {
            _separatorView = [[UIView alloc] init];
            _separatorView.backgroundColor = separatorColor;
            [self addSubview:_separatorView];
        }
    }
    return self;
}

- (void)dealloc {
    [_loadMoreDisposable dispose];
}

- (void)setResults:(TGBotContextResults *)results {
    [self _setResults:results];
}

- (void)_setResults:(TGBotContextResults *)results {
    _results = results;
    
    NSMutableDictionary *cachedContents = [[NSMutableDictionary alloc] init];
    for (TGGenericContextResultCell *cell in [_tableView visibleCells]) {
        TGGenericContextResultCellContent *content = [cell _takeContent];
        if (content != nil && content.result.resultId != nil) {
            cachedContents[content.result.resultId] = content;
        }
    }
    
    _doNotBindContent = true;
    
    [_tableView reloadData];
    [_tableView layoutSubviews];
    
    for (NSIndexPath *indexPath in [_tableView indexPathsForVisibleRows]) {
        TGGenericContextResultCell *cell = (TGGenericContextResultCell *)[_tableView cellForRowAtIndexPath:indexPath];
        TGBotContextResult *result = _results.results[indexPath.row];
        TGGenericContextResultCellContent *content = cachedContents[result.resultId];
        if (content != nil) {
            [cell _putContent:content];
            [cachedContents removeObjectForKey:result.resultId];
        }
    }
    
    [self bindCellContents];
    
    _doNotBindContent = false;
    
    [self setNeedsPreferredHeightUpdate];
    
    _stripeView.hidden = _results.results.count == 0;
    _separatorView.hidden = _results.results.count == 0;
    _bottomView.hidden = _results.results.count == 0;
    
    [self scrollViewDidScroll:_tableView];
}

- (CGFloat)preferredHeight
{
    return _tableView.rowHeight * MIN([TGViewController isWidescreen] ? 2.5f : 1.5f, (CGFloat)_results.results.count);
}

- (bool)displayForTextEntryOnly {
    return true;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _results.results.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TGGenericContextResultCell *cell = (TGGenericContextResultCell *)[tableView dequeueReusableCellWithIdentifier:@"TGGenericContextResultCell"];
    if (cell == nil) {
        cell = [[TGGenericContextResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TGGenericContextResultCell"];
        __weak TGModernConversationGenericContextResultsAssociatedPanel *weakSelf = self;
        cell.preview = ^(NSString *url, bool isEmbed, CGSize embedSize) {
            __strong TGModernConversationGenericContextResultsAssociatedPanel *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (strongSelf->_previewWebpage) {
                    strongSelf->_previewWebpage(url, isEmbed, embedSize);
                }
            }
        };
    }
    
    if (!_doNotBindContent) {
        [cell setResult:_results.results[indexPath.row]];
    }
    
    return cell;
}

- (void)bindCellContents {
    for (NSIndexPath *indexPath in [_tableView indexPathsForVisibleRows]) {
        TGGenericContextResultCell *cell = (TGGenericContextResultCell *)[_tableView cellForRowAtIndexPath:indexPath];
        if (![cell hasContent]) {
            [cell setResult:_results.results[indexPath.row]];
        }
    }
}

- (void)tableView:(UITableView *)__unused tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TGBotContextResult *result = _results.results[indexPath.row];
    if (_resultSelected) {
        _resultSelected(_results, result);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _tableView) {
        if (!_loadingMore && _results.nextOffset.length != 0 && scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height * 2.0f) {
            _loadingMore = true;
            __weak TGModernConversationGenericContextResultsAssociatedPanel *weakSelf = self;
            [_loadMoreDisposable setDisposable:[[[TGBotSignals botContextResultForUserId:_results.userId query:_results.query offset:_results.nextOffset] deliverOn:[SQueue mainQueue]] startWithNext:^(TGBotContextResults *nextResults) {
                __strong TGModernConversationGenericContextResultsAssociatedPanel *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    TGBotContextResults *mergedResults = [[TGBotContextResults alloc] initWithUserId:strongSelf->_results.userId isMedia:strongSelf->_results.isMedia query:strongSelf->_results.query nextOffset:nextResults.nextOffset results:[strongSelf->_results.results arrayByAddingObjectsFromArray:nextResults.results]];
                    strongSelf->_loadingMore = false;
                    [strongSelf _setResults:mergedResults];
                }
            }]];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _backgroundView.frame = CGRectMake(-1000, 0, self.frame.size.width + 2000, self.frame.size.height);
    _effectView.frame = CGRectMake(-1000, 0, self.frame.size.width + 2000, self.frame.size.height);
    
    CGFloat separatorHeight = TGIsRetina() ? 0.5f : 1.0f;
    _stripeView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, separatorHeight);
    _separatorView.frame = CGRectMake(0.0f, self.frame.size.height - separatorHeight, self.frame.size.width, separatorHeight);
    
    _tableView.frame = CGRectMake(0.0f, separatorHeight, self.frame.size.width, self.frame.size.height - separatorHeight);
    
    _bottomView.frame = CGRectMake(0.0f, self.frame.size.height, self.frame.size.width, 4.0f);
}

- (void)selectPreviousItem
{
    if ([self tableView:_tableView numberOfRowsInSection:0] == 0)
        return;
    
    NSIndexPath *newIndexPath = _tableView.indexPathForSelectedRow;
    
    if (newIndexPath == nil)
        newIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    else if (newIndexPath.row > 0)
        newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row - 1 inSection:0];
    
    if (_tableView.indexPathForSelectedRow != nil)
        [_tableView deselectRowAtIndexPath:_tableView.indexPathForSelectedRow animated:false];
    
    if (newIndexPath != nil)
        [_tableView selectRowAtIndexPath:newIndexPath animated:false scrollPosition:UITableViewScrollPositionBottom];
}

- (void)selectNextItem
{
    if ([self tableView:_tableView numberOfRowsInSection:0] == 0)
        return;
    
    NSIndexPath *newIndexPath = _tableView.indexPathForSelectedRow;
    
    if (newIndexPath == nil)
        newIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    else if (newIndexPath.row < [self tableView:_tableView numberOfRowsInSection:newIndexPath.section] - 1)
        newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row + 1 inSection:0];
    
    if (_tableView.indexPathForSelectedRow != nil)
        [_tableView deselectRowAtIndexPath:_tableView.indexPathForSelectedRow animated:false];
    
    if (newIndexPath != nil)
        [_tableView selectRowAtIndexPath:newIndexPath animated:false scrollPosition:UITableViewScrollPositionBottom];
}

- (void)commitSelectedItem
{
    if ([self tableView:_tableView numberOfRowsInSection:0] == 0)
        return;
    
    NSIndexPath *selectedIndexPath = _tableView.indexPathForSelectedRow;
    if (selectedIndexPath == nil)
        selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self tableView:_tableView didSelectRowAtIndexPath:selectedIndexPath];
}

@end
