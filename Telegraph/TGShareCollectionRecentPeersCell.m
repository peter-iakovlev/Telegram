#import "TGShareCollectionRecentPeersCell.h"
#import "TGModernMediaCollectionView.h"

#import "TGShareCollectionCell.h"

#import <SSignalKit/SSignalKit.h>

#import "TGDialogListRecentPeers.h"

#import "TGUser.h"
#import "TGConversation.h"
#import "TGModernButton.h"
#import "TGFont.h"

NSString *const TGShareCollectionRecentPeersCellIdentifier = @"TGShareCollectionRecentPeersCell";

@interface TGShareCollectionRecentPeersCell () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource> {
    NSArray *_recentPeers;
    
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_collectionLayout;
    
    UIView *_headerBackground;
    UILabel *_headerLabel;
    
    UIView *_bottomHeaderBackground;
    UILabel *_bottomHeaderLabel;
}

@end

@implementation TGShareCollectionRecentPeersCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.clipsToBounds = true;
        
        _headerBackground = [[UIView alloc] init];
        _headerBackground.backgroundColor = UIColorRGB(0xf7f7f7);
        [self addSubview:_headerBackground];
        
        _headerLabel = [[UILabel alloc] init];
        _headerLabel.backgroundColor = UIColorRGB(0xf7f7f7);
        _headerLabel.opaque = true;
        _headerLabel.textColor = UIColorRGB(0x8e8e93);
        _headerLabel.font = TGBoldSystemFontOfSize(12.0f);
        [self addSubview:_headerLabel];
    
        _bottomHeaderBackground = [[UIView alloc] init];
        _bottomHeaderBackground.backgroundColor = UIColorRGB(0xf7f7f7);
        [self addSubview:_bottomHeaderBackground];
        
        _bottomHeaderLabel = [[UILabel alloc] init];
        _bottomHeaderLabel.backgroundColor = UIColorRGB(0xf7f7f7);
        _bottomHeaderLabel.opaque = true;
        _bottomHeaderLabel.text = [TGLocalized(@"DialogList.SearchSectionRecent") uppercaseString];
        _bottomHeaderLabel.textColor = UIColorRGB(0x8e8e93);
        _bottomHeaderLabel.font = TGBoldSystemFontOfSize(12.0f);
        [_bottomHeaderLabel sizeToFit];
        [self addSubview:_bottomHeaderLabel];
        
        _collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.opaque = false;
        _collectionView.backgroundColor = nil;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        [_collectionView registerClass:[TGShareCollectionCell class] forCellWithReuseIdentifier:TGShareCollectionCellIdentifier];
        [self addSubview:_collectionView];
    }
    return self;
}

- (void)dealloc {
}

- (void)setRecentPeers:(TGDialogListRecentPeers *)recentPeers {
    [self setPeers:recentPeers.peers];
    _headerLabel.text = [recentPeers.title uppercaseString];
    [_headerLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)setPeers:(NSArray<TGConversation *> *)peers {
    _recentPeers = peers;
    [_collectionView reloadData];
}

+ (UIEdgeInsets)insets {
    return UIEdgeInsetsMake(8.0f, 16.0f, 5.0f, 16.0f);
}

+ (CGSize)itemSize {
    return CGSizeMake(70.0f, 90.0f);
}

+ (CGFloat)horizontalSpacing {
    return 0.0f;
}

+ (CGFloat)verticalSpacing {
    
    return 15.0f;
}

+ (NSInteger)maxRowCount:(bool)expanded {
    return expanded ? 3 : 1;
}

+ (CGFloat)heightForWidth:(CGFloat)width count:(NSInteger)count expanded:(bool)expanded {
    UIEdgeInsets insets = [TGShareCollectionRecentPeersCell insets];
    CGSize itemSize = [TGShareCollectionRecentPeersCell itemSize];
    CGFloat horizontalSpacing = [TGShareCollectionRecentPeersCell verticalSpacing];
    CGFloat verticalSpacing = [TGShareCollectionRecentPeersCell verticalSpacing];
    
    NSInteger columnCount = (NSInteger)((width - insets.left - insets.right + horizontalSpacing) / (itemSize.width + horizontalSpacing));
    NSInteger rowCount = MIN([self maxRowCount:expanded], count / columnCount + (count % columnCount == 0 ? 0 : 1));
    
    return 27.0f + rowCount * itemSize.height + MAX(0, rowCount - 1) * verticalSpacing + insets.top + insets.bottom;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _headerBackground.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 27.0f);
    _headerLabel.frame = CGRectMake(14.0f, 6.0f, _headerLabel.frame.size.width, _headerLabel.frame.size.height);
    
    _bottomHeaderBackground.frame = CGRectMake(0.0f, 117.0f, self.frame.size.width, 27.0f);
    _bottomHeaderLabel.frame = CGRectMake(14.0f, CGRectGetMinY(_bottomHeaderBackground.frame) + 6.0f, _bottomHeaderLabel.frame.size.width, _bottomHeaderLabel.frame.size.height);
    
    _collectionView.frame = CGRectMake(0.0f, 27.0f, self.frame.size.width, 90.0f);
}

- (void)expandButtonPressed {
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)__unused collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0)
        return _recentPeers.count;

    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGShareCollectionCell *cell = (TGShareCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:TGShareCollectionCellIdentifier forIndexPath:indexPath];
    
    [cell setShowOnlyFirstName:true];
    
    id peer = _recentPeers[indexPath.item];
    int64_t peerId = [peer isKindOfClass:[TGUser class]] ? [(TGUser *)peer uid] : [(TGConversation *)peer conversationId];
    [cell setPeer:peer];
    [cell setChecked:self.isChecked(peerId)];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)__unused collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id peer = _recentPeers[indexPath.row];
    int64_t peerId = [peer isKindOfClass:[TGUser class]] ? [(TGUser *)peer uid] : [(TGConversation *)peer conversationId];
    
    bool checked = self.toggleChecked(peerId, peer);

    for (TGShareCollectionCell *cell in _collectionView.visibleCells)
    {
        if (cell.peerId == peerId)
            [cell setChecked:checked animated:true];
    }
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout*)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath {
    return CGSizeMake(70.0f, 80.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)__unused section {
    return [TGShareCollectionRecentPeersCell insets];
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)__unused section {
    return [TGShareCollectionRecentPeersCell verticalSpacing];
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)__unused section {
    return [TGShareCollectionRecentPeersCell horizontalSpacing];
}

@end
