#import "TGActor.h"

@class TGAccountSettings;

@interface TGAccountSettingsActor : TGActor

+ (TGAccountSettings *)accountSettingsFotCurrentStateId;
+ (void)setAccountSettingsForCurrentStateId:(TGAccountSettings *)accountSettings;

@end
