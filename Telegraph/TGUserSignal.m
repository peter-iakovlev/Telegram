#import "TGUserSignal.h"

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"
#import "TGDatabase.h"

#import "ActionStage.h"

#import "TLUserFull$userFull.h"
#import "TGUserDataRequestBuilder.h"
#import "TGConversation+Telegraph.h"

@interface TGUserUpdatesAdapter : NSObject <ASWatcher>
{
    int32_t _userId;
    void (^_userUpdated)(TGUser *);
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGUserUpdatesAdapter

- (instancetype)initWithUserId:(int32_t)userId userUpdated:(void (^)(TGUser *))userUpdated
{
    self = [super init];
    if (self != nil)
    {
        _userId = userId;
        _userUpdated = [userUpdated copy];
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        [ActionStageInstance() watchForPaths:@[
            @"/tg/userdatachanges",
            @"/tg/userpresencechanges"
        ] watcher:self];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/tg/userdatachanges"] || [path isEqualToString:@"/tg/userpresencechanges"])
    {
        NSArray *users = ((SGraphObjectNode *)resource).object;
        
        for (TGUser *user in users)
        {
            if (user.uid == _userId)
            {
                if (_userUpdated)
                    _userUpdated(user);
            }
        }
    }
}

@end

@implementation TGUserSignal

+ (SSignal *)userWithUserId:(int32_t)userId
{
    SSignal *localSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGUser *user = [TGDatabaseInstance() loadUser:userId];
        if (user == nil)
            [subscriber putError:nil];
        else
        {
            [subscriber putNext:user];
            [subscriber putCompletion];
        }
        return nil;
    }];
    
    SSignal *updatesSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGUserUpdatesAdapter *adapter = [[TGUserUpdatesAdapter alloc] initWithUserId:userId userUpdated:^(TGUser *user)
        {
            [subscriber putNext:user];
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [adapter description]; //keep reference
        }];
    }];
    
    return [localSignal then:updatesSignal];
}

+ (SSignal *)updatedUserCachedDataWithUserId:(int32_t)userId {
    return [[TGDatabaseInstance() modify:^id {
        TGUser *user = [TGDatabaseInstance() loadUser:userId];
        if (user != nil) {
            TLRPCusers_getFullUser$users_getFullUser *getFullUser = [[TLRPCusers_getFullUser$users_getFullUser alloc] init];
            TLInputUser$inputUser *inputUser = [[TLInputUser$inputUser alloc] init];
            inputUser.user_id = user.uid;
            inputUser.access_hash = user.phoneNumberHash;
            getFullUser.n_id = inputUser;
            return [[[TGTelegramNetworking instance] requestSignal:getFullUser] mapToSignal:^SSignal *(TLUserFull$userFull *result) {
                return [[TGDatabaseInstance() modify:^id{
                    [TGDatabaseInstance() updateCachedUserData:user.uid block:^TGCachedUserData *(TGCachedUserData *data) {
                        if (data == nil) {
                            return [[TGCachedUserData alloc] initWithAbout:result.about groupsInCommonCount:result.common_chats_count groupsInCommon:nil supportsCalls:result.flags & (1 << 4) callsPrivate:result.flags & (1 << 5)];
                        } else {
                            return [[[[data updateAbout:result.about] updateGroupsInCommonCount:result.common_chats_count] updateSupportsCalls:result.flags & (1 << 4)] updateCallsPrivate:result.flags & (1 << 5)];
                        }
                    }];
                    
                    return [SSignal complete];
                }] switchToLatest];
            }];
        } else {
            return [SSignal fail:nil];
        }
    }] switchToLatest];
}

+ (SSignal *)groupsInCommon:(int32_t)userId {
    return [[TGDatabaseInstance() modify:^id {
        TGUser *user = [TGDatabaseInstance() loadUser:userId];
        if (user != nil) {
            TLRPCmessages_getCommonChats$messages_getCommonChats *getCommonChats = [[TLRPCmessages_getCommonChats$messages_getCommonChats alloc] init];
            TLInputUser$inputUser *inputUser = [[TLInputUser$inputUser alloc] init];
            inputUser.user_id = user.uid;
            inputUser.access_hash = user.phoneNumberHash;
            getCommonChats.user_id = inputUser;
            getCommonChats.limit = 200;
            return [[[TGTelegramNetworking instance] requestSignal:getCommonChats] mapToSignal:^SSignal *(TLmessages_Chats *result) {
                NSMutableArray *conversations = [[NSMutableArray alloc] init];
                for (TLChat *chat in result.chats) {
                    TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chat];
                    if (conversation.conversationId != 0) {
                        [conversations addObject:conversation];
                    }
                }
                return [[TGDatabaseInstance() modify:^id{
                    [TGDatabaseInstance() updateCachedUserData:user.uid block:^TGCachedUserData *(TGCachedUserData *data) {
                        if (data == nil) {
                            return [[TGCachedUserData alloc] initWithAbout:nil groupsInCommonCount:(int32_t)conversations.count groupsInCommon:[[TGCachedUserGroupsInCommon alloc] initWithGroups:conversations] supportsCalls:false callsPrivate:false];
                        } else {
                            return [[data updateGroupsInCommon:[[TGCachedUserGroupsInCommon alloc] initWithGroups:conversations]] updateGroupsInCommonCount:(int32_t)conversations.count];
                        }
                    }];
                    
                    return [SSignal single:[[TGCachedUserGroupsInCommon alloc] initWithGroups:conversations]];
                }] switchToLatest];
            }];
        } else {
            return [SSignal fail:nil];
        }
    }] switchToLatest];
}

@end
