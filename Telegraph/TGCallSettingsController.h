#import "TGCollectionMenuController.h"

#import "ASWatcher.h"

@interface TGCallSettingsController : TGCollectionMenuController <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

@end
