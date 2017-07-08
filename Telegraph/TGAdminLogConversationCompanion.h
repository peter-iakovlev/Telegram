#import "TGGenericModernConversationCompanion.h"

@class TGConversation;
@class TGUser;

@interface TGAdminLogConversationCompanion : TGGenericModernConversationCompanion

- (instancetype)initWithConversation:(TGConversation *)conversation;

- (void)updateSearchQuery:(NSString *)query;
- (void)presentFilterController;

- (bool)canBanUser:(int32_t)userId;
- (void)banUser:(TGUser *)userId;

@end

