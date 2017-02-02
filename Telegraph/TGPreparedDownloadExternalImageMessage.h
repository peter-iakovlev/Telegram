#import "TGPreparedMessage.h"

#import "TGExternalImageSearchResult.h"

#import "PSCoding.h"

@class TGImageInfo;

@interface TGPreparedDownloadExternalImageMessage : TGPreparedMessage

@property (nonatomic, readonly) TGExternalImageSearchResult *searchResult;
@property (nonatomic) int size;
@property (nonatomic, strong) TGImageInfo *imageInfo;
@property (nonatomic, strong) NSString *caption;

- (instancetype)initWithSearchResult:(TGExternalImageSearchResult *)searchResult imageInfo:(TGImageInfo *)imageInfo caption:(NSString *)caption replyMessage:(TGMessage *)replyMessage botContextResult:(TGBotContextResultAttachment *)botContextResult replyMarkup:(TGReplyMarkupAttachment *)replyMarkup;;

@end

@interface TGDownloadExternalImageInfo : NSObject <PSCoding>

@property (nonatomic, strong, readonly) TGExternalImageSearchResult *searchResult;

- (instancetype)initWithSearchResult:(TGExternalImageSearchResult *)searchResult;

@end
