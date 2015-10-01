#import "TGPasswordRecoveryController.h"

#import "TGTwoStepRecoverySignals.h"

#import "TGUsernameCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGProgressWindow.h"

#import "TGAlertView.h"

@interface TGPasswordRecoveryController ()
{
    NSString *_emailPattern;
    
    UIBarButtonItem *_nextItem;
    TGUsernameCollectionItem *_codeItem;
    
    SMetaDisposable *_recoverDisposable;
}

@end

@implementation TGPasswordRecoveryController

- (instancetype)initWithEmailPattern:(NSString *)emailPattern
{
    self = [super init];
    if (self != nil)
    {
        _emailPattern = emailPattern;
        
        _recoverDisposable = [[SMetaDisposable alloc] init];
        
        self.title = TGLocalized(@"TwoStepAuth.RecoveryTitle");
        
        _nextItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Next") style:UIBarButtonItemStyleDone target:self action:@selector(nextPressed)];
        [self setRightBarButtonItem:_nextItem];
        _nextItem.enabled = false;
        
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
        
        _codeItem = [[TGUsernameCollectionItem alloc] init];
        _codeItem.title = TGLocalized(@"TwoStepAuth.RecoveryCode");
        _codeItem.placeholder = @"";
        _codeItem.keyboardType = UIKeyboardTypeNumberPad;
        __weak TGPasswordRecoveryController *weakSelf = self;
        _codeItem.usernameChanged = ^(NSString *code)
        {
            __strong TGPasswordRecoveryController *strongSelf = weakSelf;
            if (strongSelf != nil)
                strongSelf->_nextItem.enabled = code.length != 0;
        };
        _codeItem.usernameValid = true;
        
        TGCommentCollectionItem *helpItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"TwoStepAuth.RecoveryCodeHelp")];
        
        TGCollectionMenuSection *firstSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _codeItem,
            helpItem
        ]];
        firstSection.insets = UIEdgeInsetsMake(32.0f, 0.0f, 0.0f, 0.0);
        [self.menuSections addSection:firstSection];
        
        TGCommentCollectionItem *recoverItem = [[TGCommentCollectionItem alloc] initWithText:[[NSString alloc] initWithFormat:TGLocalized(@"TwoStepAuth.RecoveryEmailUnavailable"), _emailPattern]];
        recoverItem.textColor = TGAccentColor();
        recoverItem.action = ^
        {
            __strong TGPasswordRecoveryController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (strongSelf->_completion)
                    strongSelf->_completion(false, 0);
            }
        };
        
        TGCollectionMenuSection *secondSection = [[TGCollectionMenuSection alloc] initWithItems:@[recoverItem]];
        secondSection.insets = UIEdgeInsetsMake(6.0f, 0.0f, 32.0f, 0.0f);
        [self.menuSections addSection:secondSection];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_codeItem becomeFirstResponder];
}

- (void)cancelPressed
{
    if (_cancelled)
        _cancelled();
}

- (void)nextPressed
{
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow show:true];
    
    __weak TGPasswordRecoveryController *weakSelf = self;
    [_recoverDisposable setDisposable:[[[[TGTwoStepRecoverySignals recoverPasswordWithCode:_codeItem.username] deliverOn:[SQueue mainQueue]] onDispose:^
    {
        TGDispatchOnMainThread(^
        {
            [progressWindow dismiss:true];
        });
    }] startWithNext:^(NSNumber *userId)
    {
        __strong TGPasswordRecoveryController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (strongSelf->_completion)
                strongSelf->_completion(true, [userId intValue]);
        }
    } error:^(id error)
    {
        NSString *errorText = TGLocalized(@"TwoStepAuth.RecoveryCodeInvalid");
        if ([error respondsToSelector:@selector(intValue)])
        {
            if ([error intValue] == TGTwoStepRecoveryErrorCodeExpired)
                errorText = TGLocalized(@"TwoStepAuth.RecoveryCodeExpired");
            else if ([error intValue] == TGTwoStepRecoveryErrorFlood)
                errorText = TGLocalized(@"TwoStepAuth.FloodError");
        }
        
        [[[TGAlertView alloc] initWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
    } completed:nil]];
}

@end
