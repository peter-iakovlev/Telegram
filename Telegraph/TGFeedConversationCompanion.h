#import "TGGenericModernConversationCompanion.h"

#import "TGFeed.h"

@interface TGFeedConversationCompanion : TGGenericModernConversationCompanion

- (instancetype)initWithFeed:(TGFeed *)feed;

- (void)navigateToMessageId:(int32_t)messageId peerId:(int64_t)peerId animated:(bool)animated;

@end
