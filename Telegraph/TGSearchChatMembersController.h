#import "TGViewController.h"

@class TGUser;
@class TGCachedConversationMember;

@interface TGSearchChatMembersController : TGViewController

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash includeContacts:(bool)includeContacts completion:(void (^)(TGUser *user, TGCachedConversationMember *member))completion;

@end
