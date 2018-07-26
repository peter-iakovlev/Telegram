#import <LegacyComponents/LegacyComponents.h>

#import "TGCollectionMenuSectionList.h"
#import "TGCollectionMenuLayout.h"
#import "TGCollectionItemView.h"
#import "TGCollectionMenuView.h"

@class TGPresentation;

@interface TGCollectionMenuController : TGViewController

@property (nonatomic, strong) TGCollectionMenuSectionList *menuSections;

@property (nonatomic, strong) TGCollectionMenuView *collectionView;
@property (nonatomic, strong) TGCollectionMenuLayout *collectionLayout;
@property (nonatomic) bool enableItemReorderingGestures;

@property (nonatomic) bool disableStopScrolling;

@property (nonatomic, strong) TGPresentation *presentation;

- (void)_resetCollectionView;
- (void)_ensureBinding;
- (NSIndexPath *)indexPathForItem:(TGCollectionItem *)item;
- (NSUInteger)indexForSection:(TGCollectionMenuSection *)section;

- (void)enterEditingMode:(bool)animated;
- (void)leaveEditingMode:(bool)animated;

- (void)didEnterEditingMode:(bool)animated;
- (void)didLeaveEditingMode:(bool)animated;

- (void)updateItemPositions;

- (void)animateCollectionCrossfade;

- (void)loadMore;

- (void)willDisplayItem:(TGCollectionItem *)item;

@end
