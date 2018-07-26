#import "TGPreparedMessage.h"

#import "TGExternalImageSearchResult.h"

#import <LegacyComponents/LegacyComponents.h>

@class TGImageInfo;

@interface TGPreparedDownloadExternalImageMessage : TGPreparedMessage

@property (nonatomic, readonly) TGExternalImageSearchResult *searchResult;
@property (nonatomic) int size;
@property (nonatomic, strong) TGImageInfo *imageInfo;

- (instancetype)initWithSearchResult:(TGExternalImageSearchResult *)searchResult imageInfo:(TGImageInfo *)imageInfo text:(NSString *)text entities:(NSArray *)entities replyMessage:(TGMessage *)replyMessage botContextResult:(TGBotContextResultAttachment *)botContextResult replyMarkup:(TGReplyMarkupAttachment *)replyMarkup;;

@end

@interface TGDownloadExternalImageInfo : NSObject <PSCoding>

@property (nonatomic, strong, readonly) TGExternalImageSearchResult *searchResult;

- (instancetype)initWithSearchResult:(TGExternalImageSearchResult *)searchResult;

@end
