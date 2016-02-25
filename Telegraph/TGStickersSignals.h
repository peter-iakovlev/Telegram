#import <SSignalKit/SSignalKit.h>

#import "TGStickerPack.h"

@interface TGStickersSignals : NSObject

+ (void)clearCache;
+ (void)addUseCountForDocumentId:(int64_t)documentId;

+ (bool)isStickerPackInstalled:(id<TGStickerPackReference>)packReference;
+ (NSString *)stickerPackShortName:(id<TGStickerPackReference>)packReference;
+ (void)forceUpdateStickers;
+ (void)dispatchStickers;
+ (SSignal *)stickerPacks;

+ (SSignal *)stickerPackInfo:(id<TGStickerPackReference>)packReference;
+ (SSignal *)installStickerPack:(id<TGStickerPackReference>)packReference;
+ (SSignal *)removeStickerPack:(id<TGStickerPackReference>)packReference;
+ (SSignal *)toggleStickerPackHidden:(id<TGStickerPackReference>)packReference hidden:(bool)hidden;
+ (SSignal *)reorderStickerPacks:(NSArray *)packReferences;

+ (void)remoteAddedStickerPack:(TGStickerPack *)stickerPack;
+ (void)remoteReorderedStickerPacks:(NSArray *)updatedOrder;

+ (SSignal *)preloadedStickerPreviews:(NSArray *)documents count:(NSUInteger)count;

@end
