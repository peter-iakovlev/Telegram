#import "TGAccessRequiredAlertView.h"

@implementation TGAccessRequiredAlertView

+ (TGCustomAlertView *)presentWithMessage:(NSString *)message showSettingsButton:(bool)showSettingsButton completionBlock:(void (^)(void))completionBlock
{
    if (iosMajorVersion() < 8 || !showSettingsButton)
    {
        return [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"AccessDenied.Title") message:message cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:^(__unused bool okButtonPressed)
        {
            if (completionBlock != nil)
                completionBlock();
        }];
    }
    else
    {
        return [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"AccessDenied.Title") message:message cancelButtonTitle:TGLocalized(@"Common.NotNow") okButtonTitle:TGLocalized(@"AccessDenied.Settings") completionBlock:^(bool settingsButtonPressed)
        {
            if (settingsButtonPressed)
                [TGAccessRequiredAlertView openSettings];
            
            if (completionBlock != nil)
                completionBlock();
        }];
    }
}

+ (void)openSettings
{
    if (&UIApplicationOpenSettingsURLString != NULL)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

@end
