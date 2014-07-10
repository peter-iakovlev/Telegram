#import "TGGenericModernConversationCompanion.h"

@class TGConversation;

@interface TGBroadcastModernConversationCompanion : TGGenericModernConversationCompanion

- (instancetype)initWithConversationId:(int64_t)conversationId conversation:(TGConversation *)conversation;

@end
