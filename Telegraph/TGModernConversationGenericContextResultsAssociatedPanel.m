#import "TGModernConversationGenericContextResultsAssociatedPanel.h"

#import "TGBotContextResults.h"
#import "TGGenericContextResultCell.h"

#import "TGImageUtils.h"

#import "TGBotContextExternalResult.h"
#import "TGBotContextMediaResult.h"

#import "TGBotContextResultAttachment.h"

#import "TGBotSignals.h"

#import "TGViewController.h"

#import "TGPreviewMenu.h"

#import "TGModernButton.h"

#import "TGFont.h"

#import "TGModernConversationGenericContextResultsAssociatedPanelSwitchPm.h"

@interface TGModernConversationGenericContextResultsAssociatedPanel () <UITableViewDelegate, UITableViewDataSource> {
    TGBotContextResults *_results;
    
    UIView *_backgroundView;
    UIView *_effectView;
    
    UITableView *_tableView;
    UIView *_tableViewSeparator;
    UIView *_tableViewBackground;
    UIView *_separatorView;
    
    UIView *_bottomView;
    
    bool _doNotBindContent;
    
    SMetaDisposable *_loadMoreDisposable;
    bool _loadingMore;
    
    TGItemPreviewHandle *_previewHandle;
    
    bool _resetOffsetOnLayout;
    
    TGModernConversationGenericContextResultsAssociatedPanelSwitchPm *_switchPm;
    
    bool _animatingOut;
}

@end

@implementation TGModernConversationGenericContextResultsAssociatedPanel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _loadMoreDisposable = [[SMetaDisposable alloc] init];
        
        self.clipsToBounds = true;
        
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
        
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = bottomColor;
        [self addSubview:_bottomView];
        
        _tableViewBackground = [[UIView alloc] init];
        _tableViewBackground.backgroundColor = backgroundColor;
        [self addSubview:_tableViewBackground];
        
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.tableFooterView = [[UIView alloc] init];
        if (iosMajorVersion() >= 7)
        {
            _tableView.separatorColor = cellSeparatorColor;
            _tableView.separatorInset = UIEdgeInsetsMake(0.0f, 80.0f, 0.0f, 0.0f);
        }
        _tableView.backgroundColor = nil;
        _tableView.opaque = false;
        
        [self addSubview:_tableView];
        
        _tableViewSeparator = [[UIView alloc] init];
        _tableViewSeparator.backgroundColor = separatorColor;
        [self addSubview:_tableViewSeparator];
        
        if (self.style != TGModernConversationAssociatedInputPanelDarkBlurredStyle)
        {
            _separatorView = [[UIView alloc] init];
            _separatorView.backgroundColor = separatorColor;
            [self addSubview:_separatorView];
        }
        
        __weak TGModernConversationGenericContextResultsAssociatedPanel *weakSelf = self;
        _previewHandle = [TGPreviewMenu setupPreviewControllerForView:_tableView configurator:^TGItemPreviewController *(CGPoint gestureLocation)
        {
            __strong TGModernConversationGenericContextResultsAssociatedPanel *strongSelf = weakSelf;
            if (strongSelf == nil)
                return nil;
            
            NSIndexPath *indexPath = [strongSelf->_tableView indexPathForRowAtPoint:gestureLocation];
            if (indexPath == nil)
                return nil;
            
            TGBotContextResult *result = strongSelf->_results.results[indexPath.item];
            return [strongSelf presentPreviewForResultIfAvailable:result immediately:false];
        }];
    }
    return self;
}

- (void)dealloc {
    [_loadMoreDisposable dispose];
}

- (TGItemPreviewController *)presentPreviewForResultIfAvailable:(TGBotContextResult *)result immediately:(bool)immediately
{
    if (self.onResultPreview != nil)
        self.onResultPreview();
    
    __weak TGModernConversationGenericContextResultsAssociatedPanel *weakSelf = self;
    return [TGPreviewMenu presentInParentController:self.controller expandImmediately:immediately result:result results:_results sendAction:^(TGBotContextResult *result)
    {
        __strong TGModernConversationGenericContextResultsAssociatedPanel *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf.resultSelected != nil)
            strongSelf.resultSelected(strongSelf->_results, result);
    } sourcePointForItem:^CGPoint(__unused id item)
    {
        __strong TGModernConversationGenericContextResultsAssociatedPanel *strongSelf = weakSelf;
        if (strongSelf != nil)
            return [strongSelf centerPointForResult:result];
                
        return CGPointZero;
    } sourceView:nil sourceRect:nil];
}

- (void)updatePreferredHeight {
    if (self.preferredHeightUpdated != nil) {
        self.preferredHeightUpdated();
    }
    
    if ([self fillsAvailableSpace]) {
        
    }
}

- (void)setResults:(TGBotContextResults *)results {
    [self _setResults:results resetScrollPosition:true];
}

- (void)_setResults:(TGBotContextResults *)results resetScrollPosition:(bool)resetScrollPosition {
    CGFloat previousPreferredHeight = [self preferredHeight];
    
    bool wasEmpty = _results.results.count == 0 && _results.switchPm == nil;
    _results = results;
    
    if (ABS([self preferredHeight] - previousPreferredHeight) > FLT_EPSILON) {
        [self updatePreferredHeight];
    }
    
    NSMutableDictionary *cachedContents = [[NSMutableDictionary alloc] init];
    for (TGGenericContextResultCell *cell in [_tableView visibleCells]) {
        TGGenericContextResultCellContent *content = [cell _takeContent];
        if (content != nil && content.result.resultId != nil) {
            cachedContents[content.result.resultId] = content;
        }
    }
    
    _doNotBindContent = true;
    
    if (results.switchPm != nil) {
        if (_switchPm != nil) {
            _switchPm.title = results.switchPm.text;
        } else {
            _switchPm = [[TGModernConversationGenericContextResultsAssociatedPanelSwitchPm alloc] initWithFrame:CGRectMake(0.0f, -32.0f, _tableView.frame.size.width, 32.0f)];
            _switchPm.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            _switchPm.title = results.switchPm.text;
            __weak TGModernConversationGenericContextResultsAssociatedPanel *weakSelf = self;
            _switchPm.pressed = ^{
                __strong TGModernConversationGenericContextResultsAssociatedPanel *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    if (strongSelf->_activateSwitchPm) {
                        strongSelf->_activateSwitchPm(results.switchPm.startParam);
                    }
                }
            };
            [_tableView addSubview:_switchPm];
        }
    } else if (_switchPm != nil) {
        [_switchPm removeFromSuperview];
        _switchPm = nil;
    }
    
    [_tableView reloadData];
    if (resetScrollPosition) {
        [_tableView setContentOffset:CGPointZero animated:false];
        [_tableView layoutSubviews];
        
        _resetOffsetOnLayout = true;
        [self layoutSubviews];
        _resetOffsetOnLayout = false;
    }
    
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
    
    _tableViewBackground.hidden = _results.results.count == 0;
    _separatorView.hidden = _results.results.count == 0;
    _bottomView.hidden = _results.results.count == 0;
    
    [self scrollViewDidScroll:_tableView];
    
    if (wasEmpty && (_results.results.count != 0 || _results.switchPm != nil)) {
        [self animateIn];
    }
}

- (bool)fillsAvailableSpace {
    return true;//iosMajorVersion() >= 9;
}

- (CGFloat)preferredHeight {
    return [self preferredHeightAndOverlayHeight:NULL];
}

- (CGFloat)preferredHeightAndOverlayHeight:(CGFloat *)overlayHeight {
    CGFloat height = 0.0f;
    CGFloat lastHeight = 0.0f;
    NSInteger lastIndex = ((NSInteger)_results.results.count) - 1;
    for (NSInteger i = 0; i <= lastIndex; i++) {
        CGFloat rowHeight = [self tableView:_tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (i == lastIndex) {
            lastHeight = rowHeight;
        } else {
            height += rowHeight;
        }
    }
    
    if (_switchPm != nil) {
        height += _switchPm.frame.size.height;
    }
    
    CGFloat maxHeight = 240.0f;
    if (![TGViewController hasLargeScreen]) {
        maxHeight = 140.0f;
    }
    
    CGFloat overlayHeightValue = 0.0f;
    
    if (overlayHeight) {
        *overlayHeight = overlayHeightValue;
    }
    
    height += overlayHeightValue;
    
    if (lastIndex > 0) {
        return MIN(maxHeight, CGFloor(height + lastHeight * 0.5f));
    } else {
        return MIN(maxHeight, height + lastHeight);
    }
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

- (CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id result = _results.results[indexPath.row];
    if ([result isKindOfClass:[TGBotContextResult class]]) {
        TGBotContextResult *concreteResult = (TGBotContextResult *)result;
        if ([concreteResult.type isEqual:@"audio"] || [concreteResult.type isEqual:@"contact"] || [concreteResult.type isEqual:@"voice"]) {
            return 62.0f;
        }
    }
    return 75.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TGGenericContextResultCell *cell = (TGGenericContextResultCell *)[tableView dequeueReusableCellWithIdentifier:@"TGGenericContextResultCell"];
    if (cell == nil) {
        cell = [[TGGenericContextResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TGGenericContextResultCell"];
        __weak TGModernConversationGenericContextResultsAssociatedPanel *weakSelf = self;
        cell.preview = ^(TGBotContextResult *result) {
            __strong TGModernConversationGenericContextResultsAssociatedPanel *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf presentPreviewForResultIfAvailable:result immediately:true];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TGBotContextResult *result = _results.results[indexPath.row];
    
    if ([self presentPreviewForResultIfAvailable:result immediately:true] == nil)
    {
        if (_resultSelected != nil)
            _resultSelected(_results, result);
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _tableView) {
        if (!_loadingMore && _results.nextOffset.length != 0 && scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height * 2.0f) {
            _loadingMore = true;
            TGBotContextResultsSwitchPm *switchPm = _results.switchPm;
            __weak TGModernConversationGenericContextResultsAssociatedPanel *weakSelf = self;
            [_loadMoreDisposable setDisposable:[[[TGBotSignals botContextResultForUserId:_results.userId peerId:_results.peerId accessHash:_results.accessHash query:_results.query geoPoint:nil offset:_results.nextOffset] deliverOn:[SQueue mainQueue]] startWithNext:^(TGBotContextResults *nextResults) {
                __strong TGModernConversationGenericContextResultsAssociatedPanel *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    TGBotContextResults *mergedResults = [[TGBotContextResults alloc] initWithUserId:strongSelf->_results.userId peerId:strongSelf->_results.peerId accessHash:strongSelf->_results.accessHash isMedia:strongSelf->_results.isMedia query:strongSelf->_results.query nextOffset:nextResults.nextOffset results:[strongSelf->_results.results arrayByAddingObjectsFromArray:nextResults.results] switchPm:switchPm];
                    strongSelf->_loadingMore = false;
                    [strongSelf _setResults:mergedResults resetScrollPosition:false];
                }
            }]];
        }
        
        [self updateTableBackground];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_animatingOut) {
        return;
    }
    
    _backgroundView.frame = CGRectMake(-1000, 0, self.frame.size.width + 2000, self.frame.size.height);
    _effectView.frame = CGRectMake(-1000, 0, self.frame.size.width + 2000, self.frame.size.height);
    
    CGFloat separatorHeight = TGScreenPixel;
    _separatorView.frame = CGRectMake(0.0f, self.frame.size.height - separatorHeight, self.frame.size.width, separatorHeight);
    
    UIEdgeInsets previousInset = _tableView.contentInset;
    //CGPoint contentOffset = _tableView.contentOffset;
    
    _tableView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    
    if ([self fillsAvailableSpace]) {
        CGFloat overlayHeight = 0.0;
        CGFloat preferredHeight = [self preferredHeightAndOverlayHeight:&overlayHeight];
        
        CGFloat topInset = MAX(0.0f, self.frame.size.height - preferredHeight);
        if (_switchPm != nil) {
            topInset += _switchPm.frame.size.height;
        }
        CGFloat insetDifference = topInset - _tableView.contentInset.top;
        UIEdgeInsets finalInset = UIEdgeInsetsMake(topInset, 0.0f, MAX(0.0f, overlayHeight - 1.0f / TGScreenScaling()), 0.0f);
        
        if (_resetOffsetOnLayout) {
            _resetOffsetOnLayout = false;
            _tableView.contentInset = finalInset;
            _tableView.contentOffset = CGPointMake(0.0f, -_tableView.contentInset.top);
        } else if (ABS(insetDifference) > FLT_EPSILON) {
            //if (ABS(insetDifference) <= 36.0f + 0.1) {
            {
                [self _autoAdjustInsetsForScrollView:_tableView finalInset:finalInset previousInset:previousInset];
                
                //contentOffset.y -= insetDifference;
                //_tableView.contentOffset = contentOffset;
            }
        }
    } else {
        if (_switchPm != nil) {
            _tableView.contentInset = UIEdgeInsetsMake(_switchPm.frame.size.height, 0.0f, 0.0f, 0.0f);
        } else {
            _tableView.contentInset = UIEdgeInsetsZero;
        }
        if (_resetOffsetOnLayout) {
            _resetOffsetOnLayout = false;
            _tableView.contentOffset = CGPointMake(0.0f, -_tableView.contentInset.top);
        }
    }
    
    _bottomView.frame = CGRectMake(0.0f, self.frame.size.height, self.frame.size.width, 4.0f);
    
    [self updateTableBackground];
}

- (void)_autoAdjustInsetsForScrollView:(UIScrollView *)scrollView finalInset:(UIEdgeInsets)finalInset previousInset:(UIEdgeInsets)previousInset
{
    CGPoint contentOffset = scrollView.contentOffset;
    
    scrollView.contentInset = finalInset;
    if (iosMajorVersion() <= 8 && scrollView.subviews.count != 0) {
        if ([NSStringFromClass([scrollView.subviews.firstObject class]) hasPrefix:@"UITableViewWra"]) {
            CGRect frame = scrollView.subviews.firstObject.frame;
            frame.origin = CGPointZero;
            scrollView.subviews.firstObject.frame = frame;
        }
    }
    
    if (!UIEdgeInsetsEqualToEdgeInsets(previousInset, UIEdgeInsetsZero))
    {
        CGFloat maxOffset = scrollView.contentSize.height - (scrollView.frame.size.height - finalInset.bottom);
        
        contentOffset.y += previousInset.top - finalInset.top;
        contentOffset.y = MAX(-finalInset.top, MIN(contentOffset.y, maxOffset));
        [scrollView setContentOffset:contentOffset animated:false];
    }
    else if (contentOffset.y < finalInset.top)
    {
        contentOffset.y = -finalInset.top;
        [scrollView setContentOffset:contentOffset animated:false];
    }
}

- (void)updateTableBackground {
    if (_animatingOut) {
        return;
    }
    
    CGFloat backgroundOriginY = MAX(0.0f, -_tableView.contentOffset.y - (_switchPm == nil ? 0.0f : _switchPm.frame.size.height));
    _tableViewBackground.frame = CGRectMake(0.0f, backgroundOriginY, self.frame.size.width, self.frame.size.height - backgroundOriginY);
    _tableViewSeparator.frame = CGRectMake(0.0f, backgroundOriginY - 0.5f, self.frame.size.width, 0.5f);
    
    _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(backgroundOriginY, 0.0f, 0.0f, 0.0f);
    
    self.overlayBarOffset = _tableView.contentOffset.y;
    if (self.updateOverlayBarOffset) {
        self.updateOverlayBarOffset(self.overlayBarOffset);
    }
}

- (CGRect)tableBackgroundFrame {
    return _tableViewBackground.frame;
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

- (CGPoint)centerPointForResult:(TGBotContextResult *)result
{
    CGRect rect = [self rectForResult:result];
    
    if (!CGRectEqualToRect(rect, CGRectZero))
        return CGPointMake(rect.origin.x + 41.0f, rect.origin.y + 34.0f);
    
    return CGPointZero;
}

- (CGRect)rectForResult:(TGBotContextResult *)result
{
    for (TGGenericContextResultCell *cell in _tableView.visibleCells)
    {
        if ([cell.result isEqual:result])
        {
            NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
            if (indexPath != nil)
                return [_tableView convertRect:cell.frame toView:nil];
        }
    }
    
    return CGRectZero;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(_tableViewBackground.frame, point)) {
        return [super hitTest:point withEvent:event];
    }
    return nil;
}

- (void)animateIn {
    [self layoutSubviews];
    CGFloat offset = [self preferredHeight];
    CGRect normalFrame = _tableView.frame;
    _tableView.frame = CGRectMake(normalFrame.origin.x, normalFrame.origin.y + offset, normalFrame.size.width, normalFrame.size.height);
    CGRect normalBackgroundFrame = _tableViewBackground.frame;
    _tableViewBackground.frame = CGRectMake(normalBackgroundFrame.origin.x, normalBackgroundFrame.origin.y + offset, normalBackgroundFrame.size.width, normalBackgroundFrame.size.height);
    CGRect normalSeparatorFrame = _tableViewSeparator.frame;
    _tableViewSeparator.frame = CGRectMake(normalSeparatorFrame.origin.x, normalSeparatorFrame.origin.y + offset, normalSeparatorFrame.size.width, normalSeparatorFrame.size.height);
    [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^{
        _tableView.frame = normalFrame;
        _tableViewBackground.frame = normalBackgroundFrame;
        _tableViewSeparator.frame = normalSeparatorFrame;
    } completion:nil];
}

- (void)animateOut:(void (^)())completion {
    CGFloat offset = self.frame.size.height - _tableViewBackground.frame.origin.y;
    CGRect normalFrame = _tableView.frame;
    CGRect normalBackgroundFrame = _tableViewBackground.frame;
    CGRect normalSeparatorFrame = _tableViewSeparator.frame;
    
    _animatingOut = true;
    
    [UIView animateWithDuration:0.15 delay:0.0 options:0 animations:^{
        _tableView.frame = CGRectMake(normalFrame.origin.x, normalFrame.origin.y + offset, normalFrame.size.width, normalFrame.size.height);
        _tableViewBackground.frame = CGRectMake(normalBackgroundFrame.origin.x, normalBackgroundFrame.origin.y + offset, normalBackgroundFrame.size.width, normalBackgroundFrame.size.height);
        _tableViewSeparator.frame = CGRectMake(normalSeparatorFrame.origin.x, normalSeparatorFrame.origin.y + offset, normalSeparatorFrame.size.width, normalSeparatorFrame.size.height);
    } completion:^(__unused BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

@end
