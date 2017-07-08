#import "TGShareTopPeersCell.h"

#import "TGUserModel.h"
#import "LegacyDatabase.h"

#import "TGShareSinglePeerCell.h"

@interface TGShareTopPeersCell () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSArray *_peers;
    TGShareContext *_shareContext;
    
    UIView *_sectionContainer;
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_collectionLayout;
}
@end

@implementation TGShareTopPeersCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self != nil) {
        UIView *sectionContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        
        sectionContainer.clipsToBounds = false;
        sectionContainer.opaque = false;
        
        UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        sectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        sectionView.backgroundColor = TGColorWithHex(0xf7f7f7);
        [sectionContainer addSubview:sectionView];
        
        UILabel *sectionLabel = [[UILabel alloc] init];
        sectionLabel.tag = 100;
        sectionLabel.backgroundColor = sectionView.backgroundColor;
        sectionLabel.numberOfLines = 1;
        sectionLabel.font = [UIFont systemFontOfSize:12.0f weight:UIFontWeightSemibold];
        sectionLabel.text = [NSLocalizedString(@"Share.PeopleSection", nil) uppercaseString];
        sectionLabel.textColor = TGColorWithHex(0x8e8e93);
        [sectionLabel sizeToFit];
        sectionLabel.frame = CGRectMake(14.0f, 6.0f, sectionLabel.frame.size.width, sectionLabel.frame.size.height);
        [sectionContainer addSubview:sectionLabel];
        _sectionContainer = sectionContainer;
        [self addSubview:sectionContainer];
        
        _collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.opaque = false;
        _collectionView.backgroundColor = nil;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        [_collectionView registerClass:[TGShareSinglePeerCell class] forCellWithReuseIdentifier:@"TGShareSinglePeerCell"];
        [self addSubview:_collectionView];
    }
    return self;
}

- (void)setPeers:(NSArray *)peers shareContext:(TGShareContext *)shareContext
{
    _peers = peers;
    _shareContext = shareContext;
    
    [_collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)__unused collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return _peers.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TGShareSinglePeerCell *cell = (TGShareSinglePeerCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TGShareSinglePeerCell" forIndexPath:indexPath];
    
    TGUserModel *user = _peers[indexPath.item];
    [cell setPeer:user shareContext:_shareContext];
    [cell setChecked:self.isChecked(user.userId)];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGUserModel *user = _peers[indexPath.item];
    if (self.checked != nil)
        self.checked(user.userId);
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath {
    return CGSizeMake(70.0f, 80.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)__unused section {
    return UIEdgeInsetsMake(8.0f, 9.0f, 5.0f, 9.0f);
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)__unused section {
    return 15.0f;
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)__unused section {
    return 4.0f;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _sectionContainer.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, 28.0f);
    _collectionView.frame = CGRectMake(0.0f, 28.0f, self.bounds.size.width, self.bounds.size.height - 28.0f);
}

@end
