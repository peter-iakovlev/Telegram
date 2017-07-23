#import "TGAccountSettingsUpdateActor.h"

#import "ActionStage.h"
#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

#import <MTProtoKit/MTRequest.h>

#import "TGAccountSettings.h"

#import "TGDatabase.h"

#import "TGUserDataRequestBuilder.h"
#import "TGTelegraph.h"

#import "TGUpdateStateRequestBuilder.h"
#import "TGAccountSettingsActor.h"

@interface TGAccountSettingsUpdateActor ()
{
    NSMutableSet *_remainingSettingKeys;
    
    TGAccountSettings *_accountSettings;
}

@end

@implementation TGAccountSettingsUpdateActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/updateAccountSettings";
}

- (void)prepare:(NSDictionary *)options
{
    [super prepare:options];
    
    self.requestQueueName = @"accountSettings";
}

- (void)_maybeComplete:(bool)success
{
    if (_remainingSettingKeys.count == 0)
    {
        if (success)
            [TGAccountSettingsActor setAccountSettingsForCurrentStateId:_accountSettings];
        if (success)
            [ActionStageInstance() actionCompleted:self.path result:nil];
        else
            [ActionStageInstance() actionFailed:self.path reason:-1];
    }
}

- (void)execute:(NSDictionary *)options
{
    _accountSettings = [TGAccountSettingsActor accountSettingsFotCurrentStateId];
    if (_accountSettings == nil)
        _accountSettings = [[TGAccountSettings alloc] initWithDefaultValues];
    
    _remainingSettingKeys = [[NSMutableSet alloc] init];
    [self updateOptions:options];
}

- (void)watcherJoined:(ASHandle *)watcherHandle options:(NSDictionary *)options waitingInActorQueue:(bool)waitingInActorQueue
{
    [super watcherJoined:watcherHandle options:options waitingInActorQueue:waitingInActorQueue];
    
    [self updateOptions:options];
}

- (NSArray *)inputUsersFromUserIds:(NSArray *)userIds
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSNumber *nUserId in userIds)
    {
        TGUser *user = [TGDatabaseInstance() loadUser:[nUserId intValue]];
        TLInputUser$inputUser *inputUser = [[TLInputUser$inputUser alloc] init];
        inputUser.user_id = [nUserId intValue];
        inputUser.access_hash = user.phoneNumberHash;
        [array addObject:inputUser];
    }
    return array;
}

- (void)updateOptions:(NSDictionary *)options
{
    if (self.cancelToken != nil)
        [[TGTelegramNetworking instance] cancelRpc:self.cancelToken];
    
    NSMutableArray *requestList = [[NSMutableArray alloc] init];
    for (NSDictionary *desc in options[@"settingList"])
    {
        if (desc[@"notifications"] != nil)
        {
            TGNotificationPrivacyAccountSetting *privacySettings = (TGNotificationPrivacyAccountSetting *)desc[@"notifications"];
            _accountSettings = [[TGAccountSettings alloc] initWithNotificationSettings:privacySettings groupsAndChannelsSettings:_accountSettings.groupsAndChannelsSettings callSettings:_accountSettings.callSettings accountTTLSetting:_accountSettings.accountTTLSetting];
            [_remainingSettingKeys addObject:@"notificationPrivacySettings"];
            
            MTRequest *request = [[MTRequest alloc] init];
            
            TLRPCaccount_setPrivacy$account_setPrivacy *setPrivacy = [[TLRPCaccount_setPrivacy$account_setPrivacy alloc] init];
            setPrivacy.key = [[TLInputPrivacyKey$inputPrivacyKeyStatusTimestamp alloc] init];
            
            NSMutableArray *rules = [[NSMutableArray alloc] init];
            
            if (privacySettings.alwaysShareWithUserIds.count != 0)
            {
                if (privacySettings.lastSeenPrimarySetting != TGPrivacySettingsLastSeenPrimarySettingEverybody)
                {
                    TLInputPrivacyRule$inputPrivacyValueAllowUsers *allowUsers = [[TLInputPrivacyRule$inputPrivacyValueAllowUsers alloc] init];
                    allowUsers.users = [self inputUsersFromUserIds:privacySettings.alwaysShareWithUserIds];
                    [rules addObject:allowUsers];
                }
            }
            if (privacySettings.neverShareWithUserIds.count != 0)
            {
                if (privacySettings.lastSeenPrimarySetting != TGPrivacySettingsLastSeenPrimarySettingNobody)
                {
                    TLInputPrivacyRule$inputPrivacyValueDisallowUsers *disallowUsers = [[TLInputPrivacyRule$inputPrivacyValueDisallowUsers alloc] init];
                    disallowUsers.users = [self inputUsersFromUserIds:privacySettings.neverShareWithUserIds];
                    [rules addObject:disallowUsers];
                }
            }
            switch (privacySettings.lastSeenPrimarySetting)
            {
                case TGPrivacySettingsLastSeenPrimarySettingContacts:
                {
                    [rules addObject:[[TLInputPrivacyRule$inputPrivacyValueAllowContacts alloc] init]];
                    break;
                }
                case TGPrivacySettingsLastSeenPrimarySettingEverybody:
                {
                    [rules addObject:[[TLInputPrivacyRule$inputPrivacyValueAllowAll alloc] init]];
                    break;
                }
                case TGPrivacySettingsLastSeenPrimarySettingNobody:
                {
                    [rules addObject:[[TLInputPrivacyRule$inputPrivacyValueDisallowAll alloc] init]];
                    break;
                }
            }
            
            setPrivacy.rules = rules;
            request.body = setPrivacy;
            
            __weak TGAccountSettingsUpdateActor *weakSelf = self;
            [request setCompleted:^(__unused id result, __unused NSTimeInterval timestamp, id error)
             {
                 __strong TGAccountSettingsUpdateActor *strongSelf = weakSelf;
                 if (strongSelf != nil)
                 {
                     [ActionStageInstance() dispatchOnStageQueue:^
                      {
                          if (error == nil)
                              [strongSelf setNotificationsPrivacySuccess];
                          else
                              [strongSelf setNotificationPrivacyFailed];
                      }];
                 }
             }];
            
            [request setShouldContinueExecutionWithErrorContext:^bool(__unused MTRequestErrorContext *context)
            {
                return false;
            }];
            
            [requestList addObject:request];
        }
        else if (desc[@"groupsAndChannels"] != nil)
        {
            TGNotificationPrivacyAccountSetting *privacySettings = (TGNotificationPrivacyAccountSetting *)desc[@"groupsAndChannels"];
            _accountSettings = [[TGAccountSettings alloc] initWithNotificationSettings:_accountSettings.notificationSettings groupsAndChannelsSettings:privacySettings callSettings:_accountSettings.callSettings accountTTLSetting:_accountSettings.accountTTLSetting];
            [_remainingSettingKeys addObject:@"groupsAndChannelsPrivacySettings"];
            
            MTRequest *request = [[MTRequest alloc] init];
            
            TLRPCaccount_setPrivacy$account_setPrivacy *setPrivacy = [[TLRPCaccount_setPrivacy$account_setPrivacy alloc] init];
            setPrivacy.key = [[TLInputPrivacyKey$inputPrivacyKeyChatInvite alloc] init];
            
            NSMutableArray *rules = [[NSMutableArray alloc] init];
            
            if (privacySettings.alwaysShareWithUserIds.count != 0)
            {
                if (privacySettings.lastSeenPrimarySetting != TGPrivacySettingsLastSeenPrimarySettingEverybody)
                {
                    TLInputPrivacyRule$inputPrivacyValueAllowUsers *allowUsers = [[TLInputPrivacyRule$inputPrivacyValueAllowUsers alloc] init];
                    allowUsers.users = [self inputUsersFromUserIds:privacySettings.alwaysShareWithUserIds];
                    [rules addObject:allowUsers];
                }
            }
            if (privacySettings.neverShareWithUserIds.count != 0)
            {
                if (privacySettings.lastSeenPrimarySetting != TGPrivacySettingsLastSeenPrimarySettingNobody)
                {
                    TLInputPrivacyRule$inputPrivacyValueDisallowUsers *disallowUsers = [[TLInputPrivacyRule$inputPrivacyValueDisallowUsers alloc] init];
                    disallowUsers.users = [self inputUsersFromUserIds:privacySettings.neverShareWithUserIds];
                    [rules addObject:disallowUsers];
                }
            }
            switch (privacySettings.lastSeenPrimarySetting)
            {
                case TGPrivacySettingsLastSeenPrimarySettingContacts:
                {
                    [rules addObject:[[TLInputPrivacyRule$inputPrivacyValueAllowContacts alloc] init]];
                    break;
                }
                case TGPrivacySettingsLastSeenPrimarySettingEverybody:
                {
                    [rules addObject:[[TLInputPrivacyRule$inputPrivacyValueAllowAll alloc] init]];
                    break;
                }
                case TGPrivacySettingsLastSeenPrimarySettingNobody:
                {
                    [rules addObject:[[TLInputPrivacyRule$inputPrivacyValueDisallowAll alloc] init]];
                    break;
                }
            }
            
            setPrivacy.rules = rules;
            request.body = setPrivacy;
            
            __weak TGAccountSettingsUpdateActor *weakSelf = self;
            [request setCompleted:^(__unused id result, __unused NSTimeInterval timestamp, id error)
             {
                 __strong TGAccountSettingsUpdateActor *strongSelf = weakSelf;
                 if (strongSelf != nil)
                 {
                     [ActionStageInstance() dispatchOnStageQueue:^
                      {
                          if (error == nil)
                              [strongSelf setGroupsAndChannelsPrivacySuccess];
                          else
                              [strongSelf setGroupsAndChannelsPrivacyFailed];
                      }];
                 }
             }];
            
            [request setShouldContinueExecutionWithErrorContext:^bool(__unused MTRequestErrorContext *context)
             {
                 return false;
             }];
            
            [requestList addObject:request];
        }
        else if (desc[@"calls"] != nil)
        {
            TGNotificationPrivacyAccountSetting *privacySettings = (TGNotificationPrivacyAccountSetting *)desc[@"calls"];
            _accountSettings = [[TGAccountSettings alloc] initWithNotificationSettings:_accountSettings.notificationSettings groupsAndChannelsSettings:_accountSettings.groupsAndChannelsSettings callSettings:privacySettings accountTTLSetting:_accountSettings.accountTTLSetting];
            [_remainingSettingKeys addObject:@"calls"];
            
            MTRequest *request = [[MTRequest alloc] init];
            
            TLRPCaccount_setPrivacy$account_setPrivacy *setPrivacy = [[TLRPCaccount_setPrivacy$account_setPrivacy alloc] init];
            setPrivacy.key = [[TLInputPrivacyKey$inputPrivacyKeyPhoneCall alloc] init];
            
            NSMutableArray *rules = [[NSMutableArray alloc] init];
            
            if (privacySettings.alwaysShareWithUserIds.count != 0)
            {
                if (privacySettings.lastSeenPrimarySetting != TGPrivacySettingsLastSeenPrimarySettingEverybody)
                {
                    TLInputPrivacyRule$inputPrivacyValueAllowUsers *allowUsers = [[TLInputPrivacyRule$inputPrivacyValueAllowUsers alloc] init];
                    allowUsers.users = [self inputUsersFromUserIds:privacySettings.alwaysShareWithUserIds];
                    [rules addObject:allowUsers];
                }
            }
            if (privacySettings.neverShareWithUserIds.count != 0)
            {
                if (privacySettings.lastSeenPrimarySetting != TGPrivacySettingsLastSeenPrimarySettingNobody)
                {
                    TLInputPrivacyRule$inputPrivacyValueDisallowUsers *disallowUsers = [[TLInputPrivacyRule$inputPrivacyValueDisallowUsers alloc] init];
                    disallowUsers.users = [self inputUsersFromUserIds:privacySettings.neverShareWithUserIds];
                    [rules addObject:disallowUsers];
                }
            }
            switch (privacySettings.lastSeenPrimarySetting)
            {
                case TGPrivacySettingsLastSeenPrimarySettingContacts:
                {
                    [rules addObject:[[TLInputPrivacyRule$inputPrivacyValueAllowContacts alloc] init]];
                    break;
                }
                case TGPrivacySettingsLastSeenPrimarySettingEverybody:
                {
                    [rules addObject:[[TLInputPrivacyRule$inputPrivacyValueAllowAll alloc] init]];
                    break;
                }
                case TGPrivacySettingsLastSeenPrimarySettingNobody:
                {
                    [rules addObject:[[TLInputPrivacyRule$inputPrivacyValueDisallowAll alloc] init]];
                    break;
                }
            }
            
            setPrivacy.rules = rules;
            request.body = setPrivacy;
            
            __weak TGAccountSettingsUpdateActor *weakSelf = self;
            [request setCompleted:^(__unused id result, __unused NSTimeInterval timestamp, id error)
             {
                 __strong TGAccountSettingsUpdateActor *strongSelf = weakSelf;
                 if (strongSelf != nil)
                 {
                     [ActionStageInstance() dispatchOnStageQueue:^
                      {
                          if (error == nil)
                              [strongSelf setCallPrivacySuccess];
                          else
                              [strongSelf setCallPrivacyFailed];
                      }];
                 }
             }];
            
            [request setShouldContinueExecutionWithErrorContext:^bool(__unused MTRequestErrorContext *context)
             {
                 return false;
             }];
            
            [requestList addObject:request];
        }
        else if (desc[@"accountTTL"] != nil)
        {
            TGAccountTTLSetting *accountTTLSetting = (TGAccountTTLSetting *)desc[@"accountTTL"];
            _accountSettings = [[TGAccountSettings alloc] initWithNotificationSettings:_accountSettings.notificationSettings groupsAndChannelsSettings:_accountSettings.groupsAndChannelsSettings callSettings:_accountSettings.callSettings accountTTLSetting:accountTTLSetting];
            [_remainingSettingKeys addObject:@"accountTTLSetting"];
            
            MTRequest *request = [[MTRequest alloc] init];
            
            TLRPCaccount_setAccountTTL$account_setAccountTTL *setAccountTTL = [[TLRPCaccount_setAccountTTL$account_setAccountTTL alloc] init];
            TLAccountDaysTTL$accountDaysTTL *daysTTL = [[TLAccountDaysTTL$accountDaysTTL alloc] init];
            daysTTL.days = (int)(ceilf([accountTTLSetting.accountTTL intValue] / (60 * 60 * 24.0f)));
            setAccountTTL.ttl = daysTTL;
            
            request.body = setAccountTTL;
            
            __weak TGAccountSettingsUpdateActor *weakSelf = self;
            [request setCompleted:^(__unused id result, __unused NSTimeInterval timestamp, id error)
            {
                __strong TGAccountSettingsUpdateActor *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    [ActionStageInstance() dispatchOnStageQueue:^
                    {
                        if (error == nil)
                            [strongSelf setAccountTtlSuccess];
                        else
                            [strongSelf setAccountTtlFailed];
                    }];
                }
            }];
            
            [request setShouldContinueExecutionWithErrorContext:^bool(__unused MTRequestErrorContext *context)
            {
                return false;
            }];
            
            [requestList addObject:request];
        }
    }
    
    for (MTRequest *request in requestList)
    {
        [[TGTelegramNetworking instance] addRequest:request];
    }
}

- (void)setNotificationsPrivacySuccess
{
    [TGDatabaseInstance() setLocalUserStatusPrivacyRules:_accountSettings.notificationSettings changedLoadedUsers:^(NSArray *users)
    {
        std::shared_ptr<std::map<int, TGUserPresence> > pMap(new std::map<int, TGUserPresence>());
        for (TGUser *user in users)
        {
            pMap->insert(std::pair<int, TGUserPresence>(user.uid, user.presence));
        }
        [TGTelegraphInstance dispatchMultipleUserPresenceChanges:pMap];
    }];
    
    [_remainingSettingKeys removeObject:@"notificationPrivacySettings"];
    [self _maybeComplete:true];
    
    [ActionStageInstance() requestActor:@"/tg/updateUserStatuses" options:nil flags:0 watcher:TGTelegraphInstance];
    [TGUpdateStateRequestBuilder invalidateStateVersion];
}

- (void)setNotificationPrivacyFailed
{
    [_remainingSettingKeys removeObject:@"notificationPrivacySettings"];
    [self _maybeComplete:false];
}

- (void)setGroupsAndChannelsPrivacySuccess
{
    [_remainingSettingKeys removeObject:@"groupsAndChannelsPrivacySettings"];
    [self _maybeComplete:true];
}

- (void)setGroupsAndChannelsPrivacyFailed
{
    [_remainingSettingKeys removeObject:@"groupsAndChannelsPrivacySettings"];
    [self _maybeComplete:false];
}

- (void)setCallPrivacySuccess
{
    [_remainingSettingKeys removeObject:@"calls"];
    [self _maybeComplete:true];
}

- (void)setCallPrivacyFailed
{
    [_remainingSettingKeys removeObject:@"calls"];
    [self _maybeComplete:false];
}

- (void)setAccountTtlSuccess
{
    [_remainingSettingKeys removeObject:@"accountTTLSetting"];
    [self _maybeComplete:true];
}

- (void)setAccountTtlFailed
{
    [_remainingSettingKeys removeObject:@"accountTTLSetting"];
    [self _maybeComplete:false];
}

@end
