#import "TGUploadedMessageContent.h"

#import "ApiLayer70.h"

@interface TGUploadedMessageContentMedia : TGUploadedMessageContent

@property (nonatomic, strong, readonly) Api70_InputMedia *inputMedia;

- (instancetype)initWithInputMedia:(Api70_InputMedia *)inputMedia;

@end
