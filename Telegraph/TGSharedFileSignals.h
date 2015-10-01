#import <SSignalKit/SSignalKit.h>

@class TGDocumentMediaAttachment;
@class TGMemoryImageCache;

@interface TGSharedFileSignals : NSObject

+ (SSignal *)squareFileThumbnail:(TGDocumentMediaAttachment *)documentAttachment ofSize:(CGSize)size threadPool:(SThreadPool *)threadPool memoryCache:(TGMemoryImageCache *)memoryCache pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock;

@end
