#import "TGMenuSheetItemView.h"

@class TGStickerPack;
@class TGDocumentMediaAttachment;

@interface TGStickersCollectionItemView : TGMenuSheetItemView

@property (nonatomic, copy) void (^sendSticker)(TGDocumentMediaAttachment *);
@property (nonatomic, assign) bool collapseInLandscape;

- (void)setStickerPack:(TGStickerPack *)stickerPack animated:(bool)animated;

- (void)setFailed;

@end
