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
    bool _showTrendingFirst;
    bool _showTrendingLast;
    NSArray *_stickerPacks;
    
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_collectionLayout;
    UIView *_bottomStripe;
    
    NSString *_trendingStickersBadge;
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
        
        _collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height) collectionViewLayout:_collectionLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = nil;
        _collectionView.opaque = false;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.contentInset = UIEdgeInsetsZero;
        [_collectionView registerClass:[TGStickerKeyboardTabCell class] forCellWithReuseIdentifier:@"TGStickerKeyboardTabCell"];
        [_collectionView registerClass:[TGStickerKeyboardTabSettingsCell class] forCellWithReuseIdentifier:@"TGStickerKeyboardTabSettingsCell"];
        [self addSubview:_collectionView];
        
        switch (style)
        {
            case TGStickerKeyboardViewDarkBlurredStyle:
            {
                self.backgroundColor = UIColorRGB(0x444444);
            }
                break;
                
            case TGStickerKeyboardViewPaintStyle:
            {
                self.backgroundColor = [UIColor clearColor];
                _collectionView.contentInset = UIEdgeInsetsMake(0.0f, 12.0f, 0.0f, 12.0f);
            }
                break;
                
            case TGStickerKeyboardViewPaintDarkStyle:
            {
                self.backgroundColor = [UIColor clearColor];
                _collectionView.contentInset = UIEdgeInsetsMake(0.0f, 12.0f, 0.0f, 12.0f);
            }
                break;
                
            default:
            {
                self.backgroundColor = UIColorRGB(0xfafafa);
                
                CGFloat stripeHeight = TGIsRetina() ? 0.5f : 1.0f;
                _bottomStripe = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - stripeHeight, frame.size.width, stripeHeight)];
                _bottomStripe.backgroundColor = UIColorRGB(0xd8d8d8);
                [self addSubview:_bottomStripe];
            }
                break;
        }
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
    return 2 + ((_style == TGStickerKeyboardViewDefaultStyle) ? 1 : 0);
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)__unused section
{
    if (section == 0) {
        return (_showGifs ? 1 : 0) + (_showTrendingFirst ? 1 : 0);
    } else if (section == 1) {
        return 1 + _stickerPacks.count;
    } else if (section == 2) {
        return 1 + (_showTrendingLast ? 1 : 0);
    } else {
        return 0;
    }
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout*)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    if (indexPath.section == 1 && indexPath.item == 0 && !_showRecent)
        return CGSizeMake(1.0f, 45.0f);
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
        if (indexPath.item == 0 && _showGifs) {
            [cell setMode:TGStickerKeyboardTabSettingsCellGifs];
            [cell setBadge:nil];
        } else {
            [cell setMode:TGStickerKeyboardTabSettingsCellTrending];
            [cell setBadge:_trendingStickersBadge];
        }
        return cell;
    } else if (indexPath.section == 1) {
        TGStickerKeyboardTabCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TGStickerKeyboardTabCell" forIndexPath:indexPath];
        [cell setStyle:_style];
        
        if (indexPath.item == 0) {
            if (_showRecent) {
                [cell setRecent];
            } else {
                [cell setNone];
            }
        }
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
        if (_showTrendingLast && indexPath.item == 0) {
            [cell setBadge:_trendingStickersBadge];
            [cell setMode:TGStickerKeyboardTabSettingsCellTrending];
            cell.pressed = nil;
        } else {
            [cell setBadge:nil];
            [cell setMode:TGStickerKeyboardTabSettingsCellSettings];
            cell.pressed = ^{
                [TGAppDelegateInstance.rootController presentViewController:[TGNavigationController navigationControllerWithControllers:@[[[TGStickerPacksSettingsController alloc] initWithEditing:true masksMode:false]]] animated:true completion:nil];
            };
        }
        return cell;
    } else {
        return nil;
    }
}

- (void)collectionView:(UICollectionView *)__unused collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.item == 0 && _showGifs) {
            [self scrollToGifsButton];
        } else {
            [self scrollToTrendingButton];
        }
    } else if (indexPath.section == 1) {
        if (_currentStickerPackIndexChanged)
            _currentStickerPackIndexChanged(indexPath.item);
    } else if (indexPath.section == 2) {
        if (indexPath.item == 0 && _showTrendingLast) {
            [self scrollToTrendingButton];
        }
    }
}

- (void)setStickerPacks:(NSArray *)stickerPacks showRecent:(bool)showRecent showGifs:(bool)showGifs showTrendingFirst:(bool)showTrendingFirst showTrendingLast:(bool)showTrendingLast {
    _stickerPacks = stickerPacks;
    _showRecent = showRecent;
    _showGifs = showGifs;
    _showTrendingFirst = showTrendingFirst;
    _showTrendingLast = showTrendingLast;
    
    [_collectionView reloadData];
}

- (void)setCurrentStickerPackIndex:(NSUInteger)currentStickerPackIndex animated:(bool)animated
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
    [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:currentStickerPackIndex inSection:1] animated:animated scrollPosition:scrollPosition];
}

- (void)setCurrentGifsModeSelected {
    [self scrollToGifsButton];
}

- (void)setCurrentTrendingModeSelected {
    [self scrollToTrendingButton];
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

- (void)scrollToTrendingButton {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_showGifs ? 1 : 0 inSection:0];
    if (_showTrendingLast) {
        indexPath = [NSIndexPath indexPathForItem:0 inSection:2];
    }
    if (indexPath.section < [self numberOfSectionsInCollectionView:_collectionView] && indexPath.item < [self collectionView:_collectionView numberOfItemsInSection:indexPath.section]) {
        UICollectionViewLayoutAttributes *attributes = [_collectionLayout layoutAttributesForItemAtIndexPath:indexPath];
        
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
        [_collectionView selectItemAtIndexPath:indexPath animated:false scrollPosition:scrollPosition];
        
        if (_showTrendingLast) {
            if (_navigateToTrendingLast) {
                _navigateToTrendingLast();
            }
        } else {
            if (_navigateToTrendingFirst) {
                _navigateToTrendingFirst();
            }
        }
    }
}

- (void)setTrendingStickersBadge:(NSString *)badge {
    if (!TGStringCompare(_trendingStickersBadge, badge)) {
        _trendingStickersBadge = badge;
        for (id cell in [_collectionView visibleCells]) {
            if ([cell isKindOfClass:[TGStickerKeyboardTabSettingsCell class]]) {
                if (((TGStickerKeyboardTabSettingsCell *)cell).mode == TGStickerKeyboardTabSettingsCellTrending) {
                    [(TGStickerKeyboardTabSettingsCell *)cell setBadge:badge];
                }
            }
        }
        TGStickerKeyboardTabSettingsCell *cell = (TGStickerKeyboardTabSettingsCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:2]];
        if (cell != nil) {
            [cell setBadge:badge];
        }
    }
}

@end
