#import "TGCollectionMenuController.h"

@interface TGCallDataSettingsController : TGCollectionMenuController

@property (nonatomic, copy) void (^onModeChanged)(int mode);

@end
