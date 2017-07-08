#import "TGCollectionMenuController.h"

@class TGConversation;
@class TGUser;
@class TGCachedConversationMember;
@class TGChannelAdminRights;
@class SSignal;

@interface TGChannelModeratorController : TGCollectionMenuController

@property (nonatomic, copy) void (^done)(TGChannelAdminRights *);
@property (nonatomic, copy) void (^revoke)();

- (instancetype)initWithConversation:(TGConversation *)conversation user:(TGUser *)user currentSignal:(SSignal *)currentSignal;

@end
