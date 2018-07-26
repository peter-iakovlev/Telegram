#import <SSignalKit/SSignalKit.h>

@class TGDocumentMediaAttachment;

@interface TGRecentStickersSignal : NSObject

+ (void)clearRecentStickers;
+ (void)sync;
+ (void)addRecentStickerFromDocument:(TGDocumentMediaAttachment *)document;
+ (void)addRemoteRecentStickerFromDocuments:(NSArray *)documents sync:(bool)sync;
+ (void)removeRecentStickerByDocumentId:(int64_t)documentId;
+ (SSignal *)recentStickers;

@end
