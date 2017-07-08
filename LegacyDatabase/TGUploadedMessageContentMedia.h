#import "TGUploadedMessageContent.h"

#import "ApiLayer69.h"

@interface TGUploadedMessageContentMedia : TGUploadedMessageContent

@property (nonatomic, strong, readonly) Api69_InputMedia *inputMedia;

- (instancetype)initWithInputMedia:(Api69_InputMedia *)inputMedia;

@end
