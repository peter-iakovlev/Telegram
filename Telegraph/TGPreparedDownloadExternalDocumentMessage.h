#import "TGPreparedMessage.h"

@class TGImageInfo;

@interface TGPreparedDownloadExternalDocumentMessage : TGPreparedMessage

@property (nonatomic, strong) NSString *documentUrl;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic) int size;
@property (nonatomic, strong) TGImageInfo *thumbnailInfo;
@property (nonatomic) int64_t localDocumentId;
@property (nonatomic, strong) NSArray *attributes;
@property (nonatomic, strong) NSString *caption;

- (instancetype)initWithLocalDocumentId:(int64_t)localDocumentId documentUrl:(NSString *)documentUrl mimeType:(NSString *)mimeType thumbnailInfo:(TGImageInfo *)thumbnailInfo attributes:(NSArray *)attributes caption:(NSString *)caption replyMessage:(TGMessage *)replyMessage botContextResult:(TGBotContextResultAttachment *)botContextResult replyMarkup:(TGReplyMarkupAttachment *)replyMarkup;;

@end
