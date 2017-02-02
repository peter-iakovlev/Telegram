#import "TGChangePhoneNumberNumberController.h"

#import "ActionStage.h"

#import "TGHeaderCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGCountryAndPhoneCollectionItem.h"

#import "TGChangePhoneNumberCodeController.h"

#import "TGProgressWindow.h"
#import "TGAlertView.h"

#import "TGVerifyChangePhoneActor.h"

#import "TGPhoneUtils.h"

@interface TGChangePhoneNumberNumberController () <ASWatcher>
{
    UIBarButtonItem *_nextItem;
    
    TGCountryAndPhoneCollectionItem *_countryAndPhoneItem;
    bool _didDisappear;
    
    NSString *_phoneNumber;
    
    TGProgressWindow *_progressWindow;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGChangePhoneNumberNumberController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        self.title = TGLocalized(@"ChangePhoneNumberNumber.Title");
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Back") style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
        
        _nextItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Next") style:UIBarButtonItemStyleDone target:self action:@selector(nextPressed)];
        _nextItem.enabled = false;
        [self setRightBarButtonItem:_nextItem];
        
        _countryAndPhoneItem = [[TGCountryAndPhoneCollectionItem alloc] init];
        __weak TGChangePhoneNumberNumberController *weakSelf = self;
        _countryAndPhoneItem.presentViewController = ^(UIViewController *controller)
        {
            __strong TGChangePhoneNumberNumberController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf presentViewController:controller animated:true completion:nil];
            }
        };
        _countryAndPhoneItem.phoneChanged = ^(NSString *phoneNumber)
        {
            __strong TGChangePhoneNumberNumberController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf->_nextItem.enabled = phoneNumber.length > 1;
                strongSelf->_phoneNumber = phoneNumber;
            }
        };
        
        TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"ChangePhoneNumberNumber.NewNumber")],
            _countryAndPhoneItem,
            [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"ChangePhoneNumberNumber.Help")]
        ]];
        section.insets = UIEdgeInsetsMake(32.0f, 0.0f, 0.0f, 0.0f);
        [self.menuSections addSection:section];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)backPressed
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)loadView
{
    [super loadView];
    
    self.collectionView.delaysContentTouches = false;
}

- (void)nextPressed
{
    _progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [_progressWindow show:true];
    
    [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/verifyChangePhoneNumber/(%@)", _phoneNumber] options:@{@"phoneNumber": _phoneNumber} flags:0 watcher:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_didDisappear)
        [_countryAndPhoneItem becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _didDisappear = true;
}

- (void)viewDidLayoutSubviews
{
    [_countryAndPhoneItem becomeFirstResponder];
    
    [super viewDidLayoutSubviews];
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/verifyChangePhoneNumber/"])
    {
        TGDispatchOnMainThread(^
        {
            [_progressWindow dismiss:true];
            
            if (status == ASStatusSuccess)
            {
                [self.navigationController pushViewController:[[TGChangePhoneNumberCodeController alloc] initWithPhoneNumber:_phoneNumber phoneCodeHash:result[@"phoneCodeHash"] callTimeout:[result[@"callTimeout"] doubleValue]] animated:true];
            }
            else
            {
                NSString *errorText = TGLocalized(@"Login.UnknownError");
                bool occupied = false;
                
                if (status == TGVerifyChangePhoneErrorInvalidPhone)
                    errorText = TGLocalized(@"Login.InvalidPhoneError");
                else if (status == TGVerifyChangePhoneErrorFlood)
                    errorText = TGLocalized(@"Login.CodeFloodError");
                else if (status == TGVerifyChangePhoneErrorPhoneOccupied)
                {
                    errorText = [[NSString alloc] initWithFormat:TGLocalized(@"ChangePhone.ErrorOccupied"), [TGPhoneUtils formatPhone:_phoneNumber forceInternational:true]];
                    occupied = true;
                }
                
                if (occupied)
                {
                    TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:TGLocalized(@"Generic.ErrorMoreInfo") completionBlock:^(__unused bool okButtonPressed)
                    {
                        
                    }];
                    [alertView show];
                }
                else
                {
                    TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:errorText delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil];
                    [alertView show];
                }
            }
        });
    }
}

@end
