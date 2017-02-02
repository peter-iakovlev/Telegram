#import <Foundation/Foundation.h>

#import <SSignalKit/SSignalKit.h>

#import "TGGroupInvitationInfo.h"

@class TGUser;

typedef enum {
    TGSynchronizePinnedConversationsActionPush = 1,
    TGSynchronizePinnedConversationsActionPull = 2
} TGSynchronizePinnedConversationsActionType;

@interface TGSynchronizePinnedConversationsAction : NSObject <NSCoding>

@property (nonatomic, readonly) int32_t type;
@property (nonatomic, readonly) int32_t version;

- (instancetype)initWithType:(int32_t)type version:(int32_t)version;

@end

@interface TGGroupManagementSignals : NSObject

+ (SSignal *)makeGroupWithTitle:(NSString *)title users:(NSArray *)users;
+ (SSignal *)exportGroupInvitationLink:(int32_t)groupId;
+ (SSignal *)groupInvitationLinkInfo:(NSString *)hash;
+ (SSignal *)acceptGroupInvitationLink:(NSString *)hash;
+ (SSignal *)updateGroupPhoto:(int64_t)peerId uploadedFile:(SSignal *)uploadedFile;
+ (SSignal *)inviteUserWithId:(int32_t)userId toGroupWithId:(int32_t)groupId;
+ (SSignal *)toggleGroupHasAdmins:(int64_t)peerId hasAdmins:(bool)hasAdmins;
+ (SSignal *)toggleUserIsAdmin:(int64_t)peerId user:(TGUser *)user isAdmin:(bool)isAdmin;
+ (SSignal *)migrateGroup:(int64_t)peerId;
+ (SSignal *)messageEditData:(int64_t)peerId accessHash:(int64_t)accessHash messageId:(int32_t)messageId;
+ (SSignal *)editMessage:(int64_t)peerId accessHash:(int64_t)accessHash messageId:(int32_t)messageId text:(NSString *)text entities:(NSArray *)entities disableLinksPreview:(bool)disableLinksPreview;

+ (SSignal *)validatePeerReadStates:(SSignal *)peers;
+ (SSignal *)synchronizePeerMessageDrafts:(SSignal *)peerIdsSets;
+ (SSignal *)conversationsToBeRemovedToAssignPublicUsernames:(int64_t)conversationId accessHash:(int64_t)accessHash;
+ (SSignal *)preloadedPeer:(int64_t)peerId accessHash:(int64_t)accessHash;

+ (SSignal *)updatePinnedState:(int64_t)peerId pinned:(bool)pinned;
+ (SSignal *)synchronizePinnedConversations;
+ (SSignal *)pullPinnedConversations;
+ (void)beginPullPinnedConversations;

@end
