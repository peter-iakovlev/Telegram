#import "TGUploadedMessageContent.h"

#import "ApiLayer48.h"

@interface TGUploadedMessageContentMedia : TGUploadedMessageContent

@property (nonatomic, strong, readonly) Api48_InputMedia *inputMedia;

- (instancetype)initWithInputMedia:(Api48_InputMedia *)inputMedia;

@end
