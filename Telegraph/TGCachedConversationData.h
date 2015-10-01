#import <Foundation/Foundation.h>

#import "PSCoding.h"
#import "TGConversation.h"

@interface TGCachedConversationMember : NSObject <PSCoding>

@property (nonatomic, readonly) int32_t uid;
@property (nonatomic, readonly) TGChannelRole role;
@property (nonatomic, readonly) int32_t timestamp;

- (instancetype)initWithUid:(int32_t)uid role:(TGChannelRole)role timestamp:(int32_t)timestamp;

@end

@interface TGCachedConversationData : NSObject <PSCoding>

@property (nonatomic, readonly) int32_t managementCount;
@property (nonatomic, readonly) int32_t blacklistCount;
@property (nonatomic, readonly) int32_t memberCount;

@property (nonatomic, strong, readonly) NSArray *managementMembers;
@property (nonatomic, strong, readonly) NSArray *blacklistMembers;
@property (nonatomic, strong, readonly) NSArray *generalMembers;

@property (nonatomic, strong, readonly) NSString *privateLink;

- (instancetype)init;
- (instancetype)initWithManagementCount:(int32_t)managementCount blacklistCount:(int32_t)blacklistCount memberCount:(int32_t)memberCount managementMembers:(NSArray *)managementMembers blacklistMembers:(NSArray *)blacklistMembers generalMembers:(NSArray *)generalMembers privateLink:(NSString *)privateLink;

- (TGCachedConversationData *)updateManagementCount:(int32_t)managementCount blacklistCount:(int32_t)blacklistCount memberCount:(int32_t)memberCount;

- (TGCachedConversationData *)blacklistMember:(int32_t)uid timestamp:(int32_t)timestamp;
- (TGCachedConversationData *)unblacklistMember:(int32_t)uid timestamp:(int32_t)timestamp;
- (TGCachedConversationData *)addManagementMember:(TGCachedConversationMember *)member;
- (TGCachedConversationData *)removeManagementMember:(int32_t)uid;
- (TGCachedConversationData *)addMembers:(NSArray *)uids timestamp:(int32_t)timestamp;
- (TGCachedConversationData *)updatePrivateLink:(NSString *)privateLink;

- (TGCachedConversationData *)updateGeneralMembers:(NSArray *)generalMembers;
- (TGCachedConversationData *)updateManagementMembers:(NSArray *)managementMembers;
- (TGCachedConversationData *)updateBlacklistMembers:(NSArray *)blacklistMembers;

@end
