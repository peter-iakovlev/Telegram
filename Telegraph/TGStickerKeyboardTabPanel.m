#import "TGStickerKeyboardTabPanel.h"

#import "TGStickerKeyboardTabCell.h"
#import "TGStickerKeyboardTabSettingsCell.h"

#import "TGStickerPack.h"
#import "TGDocumentMediaAttachment.h"

#import "TGImageUtils.h"

#import "TGStickerPacksSettingsController.h"
#import "TGAppDelegate.h"

@interface TGStickerKeyboardTabPanel () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    TGStickerKeyboardViewStyle _style;
    
    bool _showRecent;
    bool _showGifs;
    NSArray *_stickerPacks;
    
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_collectionLayout;
    UIView *_bottomStripe;
}

@end

@implementation TGStickerKeyboardTabPanel

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame style:TGStickerKeyboardViewDefaultStyle];
}

- (instancetype)initWithFrame:(CGRect)frame style:(TGStickerKeyboardViewStyle)style
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _style = style;
        
        if (style == TGStickerKeyboardViewDarkBlurredStyle)
            self.backgroundColor = UIColorRGB(0x444444);
        else
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
        [_collectionView registerClass:[TGStickerKeyboardTabSettingsCell class] forCellWithReuseIdentifier:@"TGStickerKeyboardTabSettingsCell"];
        [self addSubview:_collectionView];
        
        CGFloat stripeHeight = TGIsRetina() ? 0.5f : 1.0f;
        _bottomStripe = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - stripeHeight, frame.size.width, stripeHeight)];
        _bottomStripe.backgroundColor = UIColorRGB(0xd8d8d8);
        if (style != TGStickerKeyboardViewDarkBlurredStyle)
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
    return 2 + ((_stickerPacks.count > 1 && _style == TGStickerKeyboardViewDefaultStyle) ? 1 : 0);
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)__unused section
{
    if (section == 0) {
        return _showGifs ? 1 : 0;
    } else if (section == 1) {
        return 1 + _stickerPacks.count;
    } else if (section == 2) {
        return 1;
    } else {
        return 0;
    }
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout*)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    if (indexPath.section == 1 && indexPath.item == 0 && !_showRecent)
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
    if (indexPath.section == 0) {
        TGStickerKeyboardTabSettingsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TGStickerKeyboardTabSettingsCell" forIndexPath:indexPath];
        [cell setMode:TGStickerKeyboardTabSettingsCellGifs];
        return cell;
    } else if (indexPath.section == 1) {
        TGStickerKeyboardTabCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TGStickerKeyboardTabCell" forIndexPath:indexPath];
        [cell setStyle:_style];
        
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
    } else if (indexPath.section == 2) {
        TGStickerKeyboardTabSettingsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TGStickerKeyboardTabSettingsCell" forIndexPath:indexPath];
        [cell setMode:TGStickerKeyboardTabSettingsCellSettings];
        cell.pressed = ^{
            [TGAppDelegateInstance.rootController presentViewController:[TGNavigationController navigationControllerWithControllers:@[[[TGStickerPacksSettingsController alloc] initWithEditing:true]]] animated:true completion:nil];
        };
        return cell;
    } else {
        return nil;
    }
}

- (void)collectionView:(UICollectionView *)__unused collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self scrollToGifsButton];
    } else if (indexPath.section == 1) {
        if (_currentStickerPackIndexChanged)
            _currentStickerPackIndexChanged(indexPath.item);
    }
}

- (void)setStickerPacks:(NSArray *)stickerPacks showRecent:(bool)showRecent showGifs:(bool)showGifs
{
    _stickerPacks = stickerPacks;
    _showRecent = showRecent;
    _showGifs = showGifs;
    
    [_collectionView reloadData];
}

- (void)setCurrentStickerPackIndex:(NSUInteger)currentStickerPackIndex
{
    NSArray *selectedItems = [_collectionView indexPathsForSelectedItems];
    if (selectedItems.count == 1 && ((NSIndexPath *)selectedItems[0]).item == (NSInteger)currentStickerPackIndex)
        return;
    
    UICollectionViewLayoutAttributes *attributes = [_collectionLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:currentStickerPackIndex inSection:1]];
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
    [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:currentStickerPackIndex inSection:1] animated:false scrollPosition:scrollPosition];
}

- (void)setCurrentGifsModeSelected {
    [self scrollToGifsButton];
}

- (void)scrollToGifsButton {
    UICollectionViewLayoutAttributes *attributes = [_collectionLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
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
    [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:false scrollPosition:scrollPosition];
    
    if (_navigateToGifs) {
        _navigateToGifs();
    }
}

@end
