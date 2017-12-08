#import "TGCollectionItem.h"

#import <LegacyComponents/TGStickerPack.h>

typedef enum {
    TGStickerPackItemStatusNone = 0,
    TGStickerPackItemStatusNotInstalled,
    TGStickerPackItemStatusInstalled
} TGStickerPackItemStatus;

typedef enum {
    TGStickerPackItemSearchStatusNone = 0,
    TGStickerPackItemSearchStatusSearching = 1,
    TGStickerPackItemSearchStatusFailed = 2
} TGStickerPackItemSearchStatus;

@interface TGStickerPackCollectionItem : TGCollectionItem

@property (nonatomic, strong) TGStickerPack *stickerPack;
@property (nonatomic) TGStickerPackItemSearchStatus searchStatus;

@property (nonatomic) bool enableEditing;
@property (nonatomic) bool unread;
@property (nonatomic) TGStickerPackItemStatus status;
@property (nonatomic) bool isChecked;

@property (nonatomic, copy) void (^previewStickerPack)();
@property (nonatomic, copy) void (^deleteStickerPack)();
@property (nonatomic, copy) void (^addStickerPack)();

- (instancetype)initWithStickerPack:(TGStickerPack *)stickerPack;

@end
