#import "TGViewController.h"

@interface TGChatSearchController : TGViewController

- (instancetype)initWithPeerId:(int64_t)peerId messageSelected:(void (^)(int32_t, NSString *, NSArray *))messageSelected;

@end
