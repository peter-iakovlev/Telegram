#import <SSignalKit/SSignalKit.h>

#import <LegacyComponents/TGStickerPack.h>
#import "TGArchivedStickerPacksSummary.h"

@class TLInputStickerSet;

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

+ (SSignal *)remoteStickersForEmoticon:(NSString *)emoticon;
+ (SSignal *)stickerPackInfo:(id<TGStickerPackReference>)packReference;
+ (SSignal *)installStickerPackAndGetArchived:(id<TGStickerPackReference>)packReference;
+ (SSignal *)installStickerPackAndGetArchived:(id<TGStickerPackReference>)packReference hintUnarchive:(bool)hintUnarchive;
+ (SSignal *)removeStickerPack:(id<TGStickerPackReference>)packReference hintArchived:(bool)hintArchived;
+ (SSignal *)toggleStickerPackHidden:(id<TGStickerPackReference>)packReference hidden:(bool)hidden;
+ (SSignal *)reorderStickerPacks:(NSArray *)packReferences;
+ (SSignal *)archivedStickerPacksWithOffsetId:(int64_t)offsetId limit:(NSUInteger)limit;

+ (SSignal *)searchStickersWithQuery:(NSString *)query;

+ (void)remoteAddedStickerPack:(TGStickerPack *)stickerPack;
+ (void)remoteReorderedStickerPacks:(NSArray *)updatedOrder;

+ (SSignal *)preloadedStickerPreviews:(NSDictionary *)dictionary count:(NSUInteger)count;

+ (void)markFeaturedStickersAsRead;
+ (void)markFeaturedStickerPackAsRead:(NSArray *)packIds;

+ (TLInputStickerSet *)_inputStickerSetFromPackReference:(id<TGStickerPackReference>)packReference;

+ (SSignal *)cachedStickerPack:(id<TGStickerPackReference>)packReference;

+ (SSignal *)stickersForEmojis:(NSArray *)emojis includeRemote:(bool)includeRemote updateRemoteCached:(bool)updateRemoteCached;

@end
