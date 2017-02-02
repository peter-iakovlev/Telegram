#import "TGMediaSelectionContext.h"

@interface TGMediaPickerSelectionGestureRecognizer : NSObject

@property (nonatomic, copy) bool (^isItemSelected)(NSIndexPath *);
@property (nonatomic, copy) void (^toggleItemSelection)(NSIndexPath *);

- (instancetype)initForCollectionView:(UICollectionView *)collectionView;
- (void)cancel;

@end
