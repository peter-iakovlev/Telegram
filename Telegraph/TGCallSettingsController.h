#import "TGCollectionMenuController.h"

#import <LegacyComponents/ASWatcher.h>

@interface TGCallSettingsController : TGCollectionMenuController <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

@end
