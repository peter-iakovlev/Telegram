#import "TGPreparedMessage.h"

@class TGImageInfo;

@interface TGPreparedDownloadImageMessage : TGPreparedMessage

@property (nonatomic, strong) TGImageInfo *imageInfo;

@property (nonatomic, strong) NSString *caption;

- (instancetype)initWithImageInfo:(TGImageInfo *)imageInfo caption:(NSString *)caption replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup;;

@end
