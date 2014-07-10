#import "TGCollectionMenuController.h"

#import "ASWatcher.h"

@interface TGBroadcastListInfoController : TGCollectionMenuController <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

- (instancetype)initWithConversationId:(int64_t)conversationId;

@end
