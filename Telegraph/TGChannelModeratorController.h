#import "TGCollectionMenuController.h"

@class TGConversation;
@class TGUser;
@class TGCachedConversationMember;

@interface TGChannelModeratorController : TGCollectionMenuController

@property (nonatomic, copy) void (^done)(TGCachedConversationMember *member);

- (instancetype)initWithConversation:(TGConversation *)conversation user:(TGUser *)user member:(TGCachedConversationMember *)member;

@end
