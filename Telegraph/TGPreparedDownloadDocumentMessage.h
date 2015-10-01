#import "TGPreparedMessage.h"

#import "PSCoding.h"

@class TGImageInfo;

@interface TGPreparedDownloadDocumentMessage : TGPreparedMessage

@property (nonatomic, strong) NSString *giphyId;
@property (nonatomic, strong) NSString *documentUrl;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic) int size;
@property (nonatomic, strong) TGImageInfo *thumbnailInfo;
@property (nonatomic) int64_t localDocumentId;
@property (nonatomic, strong) NSArray *attributes;

@property (nonatomic, strong) TGMessage *replyMessage;

- (instancetype)initWithGiphyId:(NSString *)giphyId documentUrl:(NSString *)documentUrl localDocumentId:(int64_t)localDocumentId mimeType:(NSString *)mimeType size:(int)size thumbnailInfo:(TGImageInfo *)thumbnailInfo attributes:(NSArray *)attributes replyMessage:(TGMessage *)replyMessage;

@end

@interface TGDownloadDocumentUrl : NSObject <PSCoding>

@property (nonatomic, strong, readonly) NSString *giphyId;
@property (nonatomic, strong, readonly) NSString *documentUrl;

- (instancetype)initWithGiphyId:(NSString *)giphyId documentUrl:(NSString *)documentUrl;

@end
