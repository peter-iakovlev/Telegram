#import <LegacyComponents/LegacyComponents.h>

@class TGConversation;
@class TGUser;

@interface TGChatSearchController : TGViewController

- (instancetype)initWithPeerId:(int64_t)peerId messageSelected:(void (^)(int32_t, NSString *, NSArray *))messageSelected;

+ (void)initializeDialogListData:(TGConversation *)conversation customUser:(TGUser *)customUser selfUser:(TGUser *)selfUser;

@end
