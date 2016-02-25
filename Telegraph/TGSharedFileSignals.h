#import <SSignalKit/SSignalKit.h>

@class TGDocumentMediaAttachment;
@class TGMemoryImageCache;

@interface TGSharedFileSignals : NSObject

+ (SSignal *)squareFileThumbnail:(TGDocumentMediaAttachment *)documentAttachment ofSize:(CGSize)size threadPool:(SThreadPool *)threadPool memoryCache:(TGMemoryImageCache *)memoryCache pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock;

// returns Signal<[Signal<NSData>, Signal<NSNumber>]>
+ (SSignal *)documentData:(TGDocumentMediaAttachment *)document priority:(bool)priority;
+ (SSignal *)documentPath:(TGDocumentMediaAttachment *)document priority:(bool)priority;

@end
