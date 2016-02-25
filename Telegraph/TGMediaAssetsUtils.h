#import "TGMediaAssetFetchResultChange.h"
#import "TGMediaAssetImageSignals.h"

@class TGMediaAsset;
@class TGMediaSelectionContext;

@interface TGMediaAssetsPreheatMixin : NSObject

@property (nonatomic, copy) NSInteger (^assetCount)(void);
@property (nonatomic, copy) TGMediaAsset *(^assetAtIndex)(NSInteger);

@property (nonatomic, assign) TGMediaAssetImageType imageType;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) bool reversed;

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView scrollDirection:(UICollectionViewScrollDirection)scrollDirection;
- (void)update;
- (void)stop;

@end


@interface TGMediaAssetsCollectionViewIncrementalUpdater : NSObject

+ (void)updateCollectionView:(UICollectionView *)collectionView withChange:(TGMediaAssetFetchResultChange *)change completion:(void (^)(bool incremental))completion;

@end
