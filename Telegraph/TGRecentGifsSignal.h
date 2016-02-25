#import <SSignalKit/SSignalKit.h>

@class TGDocumentMediaAttachment;

@interface TGRecentGifsSignal : NSObject

+ (void)clearRecentGifs;
+ (void)sync;
+ (void)addRecentGifFromDocument:(TGDocumentMediaAttachment *)document;
+ (void)addRemoteRecentGifFromDocuments:(NSArray *)documents;
+ (void)removeRecentGifByDocumentId:(int64_t)documentId;
+ (SSignal *)recentGifs;

@end
