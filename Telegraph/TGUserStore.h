#import "TGDatabaseStore.h"

#import "PSKeyValueStore.h"

@class TGUserModel;
@class TGUserPresenceModel;

@interface TGUserStore : NSObject <TGDatabaseStore>

- (instancetype)initWithKeyValueStore:(id<PSKeyValueStore>)keyValueStore;

- (void)storeUsers:(NSArray *)users;
- (TGUserModel *)userWithId:(int32_t)uid;
- (NSMutableDictionary *)usersWithIds:(NSArray *)uids;

- (void)storeUserPresences:(NSArray *)userPresences;
- (TGUserPresenceModel *)userPresenceWithId:(int32_t)uid;
- (NSMutableDictionary *)userPresencesWithIds:(NSArray *)uids;

@end
