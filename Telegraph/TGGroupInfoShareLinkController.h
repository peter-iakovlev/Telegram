#import "TGCollectionMenuController.h"

@interface TGGroupInfoShareLinkController : TGCollectionMenuController

@property (nonatomic, copy) void (^linkChanged)(NSString *link);

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash currentLink:(NSString *)currentLink;

@end
