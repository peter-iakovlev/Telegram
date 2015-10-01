#import "TGPasswordHintController.h"

#import "TGPasswordSetupView.h"

@interface TGPasswordHintController ()
{
    NSString *_password;
    TGPasswordSetupView *_view;
    UIBarButtonItem *_nextItem;
}

@end

@implementation TGPasswordHintController

- (instancetype)initWithPassword:(NSString *)password
{
    self = [super init];
    if (self != nil)
    {
        _password = password;
        
        self.title = TGLocalized(@"TwoStepAuth.SetupHintTitle");
        
        _nextItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Next") style:UIBarButtonItemStyleDone target:self action:@selector(nextPressed)];
        [self setRightBarButtonItem:_nextItem];
        _nextItem.enabled = true;
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Back") style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
    }
    return self;
}

- (void)backPressed
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)nextPressed
{
    if (_completion)
        _completion(_view.password);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_view becomeFirstResponder];
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = UIColorRGB(0xefeff4);
    
    _view = [[TGPasswordSetupView alloc] initWithFrame:self.view.bounds];
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _view.secureEntry = false;
    [self.view addSubview:_view];
    
    [_view setTitle:TGLocalized(@"TwoStepAuth.SetupHint")];
    
    NSMutableString *maskText = [[NSMutableString alloc] init];
    if (_password.length > 2)
    {
        [maskText appendString:[_password substringToIndex:1]];
        for (NSUInteger i = 2; i < _password.length; i++)
        {
            [maskText appendString:@"*"];
        }
        [maskText appendString:[_password substringWithRange:NSMakeRange(_password.length - 1, 1)]];
    }
    
    [_view setText:maskText];
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    [super controllerInsetUpdated:previousInset];
    
    if (!self.viewControllerIsDisappearing)
        [_view setContentInsets:self.controllerInset];
}

- (bool)willCaptureInputShortly
{
    return true;
}

@end
