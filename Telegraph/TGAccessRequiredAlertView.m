#import "TGAccessRequiredAlertView.h"

@implementation TGAccessRequiredAlertView

- (instancetype)initWithMessage:(NSString *)message showSettingsButton:(bool)showSettingsButton completionBlock:(void (^)(void))completionBlock
{
    if (iosMajorVersion() < 8 || !showSettingsButton)
    {
        return [super initWithTitle:TGLocalized(@"AccessDenied.Title") message:message cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:^(__unused bool okButtonPressed)
        {
            if (completionBlock != nil)
                completionBlock();
        }];
    }
    else
    {
        return [super initWithTitle:TGLocalized(@"AccessDenied.Title") message:message cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:@[ TGLocalized(@"AccessDenied.Settings") ] completionBlock:^(bool settingsButtonPressed)
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
