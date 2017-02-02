#import <SSignalKit/SSignalKit.h>

@class TGDocumentMediaAttachment;

@interface TGRecentMaskStickersSignal : NSObject

+ (void)clearRecentStickers;
+ (void)sync;
+ (void)addRecentStickersFromDocuments:(NSArray<TGDocumentMediaAttachment *> *)documents;
+ (void)addRemoteRecentStickerFromDocuments:(NSArray *)documents;
+ (void)removeRecentStickerByDocumentId:(int64_t)documentId;
+ (SSignal *)recentStickers;

@end
