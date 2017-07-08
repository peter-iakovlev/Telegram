#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

#import "TGConversation.h"
#import "TGChannelAdminLogEntry.h"

@class TGMessageHole;
@class TGConversation;
@class TGUser;

@class TLChannelParticipant;

typedef enum {
    TGChannelHistoryHoleDirectionEarlier,
    TGChannelHistoryHoleDirectionLater
} TGChannelHistoryHoleDirection;

typedef struct {
    bool join;
    bool leave;
    bool invite;
    bool ban;
    bool unban;
    bool kick;
    bool unkick;
    bool promote;
    bool demote;
    bool info;
    bool settings;
    bool pinned;
    bool edit;
    bool del;
} TGChannelEventFilter;

@interface TGChannelManagementSignals : NSObject

+ (SSignal *)makeChannelWithTitle:(NSString *)title about:(NSString *)about group:(bool)group;
+ (SSignal *)addChannel:(TGConversation *)conversation;
+ (bool)_containsPreloadedHistoryForPeerId:(int64_t)peerId aroundMessageId:(int32_t)messageId;
+ (SSignal *)preloadedHistoryForPeerId:(int64_t)peerId accessHash:(int64_t)accessHash aroundMessageId:(int32_t)messageId;
+ (SSignal *)preloadedChannelAtMessage:(int64_t)peerId messageId:(int32_t)messageId;
+ (SSignal *)preloadedChannel:(int64_t)peerId;
+ (SSignal *)channelMessageHoleForPeerId:(int64_t)peerId accessHash:(int64_t)accessHash hole:(TGMessageHole *)hole direction:(TGChannelHistoryHoleDirection)direction important:(bool)important;
+ (SSignal *)exportChannelInvitationLink:(int64_t)peerId accessHash:(int64_t)accessHash;
+ (SSignal *)deleteChannelMessages;
+ (SSignal *)readChannelMessages;
+ (SSignal *)leaveChannels;
+ (void)updateChannelState:(int64_t)peerId pts:(int32_t)pts ptsCount:(int32_t)ptsCount;
+ (SSignal *)joinTemporaryChannel:(int64_t)peerId;
+ (SSignal *)inviteUsers:(int64_t)peerId accessHash:(int64_t)accessHash users:(NSArray *)users;

+ (SSignal *)checkChannelUsername:(int64_t)peerId accessHash:(int64_t)accessHash username:(NSString *)username;
+ (SSignal *)updateChannelUsername:(int64_t)peerId accessHash:(int64_t)accessHash username:(NSString *)username;
+ (SSignal *)updateChannelAbout:(int64_t)peerId accessHash:(int64_t)accessHash about:(NSString *)about;
+ (SSignal *)updateChannelPhoto:(int64_t)peerId accessHash:(int64_t)accessHash uploadedFile:(SSignal *)uploadedFile;
+ (SSignal *)updateChannelExtendedInfo:(int64_t)peerId accessHash:(int64_t)accessHash updateUnread:(bool)updateUnread;

+ (SSignal *)updatedPeerMessageViews:(int64_t)peerId accessHash:(int64_t)accessHash messageIds:(NSArray *)messageIds;
+ (SSignal *)consumeMessages:(int64_t)peerId accessHash:(int64_t)accessHash messageIds:(NSArray *)messageIds;

+ (SSignal *)toggleChannelEverybodyCanInviteMembers:(int64_t)peerId accessHash:(int64_t)accessHash enabled:(bool)enabled;
+ (SSignal *)updateChannelAdminRights:(int64_t)peerId accessHash:(int64_t)accessHash user:(TGUser *)user rights:(TGChannelAdminRights *)rights;
+ (SSignal *)updateChannelBannedRightsAndGetMembership:(int64_t)peerId accessHash:(int64_t)accessHash user:(TGUser *)user rights:(TGChannelBannedRights *)rights;
+ (SSignal *)channelRole:(int64_t)peerId accessHash:(int64_t)accessHash user:(TGUser *)user;
+ (SSignal *)channelBlacklistMembers:(int64_t)peerId accessHash:(int64_t)accessHash offset:(NSUInteger)offset count:(NSUInteger)count;
+ (SSignal *)channelBannedMembers:(int64_t)peerId accessHash:(int64_t)accessHash offset:(NSUInteger)offset count:(NSUInteger)count;
+ (SSignal *)channelMembers:(int64_t)peerId accessHash:(int64_t)accessHash offset:(NSUInteger)offset count:(NSUInteger)count;
+ (SSignal *)channelAdmins:(int64_t)peerId accessHash:(int64_t)accessHash offset:(NSUInteger)offset count:(NSUInteger)count;
+ (SSignal *)channelInviterUser:(int64_t)peerId accessHash:(int64_t)accessHash;

+ (SSignal *)deleteChannel:(int64_t)peerId accessHash:(int64_t)accessHash;
+ (SSignal *)canMakePublicChannels;

+ (SSignal *)updateChannelSignaturesEnabled:(int64_t)peerId accessHash:(int64_t)accessHash enabled:(bool)enabled;

+ (SSignal *)messageEditData:(int64_t)peerId accessHash:(int64_t)accessHash messageId:(int32_t)messageId;

+ (SSignal *)updatePinnedMessage:(int64_t)peerId accessHash:(int64_t)accessHash messageId:(int32_t)messageId notify:(bool)notify;
+ (SSignal *)removeAllUserMessages:(int64_t)peerId accessHash:(int64_t)accessHash user:(TGUser *)user;
+ (SSignal *)reportUserSpam:(int64_t)peerId accessHash:(int64_t)accessHash user:(TGUser *)user messageIds:(NSArray *)messageIds;

+ (SSignal *)resolveChannelWithUsername:(NSString *)username;

+ (SSignal *)channelAdminLogEvents:(int64_t)peerId accessHash:(int64_t)accessHash minEntryId:(int64_t)minEntryId count:(int32_t)count filter:(TGChannelEventFilter)filter searchQuery:(NSString *)searchQuery userIds:(NSArray *)userIds;

+ (TGCachedConversationMember *)parseMember:(TLChannelParticipant *)desc;

@end
