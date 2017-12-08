#import "TGContactsController.h"

#import <LegacyComponents/LegacyComponents.h>

@class TGConversation;

@interface TGSelectContactController : TGContactsController <TGNavigationControllerItem>

@property (nonatomic) bool shouldBeRemovedFromNavigationAfterHiding;

@property (nonatomic, strong) ASHandle *actionsHandle;

@property (nonatomic, strong) TGConversation *channelConversation;
@property (nonatomic, strong) NSString *channelLink;

@property (nonatomic, copy) void (^onChannelMembersInvited)(NSArray *users);
@property (nonatomic, copy) void (^onCreateLink)();
@property (nonatomic, copy) void (^onCall)(TGUser *);

- (id)initWithCreateGroup:(bool)createGroup createEncrypted:(bool)createEncrypted createBroadcast:(bool)createBroadcast createChannel:(bool)createChannel inviteToChannel:(bool)inviteToChannel showLink:(bool)showLink;

- (id)initWithCreateGroup:(bool)createGroup createEncrypted:(bool)createEncrypted createBroadcast:(bool)createBroadcast createChannel:(bool)createChannel inviteToChannel:(bool)inviteToChannel showLink:(bool)showLink call:(bool)call;

@end
