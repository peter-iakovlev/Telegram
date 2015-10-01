#import "TGModernConversationHashtagsAssociatedPanel.h"

#import "TGHashtagPanelCell.h"

#import "TGImageUtils.h"

@interface TGModernConversationHashtagsAssociatedPanel () <UITableViewDelegate, UITableViewDataSource>
{
    SMetaDisposable *_disposable;
    NSArray *_hashtagList;
    
    UITableView *_tableView;
    UIView *_stripeView;
    UIView *_separatorView;
    
    UIView *_bottomView;
}

@end

@implementation TGModernConversationHashtagsAssociatedPanel

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
            _tableView.separatorInset = UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 0.0f);
        }
        _tableView.backgroundColor = nil;
        _tableView.rowHeight = 41.0f;
        _tableView.opaque = false;
        
        [self addSubview:_tableView];
        
        _stripeView = [[UIView alloc] init];
        _stripeView.backgroundColor = separatorColor;
        [self addSubview:_stripeView];
        
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = separatorColor;
        [self addSubview:_separatorView];
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
    return 41.0f * MIN(3.5f, (CGFloat)_hashtagList.count);
}

- (void)setHashtagListSignal:(SSignal *)hashtagListSignal
{
    if (hashtagListSignal == nil)
    {
        [_disposable setDisposable:nil];
        [self setHashtagList:@[]];
    }
    else
    {
        __weak TGModernConversationHashtagsAssociatedPanel *weakSelf = self;
        [_disposable setDisposable:[hashtagListSignal startWithNext:^(NSArray *hashtagList)
        {
            __strong TGModernConversationHashtagsAssociatedPanel *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf setHashtagList:hashtagList];
        }]];
    }
}

- (void)setHashtagList:(NSArray *)hashtagList
{
    _hashtagList = hashtagList;
    
    [_tableView reloadData];
    
    [self setNeedsPreferredHeightUpdate];
    
    _stripeView.hidden = hashtagList.count == 0;
    _separatorView.hidden = hashtagList.count == 0;
    _bottomView.hidden = hashtagList.count == 0;
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section
{
    return _hashtagList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGHashtagPanelCell *cell = (TGHashtagPanelCell *)[tableView dequeueReusableCellWithIdentifier:TGHashtagPanelCellKind];
    if (cell == nil)
        cell = [[TGHashtagPanelCell alloc] initWithStyle:self.style];
    
    [cell setHashtag:_hashtagList[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)__unused tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *hashtag = _hashtagList[indexPath.row];
    if (_hashtagSelected)
        _hashtagSelected(hashtag);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat separatorHeight = TGIsRetina() ? 0.5f : 1.0f;
    _stripeView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, separatorHeight);
    _separatorView.frame = CGRectMake(0.0f, self.frame.size.height - separatorHeight, self.frame.size.width, separatorHeight);
    
    _tableView.frame = CGRectMake(0.0f, separatorHeight, self.frame.size.width, self.frame.size.height - separatorHeight);
    
    _bottomView.frame = CGRectMake(0.0f, self.frame.size.height, self.frame.size.width, 4.0f);
}

@end
