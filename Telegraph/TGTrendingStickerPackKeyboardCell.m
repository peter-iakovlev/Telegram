#import "TGTrendingStickerPackKeyboardCell.h"

#import "TGFont.h"

#import "TGStickerPack.h"
#import "TGStringUtils.h"

#import "TGModernButton.h"

#import "TGStickerCollectionViewCell.h"

static CGFloat preloadInset = 64.0f;

@interface TGTrendingStickerPackKeyboardCell () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource> {
    UILabel *_titleLabel;
    UILabel *_countLabel;
    
    TGModernButton *_button;
    
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_collectionLayout;
    
    TGStickerPack *_stickerPack;
    
    UIImageView *_dotView;
}

@end

@implementation TGTrendingStickerPackKeyboardCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGBoldSystemFontOfSize(16.0f);
        [self.contentView addSubview:_titleLabel];
        
        _countLabel = [[UILabel alloc] init];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.textColor = UIColorRGB(0x8e8e93);
        _countLabel.font = TGSystemFontOfSize(14.5f);
        [self.contentView addSubview:_countLabel];
        
        static UIImage *buttonImage = nil;
        static UIImage *dotImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            {
                CGSize size = CGSizeMake(8.0f, 8.0f);
                UIGraphicsBeginImageContextWithOptions(size, false, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetStrokeColorWithColor(context, TGAccentColor().CGColor);
                CGContextSetLineWidth(context, 1.0f);
                CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, size.width - 1.0f, size.height - 1.0f));
                buttonImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)(size.width / 2.0f) topCapHeight:(NSInteger)(size.height / 2.0f)];
                UIGraphicsEndImageContext();
            }
            {
                CGSize size = CGSizeMake(6.0f, 6.0f);
                UIGraphicsBeginImageContextWithOptions(size, false, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetFillColorWithColor(context, TGAccentColor().CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, size.width, size.height));
                dotImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
        });
        
        _button = [[TGModernButton alloc] init];
        [_button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        _button.modernHighlight = true;
        [_button setTitle:TGLocalized(@"Stickers.Install") forState:UIControlStateNormal];
        [_button setTitleColor:TGAccentColor()];
        _button.titleLabel.font = TGMediumSystemFontOfSize(13.0f);
        _button.contentEdgeInsets = UIEdgeInsetsMake(5.0f, 10.0f, 5.0f, 10.0f);
        [_button sizeToFit];
        [self.contentView addSubview:_button];
        
        [_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        _collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.opaque = false;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.alwaysBounceVertical = false;
        _collectionView.delaysContentTouches = false;
        _collectionView.contentInset = UIEdgeInsetsMake(0.0, preloadInset, 0.0f, preloadInset);
        [_collectionView registerClass:[TGStickerCollectionViewCell class] forCellWithReuseIdentifier:@"TGStickerCollectionViewCell"];
        [self.contentView addSubview:_collectionView];
        
        _dotView = [[UIImageView alloc] initWithImage:dotImage];
        _dotView.hidden = true;
        [self.contentView addSubview:_dotView];
    }
    return self;
}

- (void)setStickerPack:(TGStickerPack *)stickerPack {
    NSString *title = stickerPack.title;
    if ([stickerPack.packReference isKindOfClass:[TGStickerPackBuiltinReference class]])
        title = TGLocalized(@"StickerPack.BuiltinPackName");
    _titleLabel.text = title;
    
    _countLabel.text = [[NSString alloc] initWithFormat:TGLocalized([TGStringUtils integerValueFormat:@"StickerPack.StickerCount_" value:stickerPack.documents.count]), [[NSString alloc] initWithFormat:@"%d", (int)stickerPack.documents.count]];
    
    _stickerPack = stickerPack;
    [_collectionView reloadData];
    
    [self setNeedsLayout];
}

- (void)setInstalled:(bool)installed {
    _installed = installed;
    _button.hidden = installed;
}

- (void)setUnread:(bool)unread {
    _unread = unread;
    _dotView.hidden = !unread;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat topInset = 9.0f;
    CGFloat leftInset = 13.0f;
    CGFloat rightInset = 15.0f;
    
    CGFloat maxTextWidth = self.bounds.size.width - leftInset - rightInset - _button.frame.size.width - 8.0f;
    
    CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
    _titleLabel.frame = CGRectMake(leftInset, topInset, MIN(titleSize.width, maxTextWidth), titleSize.height);
    
    _dotView.frame = CGRectMake(CGRectGetMaxX(_titleLabel.frame) + 3.0f, _titleLabel.frame.origin.y + 8.0f, _dotView.frame.size.width, _dotView.frame.size.height);
    
    CGSize countSize = [_countLabel.text sizeWithFont:_countLabel.font];
    _countLabel.frame = CGRectMake(leftInset, CGRectGetMaxY(_titleLabel.frame) + 1.0f, MIN(countSize.width, maxTextWidth), countSize.height);
    
    _button.frame = CGRectMake(self.bounds.size.width - _button.frame.size.width - rightInset, 16.0f, _button.frame.size.width, _button.frame.size.height);
    
    CGRect collectionFrame = CGRectMake(-preloadInset, 52.0f, self.bounds.size.width + preloadInset * 2.0f, 78.0f);
    if (!CGRectEqualToRect(collectionFrame, _collectionView.frame)) {
        _collectionView.frame = collectionFrame;
        [_collectionLayout invalidateLayout];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)__unused collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)__unused section {
    return MIN((NSInteger)_stickerPack.documents.count, 5);
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout*)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath {
    return CGSizeMake(62.0f, 62.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat sideInset = (collectionView.frame.size.width < 330.0f) ? 3.0f : 15.0f;
    return UIEdgeInsetsMake(0.0f, sideInset, [self collectionView:collectionView layout:collectionViewLayout minimumLineSpacingForSectionAtIndex:section], sideInset);
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout*)__unused collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return 7.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)__unused collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return (collectionView.frame.size.width < 330.0f) ? 0.0f : 4.0f;
}

- (TGDocumentMediaAttachment *)documentAtIndexPath:(NSIndexPath *)indexPath {
    return _stickerPack.documents[indexPath.item];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGStickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TGStickerCollectionViewCell" forIndexPath:indexPath];
    [cell setDocumentMedia:[self documentAtIndexPath:indexPath]];
    return cell;
}

- (void)buttonPressed {
    if (_install) {
        _install();
    }
}

- (void)collectionView:(UICollectionView *)__unused collectionView didSelectItemAtIndexPath:(NSIndexPath *)__unused indexPath {
    if (_info)
        _info();
}

@end
