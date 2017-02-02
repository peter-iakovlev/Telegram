#import "TGWidgetController.h"
#import <NotificationCenter/NotificationCenter.h>

#import "TGWidgetSignals.h"
#import "TGWidgetUser.h"

#import "TGWidgetUserCell.h"

const UIEdgeInsets TGWidgetCollectionInsets = { 19.0f, 8.0f, 8.0f, 8.0f };

@interface TGWidgetController () <NCWidgetProviding, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    UIVisualEffectView *_effectView;
    UICollectionViewFlowLayout *_collectionLayout;
    UICollectionView *_collectionView;
    UILabel *_label;
    
    SMetaDisposable *_disposable;
    NSArray *_users;
    int32_t _clientUserId;
}
@end

@implementation TGWidgetController

- (void)dealloc
{
    [_disposable dispose];
}

#pragma mark - View

- (void)loadView
{
    [super loadView];
    self.view.tintColor = [UIColor clearColor];
    
    _collectionLayout = [[UICollectionViewFlowLayout alloc] init];
    _collectionLayout.minimumInteritemSpacing = 4;
    _collectionLayout.minimumLineSpacing = 20.0f;
    _collectionLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UIVisualEffect *effect = nil;
    if ([UIVibrancyEffect respondsToSelector:@selector(widgetPrimaryVibrancyEffect)])
        effect = [UIVibrancyEffect widgetPrimaryVibrancyEffect];
    else
        effect = [UIVibrancyEffect notificationCenterVibrancyEffect];
    
    _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    _effectView.frame = self.view.bounds;
    _effectView.autoresizingMask = self.view.autoresizingMask;
    [self.view addSubview:_effectView];

    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:_collectionLayout];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.scrollEnabled = false;
    [_collectionView registerClass:[TGWidgetUserCell class] forCellWithReuseIdentifier:TGWidgetUserCellIdentifier];
    [self.view addSubview:_collectionView];
    
    _label = [[UILabel alloc] initWithFrame:self.view.bounds];
    _label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _label.font = [UIFont systemFontOfSize:14.0f];
    _label.hidden = true;
    _label.textAlignment = NSTextAlignmentCenter;
    [_effectView.contentView addSubview:_label];
}

- (void)viewDidLoad
{
    __weak TGWidgetController *weakSelf = self;
    [_disposable setDisposable:[[TGWidgetSignals peopleSignal] startWithNext:^(NSDictionary *data)
    {
        __strong TGWidgetController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (data != nil)
        {
            NSArray *users = data[@"users"];
            if (users.count > 0)
                [strongSelf updateCollectionViewWithUsers:users];
            else
                [strongSelf setNoUsers];
            
            strongSelf->_clientUserId = (int32_t)[data[@"clientUserId"] integerValue];
        }
        else
        {
            [strongSelf setLoginRequired];
        }
    }]];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _collectionView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 205.0f);
}

- (void)updateCollectionViewWithUsers:(NSArray *)users
{
    _users = users;
    
    _collectionView.hidden = false;
    [_collectionView reloadData];
    
    [self.extensionContext setWidgetLargestAvailableDisplayMode:users.count > 4 ? NCWidgetDisplayModeExpanded : NCWidgetDisplayModeCompact];
}

- (void)setPasscodeRequired
{
    [self _hideCollectionView];
}

- (void)setLoginRequired
{
    [self _hideCollectionView];
    [self _setLabelText:NSLocalizedString(@"Widget.AuthRequired", nil)];
}

- (void)setNoUsers
{
    [self _hideCollectionView];
    [self _setLabelText:NSLocalizedString(@"Widget.NoUsers", nil)];
}

- (void)_hideCollectionView
{
    _collectionView.hidden = true;
    [self.extensionContext setWidgetLargestAvailableDisplayMode:NCWidgetDisplayModeCompact];
}

- (void)_setLabelText:(NSString *)text
{
    _label.text = text;
    _label.hidden = false;
}

#pragma mark - Collection View Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _users.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGWidgetUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TGWidgetUserCellIdentifier forIndexPath:indexPath];
    
    TGWidgetUser *user = _users[indexPath.row];
    [cell setUser:user avatarSignal:[TGWidgetSignals userAvatarWithUser:user clientUserId:_clientUserId] effectView:_effectView];
    
    if ([self isCompactDisplayMode] && indexPath.row > 3)
        [cell setHidden:true animated:false];
    
    return cell;
}

#pragma mark - Collection View Delegate

- (void)collectionView:(UICollectionView *)__unused collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGWidgetUser *user = _users[indexPath.row];
    [self openApplicationWithUser:user];
}

#pragma mark - Collection View Layout

- (bool)isCompactDisplayMode
{
    return self.extensionContext.widgetActiveDisplayMode == NCWidgetDisplayModeCompact;
}

- (void)updateExpandedCellsVisibilityAnimated:(bool)animated
{
    bool compact = [self isCompactDisplayMode];
    
    for (NSIndexPath *indexPath in _collectionView.indexPathsForVisibleItems)
    {
        TGWidgetUserCell *cell = (TGWidgetUserCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        bool hidden = indexPath.row > 3 && compact;
        [cell setHidden:hidden animated:animated];
    }
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return TGWidgetUserCellSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)__unused section
{
    CGFloat width = collectionView.frame.size.width;
    NSInteger itemsCount = [collectionView numberOfItemsInSection:0];
    NSInteger columns = (NSInteger)floor((width - TGWidgetCollectionInsets.left - TGWidgetCollectionInsets.right) / (_collectionLayout.itemSize.width + _collectionLayout.minimumInteritemSpacing));
    
    if (itemsCount >= columns)
        return UIEdgeInsetsMake(TGWidgetCollectionInsets.top, TGWidgetCollectionInsets.left, TGWidgetCollectionInsets.bottom, TGWidgetCollectionInsets.right);
    
    CGFloat inset = (width - (_collectionLayout.itemSize.width + _collectionLayout.minimumInteritemSpacing) * itemsCount - _collectionLayout.minimumInteritemSpacing) / 2.0f;
    
    return UIEdgeInsetsMake(TGWidgetCollectionInsets.top, inset, TGWidgetCollectionInsets.bottom, inset);
}

#pragma mark - Widget

- (void)openApplicationWithUser:(TGWidgetUser *)user
{
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"tg://user?id=%d", user.identifier]];
    [self.extensionContext openURL:url completionHandler:nil];
}

- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize
{
    switch (activeDisplayMode)
    {
        case NCWidgetDisplayModeCompact:
            self.preferredContentSize = CGSizeMake(0.0f, 110.0f);
            break;
            
        default:
            self.preferredContentSize = CGSizeMake(0.0f, 205.0f);
            break;
    }
    
    [self updateExpandedCellsVisibilityAnimated:true];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler
{
    completionHandler(NCUpdateResultNoData);
}

@end
