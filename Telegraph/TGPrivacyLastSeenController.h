#import "TGCollectionMenuController.h"

@class TGNotificationPrivacyAccountSetting;

typedef enum {
    TGPrivacySettingsModeLastSeen,
    TGPrivacySettingsModeGroupsAndChannels,
    TGPrivacySettingsModeCalls
} TGPrivacySettingsMode;

@interface TGPrivacyLastSeenController : TGCollectionMenuController

@property (nonatomic, copy, readonly) void (^privacySettingsChanged)(TGNotificationPrivacyAccountSetting *);

- (instancetype)initWithMode:(TGPrivacySettingsMode)mode privacySettings:(TGNotificationPrivacyAccountSetting *)privacySettings privacySettingsChanged:(void (^)(TGNotificationPrivacyAccountSetting *))privacySettingsChanged;

@end
