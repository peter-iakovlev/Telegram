#import "TGPreparedMessage.h"

#import "PSCoding.h"

@class TGImageInfo;

@interface TGPreparedDownloadDocumentMessage : TGPreparedMessage

@property (nonatomic, strong) NSString *giphyId;
@property (nonatomic, strong) NSString *documentUrl;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic) int size;
@property (nonatomic, strong) TGImageInfo *thumbnailInfo;
@property (nonatomic) int64_t localDocumentId;

- (instancetype)initWithGiphyId:(NSString *)giphyId documentUrl:(NSString *)documentUrl localDocumentId:(int64_t)localDocumentId fileName:(NSString *)fileName mimeType:(NSString *)mimeType size:(int)size thumbnailInfo:(TGImageInfo *)thumbnailInfo;

@end

@interface TGDownloadDocumentUrl : NSObject <PSCoding>

@property (nonatomic, strong, readonly) NSString *giphyId;
@property (nonatomic, strong, readonly) NSString *documentUrl;

- (instancetype)initWithGiphyId:(NSString *)giphyId documentUrl:(NSString *)documentUrl;

@end
