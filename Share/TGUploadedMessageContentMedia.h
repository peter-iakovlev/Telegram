#import "TGUploadedMessageContent.h"

#import "ApiLayer38.h"

@interface TGUploadedMessageContentMedia : TGUploadedMessageContent

@property (nonatomic, strong, readonly) Api38_InputMedia *inputMedia;

- (instancetype)initWithInputMedia:(Api38_InputMedia *)inputMedia;

@end
