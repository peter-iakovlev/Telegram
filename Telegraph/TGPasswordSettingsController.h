#import "TGCollectionMenuController.h"

@class TGTwoStepConfig;

@interface TGPasswordSettingsController : TGCollectionMenuController

- (instancetype)initWithConfig:(TGTwoStepConfig *)config currentPassword:(NSString *)currentPassword;

@end
