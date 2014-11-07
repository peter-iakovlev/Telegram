#import "TGAccountSetting.h"

typedef enum {
    TGPrivacySettingsLastSeenPrimarySettingEverybody = 0,
    TGPrivacySettingsLastSeenPrimarySettingContacts = 1,
    TGPrivacySettingsLastSeenPrimarySettingNobody = 2
} TGPrivacySettingsLastSeenPrimarySetting;

@interface TGNotificationPrivacyAccountSetting : NSObject <TGAccountSetting>

@property (nonatomic, readonly) TGPrivacySettingsLastSeenPrimarySetting lastSeenPrimarySetting;
@property (nonatomic, strong, readonly) NSArray *alwaysShareWithUserIds;
@property (nonatomic, strong, readonly) NSArray *neverShareWithUserIds;

- (instancetype)initWithDefaultValues;
- (instancetype)initWithLastSeenPrimarySetting:(TGPrivacySettingsLastSeenPrimarySetting)lastSeenPrimarySetting alwaysShareWithUserIds:(NSArray *)alwaysShareWithUserIds neverShareWithUserIds:(NSArray *)neverShareWithUserIds;

- (TGNotificationPrivacyAccountSetting *)normalize;
- (TGNotificationPrivacyAccountSetting *)modifyLastSeenPrimarySetting:(TGPrivacySettingsLastSeenPrimarySetting)lastSeenPrimarySetting;
- (TGNotificationPrivacyAccountSetting *)modifyAlwaysShareWithUserIds:(NSArray *)alwaysShareWithUserIds;
- (TGNotificationPrivacyAccountSetting *)modifyNeverShareWithUserIds:(NSArray *)neverShareWithUserIds;

@end
