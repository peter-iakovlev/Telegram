#import "TGAccountSettings.h"

@implementation TGAccountSettings

- (instancetype)initWithDefaultValues
{
    return [self initWithNotificationSettings:[[TGNotificationPrivacyAccountSetting alloc] initWithDefaultValues] accountTTLSetting:[[TGAccountTTLSetting alloc] initWithDefaultValues]];
}

- (instancetype)initWithNotificationSettings:(TGNotificationPrivacyAccountSetting *)notificationSettings accountTTLSetting:(TGAccountTTLSetting *)accountTTLSetting
{
    self = [super init];
    if (self != nil)
    {
        _notificationSettings = notificationSettings;
        _accountTTLSetting = accountTTLSetting;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithNotificationSettings:[aDecoder decodeObjectForKey:@"notificationSettings"] accountTTLSetting:[aDecoder decodeObjectForKey:@"accountTTLSetting"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_notificationSettings forKey:@"notificationSettings"];
    [aCoder encodeObject:_accountTTLSetting forKey:@"accountTTLSetting"];
}

@end
