#import <SSignalKit/SSignalKit.h>

typedef enum {
    TGGlobalMessageSearchMembersSectionMembers,
    TGGlobalMessageSearchMembersSectionBanned,
    TGGlobalMessageSearchMembersSectionRestricted
} TGGlobalMessageSearchMembersSection;

@interface TGGlobalMessageSearchSignals : NSObject

+ (SSignal *)search:(NSString *)query includeMessages:(bool)includeMessages itemMapping:(id (^)(id))itemMapping;
+ (SSignal *)searchMessages:(NSString *)query peerId:(int64_t)peerId accessHash:(int64_t)accessHash userId:(int32_t)userId maxId:(int32_t)maxId limit:(int32_t)limit itemMapping:(id (^)(id))itemMapping;

+ (SSignal *)searchDialogs:(NSString *)query itemMapping:(id (^)(id))itemMapping;

+ (void)clearRecentResults;
+ (void)addRecentPeerResult:(int64_t)peerId;
+ (void)removeRecentPeerResult:(int64_t)peerId;
+ (SSignal *)recentPeerResults:(id (^)(id, bool))itemMapping ratedPeers:(bool)ratedPeers;

+ (SSignal *)searchUsersAndChannels:(NSString *)query;
+ (SSignal *)searchChannelMembers:(NSString *)query peerId:(int64_t)peerId accessHash:(int64_t)accessHash section:(TGGlobalMessageSearchMembersSection)section;
+ (SSignal *)searchContacts:(NSString *)query;

@end
