#import "TGPreparedMessage.h"

#import "PSCoding.h"

@class TGImageInfo;

@interface TGPreparedCloudDocumentMessage : TGPreparedMessage

@property (nonatomic, strong) NSURL *documentUrl;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic) int size;
@property (nonatomic, strong) TGImageInfo *thumbnailInfo;
@property (nonatomic) int64_t localDocumentId;
@property (nonatomic, strong) NSArray *attributes;

- (instancetype)initWithDocumentUrl:(NSURL *)documentUrl localDocumentId:(int64_t)localDocumentId mimeType:(NSString *)mimeType size:(int)size thumbnailInfo:(TGImageInfo *)thumbnailInfo attributes:(NSArray *)attributes replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup;;

@end

@interface TGCloudDocumentUrlBookmark : NSObject <PSCoding>

@property (nonatomic, readonly) NSURL *documentUrl;

- (instancetype)initWithDocumentUrl:(NSURL *)documentUrl;

@end
