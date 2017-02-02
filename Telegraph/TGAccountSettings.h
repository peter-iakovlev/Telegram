#import <Foundation/Foundation.h>

#import "TGNotificationPrivacyAccountSetting.h"
#import "TGAccountTTLSetting.h"

@interface TGAccountSettings : NSObject <NSCoding>

@property (nonatomic, strong, readonly) TGNotificationPrivacyAccountSetting *notificationSettings;
@property (nonatomic, strong, readonly) TGNotificationPrivacyAccountSetting *groupsAndChannelsSettings;
@property (nonatomic, strong, readonly) TGNotificationPrivacyAccountSetting *callSettings;
@property (nonatomic, strong, readonly) TGAccountTTLSetting *accountTTLSetting;

- (instancetype)initWithDefaultValues;
- (instancetype)initWithNotificationSettings:(TGNotificationPrivacyAccountSetting *)notificationSettings groupsAndChannelsSettings:(TGNotificationPrivacyAccountSetting *)groupsAndChannelsSettings callSettings:(TGNotificationPrivacyAccountSetting *)callSettings accountTTLSetting:(TGAccountTTLSetting *)accountTTLSetting;

@end
