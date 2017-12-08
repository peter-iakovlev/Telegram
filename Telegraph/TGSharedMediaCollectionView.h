#import <UIKit/UIKit.h>

#import <LegacyComponents/TGModernGalleryController.h>

@class TGSharedMediaSectionHeaderView;
@class TGSharedMediaSectionHeader;

@protocol TGSharedMediaCollectionViewDelegate <UICollectionViewDelegateFlowLayout>

- (void)collectionView:(UICollectionView *)collectionView setupSectionHeaderView:(TGSharedMediaSectionHeaderView *)sectionHeaderView forSectionHeader:(TGSharedMediaSectionHeader *)sectionHeader;

@end

@interface TGSharedMediaCollectionView : UICollectionView <TGModernGalleryTransitionHostScrollView>

@end
