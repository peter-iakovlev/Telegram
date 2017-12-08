#import "TGCollectionMenuController.h"

@interface TGPasscodeSettingsController : TGCollectionMenuController

+ (bool)supportsBiometrics:(bool *)isFaceId;
+ (bool)enableTouchId;

@end
