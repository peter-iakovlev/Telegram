#import "TGUploadedMessageContent.h"

#import "ApiLayer82.h"

@interface TGUploadedMessageContentMedia : TGUploadedMessageContent

@property (nonatomic, strong, readonly) Api82_InputMedia *inputMedia;

- (instancetype)initWithInputMedia:(Api82_InputMedia *)inputMedia;

@end
