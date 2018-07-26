#import "TGPreparedMessage.h"

#import "TGExternalGifSearchResult.h"

#import <LegacyComponents/LegacyComponents.h>

@class TGImageInfo;

@interface TGPreparedDownloadExternalGifMessage : TGPreparedMessage

@property (nonatomic, readonly) TGExternalGifSearchResult *searchResult;
@property (nonatomic, strong) NSString *documentUrl;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic) int size;
@property (nonatomic, strong) TGImageInfo *thumbnailInfo;
@property (nonatomic) int64_t localDocumentId;
@property (nonatomic, strong) NSArray *attributes;

- (instancetype)initWithSearchResult:(TGExternalGifSearchResult *)searchResult localDocumentId:(int64_t)localDocumentId mimeType:(NSString *)mimeType thumbnailInfo:(TGImageInfo *)thumbnailInfo attributes:(NSArray *)attributes text:(NSString *)text entities:(NSArray *)entities replyMessage:(TGMessage *)replyMessage botContextResult:(TGBotContextResultAttachment *)botContextResult replyMarkup:(TGReplyMarkupAttachment *)replyMarkup;;

@end

@interface TGDownloadExternalGifInfo : NSObject <PSCoding>

@property (nonatomic, strong, readonly) TGExternalGifSearchResult *searchResult;

- (instancetype)initWithSearchResult:(TGExternalGifSearchResult *)searchResult;

@end
