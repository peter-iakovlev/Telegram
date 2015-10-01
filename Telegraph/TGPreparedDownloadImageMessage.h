#import "TGPreparedMessage.h"

@class TGImageInfo;

@interface TGPreparedDownloadImageMessage : TGPreparedMessage

@property (nonatomic, strong) TGImageInfo *imageInfo;

@property (nonatomic, strong) NSString *caption;

@property (nonatomic, strong) TGMessage *replyMessage;

- (instancetype)initWithImageInfo:(TGImageInfo *)imageInfo caption:(NSString *)caption replyMessage:(TGMessage *)replyMessage;

@end
