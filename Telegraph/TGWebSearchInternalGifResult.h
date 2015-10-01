#import "TGWebSearchResult.h"

@class TGImageInfo;

@interface TGWebSearchInternalGifResult : NSObject <TGWebSearchResult>

@property (nonatomic, readonly) int64_t documentId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, readonly) int32_t size;
@property (nonatomic, strong, readonly) NSString *fileName;
@property (nonatomic, strong, readonly) NSString *mimeType;
@property (nonatomic, strong, readonly) TGImageInfo *thumbnailInfo;

- (instancetype)initWithDocumentId:(int64_t)documentId accessHash:(int64_t)accessHash size:(int32_t)size fileName:(NSString *)fileName mimeType:(NSString *)mimeType thumbnailInfo:(TGImageInfo *)thumbnailInfo;

@end
