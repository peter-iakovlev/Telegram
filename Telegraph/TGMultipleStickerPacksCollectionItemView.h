#import "TGMenuSheetItemView.h"

@class TGStickerPack;
@protocol TGStickerPackReference;

@interface TGMultipleStickerPacksCollectionItemView : TGMenuSheetItemView

@property (nonatomic, copy) void (^previewPack)(TGStickerPack *, id<TGStickerPackReference>);

@property (nonatomic) bool collapseInLandscape;

- (void)setStickerPacks:(NSArray<TGStickerPack *> *)stickerPacks animated:(bool)animated;

@end
