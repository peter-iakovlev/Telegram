#import "TGPasswordSetupController.h"

#import "TGPasswordSetupView.h"

#import "TGCustomAlertView.h"

#import "TGPresentation.h"

typedef enum {
    TGPasswordSetupControllerStateEnterNewPassword,
    TGPasswordSetupControllerStateConfirmNewPassword
} TGPasswordSetupControllerState;

@interface TGPasswordSetupController ()
{
    bool _setupNew;
    TGPasswordSetupView *_view;
    UIBarButtonItem *_nextItem;
    
    TGPasswordSetupControllerState _initialState;
    TGPasswordSetupControllerState _state;

    NSString *_storedPassword;
}

@end

@implementation TGPasswordSetupController

- (instancetype)initWithSetupNew:(bool)setupNew
{
    self = [super init];
    if (self != nil)
    {
        _setupNew = setupNew;
        
        self.title = TGLocalized(@"TwoStepAuth.SetupPasswordTitle");
        
        _nextItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Next") style:UIBarButtonItemStyleDone target:self action:@selector(nextPressed)];
        [self setRightBarButtonItem:_nextItem];
        _nextItem.enabled = false;
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Back") style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
        
        _initialState = TGPasswordSetupControllerStateEnterNewPassword;
    }
    return self;
}

- (void)backPressed
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)loadView
{
    [super loadView];
    
    TGPresentation *presentation = TGPresentation.current;
    self.view.backgroundColor = presentation.pallete.collectionMenuBackgroundColor;
    
    _view = [[TGPasswordSetupView alloc] initWithFrame:self.view.bounds];
    _view.presentation = presentation;
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    __weak TGPasswordSetupController *weakSelf = self;
    _view.passwordChanged = ^(NSString *password)
    {
        __strong TGPasswordSetupController *strongSelf = weakSelf;
        if (strongSelf != nil)
            strongSelf->_nextItem.enabled = password.length != 0;
    };
    [self.view addSubview:_view];
    
    [self reset];
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reset];
    
    [_view becomeFirstResponder];
}

- (NSString *)stringForState:(TGPasswordSetupControllerState)state
{
    switch (state)
    {
        case TGPasswordSetupControllerStateEnterNewPassword:
            return _setupNew ? TGLocalized(@"TwoStepAuth.SetupPasswordEnterPasswordNew") : TGLocalized(@"TwoStepAuth.SetupPasswordEnterPasswordChange");
        case TGPasswordSetupControllerStateConfirmNewPassword:
            return TGLocalized(@"TwoStepAuth.SetupPasswordConfirmPassword");
    }
}

- (void)reset
{
    _state = _initialState;
    [_view setTitle:[self stringForState:_state]];
    [_view clearInput];
}

- (void)nextPressed
{
    switch (_state)
    {
        case TGPasswordSetupControllerStateEnterNewPassword:
        {
            _storedPassword = [_view password];
            
            _state = TGPasswordSetupControllerStateConfirmNewPassword;
            [_view setTitle:[self stringForState:_state]];
            [_view clearInput];
            break;
        }
        case TGPasswordSetupControllerStateConfirmNewPassword:
        {
            if (TGStringCompare([_view password], _storedPassword))
            {
                if (_completion)
                    _completion([_view password]);
            }
            else
            {
                __weak TGPasswordSetupController *weakSelf = self;
                [TGCustomAlertView presentAlertWithTitle:nil message:TGLocalized(@"TwoStepAuth.SetupPasswordConfirmFailed") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:^(__unused bool okButtonPressed)
                {
                    __strong TGPasswordSetupController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                        [strongSelf->_view becomeFirstResponder];
                }];
                
                _state = TGPasswordSetupControllerStateEnterNewPassword;
                [_view setTitle:[self stringForState:_state]];
                [_view clearInput];
                break;
            }
        }
    }
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    [super controllerInsetUpdated:previousInset];
    
    if (!self.viewControllerIsDisappearing)
        [_view setContentInsets:self.controllerInset];
}

@end
