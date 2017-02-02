#import "TGGenericModernConversationCompanion.h"

@class TGConversation;

@interface TGChannelConversationCompanion : TGGenericModernConversationCompanion

- (instancetype)initWithConversation:(TGConversation *)conversation userActivities:(NSDictionary *)userActivities;

@end
