#import <SSignalKit/SSignalKit.h>

#import "TGStickerPack.h"
#import "TGArchivedStickerPacksSummary.h"

#import "TGStickerPacksArchive.h"

@interface TGStickersSignals : NSObject

+ (void)clearCache;
+ (void)addUseCountForDocumentId:(int64_t)documentId;

+ (bool)isStickerPackInstalled:(id<TGStickerPackReference>)packReference;
+ (NSString *)stickerPackShortName:(id<TGStickerPackReference>)packReference;
+ (void)forceUpdateStickers;
+ (void)dispatchStickers;
+ (SSignal *)stickerPacks;
+ (SSignal *)updatedFeaturedStickerPacks;

+ (NSDictionary *)cachedStickerPacks;

+ (SSignal *)stickerPackInfo:(id<TGStickerPackReference>)packReference;
+ (SSignal *)installStickerPackAndGetArchived:(id<TGStickerPackReference>)packReference;
+ (SSignal *)installStickerPackAndGetArchived:(id<TGStickerPackReference>)packReference hintUnarchive:(bool)hintUnarchive;
+ (SSignal *)removeStickerPack:(id<TGStickerPackReference>)packReference hintArchived:(bool)hintArchived;
+ (SSignal *)toggleStickerPackHidden:(id<TGStickerPackReference>)packReference hidden:(bool)hidden;
+ (SSignal *)reorderStickerPacks:(NSArray *)packReferences;
+ (SSignal *)archivedStickerPacksWithOffsetId:(int64_t)offsetId limit:(NSUInteger)limit;

+ (void)remoteAddedStickerPack:(TGStickerPack *)stickerPack;
+ (void)remoteReorderedStickerPacks:(NSArray *)updatedOrder;

+ (SSignal *)preloadedStickerPreviews:(NSDictionary *)dictionary count:(NSUInteger)count;

+ (void)markFeaturedStickersAsRead;
+ (void)markFeaturedStickerPackAsRead:(NSArray *)packIds;

@end
