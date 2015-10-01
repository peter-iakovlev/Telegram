#import "TGAlertView.h"

@interface TGAccessRequiredAlertView : TGAlertView

- (instancetype)initWithMessage:(NSString *)message showSettingsButton:(bool)showSettingsButton completionBlock:(void (^)(void))completionBlock;

@end
