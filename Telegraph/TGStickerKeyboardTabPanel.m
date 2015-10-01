#import "TGStickerKeyboardTabPanel.h"

#import "TGStickerKeyboardTabCell.h"

#import "TGStickerPack.h"
#import "TGDocumentMediaAttachment.h"

#import "TGImageUtils.h"

@interface TGStickerKeyboardTabPanel () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    bool _showRecent;
    NSArray *_stickerPacks;
    
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_collectionLayout;
    UIView *_bottomStripe;
}

@end

@implementation TGStickerKeyboardTabPanel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.backgroundColor = UIColorRGB(0xfafafa);
        
        _collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height) collectionViewLayout:_collectionLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = nil;
        _collectionView.opaque = false;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        [_collectionView registerClass:[TGStickerKeyboardTabCell class] forCellWithReuseIdentifier:@"TGStickerKeyboardTabCell"];
        [self addSubview:_collectionView];
        
        CGFloat stripeHeight = TGIsRetina() ? 0.5f : 1.0f;
        _bottomStripe = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - stripeHeight, frame.size.width, stripeHeight)];
        _bottomStripe.backgroundColor = UIColorRGB(0xd8d8d8);
        [self addSubview:_bottomStripe];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    bool sizeUpdated = !CGSizeEqualToSize(frame.size, self.frame.size);
    [super setFrame:frame];
    
    if (sizeUpdated && frame.size.width > FLT_EPSILON && frame.size.height > FLT_EPSILON)
        [self layoutForSize:frame.size];
}

- (void)setBounds:(CGRect)bounds
{
    bool sizeUpdated = !CGSizeEqualToSize(bounds.size, self.bounds.size);
    [super setBounds:bounds];
    
    if (sizeUpdated && bounds.size.width > FLT_EPSILON && bounds.size.height > FLT_EPSILON)
        [self layoutForSize:bounds.size];
}

- (void)layoutForSize:(CGSize)size
{
    _collectionView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
    [_collectionLayout invalidateLayout];
    
    CGFloat stripeHeight = TGIsRetina() ? 0.5f : 1.0f;
    _bottomStripe.frame = CGRectMake(0.0f, size.height - stripeHeight, size.width, stripeHeight);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)__unused collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)__unused section
{
    return 1 + _stickerPacks.count;
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout*)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    if (indexPath.item == 0 && !_showRecent)
        return CGSizeMake(0.0f, 45.0f);
    return CGSizeMake(52.0f, 45.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)__unused section
{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout*)__unused collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)__unused collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return (collectionView.frame.size.width < 330.0f) ? 0.0f : 4.0f;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGStickerKeyboardTabCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TGStickerKeyboardTabCell" forIndexPath:indexPath];
    if (indexPath.item == 0)
        [cell setRecent];
    else
    {
        if (((TGStickerPack *)_stickerPacks[indexPath.item - 1]).documents.count != 0)
            [cell setDocumentMedia:((TGStickerPack *)_stickerPacks[indexPath.item - 1]).documents[0]];
        else
            [cell setNone];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)__unused collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_currentStickerPackIndexChanged)
        _currentStickerPackIndexChanged(indexPath.item);
}

- (void)setStickerPacks:(NSArray *)stickerPacks showRecent:(bool)showRecent
{
    _stickerPacks = stickerPacks;
    _showRecent = showRecent;
    
    [_collectionView reloadData];
}

- (void)setCurrentStickerPackIndex:(NSUInteger)currentStickerPackIndex
{
    NSArray *selectedItems = [_collectionView indexPathsForSelectedItems];
    if (selectedItems.count == 1 && ((NSIndexPath *)selectedItems[0]).item == (NSInteger)currentStickerPackIndex)
        return;
    
    UICollectionViewLayoutAttributes *attributes = [_collectionLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:currentStickerPackIndex inSection:0]];
    UICollectionViewScrollPosition scrollPosition = UICollectionViewScrollPositionNone;
    if (!CGRectContainsRect(_collectionView.bounds, attributes.frame))
    {
        if (attributes.frame.origin.x < _collectionView.bounds.origin.x + _collectionView.bounds.size.width / 2.0f)
        {
            scrollPosition = UICollectionViewScrollPositionLeft;
        }
        else
            scrollPosition = UICollectionViewScrollPositionRight;
    }
    [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:currentStickerPackIndex inSection:0] animated:false scrollPosition:scrollPosition];
}

@end
