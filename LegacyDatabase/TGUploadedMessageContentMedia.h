#import "TGUploadedMessageContent.h"

#import "ApiLayer86.h"

@interface TGUploadedMessageContentMedia : TGUploadedMessageContent

@property (nonatomic, strong, readonly) Api86_InputMedia *inputMedia;

- (instancetype)initWithInputMedia:(Api86_InputMedia *)inputMedia;

@end
