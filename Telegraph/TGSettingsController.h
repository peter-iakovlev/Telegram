#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/ActionStage.h>

@interface TGSettingsController : TGViewController <ASWatcher>
@property (nonatomic, strong) ASHandle *actionHandle;

@end
