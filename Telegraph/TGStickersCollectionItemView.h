#import "TGMenuSheetItemView.h"

@class TGStickerPack;
@class TGDocumentMediaAttachment;

@interface TGStickersCollectionItemView : TGMenuSheetItemView

@property (nonatomic, copy) void (^sendSticker)(TGDocumentMediaAttachment *);
@property (nonatomic, copy) void (^openLink)(NSString *);
@property (nonatomic, assign) bool collapseInLandscape;
@property (nonatomic, assign) bool hasShare;

- (void)setStickerPack:(TGStickerPack *)stickerPack animated:(bool)animated;

- (void)setFailed;

@end
