#import "TGEditableCollectionItemView.h"

#import "TGStickerPack.h"

@interface TGStickerPackCollectionItemView : TGEditableCollectionItemView

@property (nonatomic, copy) void (^deleteStickerPack)();

- (void)setStickerPack:(TGStickerPack *)stickerPack;

@end
