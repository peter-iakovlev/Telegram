#import "TGStickerAssociatedInputPanel.h"

#import "TGStickerAssociatedPanelCollectionLayout.h"
#import "TGStickerAssociatedInputPanelCell.h"

#import "TGImageUtils.h"

@interface TGStickerAssociatedInputPanel () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    TGStickerAssociatedPanelCollectionLayout *_layout;
    
    NSArray *_documentList;
    
    CGFloat _targetOffset;
    UIImageView *_leftBackgroundView;
    UIImageView *_rightBackgroundView;
    UIImageView *_middleBackgroundView;
}

@end

@implementation TGStickerAssociatedInputPanel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        UIImage *leftImage = [UIImage imageNamed:@"StickerPanelPopupLeft.png"];
        UIImage *rightImage = [UIImage imageNamed:@"StickerPanelPopupRight.png"];
        UIImage *middleImage = [UIImage imageNamed:@"StickerPanelPopupMiddle.png"];
        
        _leftBackgroundView = [[UIImageView alloc] initWithImage:[leftImage stretchableImageWithLeftCapWidth:(int)(leftImage.size.width / 2.0f) topCapHeight:(int)(leftImage.size.height / 2.0f)]];
        [self addSubview:_leftBackgroundView];
        _rightBackgroundView = [[UIImageView alloc] initWithImage:[rightImage stretchableImageWithLeftCapWidth:(int)(rightImage.size.width / 2.0f) topCapHeight:(int)(rightImage.size.height / 2.0f)]];
        [self addSubview:_rightBackgroundView];
        _middleBackgroundView = [[UIImageView alloc] initWithImage:[middleImage stretchableImageWithLeftCapWidth:0 topCapHeight:(int)(middleImage.size.height / 2.0f)]];
        [self addSubview:_middleBackgroundView];
        
        _layout = [[TGStickerAssociatedPanelCollectionLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView.delaysContentTouches = false;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.clipsToBounds = true;
        [_collectionView registerClass:[TGStickerAssociatedInputPanelCell class]
            forCellWithReuseIdentifier:@"TGStickerAssociatedInputPanelCell"];
        [self addSubview:_collectionView];
    }
    return self;
}

- (CGFloat)preferredHeight
{
    return 75.0f;
}

- (NSArray *)documentList
{
    return _documentList;
}

- (void)setDocumentList:(NSArray *)documentList
{
    if (!TGObjectCompare(_documentList, documentList))
    {
        _documentList = documentList;
        [_collectionView reloadData];
        [_collectionView layoutSubviews];
    }
}

- (void)setTargetOffset:(CGFloat)targetOffset
{
    _targetOffset = targetOffset;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat localTargetOffset = _targetOffset;
    
    CGFloat topPadding = 5.0f;
    CGFloat backgroundHeight = _middleBackgroundView.image.size.height + 1 - TGRetinaPixel;
    
    CGFloat itemWidth = [self collectionView:_collectionView layout:_layout sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]].width;
    CGFloat collectionWidth = itemWidth * [self collectionView:_collectionView numberOfItemsInSection:0];
    
    CGFloat padding = 2.0f;
    CGFloat collectionPadding = 2.0f;
    
    CGFloat collectionOrigin = CGFloor((localTargetOffset - collectionWidth) / 2.0f);
    CGFloat middleOrigin = CGFloor((localTargetOffset - _middleBackgroundView.frame.size.width) / 2.0f);
    collectionOrigin = MAX(padding, collectionOrigin);
    
    _collectionView.frame = CGRectMake(collectionOrigin + collectionPadding, topPadding, self.frame.size.width - padding * 2.0f - collectionPadding * 2.0f, [self preferredHeight]);
    
    _middleBackgroundView.frame = CGRectMake(middleOrigin, topPadding, _middleBackgroundView.frame.size.width, backgroundHeight);
    _leftBackgroundView.frame = CGRectMake(collectionOrigin, topPadding, _middleBackgroundView.frame.origin.x - collectionOrigin, backgroundHeight);
    _rightBackgroundView.frame = CGRectMake(CGRectGetMaxX(_middleBackgroundView.frame), topPadding, MIN(collectionOrigin + collectionWidth, self.frame.size.width - padding) - CGRectGetMaxX(_middleBackgroundView.frame), backgroundHeight);
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)__unused section
{
    return _documentList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGStickerAssociatedInputPanelCell *cell = (TGStickerAssociatedInputPanelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TGStickerAssociatedInputPanelCell" forIndexPath:indexPath];
    
    [cell setDocument:_documentList[indexPath.row]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return CGSizeMake(72.0f, 72.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)__unused section
{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return 0.0f;
}

- (void)collectionView:(UICollectionView *)__unused collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_documentSelected)
        _documentSelected(_documentList[indexPath.row]);
}

@end
