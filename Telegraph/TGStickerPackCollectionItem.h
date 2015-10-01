#import "TGCollectionItem.h"

#import "TGStickerPack.h"

@interface TGStickerPackCollectionItem : TGCollectionItem

@property (nonatomic, strong) TGStickerPack *stickerPack;

@property (nonatomic) bool enableEditing;

@property (nonatomic, copy) void (^previewStickerPack)();
@property (nonatomic, copy) void (^deleteStickerPack)();

- (instancetype)initWithStickerPack:(TGStickerPack *)stickerPack;

@end
