#import <Foundation/Foundation.h>

#import "PSCoding.h"
#import "TGConversation.h"

@class TGChannelAdminRights;
@class TGChannelBannedRights;

@interface TGCachedConversationMember : NSObject <PSCoding>

@property (nonatomic, readonly) int32_t uid;
@property (nonatomic, readonly) bool isCreator;
@property (nonatomic, readonly) TGChannelAdminRights *adminRights;
@property (nonatomic, readonly) TGChannelBannedRights *bannedRights;
@property (nonatomic, readonly) int32_t timestamp;
@property (nonatomic, readonly) int32_t inviterId;
@property (nonatomic, readonly) int32_t adminInviterId;
@property (nonatomic, readonly) int32_t kickedById;
@property (nonatomic, readonly) bool adminCanManage;

- (instancetype)initWithUid:(int32_t)uid isCreator:(bool)isCreator adminRights:(TGChannelAdminRights *)adminRights bannedRights:(TGChannelBannedRights *)bannedRights timestamp:(int32_t)timestamp inviterId:(int32_t)inviterId adminInviterId:(int32_t)adminInviterId kickedById:(int32_t)kickedById adminCanManage:(bool)adminCanManage;

- (TGCachedConversationMember *)withUpdatedBannedRights:(TGChannelBannedRights *)bannedRights;
- (TGCachedConversationMember *)withUpdatedAdminRights:(TGChannelAdminRights *)adminRights adminInviterId:(int32_t)adminInviterId adminCanManage:(bool)adminCanManage;

@end

@interface TGConversationMigrationData : NSObject <PSCoding>

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) int32_t maxMessageId;

- (instancetype)initWithPeerId:(int64_t)peerId maxMessageId:(int32_t)maxMessageId;

@end

@interface TGCachedConversationData : NSObject <PSCoding>

@property (nonatomic, readonly) int32_t managementCount;
@property (nonatomic, readonly) int32_t blacklistCount;
@property (nonatomic, readonly) int32_t bannedCount;
@property (nonatomic, readonly) int32_t memberCount;

@property (nonatomic, strong, readonly) NSArray *managementMembers;
@property (nonatomic, strong, readonly) NSArray *blacklistMembers;
@property (nonatomic, strong, readonly) NSArray *bannedMembers;
@property (nonatomic, strong, readonly) NSArray *generalMembers;

@property (nonatomic, strong, readonly) NSString *privateLink;

@property (nonatomic, strong, readonly) TGConversationMigrationData *migrationData;

@property (nonatomic, strong, readonly) NSDictionary *botInfos;

- (instancetype)init;
- (instancetype)initWithManagementCount:(int32_t)managementCount blacklistCount:(int32_t)blacklistCount bannedCount:(int32_t)bannedCount memberCount:(int32_t)memberCount managementMembers:(NSArray *)managementMembers blacklistMembers:(NSArray *)blacklistMembers bannedMembers:(NSArray *)bannedMembers generalMembers:(NSArray *)generalMembers privateLink:(NSString *)privateLink migrationData:(TGConversationMigrationData *)migrationData botInfos:(NSDictionary *)botInfos;

- (TGCachedConversationData *)updateManagementCount:(int32_t)managementCount blacklistCount:(int32_t)blacklistCount bannedCount:(int32_t)bannedCount memberCount:(int32_t)memberCount;

- (TGCachedConversationData *)updateMemberBannedRights:(int32_t)uid rights:(TGChannelBannedRights *)rights timestamp:(int32_t)timestamp isMember:(bool)isMember kickedById:(int32_t)kickedById;
- (TGCachedConversationData *)addManagementMember:(TGCachedConversationMember *)member;
- (TGCachedConversationData *)removeManagementMember:(int32_t)uid;
- (TGCachedConversationData *)addMembers:(NSArray *)uids timestamp:(int32_t)timestamp;
- (TGCachedConversationData *)updatePrivateLink:(NSString *)privateLink;

- (TGCachedConversationData *)updateGeneralMembers:(NSArray *)generalMembers;
- (TGCachedConversationData *)updateManagementMembers:(NSArray *)managementMembers;
- (TGCachedConversationData *)updateBlacklistMembers:(NSArray *)blacklistMembers;
- (TGCachedConversationData *)updateBannedMembers:(NSArray *)bannedMembers;

- (TGCachedConversationData *)updateMigrationData:(TGConversationMigrationData *)migrationData;
- (TGCachedConversationData *)updateBotInfos:(NSDictionary *)botInfos;

@end
