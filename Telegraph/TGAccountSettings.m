#import "TGAccountSettings.h"

@implementation TGAccountSettings

- (instancetype)initWithDefaultValues
{
    return [self initWithNotificationSettings:[[TGNotificationPrivacyAccountSetting alloc] initWithDefaultValues] groupsAndChannelsSettings:[[TGNotificationPrivacyAccountSetting alloc] initWithDefaultValues] callSettings:[[TGNotificationPrivacyAccountSetting alloc] initWithDefaultValues] accountTTLSetting:[[TGAccountTTLSetting alloc] initWithDefaultValues]];
}

- (instancetype)initWithNotificationSettings:(TGNotificationPrivacyAccountSetting *)notificationSettings groupsAndChannelsSettings:(TGNotificationPrivacyAccountSetting *)groupsAndChannelsSettings callSettings:(TGNotificationPrivacyAccountSetting *)callSettings accountTTLSetting:(TGAccountTTLSetting *)accountTTLSetting
{
    self = [super init];
    if (self != nil)
    {
        _notificationSettings = notificationSettings;
        _groupsAndChannelsSettings = groupsAndChannelsSettings;
        _callSettings = callSettings;
        _accountTTLSetting = accountTTLSetting;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    TGNotificationPrivacyAccountSetting *groupsAndChannelsSettings = [aDecoder decodeObjectForKey:@"groupsAndChannelsSettings"];
    if (groupsAndChannelsSettings == nil) {
        groupsAndChannelsSettings = [[TGNotificationPrivacyAccountSetting alloc] initWithDefaultValues];
    }
    TGNotificationPrivacyAccountSetting *callSettings = [aDecoder decodeObjectForKey:@"callSettings"];
    if (callSettings == nil) {
        callSettings = [[TGNotificationPrivacyAccountSetting alloc] initWithDefaultValues];
    }
    return [self initWithNotificationSettings:[aDecoder decodeObjectForKey:@"notificationSettings"] groupsAndChannelsSettings:groupsAndChannelsSettings callSettings:callSettings accountTTLSetting:[aDecoder decodeObjectForKey:@"accountTTLSetting"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_notificationSettings forKey:@"notificationSettings"];
    [aCoder encodeObject:_groupsAndChannelsSettings forKey:@"groupsAndChannelsSettings"];
    [aCoder encodeObject:_callSettings forKey:@"callSettings"];
    [aCoder encodeObject:_accountTTLSetting forKey:@"accountTTLSetting"];
}

@end
