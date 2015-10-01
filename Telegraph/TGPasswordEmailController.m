#import "TGPasswordEmailController.h"

#import "TGUsernameCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGModernButton.h"

#import "TGFont.h"

#import "TGAlertView.h"

@interface TGPasswordEmailController ()
{
    bool _skipEnabled;
    
    UIBarButtonItem *_nextItem;
    
    TGUsernameCollectionItem *_emailItem;
    TGCommentCollectionItem *_emailHelpItem;
    
    TGModernButton *_skipButton;
}

@end

@implementation TGPasswordEmailController

- (instancetype)initWithSkipEnabled:(bool)skipEnabled
{
    self = [super init];
    if (self != nil)
    {
        _skipEnabled = skipEnabled;
        
        self.title = TGLocalized(@"TwoStepAuth.EmailTitle");
        
        _nextItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Next") style:UIBarButtonItemStyleDone target:self action:@selector(nextPressed)];
        [self setRightBarButtonItem:_nextItem];
        _nextItem.enabled = false;
        
        _emailItem = [[TGUsernameCollectionItem alloc] init];
        _emailItem.title = TGLocalized(@"TwoStepAuth.Email");
        _emailItem.placeholder = TGLocalized(@"TwoStepAuth.EmailPlaceholder");
        _emailItem.keyboardType = UIKeyboardTypeEmailAddress;
        _emailItem.usernameValid = true;
        __weak TGPasswordEmailController *weakSelf = self;
        _emailItem.usernameChanged = ^(NSString *email)
        {
            __strong TGPasswordEmailController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf->_nextItem.enabled = email.length != 0;
            }
        };
        _emailHelpItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"TwoStepAuth.EmailHelp")];
        
        TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:@[_emailItem, _emailHelpItem]];
        section.insets = UIEdgeInsetsMake(34.0f, 0.0f, 34.0f, 0.0f);
        [self.menuSections addSection:section];
    }
    return self;
}

- (bool)isEmailValid:(NSString *)string
{
    bool nameFound = false;
    bool atFound = false;
    bool dotFound = false;
    for (NSUInteger i = 0; i < string.length; i++)
    {
        unichar c = [string characterAtIndex:i];
        if (c == '@')
        {
            if (!nameFound)
                return false;
            else if (atFound)
                return false;
            
            atFound = true;
        }
        else
        {
            if (atFound)
            {
                if (c == '.')
                    dotFound = true;
            }
            else if (!nameFound)
                nameFound = true;
        }
    }
    
    return nameFound && atFound && dotFound;
}

- (void)loadView
{
    _skipButton = [[TGModernButton alloc] init];
    [_skipButton setTitle:TGLocalized(@"TwoStepAuth.EmailSkip") forState:UIControlStateNormal];
    [_skipButton setTitleColor:UIColorRGB(0x9e9ea3)];
    _skipButton.titleLabel.font = TGSystemFontOfSize(14.0f);
    [_skipButton setContentEdgeInsets:UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f)];
    [_skipButton addTarget:self action:@selector(skipPressed) forControlEvents:UIControlEventTouchUpInside];
    [_skipButton sizeToFit];
    
    [super loadView];
    
    if (_skipEnabled)
        [self.view addSubview:_skipButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_emailItem becomeFirstResponder];
}

- (void)nextPressed
{
    if (_completion)
        _completion(_emailItem.username);
}

- (void)skipPressed
{
    [[_emailItem boundView] endEditing:true];
    
    if (iosMajorVersion() >= 8)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:TGLocalized(@"TwoStepAuth.EmailSkipAlert") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TGLocalized(@"Common.Cancel") style:UIAlertActionStyleCancel handler:nil];
        
        __weak TGPasswordEmailController *weakSelf = self;
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:TGLocalized(@"TwoStepAuth.EmailSkip") style:UIAlertActionStyleDestructive handler:^(__unused UIAlertAction *action)
        {
            __strong TGPasswordEmailController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf _skip];
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:true completion:nil];
    }
    else
    {
        __weak TGPasswordEmailController *weakSelf = self;
        TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"TwoStepAuth.EmailSkipAlert") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"TwoStepAuth.EmailSkip") completionBlock:^(bool okButtonPressed)
        {
            __strong TGPasswordEmailController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (okButtonPressed)
                    [strongSelf _skip];
            }
        }];
        [alertView show];
    }
}

- (void)_skip
{
    if (_completion)
        _completion(nil);
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    [super controllerInsetUpdated:previousInset];
    
    _skipButton.frame = CGRectMake(self.view.frame.size.width - _skipButton.frame.size.width, self.view.frame.size.height - self.controllerInset.bottom - _skipButton.frame.size.height, _skipButton.frame.size.width, _skipButton.frame.size.height);
}

- (bool)willCaptureInputShortly
{
    return true;
}

@end
