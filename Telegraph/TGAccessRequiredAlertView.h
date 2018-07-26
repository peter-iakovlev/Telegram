#import "TGAlertView.h"
#import "TGCustomAlertView.h"

@interface TGAccessRequiredAlertView : TGCustomAlertView

+ (TGCustomAlertView *)presentWithMessage:(NSString *)message showSettingsButton:(bool)showSettingsButton completionBlock:(void (^)(void))completionBlock;

@end
