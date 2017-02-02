#import "TGCollectionItem.h"

#import "TGStickerPack.h"

typedef enum {
    TGStickerPackItemStatusNone = 0,
    TGStickerPackItemStatusNotInstalled,
    TGStickerPackItemStatusInstalled
} TGStickerPackItemStatus;

@interface TGStickerPackCollectionItem : TGCollectionItem

@property (nonatomic, strong) TGStickerPack *stickerPack;

@property (nonatomic) bool enableEditing;
@property (nonatomic) bool unread;
@property (nonatomic) TGStickerPackItemStatus status;

@property (nonatomic, copy) void (^previewStickerPack)();
@property (nonatomic, copy) void (^deleteStickerPack)();
@property (nonatomic, copy) void (^addStickerPack)();

- (instancetype)initWithStickerPack:(TGStickerPack *)stickerPack;

@end
