#import "TGCollectionMenuController.h"

@class TGNotificationPrivacyAccountSetting;

@interface TGPrivacyLastSeenController : TGCollectionMenuController

@property (nonatomic, copy, readonly) void (^privacySettingsChanged)(TGNotificationPrivacyAccountSetting *);

- (instancetype)initWithPrivacySettings:(TGNotificationPrivacyAccountSetting *)privacySettings privacySettingsChanged:(void (^)(TGNotificationPrivacyAccountSetting *))privacySettingsChanged;

@end
