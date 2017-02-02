#import "TGAccountSettingsActor.h"

#import "ActionStage.h"
#import "TGTelegramNetworking.h"
#import <MTProtoKit/MTRequest.h>
#import "TL/TLMetaScheme.h"

#import "TGAccountSettings.h"

#import "TGUserDataRequestBuilder.h"

#import "TGUpdateStateRequestBuilder.h"

#import "TGDatabase.h"

@interface TGAccountSettingsActor ()
{
    bool _accountTtlReceived;
    bool _privacySettingsReceived;
    bool _groupsAndChannelsSettingsReceived;
    bool _callSettingsReceived;
    
    TGAccountSettings *_accountSettings;
}

@end

@implementation TGAccountSettingsActor

+ (NSMutableDictionary *)accountSettingsForStateIdDict
{
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dict = [[NSMutableDictionary alloc] init];
    });
    
    return dict;
}

+ (TGAccountSettings *)accountSettingsForStateId:(int)stateId
{
    return [self accountSettingsForStateIdDict][@(stateId)];
}

+ (void)setAccountSettingsForStateId:(int)stateId accountSettings:(TGAccountSettings *)accountSettings
{
    [self accountSettingsForStateIdDict][@(stateId)] = accountSettings;
}

+ (TGAccountSettings *)accountSettingsFotCurrentStateId
{
    return [self accountSettingsForStateId:[TGUpdateStateRequestBuilder stateVersion]];
}

+ (void)setAccountSettingsForCurrentStateId:(TGAccountSettings *)accountSettings
{
    [self setAccountSettingsForStateId:[TGUpdateStateRequestBuilder stateVersion] accountSettings:accountSettings];
}

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/accountSettings";
}

- (void)_maybeComplete
{
    if (_accountTtlReceived && _privacySettingsReceived && _groupsAndChannelsSettingsReceived && _callSettingsReceived)
    {
        [TGDatabaseInstance() setLocalUserStatusPrivacyRules:_accountSettings.notificationSettings changedLoadedUsers:^(__unused NSArray *users)
        {
        }];
        
        [TGAccountSettingsActor setAccountSettingsForStateId:[TGUpdateStateRequestBuilder stateVersion] accountSettings:_accountSettings];
        
        [ActionStageInstance() actionCompleted:self.path result:_accountSettings];
    }
}

- (void)prepare:(NSDictionary *)options
{
    [super prepare:options];
    
    self.requestQueueName = @"accountSettings";
}

- (void)execute:(NSDictionary *)__unused options
{
    _accountSettings = [[TGAccountSettings alloc] initWithDefaultValues];
    
    {
        MTRequest *request = [[MTRequest alloc] init];
        
        TLRPCaccount_getAccountTTL$account_getAccountTTL *getAccountTTL = [[TLRPCaccount_getAccountTTL$account_getAccountTTL alloc] init];
        request.body = getAccountTTL;
        
        __weak TGAccountSettingsActor *weakSelf = self;
        [request setCompleted:^(id result, __unused NSTimeInterval timestamp, id error)
        {
            __strong TGAccountSettingsActor *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [ActionStageInstance() dispatchOnStageQueue:^
                {
                    if (error == nil)
                        [strongSelf accountTtlRequestSuccess:result];
                    else
                        [strongSelf accountTtlRequestFailed];
                }];
            }
        }];
        
        [[TGTelegramNetworking instance] addRequest:request];
    }
    
    {
        MTRequest *request = [[MTRequest alloc] init];
        
        TLRPCaccount_getPrivacy$account_getPrivacy *getPrivacy = [[TLRPCaccount_getPrivacy$account_getPrivacy alloc] init];
        getPrivacy.key = [[TLInputPrivacyKey$inputPrivacyKeyStatusTimestamp alloc] init];
        request.body = getPrivacy;
        
        __weak TGAccountSettingsActor *weakSelf = self;
        [request setCompleted:^(id result, __unused NSTimeInterval timestamp, id error)
        {
            __strong TGAccountSettingsActor *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [ActionStageInstance() dispatchOnStageQueue:^
                {
                    if (error == nil)
                        [strongSelf privacySettingsRequestSuccess:result];
                    else
                        [strongSelf privacySettingsRequestFailed];
                }];
            }
        }];
        
        [[TGTelegramNetworking instance] addRequest:request];
    }
    
    {
        MTRequest *request = [[MTRequest alloc] init];
        
        TLRPCaccount_getPrivacy$account_getPrivacy *getPrivacy = [[TLRPCaccount_getPrivacy$account_getPrivacy alloc] init];
        getPrivacy.key = [[TLInputPrivacyKey$inputPrivacyKeyChatInvite alloc] init];
        request.body = getPrivacy;
        
        __weak TGAccountSettingsActor *weakSelf = self;
        [request setCompleted:^(id result, __unused NSTimeInterval timestamp, id error)
         {
             __strong TGAccountSettingsActor *strongSelf = weakSelf;
             if (strongSelf != nil)
             {
                 [ActionStageInstance() dispatchOnStageQueue:^
                  {
                      if (error == nil)
                          [strongSelf groupsAndChannelsSettingsRequestSuccess:result];
                      else
                          [strongSelf groupsAndChannelsSettingsRequestFailed];
                  }];
             }
         }];
        
        [[TGTelegramNetworking instance] addRequest:request];
    }
    
    {
        MTRequest *request = [[MTRequest alloc] init];
        
        TLRPCaccount_getPrivacy$account_getPrivacy *getPrivacy = [[TLRPCaccount_getPrivacy$account_getPrivacy alloc] init];
        getPrivacy.key = [[TLInputPrivacyKey$inputPrivacyKeyPhoneCall alloc] init];
        request.body = getPrivacy;
        
        __weak TGAccountSettingsActor *weakSelf = self;
        [request setCompleted:^(id result, __unused NSTimeInterval timestamp, id error)
         {
             __strong TGAccountSettingsActor *strongSelf = weakSelf;
             if (strongSelf != nil)
             {
                 [ActionStageInstance() dispatchOnStageQueue:^
                  {
                      if (error == nil)
                          [strongSelf callSettingsRequestSuccess:result];
                      else
                          [strongSelf callSettingsRequestFailed];
                  }];
             }
         }];
        
        [[TGTelegramNetworking instance] addRequest:request];
    }
}

- (void)accountTtlRequestSuccess:(TLAccountDaysTTL *)accountDaysTTL
{
    _accountSettings = [[TGAccountSettings alloc] initWithNotificationSettings:_accountSettings.notificationSettings groupsAndChannelsSettings:_accountSettings.groupsAndChannelsSettings callSettings:_accountSettings.callSettings accountTTLSetting:[[TGAccountTTLSetting alloc] initWithAccountTTL:@(accountDaysTTL.days * 24 * 60 * 60)]];
    _accountTtlReceived = true;
    [self _maybeComplete];
}

- (void)accountTtlRequestFailed
{
    _accountTtlReceived = true;
    [self _maybeComplete];
}

- (void)privacySettingsRequestSuccess:(TLaccount_PrivacyRules *)privacyRules
{
    [TGUserDataRequestBuilder executeUserDataUpdate:privacyRules.users];
    
    TGNotificationPrivacyAccountSetting *privacySettings = [[TGNotificationPrivacyAccountSetting alloc] initWithDefaultValues];
    
    privacySettings = [privacySettings modifyLastSeenPrimarySetting:TGPrivacySettingsLastSeenPrimarySettingNobody];
    
    for (TLPrivacyRule *rule in privacyRules.rules)
    {
        if ([rule isKindOfClass:[TLPrivacyRule$privacyValueAllowAll class]])
        {
            privacySettings = [privacySettings modifyLastSeenPrimarySetting:TGPrivacySettingsLastSeenPrimarySettingEverybody];
        }
        else if ([rule isKindOfClass:[TLPrivacyRule$privacyValueAllowContacts class]])
        {
            privacySettings = [privacySettings modifyLastSeenPrimarySetting:TGPrivacySettingsLastSeenPrimarySettingContacts];
        }
        else if ([rule isKindOfClass:[TLPrivacyRule$privacyValueAllowUsers class]])
        {
            TLPrivacyRule$privacyValueAllowUsers *allowUsers = (TLPrivacyRule$privacyValueAllowUsers *)rule;
            privacySettings = [privacySettings modifyAlwaysShareWithUserIds:allowUsers.users];
        }
        else if ([rule isKindOfClass:[TLPrivacyRule$privacyValueDisallowAll class]])
        {
            privacySettings = [privacySettings modifyLastSeenPrimarySetting:TGPrivacySettingsLastSeenPrimarySettingNobody];
        }
        else if ([rule isKindOfClass:[TLPrivacyRule$privacyValueDisallowContacts class]])
        {
        }
        else if ([rule isKindOfClass:[TLPrivacyRule$privacyValueDisallowUsers class]])
        {
            privacySettings = [privacySettings modifyLastSeenPrimarySetting:TGPrivacySettingsLastSeenPrimarySettingNobody];
            TLPrivacyRule$privacyValueDisallowUsers *disallowUsers = (TLPrivacyRule$privacyValueDisallowUsers *)rule;
            privacySettings = [privacySettings modifyNeverShareWithUserIds:disallowUsers.users];
        }
    }
    
    _accountSettings = [[TGAccountSettings alloc] initWithNotificationSettings:[privacySettings normalize] groupsAndChannelsSettings:_accountSettings.groupsAndChannelsSettings callSettings:_accountSettings.callSettings accountTTLSetting:_accountSettings.accountTTLSetting];
    
    _privacySettingsReceived = true;
    [self _maybeComplete];
}

- (void)groupsAndChannelsSettingsRequestSuccess:(TLaccount_PrivacyRules *)privacyRules
{
    [TGUserDataRequestBuilder executeUserDataUpdate:privacyRules.users];
    
    TGNotificationPrivacyAccountSetting *privacySettings = [[TGNotificationPrivacyAccountSetting alloc] initWithDefaultValues];
    
    privacySettings = [privacySettings modifyLastSeenPrimarySetting:TGPrivacySettingsLastSeenPrimarySettingNobody];
    
    for (TLPrivacyRule *rule in privacyRules.rules)
    {
        if ([rule isKindOfClass:[TLPrivacyRule$privacyValueAllowAll class]])
        {
            privacySettings = [privacySettings modifyLastSeenPrimarySetting:TGPrivacySettingsLastSeenPrimarySettingEverybody];
        }
        else if ([rule isKindOfClass:[TLPrivacyRule$privacyValueAllowContacts class]])
        {
            privacySettings = [privacySettings modifyLastSeenPrimarySetting:TGPrivacySettingsLastSeenPrimarySettingContacts];
        }
        else if ([rule isKindOfClass:[TLPrivacyRule$privacyValueAllowUsers class]])
        {
            TLPrivacyRule$privacyValueAllowUsers *allowUsers = (TLPrivacyRule$privacyValueAllowUsers *)rule;
            privacySettings = [privacySettings modifyAlwaysShareWithUserIds:allowUsers.users];
        }
        else if ([rule isKindOfClass:[TLPrivacyRule$privacyValueDisallowAll class]])
        {
            privacySettings = [privacySettings modifyLastSeenPrimarySetting:TGPrivacySettingsLastSeenPrimarySettingNobody];
        }
        else if ([rule isKindOfClass:[TLPrivacyRule$privacyValueDisallowContacts class]])
        {
        }
        else if ([rule isKindOfClass:[TLPrivacyRule$privacyValueDisallowUsers class]])
        {
            privacySettings = [privacySettings modifyLastSeenPrimarySetting:TGPrivacySettingsLastSeenPrimarySettingNobody];
            TLPrivacyRule$privacyValueDisallowUsers *disallowUsers = (TLPrivacyRule$privacyValueDisallowUsers *)rule;
            privacySettings = [privacySettings modifyNeverShareWithUserIds:disallowUsers.users];
        }
    }
    
    _accountSettings = [[TGAccountSettings alloc] initWithNotificationSettings:_accountSettings.notificationSettings groupsAndChannelsSettings:[privacySettings normalize] callSettings:_accountSettings.callSettings accountTTLSetting:_accountSettings.accountTTLSetting];
    
    _groupsAndChannelsSettingsReceived = true;
    [self _maybeComplete];
}

- (void)callSettingsRequestSuccess:(TLaccount_PrivacyRules *)privacyRules
{
    [TGUserDataRequestBuilder executeUserDataUpdate:privacyRules.users];
    
    TGNotificationPrivacyAccountSetting *privacySettings = [[TGNotificationPrivacyAccountSetting alloc] initWithDefaultValues];
    
    privacySettings = [privacySettings modifyLastSeenPrimarySetting:TGPrivacySettingsLastSeenPrimarySettingNobody];
    
    for (TLPrivacyRule *rule in privacyRules.rules)
    {
        if ([rule isKindOfClass:[TLPrivacyRule$privacyValueAllowAll class]])
        {
            privacySettings = [privacySettings modifyLastSeenPrimarySetting:TGPrivacySettingsLastSeenPrimarySettingEverybody];
        }
        else if ([rule isKindOfClass:[TLPrivacyRule$privacyValueAllowContacts class]])
        {
            privacySettings = [privacySettings modifyLastSeenPrimarySetting:TGPrivacySettingsLastSeenPrimarySettingContacts];
        }
        else if ([rule isKindOfClass:[TLPrivacyRule$privacyValueAllowUsers class]])
        {
            TLPrivacyRule$privacyValueAllowUsers *allowUsers = (TLPrivacyRule$privacyValueAllowUsers *)rule;
            privacySettings = [privacySettings modifyAlwaysShareWithUserIds:allowUsers.users];
        }
        else if ([rule isKindOfClass:[TLPrivacyRule$privacyValueDisallowAll class]])
        {
            privacySettings = [privacySettings modifyLastSeenPrimarySetting:TGPrivacySettingsLastSeenPrimarySettingNobody];
        }
        else if ([rule isKindOfClass:[TLPrivacyRule$privacyValueDisallowContacts class]])
        {
        }
        else if ([rule isKindOfClass:[TLPrivacyRule$privacyValueDisallowUsers class]])
        {
            privacySettings = [privacySettings modifyLastSeenPrimarySetting:TGPrivacySettingsLastSeenPrimarySettingNobody];
            TLPrivacyRule$privacyValueDisallowUsers *disallowUsers = (TLPrivacyRule$privacyValueDisallowUsers *)rule;
            privacySettings = [privacySettings modifyNeverShareWithUserIds:disallowUsers.users];
        }
    }
    
    _accountSettings = [[TGAccountSettings alloc] initWithNotificationSettings:_accountSettings.notificationSettings groupsAndChannelsSettings:_accountSettings.groupsAndChannelsSettings callSettings:[privacySettings normalize] accountTTLSetting:_accountSettings.accountTTLSetting];
    
    _callSettingsReceived = true;
    [self _maybeComplete];
}

- (void)privacySettingsRequestFailed
{
    _privacySettingsReceived = true;
    [self _maybeComplete];
}

- (void)groupsAndChannelsSettingsRequestFailed {
    _groupsAndChannelsSettingsReceived = true;
    [self _maybeComplete];
}

- (void)callSettingsRequestFailed
{
    _callSettingsReceived = true;
    [self _maybeComplete];
}

@end
