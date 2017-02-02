#import <UIKit/UIKit.h>

@interface TGGifKeyboardBalancedLayout : UICollectionViewLayout

@property (nonatomic) CGFloat preferredRowSize;

// The size of each section's header. This maybe dynamically adjusted
// per section via the protocol method referenceSizeForHeaderInSection.
@property (nonatomic) CGSize headerReferenceSize;

// The size of each section's header. This maybe dynamically adjusted
// per section via the protocol method referenceSizeForFooterInSection.
@property (nonatomic) CGSize footerReferenceSize;

// The margins used to lay out content in a section.
@property (nonatomic) UIEdgeInsets sectionInset;

// The minimum spacing to use between lines of items in the grid.
@property (nonatomic) CGFloat minimumLineSpacing;

// The minimum spacing to use between items in the same row.
@property (nonatomic) CGFloat minimumInteritemSpacing;

// The scroll direction of the grid.
@property (nonatomic) UICollectionViewScrollDirection scrollDirection;

- (CGSize)standaloneContentSize:(CGSize)viewportSize;

@end

@protocol TGGifKeyboardBalancedLayoutDelegate <NSObject>

@required

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(TGGifKeyboardBalancedLayout *)collectionViewLayout preferredSizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end