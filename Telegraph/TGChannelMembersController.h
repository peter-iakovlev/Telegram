#import "TGCollectionMenuController.h"

@class TGConversation;

typedef enum {
    TGChannelMembersModeMembers,
    TGChannelMembersModeBannedAndRestricted,
    TGChannelMembersModeAdmins
} TGChannelMembersMode;

@interface TGChannelMembersController : TGCollectionMenuController

- (instancetype)initWithConversation:(TGConversation *)conversation mode:(TGChannelMembersMode)mode;

@end
