#import "TGEditableCollectionItemView.h"

#import "TGStickerPack.h"

@interface TGStickerPackCollectionItemView : TGEditableCollectionItemView

@property (nonatomic, copy) void (^deleteStickerPack)();
@property (nonatomic, copy) void (^addStickerPack)();

- (void)setStickerPack:(TGStickerPack *)stickerPack;

@end
