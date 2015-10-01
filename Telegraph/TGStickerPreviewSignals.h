#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

#import <Elements/Elements.h>

@class TGDocumentMediaAttachment;

@interface TGStickerPreviewSignals : NSObject

+ (SSignal *)stickerThumbnail:(TGDocumentMediaAttachment *)documentAttachment ofSize:(CGSize)size threadPool:(SThreadPool *)threadPool memoryCache:(EMInMemoryImageCache *)memoryCache;

@end
