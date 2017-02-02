#import "TGGroupedUserOnlineSignals.h"

#import "TGTelegramNetworking.h"
#import "ActionStage.h"
#import "TL/TLMetaScheme.h"
#import "TGTelegraph.h"
#import "TGUser+Telegraph.h"

@interface TGGroupedUserOnlineHelper : NSObject <ASWatcher> {
    NSSet *_userIds;
    NSMutableSet *_onlineUserIds;
    STimer *_onlineDispatchTimer;
}

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic, copy) void (^onlineUserIdsUpdated)(NSUInteger);

@end

@implementation TGGroupedUserOnlineHelper

- (instancetype)initWithUsers:(NSArray *)users onlineUserIdsUpdated:(void (^)(NSUInteger))onlineUserIdsUpdated {
    self = [super init];
    if (self != nil) {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        _onlineUserIds = [[NSMutableSet alloc] init];
        _onlineUserIdsUpdated = [onlineUserIdsUpdated copy];
        
        NSMutableSet *userIds = [[NSMutableSet alloc] init];
        for (TGUser *user in users) {
            [userIds addObject:@(user.uid)];
            if (user.presence.online) {
                [_onlineUserIds addObject:@(user.uid)];
            }
        }
        
        _userIds = userIds;
        
        [ActionStageInstance() watchForPaths:@[@"/tg/userdatachanges", @"/tg/userpresencechanges"] watcher:self];
        
        if (onlineUserIdsUpdated) {
            onlineUserIdsUpdated(_onlineUserIds.count);
        }
    }
    return self;
}

- (void)dealloc {
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    [_onlineDispatchTimer invalidate];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/tg/userdatachanges"] || [path isEqualToString:@"/tg/userpresencechanges"]) {
        bool changed = false;
        NSArray *users = ((SGraphObjectNode *)resource).object;
        for (TGUser *user in users) {
            if ([_userIds containsObject:@(user.uid)]) {
                if (user.presence.online) {
                    if (![_onlineUserIds containsObject:@(user.uid)]) {
                        [_onlineUserIds addObject:@(user.uid)];
                        changed = true;
                    }
                } else {
                    if ([_onlineUserIds containsObject:@(user.uid)]) {
                        [_onlineUserIds removeObject:@(user.uid)];
                        changed = true;
                    }
                }
            }
        }
        
        if (changed) {
            [self scheduleDispatch];
        }
    }
}

- (void)scheduleDispatch {
    [_onlineDispatchTimer invalidate];
    
    __weak TGGroupedUserOnlineHelper *weakSelf = self;
    _onlineDispatchTimer = [[STimer alloc] initWithTimeout:1.0 repeat:false completion:^{
        __strong TGGroupedUserOnlineHelper *strongSelf = weakSelf;
        if (strongSelf != nil) {
            strongSelf->_onlineDispatchTimer = nil;
            
            strongSelf->_onlineUserIdsUpdated(strongSelf->_onlineUserIds.count);
        }
    } queue:[SQueue wrapConcurrentNativeQueue:[ActionStageInstance() globalStageDispatchQueue]]];
    [_onlineDispatchTimer start];
}

@end

@implementation TGGroupedUserOnlineInfo

- (instancetype)initWithTotalCount:(NSUInteger)totalCount onlineCount:(NSUInteger)onlineCount {
    self = [super init];
    if (self != nil) {
        _totalCount = totalCount;
        _onlineCount = onlineCount;
    }
    return self;
}

@end

@implementation TGGroupedUserOnlineSignals

+ (SSignal *)usersOnlineStatuses:(NSArray *)users {
    TLRPCusers_getUsers$users_getUsers *getUsers = [[TLRPCusers_getUsers$users_getUsers alloc] init];
    NSMutableArray *inputUsers = [[NSMutableArray alloc] init];
    for (TGUser *user in users) {
        if (user.phoneNumberHash != 0) {
            TLInputUser$inputUser *inputUser = [[TLInputUser$inputUser alloc] init];
            inputUser.user_id = user.uid;
            inputUser.access_hash = user.phoneNumberHash;
            [inputUsers addObject:inputUser];
        }
    }
    getUsers.n_id = inputUsers;
    return [[[TGTelegramNetworking instance] requestSignal:getUsers] map:^id(NSArray *userDescs) {
        NSMutableDictionary *statuses = [[NSMutableDictionary alloc] init];
        
        for (TLUser *desc in userDescs) {
            TGUser *user = [[TGUser alloc] initWithTelegraphUserDesc:desc];
            if (user.uid != 0) {
                if (user.presence.online) {
                    statuses[@(user.uid)] = @true;
                }
            }
        }
        
        return statuses;
    }];
}

+ (SSignal *)groupedOnlineInfoForUserList:(SSignal *)users {
    NSTimeInterval pollInterval = 60.0;
#ifdef DEBUG
    pollInterval = 10.0;
#endif
    
    return [[[users mapToSignal:^SSignal *(NSArray *users) {
        if (users.count == 0) {
            return [SSignal single:nil];
        } else {
            SSignal *live = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
                TGGroupedUserOnlineHelper *helper = [[TGGroupedUserOnlineHelper alloc] initWithUsers:users onlineUserIdsUpdated:^(NSUInteger count) {
                    [subscriber putNext:[[TGGroupedUserOnlineInfo alloc] initWithTotalCount:users.count onlineCount:count]];
                }];
                
                return [[SBlockDisposable alloc] initWithBlock:^{
                    [helper description]; // keep reference
                }];
            }];
            
            return live;
        }
    }] then:[[SSignal complete] delay:pollInterval onQueue:[SQueue concurrentDefaultQueue]]] restart];
}

@end
