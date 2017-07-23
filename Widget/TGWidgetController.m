#import "TGWidgetController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <LegacyDatabase/LegacyDatabase.h>

#import "TGWidget.h"
#import "TGWidgetSignals.h"
#import "TGWidgetUserCell.h"

const UIEdgeInsets TGWidgetCollectionInsets = { 16.0f, 8.0f, 8.0f, 8.0f };
const UIEdgeInsets TGWidgetCollectionSmallInsets = { 16.0f, 4.0f, 8.0f, 4.0f };

@interface TGWidgetController () <NCWidgetProviding, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    UIVisualEffectView *_effectView;
    UICollectionViewFlowLayout *_collectionLayout;
    UICollectionView *_collectionView;
    UILabel *_label;
    
    SMetaDisposable *_disposable;
    NSArray *_users;
    NSDictionary *_unreadCounts;
    
    TGShareContext *_context;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    __weak TGWidgetController *weakSelf = self;
    _disposable = [[SMetaDisposable alloc] init];
    [_disposable setDisposable:[[[TGWidgetSignals topPeersSignal] deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *next)
    {
        __strong TGWidgetController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (next != nil)
            [strongSelf updateCollectionViewWithUsers:next[@"users"] unreadCounts:next[@"unreadCounts"] context:next[@"context"]];
        else
            [strongSelf setLoginRequired];
    }]];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _collectionView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 205.0f);
}

- (void)updateCollectionViewWithUsers:(NSArray *)users unreadCounts:(NSDictionary *)unreadCounts context:(TGShareContext *)context
{
    _users = users;
    _context = context;
    _unreadCounts = unreadCounts;
    
    if (users.count == 0)
    {
        [self setNoUsers];
    }
    else
    {
        [self _setLabelText:nil];
        _collectionView.hidden = false;
        [_collectionView reloadData];
        [_collectionView layoutSubviews];
    }
    
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
    _label.hidden = text.length == 0;
}

#pragma mark - Collection View Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _users.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGWidgetUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TGWidgetUserCellIdentifier forIndexPath:indexPath];
    
    TGLegacyUser *user = _users[indexPath.row];
    NSUInteger unreadCount = [_unreadCounts[@(user.userId)] unsignedIntegerValue];
    [cell setUser:user avatarSignal:[TGWidgetSignals userAvatarWithContext:_context user:user] unreadCount:unreadCount effectView:_effectView];
    
    if ([self isCompactDisplayMode] && indexPath.row > 3)
        [cell setHidden:true animated:false];
    
    return cell;
}

#pragma mark - Collection View Delegate

- (void)collectionView:(UICollectionView *)__unused collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGLegacyUser *user = _users[indexPath.row];
    [self openApplicationWithUser:user];
}

#pragma mark - Collection View Layout

- (bool)isCompactDisplayMode
{
    if ([self.extensionContext respondsToSelector:@selector(widgetActiveDisplayMode)]) {
        return self.extensionContext.widgetActiveDisplayMode == NCWidgetDisplayModeCompact;
    } else {
        return true;
    }
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
    if ([UIScreen mainScreen].bounds.size.width == 320)
        return TGWidgetSmallUserCellSize;

    return TGWidgetUserCellSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)__unused section
{
    UIEdgeInsets insets = TGWidgetCollectionInsets;
    if ([UIScreen mainScreen].bounds.size.width == 320)
        insets = TGWidgetCollectionSmallInsets;
    
    CGFloat width = collectionView.frame.size.width;
    NSInteger itemsCount = [collectionView numberOfItemsInSection:0];
    NSInteger columns = (NSInteger)floor((width - insets.left - insets.right) / (_collectionLayout.itemSize.width + _collectionLayout.minimumInteritemSpacing));
    
    if (itemsCount >= columns)
        return UIEdgeInsetsMake(insets.top, insets.left, insets.bottom, insets.right);
    
    CGFloat inset = (width - (_collectionLayout.itemSize.width + _collectionLayout.minimumInteritemSpacing) * itemsCount - _collectionLayout.minimumInteritemSpacing) / 2.0f;
    
    return UIEdgeInsetsMake(insets.top, inset, insets.bottom, inset);
}

#pragma mark - Widget

- (void)openApplicationWithUser:(TGLegacyUser *)user
{
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"tg://user?id=%d", user.userId]];
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
