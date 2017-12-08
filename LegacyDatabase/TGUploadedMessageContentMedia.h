#import "TGUploadedMessageContent.h"

#import "ApiLayer73.h"

@interface TGUploadedMessageContentMedia : TGUploadedMessageContent

@property (nonatomic, strong, readonly) Api73_InputMedia *inputMedia;

- (instancetype)initWithInputMedia:(Api73_InputMedia *)inputMedia;

@end
