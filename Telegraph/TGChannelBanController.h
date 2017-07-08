#import "TGCollectionMenuController.h"

@class TGConversation;
@class TGUser;
@class TGCachedConversationMember;
@class TGChannelBannedRights;
@class SSignal;

@interface TGChannelBanController : TGCollectionMenuController

@property (nonatomic, copy) void (^done)(TGChannelBannedRights *);

- (instancetype)initWithConversation:(TGConversation *)conversation user:(TGUser *)user current:(TGCachedConversationMember *)current member:(SSignal *)member;

@end
