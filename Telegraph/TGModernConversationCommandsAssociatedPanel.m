#import "TGModernConversationCommandsAssociatedPanel.h"

#import "TGCommandPanelCell.h"
#import "TGBotComandInfo.h"

#import "TGImageUtils.h"

#import "TGUser.h"

@interface TGModernConversationCommandsAssociatedPanel () <UITableViewDelegate, UITableViewDataSource>
{
    SMetaDisposable *_disposable;
    NSArray *_commandList;
    NSUInteger _commandCount;
    bool _hasUsers;
    
    UITableView *_tableView;
    UIView *_stripeView;
    UIView *_separatorView;
    
    UIView *_bottomView;
}

@end

@implementation TGModernConversationCommandsAssociatedPanel

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
            _tableView.separatorInset = UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 0.0f);
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
    return 41.0f * MIN(3.5f, (CGFloat)_commandCount);
}

- (void)setCommandListSignal:(SSignal *)commandListSignal
{
    if (commandListSignal == nil)
    {
        [_disposable setDisposable:nil];
        [self setCommandList:@[]];
    }
    else
    {
        __weak TGModernConversationCommandsAssociatedPanel *weakSelf = self;
        [_disposable setDisposable:[commandListSignal startWithNext:^(NSArray *commandList)
        {
            __strong TGModernConversationCommandsAssociatedPanel *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf setCommandList:commandList];
        }]];
    }
}

- (void)setCommandList:(NSArray *)commandList
{
    _commandList = commandList;
    _commandCount = 0;
    _hasUsers = false;
    for (NSArray *array in commandList)
    {
        _commandCount += ((NSArray *)array[1]).count;
        _hasUsers |= [array[0] isKindOfClass:[TGUser class]];
    }
    
    [_tableView reloadData];
    
    [self setNeedsPreferredHeightUpdate];
    
    _stripeView.hidden = _commandCount == 0;
    _separatorView.hidden = _commandCount == 0;
    _bottomView.hidden = _commandCount == 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView
{
    return _commandList.count;
}

-(void)tableView:(UITableView *)__unused tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)__unused indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0.0f, _hasUsers ? 51.0f : 6.0f, 0.0f, 0.0f)];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)section
{
    return ((NSArray *)_commandList[section][1]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGCommandPanelCell *cell = (TGCommandPanelCell *)[tableView dequeueReusableCellWithIdentifier:@"TGCommandPanelCell"];
    if (cell == nil)
    {
        cell = [[TGCommandPanelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TGCommandPanelCell"];
    }
    
    TGUser *user = _commandList[indexPath.section][0];
    if (![user isKindOfClass:[TGUser class]])
        user = nil;
    
    [cell setCommandInfo:((NSArray *)_commandList[indexPath.section][1])[indexPath.row] user:user];
    
    return cell;
}

- (void)tableView:(UITableView *)__unused tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGUser *user = _commandList[indexPath.section][0];
    if (![user isKindOfClass:[TGUser class]])
        user = nil;
    
    if (_commandSelected)
        _commandSelected(((NSArray *)_commandList[indexPath.section][1])[indexPath.row], user);
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
