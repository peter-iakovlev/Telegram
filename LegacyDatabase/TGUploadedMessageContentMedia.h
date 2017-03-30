#import "TGUploadedMessageContent.h"

#import "ApiLayer65.h"

@interface TGUploadedMessageContentMedia : TGUploadedMessageContent

@property (nonatomic, strong, readonly) Api65_InputMedia *inputMedia;

- (instancetype)initWithInputMedia:(Api65_InputMedia *)inputMedia;

@end
