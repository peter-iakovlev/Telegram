#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

#import "TGConversation.h"

@class TGMessageHole;
@class TGConversation;
@class TGUser;

typedef enum {
    TGChannelHistoryHoleDirectionEarlier,
    TGChannelHistoryHoleDirectionLater
} TGChannelHistoryHoleDirection;

@interface TGChannelManagementSignals : NSObject

+ (SSignal *)makeChannelWithTitle:(NSString *)title about:(NSString *)about userIds:(NSArray *)userIds;
+ (SSignal *)addChannel:(TGConversation *)conversation;
+ (SSignal *)synchronizedChannelList;
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

+ (SSignal *)toggleChannelCommentsEnabled:(int64_t)peerId accessHash:(int64_t)accessHash enabled:(bool)enabled;

+ (SSignal *)channelChangeMemberKicked:(int64_t)peerId accessHash:(int64_t)accessHash user:(TGUser *)user kicked:(bool)kicked;
+ (SSignal *)channelChangeRole:(int64_t)peerId accessHash:(int64_t)accessHash user:(TGUser *)user role:(TGChannelRole)role;
+ (SSignal *)channelRole:(int64_t)peerId accessHash:(int64_t)accessHash user:(TGUser *)user;
+ (SSignal *)channelBlacklistMembers:(int64_t)peerId accessHash:(int64_t)accessHash offset:(NSUInteger)offset count:(NSUInteger)count;
+ (SSignal *)channelMembers:(int64_t)peerId accessHash:(int64_t)accessHash offset:(NSUInteger)offset count:(NSUInteger)count;
+ (SSignal *)channelAdmins:(int64_t)peerId accessHash:(int64_t)accessHash offset:(NSUInteger)offset count:(NSUInteger)count;
+ (SSignal *)channelInviterUser:(int64_t)peerId accessHash:(int64_t)accessHash;

+ (SSignal *)deleteChannel:(int64_t)peerId accessHash:(int64_t)accessHash;
+ (SSignal *)canMakePublicChannels;

@end
