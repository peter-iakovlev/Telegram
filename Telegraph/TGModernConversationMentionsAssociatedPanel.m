#import "TGModernConversationMentionsAssociatedPanel.h"

#import "TGUser.h"

#import "TGMentionPanelCell.h"

#import "TGImageUtils.h"

@interface TGModernConversationMentionsAssociatedPanel () <UITableViewDelegate, UITableViewDataSource>
{
    SMetaDisposable *_disposable;
    NSArray *_userList;
 
    UIView *_backgroundView;
    UIView *_effectView;
    
    UITableView *_tableView;
    UIView *_stripeView;
    UIView *_separatorView;
    
    UIView *_bottomView;
}

@end

@implementation TGModernConversationMentionsAssociatedPanel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _disposable = [[SMetaDisposable alloc] init];
        
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
            separatorColor = UIColorRGBA(0xb2b2b2, 0.7f);
            cellSeparatorColor = UIColorRGBA(0xb2b2b2, 0.4f);
            bottomColor = [UIColor clearColor];
            
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
            _tableView.separatorInset = UIEdgeInsetsMake(0.0f, 52.0f, 0.0f, 0.0f);
        }
        _tableView.backgroundColor = nil;
        _tableView.rowHeight = 41.0f;
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

- (void)dealloc
{
    [_disposable dispose];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.alpha = frame.size.height >= FLT_EPSILON;
}

- (CGFloat)preferredHeight
{
    return 41.0f * MIN(3.5f, (CGFloat)_userList.count);
}

- (void)setUserListSignal:(SSignal *)userListSignal
{
    if (userListSignal == nil)
    {
        [_disposable setDisposable:nil];
        [self setUserList:@[]];
    }
    else
    {
        __weak TGModernConversationMentionsAssociatedPanel *weakSelf = self;
        [_disposable setDisposable:[[userListSignal deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *userList)
        {
            __strong TGModernConversationMentionsAssociatedPanel *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf setUserList:userList];
        }]];
    }
}

- (void)setUserList:(NSArray *)userList
{
    _userList = userList;
    
    [_tableView reloadData];
    
    [self setNeedsPreferredHeightUpdate];
    
    _stripeView.hidden = userList.count == 0;
    _separatorView.hidden = userList.count == 0;
    _bottomView.hidden = userList.count == 0;
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section
{
    return _userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGMentionPanelCell *cell = (TGMentionPanelCell *)[tableView dequeueReusableCellWithIdentifier:TGMentionPanelCellKind];
    if (cell == nil)
        cell = [[TGMentionPanelCell alloc] initWithStyle:self.style];
    
    [cell setUser:_userList[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)__unused tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGUser *user = _userList[indexPath.row];
    if (_userSelected)
        _userSelected(user);
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
