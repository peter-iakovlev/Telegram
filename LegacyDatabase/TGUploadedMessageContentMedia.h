#import "TGUploadedMessageContent.h"

#import "ApiLayer62.h"

@interface TGUploadedMessageContentMedia : TGUploadedMessageContent

@property (nonatomic, strong, readonly) Api62_InputMedia *inputMedia;

- (instancetype)initWithInputMedia:(Api62_InputMedia *)inputMedia;

@end
