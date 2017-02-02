#import <SSignalKit/SSignalKit.h>

@class TGDocumentMediaAttachment;
@class TGVideoMediaAttachment;
@class TGMemoryImageCache;

@interface TGSharedFileSignals : NSObject

+ (SSignal *)squareFileThumbnail:(TGDocumentMediaAttachment *)documentAttachment ofSize:(CGSize)size threadPool:(SThreadPool *)threadPool memoryCache:(TGMemoryImageCache *)memoryCache pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock;

// returns Signal<[Signal<NSData>, Signal<NSNumber>]>
+ (SSignal *)documentData:(TGDocumentMediaAttachment *)document priority:(bool)priority;
+ (SSignal *)documentPath:(TGDocumentMediaAttachment *)document priority:(bool)priority;

+ (SSignal *)videoData:(TGVideoMediaAttachment *)video priority:(bool)priority;

@end
