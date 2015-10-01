#import <SSignalKit/SSignalKit.h>

#import "TGStickerPack.h"

@interface TGStickersSignals : NSObject

+ (void)clearCache;
+ (void)addUseCountForDocumentId:(int64_t)documentId;

+ (bool)isStickerPackInstalled:(id<TGStickerPackReference>)packReference;
+ (SSignal *)stickerPacks;

+ (SSignal *)stickerPackInfo:(id<TGStickerPackReference>)packReference;
+ (SSignal *)installStickerPack:(id<TGStickerPackReference>)packReference;
+ (SSignal *)removeStickerPack:(id<TGStickerPackReference>)packReference;

+ (SSignal *)preloadedStickerPreviews:(NSArray *)documents count:(NSUInteger)count;

@end
