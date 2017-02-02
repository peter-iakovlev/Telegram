#import "TGPreparedMessage.h"

#import "TGExternalGifSearchResult.h"

#import "PSCoding.h"

@class TGImageInfo;

@interface TGPreparedDownloadExternalGifMessage : TGPreparedMessage

@property (nonatomic, readonly) TGExternalGifSearchResult *searchResult;
@property (nonatomic, strong) NSString *documentUrl;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic) int size;
@property (nonatomic, strong) TGImageInfo *thumbnailInfo;
@property (nonatomic) int64_t localDocumentId;
@property (nonatomic, strong) NSArray *attributes;
@property (nonatomic, strong) NSString *caption;

- (instancetype)initWithSearchResult:(TGExternalGifSearchResult *)searchResult localDocumentId:(int64_t)localDocumentId mimeType:(NSString *)mimeType thumbnailInfo:(TGImageInfo *)thumbnailInfo attributes:(NSArray *)attributes caption:(NSString *)caption replyMessage:(TGMessage *)replyMessage botContextResult:(TGBotContextResultAttachment *)botContextResult replyMarkup:(TGReplyMarkupAttachment *)replyMarkup;;

@end

@interface TGDownloadExternalGifInfo : NSObject <PSCoding>

@property (nonatomic, strong, readonly) TGExternalGifSearchResult *searchResult;

- (instancetype)initWithSearchResult:(TGExternalGifSearchResult *)searchResult;

@end