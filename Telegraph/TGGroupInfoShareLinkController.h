#import "TGCollectionMenuController.h"

@interface TGGroupInfoShareLinkController : TGCollectionMenuController

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash currentLink:(NSString *)currentLink;

@end
