#import "TGStickerAssociatedInputPanel.h"

#import "TGStickerAssociatedPanelCollectionLayout.h"
#import "TGStickerAssociatedInputPanelCell.h"

#import "TGImageUtils.h"

#import "TGSingleStickerPreviewWindow.h"

#import "TGDoubleTapGestureRecognizer.h"

@interface TGStickerAssociatedInputPanel () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TGDoubleTapGestureRecognizerDelegate>
{
    UICollectionView *_collectionView;
    TGStickerAssociatedPanelCollectionLayout *_layout;
    
    NSArray *_documentList;
    
    CGFloat _targetOffset;
    UIImageView *_leftBackgroundView;
    UIImageView *_rightBackgroundView;
    UIImageView *_middleBackgroundView;
    
    TGSingleStickerPreviewWindow *_stickerPreviewWindow;
}

@end

@implementation TGStickerAssociatedInputPanel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        NSString *leftImageName = (self.style == TGModernConversationAssociatedInputPanelDarkBlurredStyle) ? @"StickerPanelPopupLeftDark.png" : @"StickerPanelPopupLeft.png";
        NSString *rightImageName = (self.style == TGModernConversationAssociatedInputPanelDarkBlurredStyle) ? @"StickerPanelPopupRightDark.png" : @"StickerPanelPopupRight.png";
        NSString *middleImageName = (self.style == TGModernConversationAssociatedInputPanelDarkBlurredStyle) ? @"StickerPanelPopupMiddleDark.png" : @"StickerPanelPopupMiddle.png";
        
        UIImage *leftImage = [[UIImage imageNamed:leftImageName] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 10, 18, 1)];
        UIImage *rightImage = [[UIImage imageNamed:rightImageName] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 1, 18, 10)];
        UIImage *middleImage = [[UIImage imageNamed:middleImageName] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 2, 18, 2)];
        
        _leftBackgroundView = [[UIImageView alloc] initWithImage:leftImage];
        [self addSubview:_leftBackgroundView];
        _rightBackgroundView = [[UIImageView alloc] initWithImage:rightImage];
        [self addSubview:_rightBackgroundView];
        _middleBackgroundView = [[UIImageView alloc] initWithImage:middleImage];
        [self addSubview:_middleBackgroundView];
        
        if (self.style == TGModernConversationAssociatedInputPanelDarkBlurredStyle)
        {
            _leftBackgroundView.alpha = 0.96f;
            _rightBackgroundView.alpha = 0.96f;
            _middleBackgroundView.alpha = 0.96f;
        }
        
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
        
        UILongPressGestureRecognizer *tapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapGesture:)];
        tapRecognizer.minimumPressDuration = 0.25;
        
        [_collectionView addGestureRecognizer:tapRecognizer];
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
    CGFloat collectionTopPadding = topPadding;
    
    if (self.style == TGModernConversationAssociatedInputPanelDarkBlurredStyle)
    {
        topPadding = -12.0f;
        collectionTopPadding = -4.0f;
    }
    
    CGFloat backgroundHeight = _middleBackgroundView.image.size.height + 1 - TGRetinaPixel;
    
    CGFloat itemWidth = [self collectionView:_collectionView layout:_layout sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]].width;
    CGFloat collectionWidth = itemWidth * [self collectionView:_collectionView numberOfItemsInSection:0];
    
    CGFloat padding = 2.0f;
    CGFloat collectionPadding = 2.0f;
    
    CGFloat collectionOrigin = CGFloor((localTargetOffset - collectionWidth) / 2.0f);
    CGFloat middleOrigin = CGFloor((localTargetOffset - _middleBackgroundView.frame.size.width) / 2.0f);
    collectionOrigin = MAX(padding, collectionOrigin);
    
    _collectionView.frame = CGRectMake(collectionOrigin + collectionPadding, collectionTopPadding, self.frame.size.width - padding * 2.0f - collectionPadding * 2.0f, [self preferredHeight]);
    
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

- (void)longTapGesture:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _stickerPreviewWindow.hidden = true;
        
        __strong TGViewController *controller = _controller;
        NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:[recognizer locationInView:_collectionView]];
        if (indexPath != nil && controller != nil) {
            TGDocumentMediaAttachment *document = _documentList[indexPath.item];
            _stickerPreviewWindow = [[TGSingleStickerPreviewWindow alloc] initWithParentController:controller];
            _stickerPreviewWindow.userInteractionEnabled = false;
            [_stickerPreviewWindow.view setDocument:document];
            _stickerPreviewWindow.hidden = false;
        }
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled)
        {
        __weak UIWindow *weakWindow = _stickerPreviewWindow;
        [_stickerPreviewWindow.view animateDismiss:^{
            __strong UIWindow *strongWindow = weakWindow;
            strongWindow.hidden = true;
        }];
        _stickerPreviewWindow = nil;
    }
}

@end
