#import "TGGenericModernConversationCompanion.h"

@class TGConversation;

@interface TGChannelConversationCompanion : TGGenericModernConversationCompanion

- (instancetype)initWithPeerId:(int64_t)peerId conversation:(TGConversation *)conversation;

@end
