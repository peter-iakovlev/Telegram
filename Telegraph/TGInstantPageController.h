#import "TGViewController.h"

#import "TGWebPageMediaAttachment.h"

@class TGPIPSourceLocation;

@interface TGInstantPageController : TGViewController

@property (nonatomic, strong, readonly) TGWebPageMediaAttachment *webPage;

- (instancetype)initWithWebPage:(TGWebPageMediaAttachment *)webPage anchor:(NSString *)anchor peerId:(int64_t)peerId messageId:(int32_t)messageId;

- (void)scrollToPIPLocation:(TGPIPSourceLocation *)location;

@end
