#import "TGChangePhoneNumberHelpController.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"
#import "TGPhoneUtils.h"
#import "TGAlertView.h"

#import "TGChangePhoneNumberHelpView.h"

#import "TGChangePhoneNumberNumberController.h"

#import "TGDebugController.h"

#import "TGAppDelegate.h"

@interface TGChangePhoneNumberHelpController ()
{
    TGChangePhoneNumberHelpView *_view;
}

@end

@implementation TGChangePhoneNumberHelpController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.title = [TGPhoneUtils formatPhone:[TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId].phoneNumber forceInternational:false];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Back") style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
    }
    return self;
}

- (void)backPressed
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)cancelPressed
{
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = UIColorRGB(0xefeff4);
    _view = [[TGChangePhoneNumberHelpView alloc] initWithFrame:self.view.bounds];
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    __weak TGChangePhoneNumberHelpController *weakSelf = self;
    _view.changePhonePressed = ^
    {
        [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"PhoneNumberHelp.Alert") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed)
        {
            if (okButtonPressed)
            {
                __strong TGChangePhoneNumberHelpController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    [strongSelf.navigationController pushViewController:[[TGChangePhoneNumberNumberController alloc] init] animated:true];
                }
            }
        }] show];
    };
    
    _view.debugPressed = ^
    {
        __strong TGChangePhoneNumberHelpController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf.presentingViewController dismissViewControllerAnimated:true completion:^
            {
                [TGAppDelegateInstance.rootController pushContentController:[[TGDebugController alloc] init]];
            }];
        }
    };
    [self.view addSubview:_view];
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    [super controllerInsetUpdated:previousInset];
    
    UIEdgeInsets cleanInsets = self.controllerInset;
    cleanInsets.bottom = 0.0f;
    [_view setInsets:cleanInsets];
}

@end
