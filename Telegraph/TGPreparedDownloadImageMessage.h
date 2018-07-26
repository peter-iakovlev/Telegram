#import "TGPreparedMessage.h"

@class TGImageInfo;

@interface TGPreparedDownloadImageMessage : TGPreparedMessage

@property (nonatomic, strong) TGImageInfo *imageInfo;

- (instancetype)initWithImageInfo:(TGImageInfo *)imageInfo text:(NSString *)text entities:(NSArray *)entities replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup;;

@end
