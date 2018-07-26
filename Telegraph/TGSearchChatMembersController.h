#import <LegacyComponents/LegacyComponents.h>

@class TGUser;
@class TGCachedConversationMember;
@class TGPresentation;

@interface TGSearchChatMembersController : TGViewController

@property (nonatomic, strong) TGPresentation *presentation;

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash includeContacts:(bool)includeContacts completion:(void (^)(TGUser *user, TGCachedConversationMember *member))completion;

@end
