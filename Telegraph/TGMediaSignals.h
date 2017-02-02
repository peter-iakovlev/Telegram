#import <SSignalKit/SSignalKit.h>

#import "TGImageFileReference.h"

@class TGImageMediaAttachment;
@class TGVideoMediaAttachment;

@interface TGMediaSignals : NSObject

+ (SSignal *)avatarPathWithReference:(TGImageFileReference *)reference;
+ (SSignal *)stickerPathWithDocumentId:(int64_t)documentId accessHash:(int64_t)accessHash legacyThumbnailUri:(NSString *)legacyThumbnailUri datacenterId:(int32_t)datacenterId size:(CGSize)size;
+ (SSignal *)photoThumbnailPathWithImageMedia:(TGImageMediaAttachment *)imageMedia targetSize:(CGSize)targetSize;
+ (SSignal *)videoThumbnailPathWithVideoMedia:(TGVideoMediaAttachment *)videoMedia targetSize:(CGSize)targetSize;

@end
