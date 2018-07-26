#import "TGPassportRequestController.h"

#import <LegacyComponents/LegacyComponents.h>
#import <LegacyComponents/TGModernBarButton.h>

#import "TGDatabase.h"
#import "TGPresentation.h"
#import "TGTelegraph.h"
#import "TGAppDelegate.h"
#import "TGApplication.h"
#import "TGTelegramNetworking.h"
#import "TGLegacyComponentsContext.h"

#import "TGPassportSignals.h"
#import "TGTwoStepConfigSignal.h"
#import "TGTwoStepVerifyPasswordSignal.h"
#import "TGTwoStepSetPaswordSignal.h"
#import "TGTwoStepRecoverySignals.h"

#import "TGPassportICloud.h"
#import "TGPassportFile.h"

#import "TGHeaderCollectionItem.h"
#import "TGPassportFieldCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGCustomAlertView.h"

#import "TGPassportHeaderView.h"
#import "TGPassportPasswordView.h"
#import "TGPassportSetupPasswordView.h"

#import "TGPassportIdentityController.h"
#import "TGPassportAddressController.h"
#import "TGPassportPhoneController.h"
#import "TGPassportEmailController.h"
#import "TGPassportScanController.h"

#import "TGLoginCountriesController.h"
#import "TGFastTwoStepVerificationSetupController.h"
#import "TGPasswordRecoveryController.h"
#import "TGPasswordSetupController.h"
#import "TGPasswordHintController.h"

@interface TGPassportRequestController ()
{
    TGPassportFormRequest *_request;
    TGPassportErrors *_errors;
    
    SVariable *_twoStepConfig;
    SVariable *_passwordVariable;
    SVariable *_formVariable;
    
    SVariable *_viewAppeared;
    
    SVariable *_passwordSettingsVariable;
    
    TGPassportForm *_form;
    TGPassportPasswordRequest *_passwordRequest;
    
    SMetaDisposable *_disposable;
    SMetaDisposable *_saveDisposable;
    SMetaDisposable *_requestRecoveryDisposable;
    
    UIActivityIndicatorView *_activityIndicator;
    UIButton *_authorizeButton;
    UIView *_authorizeButtonContainer;
    UIView *_authorizeSeparatorView;
    
    TGModernBarButton *_barButton;
    TGPassportHeaderView *_headerView;
    TGPassportPasswordView *_passwordView;
    TGPassportSetupPasswordView *_setupPasswordView;
    
    TGCollectionMenuSection *_mainSection;
    TGPassportFieldCollectionItem *_identityItem;
    TGPassportFieldCollectionItem *_addressItem;
    TGPassportFieldCollectionItem *_phoneItem;
    TGPassportFieldCollectionItem *_emailItem;
    TGCommentCollectionItem *_privacyItem;
    
    TGCollectionMenuSection *_passwordSection;
    TGButtonCollectionItem *_passwordItem;
    
    TGCollectionMenuSection *_deleteSection;
    TGButtonCollectionItem *_deleteItem;
    
    __weak TGMenuSheetController *_menuController;
}
@end

@implementation TGPassportRequestController

- (instancetype)initWithFormRequest:(TGPassportFormRequest *)formRequest
{
    self = [super init];
    if (self != nil)
    {
        _request = formRequest;
        
        _disposable = [[SMetaDisposable alloc] init];
        _saveDisposable = [[SMetaDisposable alloc] init];
        
        _twoStepConfig = [[SVariable alloc] init];
        [_twoStepConfig set:[TGTwoStepConfigSignal twoStepConfig]];
        
        _formVariable = [[SVariable alloc] init];
        _passwordSettingsVariable = [[SVariable alloc] init];
        _passwordVariable = [[SVariable alloc] init];
        
        _viewAppeared = [[SVariable alloc] init];
        if (formRequest != nil)
            [_viewAppeared set:[SSignal single:@true]];
        
        self.title = TGLocalized(@"Passport.Title");
        
        _mainSection = [[TGCollectionMenuSection alloc] initWithItems:@[]];
        _mainSection.insets = UIEdgeInsetsMake([self topInset], 0.0f, 35.0f, 0.0f);
        [self.menuSections addSection:_mainSection];
        
        if (_request != nil)
        {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)];
        }
        else
        {
//            _passwordItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.ChangePassword") action:@selector(changePasswordPressed)];
//            _passwordItem.deselectAutomatically = true;
//            _passwordItem.alignment = NSTextAlignmentCenter;
//            _passwordItem.titleColor = self.presentation.pallete.collectionMenuAccentColor;
//            
//            _passwordSection = [[TGCollectionMenuSection alloc] initWithItems:@[]];
//            [self.menuSections addSection:_passwordSection];
            
            _deleteItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.DeletePassport") action:@selector(deletePressed)];
            _deleteItem.deselectAutomatically = true;
            _deleteItem.alignment = NSTextAlignmentCenter;
            _deleteItem.titleColor = self.presentation.pallete.collectionMenuDestructiveColor;
            
            _deleteSection = [[TGCollectionMenuSection alloc] initWithItems:@[]];
            [self.menuSections addSection:_deleteSection];
        }
        
        _barButton = [[TGModernBarButton alloc] initWithImage:TGPresentation.current.images.callsInfoIcon];
        CGPoint portraitOffset = CGPointZero;
        CGPoint landscapeOffset = CGPointZero;
        if (iosMajorVersion() >= 11)
        {
            portraitOffset.x = 6.0f;
            portraitOffset.y = 11.0f;
            landscapeOffset.x = 6.0f;
            landscapeOffset.y = 7.0f;
        }
        _barButton.portraitAdjustment = CGPointMake(6.0f + portraitOffset.x, -4.0f + portraitOffset.y);
        _barButton.landscapeAdjustment = CGPointMake(6.0f + landscapeOffset.x, -5.0f + landscapeOffset.y);
        [_barButton addTarget:self action:@selector(infoPressed) forControlEvents:UIControlEventTouchUpInside];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:_barButton]];
    }
    return self;
}

- (void)dealloc
{
    [_disposable dispose];
    [_saveDisposable dispose];
    [_requestRecoveryDisposable dispose];
}

- (void)loadView
{
    [super loadView];
    
    _barButton.image = self.presentation.images.callsInfoIcon;
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator.color = self.presentation.pallete.collectionMenuCommentColor;
    [self.view addSubview:_activityIndicator];
    [_activityIndicator startAnimating];
    
    if (_request != nil)
    {
        _authorizeButton = [[UIButton alloc] init];
        _authorizeButton.adjustsImageWhenDisabled = false;
        _authorizeButton.adjustsImageWhenHighlighted = false;
        [_authorizeButton setTitle:TGLocalized(@"Passport.Authorize") forState:UIControlStateNormal];
        [_authorizeButton addTarget:self action:@selector(authorizeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
        UIEdgeInsets safeAreaInset = self.controllerSafeAreaInset;
        _authorizeButton.frame = CGRectMake(15.0f + safeAreaInset.left, 14.0f, self.view.frame.size.width - 30.0f - safeAreaInset.left - safeAreaInset.right, 48.0f);
        _authorizeButtonContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - 76.0f - safeAreaInset.bottom, self.view.frame.size.width, 76.0f + safeAreaInset.bottom)];
        _authorizeButtonContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _authorizeButtonContainer.backgroundColor = [self.presentation.pallete.backgroundColor colorWithAlphaComponent:0.75f];
        [self.view addSubview:_authorizeButtonContainer];
    
        _authorizeSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _authorizeButtonContainer.frame.size.width, TGSeparatorHeight())];
        _authorizeSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _authorizeSeparatorView.backgroundColor = self.presentation.pallete.barSeparatorColor;
        [_authorizeButtonContainer addSubview:_authorizeSeparatorView];
    
        [self layoutButton:self.view.frame.size];
    
        UIImage *payButtonImage;
        UIImage *payButtonHighlightedImage;
        UIImage *payDisabledButtonImage;
    
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(48.0f, 48.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, self.presentation.pallete.paymentsPayButtonColor.CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 48.0f, 48.0f));
        payButtonImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:24 topCapHeight:24];
        UIGraphicsEndImageContext();
    
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(48.0f, 48.0f), false, 0.0f);
        context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [self.presentation.pallete.paymentsPayButtonColor colorWithHueMultiplier:1.0f saturationMultiplier:1.0f brightnessMultiplier:0.8f].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 48.0f, 48.0f));
        payButtonHighlightedImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:24 topCapHeight:24];
        UIGraphicsEndImageContext();
    
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(48.0f, 48.0f), false, 0.0f);
        context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, self.presentation.pallete.paymentsPayButtonDisabledColor.CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 48.0f, 48.0f));
        payDisabledButtonImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:24 topCapHeight:24];
        UIGraphicsEndImageContext();
    
        _authorizeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_authorizeButton setTitleColor:self.presentation.pallete.accentContrastColor forState:UIControlStateNormal];
        _authorizeButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        _authorizeButton.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 3.0f, 20.0f);
        [_authorizeButton setImage:self.presentation.images.passportIcon forState:UIControlStateNormal];
        [_authorizeButton setBackgroundImage:payButtonImage forState:UIControlStateNormal];
        [_authorizeButton setBackgroundImage:payButtonHighlightedImage forState:UIControlStateHighlighted];
        [_authorizeButton setBackgroundImage:payDisabledButtonImage forState:UIControlStateDisabled];
        [_authorizeButtonContainer addSubview:_authorizeButton];
    }
    
    _headerView = [[TGPassportHeaderView alloc] initWithFrame:CGRectMake(0.0f, 40.0f, self.view.frame.size.width, 170.0f)];
    _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _headerView.hidden = true;
    [_headerView setPresentation:self.presentation];
    [self.collectionView addSubview:_headerView];
    
    [self layoutHeader:self.view.frame.size];

    __weak TGPassportRequestController *weakSelf = self;
    _passwordView = [[TGPassportPasswordView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 100.0f)];
    _passwordView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _passwordView.hidden = true;
    _passwordView.nextPressed = ^(NSString *password)
    {
        __strong TGPassportRequestController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf->_passwordVariable set:[SSignal single:password]];
    };
    _passwordView.forgottenPressed = ^
    {
        __strong TGPassportRequestController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf restorePassword];
    };
    [_passwordView setPresentation:self.presentation];
    [self.collectionView addSubview:_passwordView];
    
    [self layoutPassword:self.view.frame.size];
    
    _setupPasswordView = [[TGPassportSetupPasswordView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height - self.calculatedSafeAreaInset.bottom)];
    _setupPasswordView.hidden = true;
     [_setupPasswordView setPresentation:self.presentation];
    _setupPasswordView.setupPressed = ^
    {
        __strong TGPassportRequestController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf setupTwoStepAuth:false];
    };
    [self.collectionView addSubview:_setupPasswordView];
    
    [self setExplicitTableInset:UIEdgeInsetsMake(0.0f, 0, 76.0f, 0)];
    [self setExplicitScrollIndicatorInset:UIEdgeInsetsMake(0.0f, 0, 76.0f, 0)];
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_request != nil)
        [self setupForRequest];
    else
        [self setupForEditing];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (_request == nil)
        [_viewAppeared set:[SSignal single:@true]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_passwordRequest.state == TGPassportPasswordRequestStateWaitingForEntry)
        [_passwordView focus];
}

- (void)setupForMock
{
    TGPassportDecryptedForm *form = [[TGPassportDecryptedForm alloc] initWithForm:nil values:nil];
    [self setForm:form passwordRequest:[TGPassportPasswordRequest requestWithState:TGPassportPasswordRequestStateAuthorized settings:nil hasRecovery:false passwordHint:nil error:nil]];
}

- (void)setupForRequest
{
    if (_request.payload.length == 0) {
        [self failWithError:@"PAYLOAD_EMPTY"];
        return;
    }
    
    SSignal *displaySignal = [SSignal combineSignals:@[ _passwordSettingsVariable.signal, [_formVariable.signal mapToSignal:^SSignal *(id value) {
        if (![value isKindOfClass:[TGPassportForm class]])
            return [SSignal fail:value];
        else
            return [SSignal single:value];
    }]]];
    [_passwordSettingsVariable set:[[self _passwordSignal] ignoreRepeated]];
    [_formVariable set:[self _formRequestSignal]];

    __weak TGPassportRequestController *weakSelf = self;
    [_disposable setDisposable:[[[displaySignal map:^id(NSArray *values) {
        TGPassportPasswordRequest *passwordRequest = values.firstObject;
        TGPassportForm *encryptedForm = values.lastObject;
        
        if ([encryptedForm isKindOfClass:[TGPassportForm class]] && passwordRequest.settings.secret.length > 0)
        {
            TGPassportDecryptedForm *decryptedForm = [TGPassportSignals decryptedForm:encryptedForm secret:passwordRequest.settings.secret];
            return @[ passwordRequest, decryptedForm ];
        }
        
        return values;
    }] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *values)
    {
        __strong TGPassportRequestController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        TGPassportPasswordRequest *passwordRequest = values.firstObject;
        TGPassportForm *form = values.lastObject;
        
        [strongSelf setForm:form passwordRequest:passwordRequest];
    } error:^(NSString *error)
    {
        if (![error isKindOfClass:[NSString class]])
            error = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
        
        __strong TGPassportRequestController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf failWithError:error];
    } completed:nil]];
}

- (void)failWithError:(NSString *)error
{
    if ([error isEqualToString:@"APP_VERSION_OUTDATED"])
    {
        __weak TGPassportRequestController *weakSelf = self;
        NSString *errorText = TGLocalized(@"Passport.UpdateRequiredError");
        [TGCustomAlertView presentAlertWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.NotNow") okButtonTitle:TGLocalized(@"Application.Update") completionBlock:^(__unused bool okButtonPressed)
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf dismissViewControllerAnimated:true completion:nil];
            
            if (okButtonPressed)
            {
                NSNumber *appStoreId = @686449807;
#ifdef TELEGRAM_APPSTORE_ID
                appStoreId = TELEGRAM_APPSTORE_ID;
#endif
                NSURL *appStoreURL = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", appStoreId]];
                [[UIApplication sharedApplication] openURL:appStoreURL];
            }
        }];
        
        return;
    }
    
    NSArray *returnedErrors =
    @[
      @"BOT_INVALID",
      @"PUBLIC_KEY_REQUIRED",
      @"PUBLIC_KEY_INVALID",
      @"SCOPE_EMPTY",
      @"PAYLOAD_EMPTY"
    ];
    
    __weak TGPassportRequestController *weakSelf = self;
    bool shouldReturnError = [returnedErrors containsObject:error];
    NSString *errorText = TGLocalized(@"Login.UnknownError");
    [TGCustomAlertView presentAlertWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:^(__unused bool okButtonPressed)
     {
         __strong TGPassportRequestController *strongSelf = weakSelf;
         if (strongSelf != nil)
             [strongSelf dismissViewControllerAnimated:true completion:nil];
         
         if (shouldReturnError && strongSelf->_request.callbackUrl.length > 0)
         {
             NSString *url = nil;
             if ([strongSelf->_request.callbackUrl hasPrefix:@"tgbot"]) {
                 url = [NSString stringWithFormat:@"tgbot%d://passport/error?error=%@", _request.botId, error];
             } else {
                 url = [TGPassportRequestController urlString:_request.callbackUrl byAppendingQueryString:[NSString stringWithFormat:@"tg_passport=error&error=%@", error]];
             }
             [(TGApplication *)[TGApplication sharedApplication] nativeOpenURL:[NSURL URLWithString:url]];
         }
     }];
}

- (void)setupForEditing
{
    SSignal *displaySignal = [_passwordSettingsVariable.signal mapToSignal:^SSignal *(TGPassportPasswordRequest *request)
    {
        if (request.state == TGPassportPasswordRequestStateAuthorized)
        {
            return [[TGPassportSignals allSecureValuesWithSecret:request.settings.secret] mapToSignal:^SSignal *(TGPassportDecryptedForm *form)
            {
                return [SSignal single:@{ @"password": request, @"form": form }];
            }];
        }
        else
        {
            return [SSignal single:@{ @"password": request }];
        }
    }];
    
    [_passwordSettingsVariable set:[[self _passwordSignal] ignoreRepeated]];
    
    __weak TGPassportRequestController *weakSelf = self;
    [_disposable setDisposable:[[displaySignal deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *values)
    {
        __strong TGPassportRequestController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        TGPassportPasswordRequest *passwordRequest = values[@"password"];
        TGPassportForm *form = values[@"form"];
        
        [strongSelf setForm:form passwordRequest:passwordRequest];
    }]];
}

- (SSignal *)_passwordSignal
{
    TGPassportFormRequest *request = _request;
    return [[_twoStepConfig.signal ignoreRepeated] mapToSignal:^SSignal *(TGTwoStepConfig *twoStepConfig)
    {
        if (twoStepConfig.currentSalt.length == 0)
        {
            return [SSignal single:[TGPassportPasswordRequest requestWithState:twoStepConfig.unconfirmedEmailPattern.length > 0 ? TGPassportPasswordRequestStateWaitingEmail : TGPassportPasswordRequestStateNoPassword settings:nil hasRecovery:twoStepConfig.hasRecovery passwordHint:nil error:nil]];
        }
        else
        {
            NSData *passwordHash = nil;
            NSData *secretPasswordHash = nil;
            
            bool automaticLogin = false;
            
            __block SSignal *settingsSignal = nil;
            if (request != nil && [TGPassportSignals storedPasswordHash] != nil)
            {
                passwordHash = [TGPassportSignals storedPasswordHash];
                secretPasswordHash = [TGPassportSignals storedSecretPasswordHash];
                
                automaticLogin = true;
            }
        
            if (passwordHash.length > 0 && secretPasswordHash.length > 0)
                settingsSignal = [TGTwoStepVerifyPasswordSignal passwordHashSettings:passwordHash secretPasswordHash:secretPasswordHash];
            
            SSignal *statusSignal = settingsSignal != nil ? [SSignal single:[TGPassportPasswordRequest requestWithState:TGPassportPasswordRequestStateLoggingInProgress settings:nil hasRecovery:twoStepConfig.hasRecovery passwordHint:twoStepConfig.currentHint error:nil]] : [SSignal single:[TGPassportPasswordRequest requestWithState:TGPassportPasswordRequestStateWaitingForEntry settings:nil hasRecovery:twoStepConfig.hasRecovery passwordHint:twoStepConfig.currentHint error:nil]];
            SSignal *proceedSignal = settingsSignal != nil ? [SSignal single:nil] : _passwordVariable.signal;
            
            return [statusSignal then:[proceedSignal mapToSignal:^SSignal *(NSString *password)
            {
                NSData *passwordHash = nil;
                if (settingsSignal == nil)
                {
                    settingsSignal = [TGTwoStepVerifyPasswordSignal passwordSettings:password config:twoStepConfig outPasswordHash:&passwordHash];
                }
                
                SSignal *initial = [SSignal single:[TGPassportPasswordRequest requestWithState:TGPassportPasswordRequestStateLoggingInProgress settings:nil hasRecovery:twoStepConfig.hasRecovery passwordHint:twoStepConfig.currentHint error:nil]];
                
                SSignal *process = [[[settingsSignal onNext:^(TGPasswordSettings *next)
                {
                    TGDispatchOnMainThread(^
                    {
                        if (passwordHash != nil)
                        {                            
                            NSMutableData *passwordHashData = [[NSMutableData alloc] init];
                            [passwordHashData appendData:next.secureSalt];
                            [passwordHashData appendData:[password dataUsingEncoding:NSUTF8StringEncoding]];
                            [passwordHashData appendData:next.secureSalt];
                            NSData *secretPasswordHash = [TGTwoStepConfigSignal TGSha512:passwordHashData];
                            [TGPassportSignals storePasswordHash:passwordHash secretPasswordHash:secretPasswordHash];
                        }
                    });
                }] mapToSignal:^SSignal *(TGPasswordSettings *settings)
                {
                    int64_t calculatedHash =  [TGPassportSignals secureSecretId:settings.secret];
                    if (settings.secret.length == 0)
                    {
                        NSData *secret = [TGPassportSignals secretWithSecretRandom:twoStepConfig.secretRandom];
                        return [[TGTwoStepSetPaswordSignal setSecureSecret:secret nextSecureSalt:twoStepConfig.nextSecureSalt currentSalt:twoStepConfig.currentSalt currentPassword:settings.password recoveryEmail:settings.email] mapToSignal:^SSignal *(TGTwoStepConfig *newTwoStepConfig)
                        {
                            return [[TGTwoStepVerifyPasswordSignal passwordSettings:password config:newTwoStepConfig] mapToSignal:^SSignal *(TGPasswordSettings *newSettings)
                            {
                                return [SSignal single:[TGPassportPasswordRequest requestWithState:TGPassportPasswordRequestStateAuthorized settings:newSettings hasRecovery:twoStepConfig.hasRecovery passwordHint:twoStepConfig.currentHint error:nil]];
                            }];
                        }];
                    }
                    else if (calculatedHash != settings.secretHash)
                    {
                        return [[TGTwoStepSetPaswordSignal setSecureSecret:nil nextSecureSalt:twoStepConfig.nextSecureSalt currentSalt:twoStepConfig.currentSalt currentPassword:settings.password recoveryEmail:settings.email] mapToSignal:^SSignal *(TGTwoStepConfig *newTwoStepConfig)
                        {
                            NSData *secret = [TGPassportSignals secretWithSecretRandom:newTwoStepConfig.secretRandom];
                            return [[TGTwoStepSetPaswordSignal setSecureSecret:secret nextSecureSalt:newTwoStepConfig.nextSecureSalt currentSalt:newTwoStepConfig.currentSalt currentPassword:settings.password recoveryEmail:settings.email] mapToSignal:^SSignal *(TGTwoStepConfig *newTwoStepConfig)
                            {
                                return [[TGTwoStepVerifyPasswordSignal passwordSettings:password config:newTwoStepConfig] mapToSignal:^SSignal *(TGPasswordSettings *newSettings)
                                {
                                    return [SSignal single:[TGPassportPasswordRequest requestWithState:TGPassportPasswordRequestStateAuthorized settings:newSettings hasRecovery:newTwoStepConfig.hasRecovery passwordHint:newTwoStepConfig.currentHint error:nil]];
                                }];
                            }];
                        }];
                    }
                    else
                    {
                        return [SSignal single:[TGPassportPasswordRequest requestWithState:TGPassportPasswordRequestStateAuthorized settings:settings hasRecovery:twoStepConfig.hasRecovery passwordHint:twoStepConfig.currentHint error:nil]];
                    }
                }] catch:^SSignal *(NSString *error)
                {
                    if (![error isKindOfClass:[NSString class]])
                        error = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
                    
                    if (automaticLogin && [error rangeOfString:@"PASSWORD_HASH_INVALID"].location != NSNotFound)
                    {
                        [TGPassportSignals clearStoredPasswordHashes];
                        return [SSignal single:[TGPassportPasswordRequest requestWithState:TGPassportPasswordRequestStateWaitingForEntry settings:nil hasRecovery:twoStepConfig.hasRecovery passwordHint:twoStepConfig.currentHint error:nil]];
                    }
                    else
                    {
                        return [SSignal single:[TGPassportPasswordRequest requestWithState:TGPassportPasswordRequestStateAccessDenied settings:nil hasRecovery:twoStepConfig.hasRecovery passwordHint:twoStepConfig.currentHint error:error]];
                    }
                }];
                return [initial then:process];
            }]];
        }
    }];
}

- (SSignal *)_formRequestSignal
{
    return [[TGPassportSignals authorizationFormForBotId:_request.botId scope:_request.scope publicKey:_request.publicKey] catch:^SSignal *(id error) {
        return [SSignal single:error];
    }];
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    _barButton.image = presentation.images.callsInfoIcon;
    [_headerView setPresentation:presentation];
    [_passwordView setPresentation:presentation];
    [_setupPasswordView setPresentation:presentation];
}

- (void)setForm:(TGPassportForm *)form passwordRequest:(TGPassportPasswordRequest *)passwordRequest
{
    _form = form;
    _errors = form.errors;
    _passwordRequest = passwordRequest;
    
    [self reloadItems];
}

- (void)reloadItems
{
    while (_mainSection.items.count > 0)
    {
        [_mainSection deleteItemAtIndex:0];
    }
    
    while (_passwordSection.items.count > 0)
    {
        [_passwordSection deleteItemAtIndex:0];
    }
    
    while (_deleteSection.items.count > 0)
    {
        [_deleteSection deleteItemAtIndex:0];
    }
    
    bool reloadData = false;
    bool fadeIn = false;
    bool fadeUpdate = false;
    if (_form != nil || _passwordRequest != nil)
    {
        _headerView.hidden = false;
        
        [_activityIndicator stopAnimating];
        _activityIndicator.hidden = true;
        
        TGUser *user = [TGDatabaseInstance() loadUser:_request.botId];
        [_headerView setBot:user];
        
        switch (_passwordRequest.state) {
            case TGPassportPasswordRequestStateNoPassword:
            case TGPassportPasswordRequestStateWaitingEmail:
            {
                self.collectionView.blockScrolling = true;
                
                if ((int)TGScreenSize().height == 480)
                    _headerView.hidden = true;
                
                _passwordView.hidden = true;
                _headerView.avatarHidden = true;
                _setupPasswordView.hidden = _passwordRequest.state == TGPassportPasswordRequestStateWaitingEmail;
                _setupPasswordView.request = _request != nil;
                
                fadeIn = true;
                
                if (_passwordRequest.state == TGPassportPasswordRequestStateWaitingEmail && self.presentedViewController == nil)
                {
                    _activityIndicator.hidden = false;
                    [_activityIndicator startAnimating];
                    [self setupTwoStepAuth:true];
                }
            }
                break;

            case TGPassportPasswordRequestStateWaitingForEntry:
            {
                self.collectionView.blockScrolling = true;
                
                _passwordView.hidden = false;
                [_passwordView setHint:_passwordRequest.passwordHint];
                
                __weak TGPassportRequestController *weakSelf = self;
                [[_viewAppeared.signal take:1] startWithNext:^(NSNumber *next)
                {
                    __strong TGPassportRequestController *strongSelf = weakSelf;
                    if (strongSelf != nil && next.boolValue)
                        [strongSelf->_passwordView focus];
                }];
                
                _headerView.logoHidden = _request != nil || (int)TGScreenSize().height == 480;
                _headerView.avatarHidden = _request == nil || (int)TGScreenSize().height == 480;
                _setupPasswordView.hidden = true;
                
                fadeIn = true;
            }
                break;

            case TGPassportPasswordRequestStateLoggingInProgress:
            {
                [_passwordView setProgress:true];
            }
                break;
                
            case TGPassportPasswordRequestStateInvalidSecret:
            {
                
            }
                break;
                
            case TGPassportPasswordRequestStateSettingNewPassword:
            {
                _passwordView.hidden = true;
                _headerView.avatarHidden = (int)TGScreenSize().height == 480;
                _setupPasswordView.hidden = true;
                _activityIndicator.hidden = false;
                [_activityIndicator startAnimating];
            }
                break;

            case TGPassportPasswordRequestStateAccessDenied:
            {
                self.collectionView.blockScrolling = true;
                
                NSString *errorText = TGLocalized(@"Login.UnknownError");
                if ([_passwordRequest.error hasPrefix:@"FLOOD_WAIT"])
                    errorText = TGLocalized(@"Passport.FloodError");
                else if ([_passwordRequest.error rangeOfString:@"PASSWORD_HASH_INVALID"].location != NSNotFound)
                    errorText = TGLocalized(@"Passport.InvalidPasswordError");
                [_passwordView setProgress:false];
                [_passwordView setAccessDenied:true text:errorText animated:true];
                [_passwordView setFailed];
            }
                break;
                
            case TGPassportPasswordRequestStateAuthorized:
            {
                [_passwordView setProgress:false];
                self.collectionView.blockScrolling = false;
                
                reloadData = true;
                
                if (_privacyItem == nil)
                    fadeUpdate = true;
                
                _passwordView.hidden = true;
                _setupPasswordView.hidden = true;
                
                if (_request != nil)
                {
                    _headerView.avatarHidden = (int)TGScreenSize().height == 480;
                }
                else
                {
                    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^
                    {
                        _headerView.logoHidden = true;
                    } completion:nil];
                }
                
                [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^
                {
                    [self layoutHeader:self.view.frame.size];
                } completion:nil];

                TGHeaderCollectionItem *headerItem = [[TGHeaderCollectionItem alloc] initWithTitle:_request != nil ? TGLocalized(@"Passport.RequestedInformation") : TGLocalized(@"Passport.PassportInformation")];
                [_mainSection addItem:headerItem];
                
                bool hasValues = false;
                
                NSDictionary *identityData = self.identityData;
                if (identityData != nil || _request == nil)
                {
                    TGPassportType type = (TGPassportType)[identityData[@"type"] integerValue];
                    NSArray *acceptedTypes = identityData[@"acceptedTypes"];
                    TGPassportDecryptedValue *detailsValue = identityData[@"info"];
                    TGPassportDecryptedValue *documentValue = identityData[@"value"];
                    bool selfieRequired = [identityData[@"selfie"] boolValue];
                    
                    NSMutableArray *errors = [[NSMutableArray alloc] init];
                    for (TGPassportError *error in [_errors errorsForType:detailsValue.type])
                    {
                        [errors addObject:error.text];
                    }
                    for (TGPassportError *error in [_errors errorsForType:documentValue.type])
                    {
                        [errors addObject:error.text];
                    }
                    
                    NSString *title = TGLocalized(@"Passport.FieldIdentity");
                    NSString *uploadSubtitle = TGLocalized(@"Passport.FieldIdentityUploadHelp");
                    bool singleType = false;
                    if (_request != nil && acceptedTypes.count == 1)
                    {
                        singleType = true;
                        switch (type)
                        {
                            case TGPassportTypePersonalDetails:
                                title = TGLocalized(@"Passport.Identity.TypePersonalDetails");
                                break;
                            
                            case TGPassportTypePassport:
                                title = TGLocalized(@"Passport.Identity.TypePassport");
                                uploadSubtitle = TGLocalized(@"Passport.Identity.TypePassportUploadScan");
                                break;
                                
                            case TGPassportTypeIdentityCard:
                                title = TGLocalized(@"Passport.Identity.TypeIdentityCard");
                                uploadSubtitle = TGLocalized(@"Passport.Identity.TypeIdentityCardUploadScan");
                                break;
                                
                            case TGPassportTypeDriversLicense:
                                title = TGLocalized(@"Passport.Identity.TypeDriversLicense");
                                uploadSubtitle = TGLocalized(@"Passport.Identity.TypeDriversLicenseUploadScan");
                                break;
                                
                            case TGPassportTypeInternalPassport:
                                title = TGLocalized(@"Passport.Identity.TypeInternalPassport");
                                uploadSubtitle = TGLocalized(@"Passport.Identity.TypeInternalPassportUploadScan");
                                break;
                                
                            default:
                                break;
                        }
                    }
                    
                    if ([(NSDictionary *)identityData[@"allValues"] count] > 0)
                        hasValues = true;
                    
                    _identityItem = [[TGPassportFieldCollectionItem alloc] initWithTitle:title action:@selector(identityPressed)];
                    
                    bool checked = _request != nil;
                    if (_request == nil)
                    {
                        NSArray *existingTypes = [identityData[@"allValues"] allKeys];
                        NSMutableArray *components = [[NSMutableArray alloc] init];
                        for (NSNumber *type in existingTypes)
                        {
                            NSString *typeName = [TGPassportIdentityController documentDisplayNameForType:(TGPassportType)type.integerValue];
                            if (typeName.length > 0)
                                [components addObject:typeName];
                        }
                        
                        if (components.count > 0)
                            _identityItem.subtitle = [components componentsJoinedByString:@", "];
                        else
                            _identityItem.subtitle = uploadSubtitle;
                    }
                    else
                    {
                        if (type == TGPassportTypePersonalDetails)
                        {
                            if (detailsValue == nil)
                            {
                                _identityItem.subtitle = TGLocalized(@"Passport.FieldIdentityDetailsHelp");
                                checked = false;
                            }
                            else
                            {
                                TGPassportPersonalDetailsData *detailsData = (TGPassportPersonalDetailsData *)detailsValue.data;
                                NSMutableArray *components = [[NSMutableArray alloc] init];
                                NSMutableArray *nameComponents = [[NSMutableArray alloc] init];
                                if (detailsData.firstName.length > 0)
                                    [nameComponents addObject:detailsData.firstName];
                                if (detailsData.lastName.length > 0)
                                    [nameComponents addObject:detailsData.lastName];
                                [components addObject:[nameComponents componentsJoinedByString:@" "]];
                                
                                _identityItem.subtitle = [components componentsJoinedByString:@", "];
                            }
                        }
                        else
                        {
                            if (documentValue == nil)
                            {
                                _identityItem.subtitle = uploadSubtitle;
                                checked = false;
                            }
                            else if (selfieRequired && documentValue.selfie == nil)
                            {
                                _identityItem.subtitle = TGLocalized(@"Passport.FieldIdentitySelfieHelp");
                                checked = false;
                            }
                            else
                            {
                                TGPassportPersonalDetailsData *detailsData = (TGPassportPersonalDetailsData *)detailsValue.data;
                                TGPassportDocumentData *documentData = (TGPassportDocumentData *)documentValue.data;
                                
                                NSMutableArray *components = [[NSMutableArray alloc] init];
                                
                                if (!singleType)
                                    [components addObject:[TGPassportIdentityController documentDisplayNameForType:type]];
                                
                                NSMutableArray *nameComponents = [[NSMutableArray alloc] init];
                                
                                if (detailsData.firstName.length > 0)
                                    [nameComponents addObject:detailsData.firstName];
                                if (detailsData.lastName.length > 0)
                                    [nameComponents addObject:detailsData.lastName];
                                
                                [components addObject:[nameComponents componentsJoinedByString:@" "]];
                                
                                if (documentData.documentNumber.length > 0)
                                    [components addObject:documentData.documentNumber];
                                
                                _identityItem.subtitle = [components componentsJoinedByString:@", "];
                            }
                        }
                    }
                    
                    if (errors.count > 0)
                        checked = false;
                    _identityItem.errors = errors;
                    _identityItem.isChecked = checked;
                    _identityItem.isRequired = errors.count > 0;
                    
                    _identityItem.deselectAutomatically = true;
                    [_mainSection addItem:_identityItem];
                }

                NSDictionary *addressData = self.addressData;
                if (addressData != nil || _request == nil)
                {
                    TGPassportType type = (TGPassportType)[addressData[@"type"] integerValue];
                    NSArray *acceptedTypes = identityData[@"acceptedTypes"];
                    TGPassportDecryptedValue *addressValue = addressData[@"info"];
                    TGPassportDecryptedValue *documentValue = addressData[@"value"];
                    
                    NSMutableArray *errors = [[NSMutableArray alloc] init];
                    for (TGPassportError *error in [_errors errorsForType:addressValue.type])
                    {
                        [errors addObject:error.text];
                    }
                    for (TGPassportError *error in [_errors errorsForType:documentValue.type])
                    {
                        [errors addObject:error.text];
                    }
                    
                    NSString *title = TGLocalized(@"Passport.FieldAddress");
                    //NSString *uploadSubtitle = TGLocalized(@"Passport.FieldAddressUploadHelp");
                    bool singleType = false;
                    if (_request != nil && acceptedTypes.count == 1)
                    {
                        singleType = true;
                        switch (type)
                        {
                            case TGPassportTypeAddress:
                                title = TGLocalized(@"Passport.Address.TypeResidentialAddress");
                                break;
                                
                            case TGPassportTypeUtilityBill:
                                title = TGLocalized(@"Passport.Address.TypeUtilityBill");
                                break;
                                
                            case TGPassportTypeBankStatement:
                                title = TGLocalized(@"Passport.Address.TypeBankStatement");
                                break;
                                
                            case TGPassportTypeRentalAgreement:
                                title = TGLocalized(@"Passport.Address.TypeRentalAgreement");
                                break;
                                
                            case TGPassportTypePassportRegistration:
                                title = TGLocalized(@"Passport.Address.TypePassportRegistration");
                                break;
                                
                            case TGPassportTypeTemporaryRegistration:
                                title = TGLocalized(@"Passport.Address.TypeTemporaryRegistration");
                                break;
                                
                            default:
                                break;
                        }
                    }
                    
                    if ([(NSDictionary *)addressData[@"allValues"] count] > 0)
                        hasValues = true;
                    
                    _addressItem = [[TGPassportFieldCollectionItem alloc] initWithTitle:title action:@selector(addressPressed)];
                    
                    bool checked = _request != nil;
                    if (_request == nil)
                    {
                        NSArray *existingTypes = [addressData[@"allValues"] allKeys];
                        NSMutableArray *components = [[NSMutableArray alloc] init];
                        for (NSNumber *type in existingTypes)
                        {
                            NSString *typeName = [TGPassportAddressController documentDisplayNameForType:(TGPassportType)type.integerValue];
                            if (typeName.length > 0)
                                [components addObject:typeName];
                        }
                        
                        if (components.count > 0)
                            _addressItem.subtitle = [components componentsJoinedByString:@", "];
                        else
                            _addressItem.subtitle = TGLocalized(@"Passport.FieldAddressUploadHelp");
                    }
                    else
                    {
                        if (type == TGPassportTypeAddress && addressValue == nil)
                        {
                            _addressItem.subtitle = TGLocalized(@"Passport.FieldAddressHelp");
                            checked = false;
                        }
                        else if (type != TGPassportTypeAddress && documentValue == nil)
                        {
                            _addressItem.subtitle = TGLocalized(@"Passport.FieldAddressUploadHelp");
                            checked = false;
                        }
                        else
                        {
                            TGPassportAddressData *addressData = (TGPassportAddressData *)addressValue.data;
                            
                            NSMutableArray *components = [[NSMutableArray alloc] init];
                            
                            if (!singleType)
                                [components addObject:[TGPassportAddressController documentDisplayNameForType:type]];
                            if (addressData.street1.length > 0)
                                [components addObject:addressData.street1];
                            if (addressData.street2.length > 0)
                                [components addObject:addressData.street2];
                            if (addressData.city.length > 0)
                                [components addObject:addressData.city];
                            if (addressData.state.length > 0)
                                [components addObject:addressData.state];
                            if (addressData.postcode.length > 0)
                                [components addObject:addressData.postcode];
                            if (addressData.countryCode.length > 0)
                            {
                                NSString *countryName = [TGLoginCountriesController countryNameByCountryId:addressData.countryCode code:NULL];
                                if (countryName.length > 0)
                                    [components addObject:countryName];
                            }
     
                            _addressItem.subtitle = [components componentsJoinedByString:@", "];
                        }
                    }
                    
                    if (errors.count > 0)
                        checked = false;
                    _addressItem.errors = errors;
                    _addressItem.isChecked = checked;
                    _addressItem.isRequired = errors.count > 0;
                    
                    _addressItem.deselectAutomatically = true;
                    [_mainSection addItem:_addressItem];
                }

                NSDictionary *phoneData = self.phoneData;
                if (phoneData != nil || _request == nil)
                {
                    TGPassportDecryptedValue *phoneValue = phoneData[@"value"];
                    
                    if (phoneValue != nil)
                        hasValues = true;
                    
                    _phoneItem = [[TGPassportFieldCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.FieldPhone") action:@selector(phonePressed)];
                    if (phoneValue != nil)
                    {
                        TGPassportPhoneData *phoneData = (TGPassportPhoneData *)phoneValue.plainData;
                        _phoneItem.subtitle = [TGPhoneUtils formatPhone:phoneData.phone forceInternational:true];
                        _phoneItem.isChecked = _request != nil;
                    }
                    else
                    {
                        _phoneItem.subtitle = TGLocalized(@"Passport.FieldPhoneHelp");
                    }
                    _phoneItem.deselectAutomatically = true;
                    [_mainSection addItem:_phoneItem];
                }

                NSDictionary *emailData = self.emailData;
                if (emailData != nil || _request == nil)
                {
                    TGPassportDecryptedValue *emailValue = emailData[@"value"];
                    
                    if (emailValue != nil)
                        hasValues = true;
                    
                    _emailItem = [[TGPassportFieldCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.FieldEmail") action:@selector(emailPressed)];
                    if (emailValue != nil)
                    {
                        TGPassportEmailData *emailData = (TGPassportEmailData *)emailValue.plainData;
                        _emailItem.subtitle = emailData.email;
                        _emailItem.isChecked = _request != nil;
                    }
                    else
                    {
                        _emailItem.subtitle = TGLocalized(@"Passport.FieldEmailHelp");
                    }
                    _emailItem.deselectAutomatically = true;
                    [_mainSection addItem:_emailItem];
                }
                
                NSString *formatText = _form.privacyPolicyUrl.length > 0 ? TGLocalized(@"Passport.PrivacyPolicy") : TGLocalized(@"Passport.AcceptHelp");
                NSString *text = [NSString stringWithFormat:formatText, user.displayName, user.userName];
                
                __weak TGPassportRequestController *weakSelf = self;
                _privacyItem = [[TGCommentCollectionItem alloc] initWithText:text];
                _privacyItem.action = ^
                {
                    __strong TGPassportRequestController *strongSelf = weakSelf;
                    if (strongSelf == nil)
                        return;
                    
                    if (strongSelf->_form.privacyPolicyUrl.length > 0)
                        [(TGApplication *)[TGApplication sharedApplication] nativeOpenURL:[NSURL URLWithString:strongSelf->_form.privacyPolicyUrl]];
                };
                if (_request != nil)
                    [_mainSection addItem:_privacyItem];
                
                if (_deleteSection != nil)
                {
                    //[_passwordSection addItem:_passwordItem];
                    
                    if (hasValues)
                        [_deleteSection addItem:_deleteItem];
                    else
                        [_deleteSection deleteItem:_deleteItem];
                }

                [UIView animateWithDuration:0.3 delay:0.0f options:7 << 16 animations:^{
                    [self layoutButton:self.view.frame.size];
                } completion:nil];
            }
                break;

            default:
                break;
        }
    }
    else
    {
        _activityIndicator.hidden = false;
        [_activityIndicator startAnimating];
    }
    
    if (fadeUpdate && !fadeIn)
    {
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] initWithIndex:0];
        if (_deleteSection != nil)
            [indexSet addIndex:1];
        
        [self.collectionView reloadSections:indexSet];
    }
    else
    {
        if (fadeIn)
        {
            self.collectionView.alpha = 0.0f;
            [UIView animateWithDuration:0.2 animations:^
            {
                self.collectionView.alpha = 1.0f;
            }];
        }
        if (reloadData)
            [self.collectionView reloadData];
    }
}

#pragma mark -

- (TGPassportDecryptedForm *)decryptedForm
{
    if (![_form isKindOfClass:[TGPassportDecryptedForm class]])
        return nil;
    
    return (TGPassportDecryptedForm *)_form;
}

- (NSDictionary *)identityData
{
    NSArray *scope = self.decryptedForm.requiredTypes;
    NSArray *identityTypes = @[ @(TGPassportTypePersonalDetails), @(TGPassportTypePassport), @(TGPassportTypeDriversLicense), @(TGPassportTypeIdentityCard), @(TGPassportTypeInternalPassport) ];
    bool selfieRequired = self.decryptedForm.selfieRequired;
    
    NSMutableDictionary *result = nil;
    NSMutableDictionary *allValues = nil;
    NSMutableArray *acceptedTypes = [[NSMutableArray alloc] init];
    for (NSNumber *identityType in identityTypes)
    {
        if ([scope indexOfObject:identityType] != NSNotFound)
        {
            TGPassportType type = (TGPassportType)identityType.integerValue;
            
            if (result == nil)
            {
                result = [[NSMutableDictionary alloc] init];
                result[@"acceptedTypes"] = acceptedTypes;
            }
            
            if (_request == nil)
            {
                if (allValues == nil)
                {
                    allValues = [[NSMutableDictionary alloc] init];
                    result[@"allValues"] = allValues;
                }
                
                TGPassportDecryptedValue *value = [self.decryptedForm valueForType:type];
                if (value != nil)
                    allValues[@(type)] = value;
            }
            
            if (type != TGPassportTypePersonalDetails)
                [acceptedTypes addObject:identityType];
            
            if (result[@"info"] == nil)
            {
                TGPassportDecryptedValue *details = [self.decryptedForm valueForType:TGPassportTypePersonalDetails];
                if (details != nil)
                    result[@"info"] = details;
            }
            
            if (result[@"value"] == nil && type != TGPassportTypePersonalDetails)
            {
                if (selfieRequired)
                    result[@"selfie"] = @true;
                
                if (result[@"value"] == nil)
                    result[@"type"] = identityType;
                
                TGPassportDecryptedValue *value = [self.decryptedForm valueForType:type];
                if (value != nil)
                    result[@"value"] = value;
            }
        }
    }
    
    if ((acceptedTypes.count == 0 || _request == nil) && [scope indexOfObject:@(TGPassportTypePersonalDetails)] != NSNotFound) {
        if (_request == nil)
            [acceptedTypes insertObject:@(TGPassportTypePersonalDetails) atIndex:0];
        else
            [acceptedTypes addObject:@(TGPassportTypePersonalDetails)];
        result[@"type"] = @(TGPassportTypePersonalDetails);
    }
    
    return result;
}

- (NSDictionary *)addressData
{
    NSArray *scope = self.decryptedForm.requiredTypes;
    NSArray *addressTypes = @[ @(TGPassportTypeAddress), @(TGPassportTypeUtilityBill), @(TGPassportTypeBankStatement), @(TGPassportTypeRentalAgreement), @(TGPassportTypePassportRegistration), @(TGPassportTypeTemporaryRegistration) ];
    
    NSMutableDictionary *result = nil;
    NSMutableDictionary *allValues = nil;
    NSMutableArray *acceptedTypes = [[NSMutableArray alloc] init];
    for (NSNumber *addressType in addressTypes)
    {
        if ([scope indexOfObject:addressType] != NSNotFound)
        {
            TGPassportType type = (TGPassportType)addressType.integerValue;
            
            if (result == nil)
            {
                result = [[NSMutableDictionary alloc] init];
                result[@"acceptedTypes"] = acceptedTypes;
            }
            
            if (_request == nil)
            {
                if (allValues == nil)
                {
                    allValues = [[NSMutableDictionary alloc] init];
                    result[@"allValues"] = allValues;
                }
                
                TGPassportDecryptedValue *value = [self.decryptedForm valueForType:type];
                if (value != nil)
                    allValues[@(type)] = value;
            }
            
            if (type != TGPassportTypeAddress)
                [acceptedTypes addObject:addressType];
            
            if (result[@"info"] == nil)
            {
                TGPassportDecryptedValue *details = [self.decryptedForm valueForType:TGPassportTypeAddress];
                if (details != nil)
                    result[@"info"] = details;
            }
            
            if (result[@"value"] == nil && type != TGPassportTypeAddress)
            {
                if (result[@"value"] == nil)
                    result[@"type"] = addressType;
                
                TGPassportDecryptedValue *value = [self.decryptedForm valueForType:type];
                if (value != nil)
                    result[@"value"] = value;
            }
        }
    }
    
    if ((acceptedTypes.count == 0 || _request == nil) && [scope indexOfObject:@(TGPassportTypeAddress)] != NSNotFound) {
        if (_request == nil)
            [acceptedTypes insertObject:@(TGPassportTypeAddress) atIndex:0];
        else
            [acceptedTypes addObject:@(TGPassportTypeAddress)];
        result[@"type"] = @(TGPassportTypeAddress);
    }
    
    return result;
}

- (NSDictionary *)phoneData
{
    NSArray *scope = self.decryptedForm.requiredTypes;
    NSNumber *phoneType = @(TGPassportTypePhone);
    
    if ([scope indexOfObject:phoneType] != NSNotFound)
    {
        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
        TGPassportDecryptedValue *value = [self.decryptedForm valueForType:TGPassportTypePhone];
        if (value != nil)
            result[@"value"] = value;
        
        return result;
    }
    
    return nil;
}

- (NSDictionary *)emailData
{
    NSArray *scope = self.decryptedForm.requiredTypes;
    NSNumber *emailType = @(TGPassportTypeEmail);
    
    if ([scope indexOfObject:emailType] != NSNotFound)
    {
        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
        TGPassportDecryptedValue *value = [self.decryptedForm valueForType:TGPassportTypeEmail];
        if (value != nil)
            result[@"value"] = value;
        
        return result;
    }
    
    return nil;
}

#pragma mark -

- (void)updatePersonalDetails:(TGPassportDecryptedValue *)personalDetails type:(TGPassportType)type document:(TGPassportDecryptedValue *)document errors:(TGPassportErrors *)errors
{
    TGPassportDecryptedForm *form = [self decryptedForm];
    if (form == nil)
        return;
    
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSMutableArray *removeTypes = [[NSMutableArray alloc] init];
    
    if (personalDetails != nil)
        [values addObject:personalDetails];
    
    if (document != nil)
        [values addObject:document];
    else if (type != TGPassportTypePersonalDetails || personalDetails == nil)
        [removeTypes addObject:@(type)];
    
    if (errors != nil)
        _errors = errors;
    
    form = [form updateWithValues:values removeValueTypes:removeTypes];
    _form = form;
    [self reloadItems];
}

- (void)updateAddress:(TGPassportDecryptedValue *)address type:(TGPassportType)type document:(TGPassportDecryptedValue *)document errors:(TGPassportErrors *)errors
{
    TGPassportDecryptedForm *form = [self decryptedForm];
    if (form == nil)
        return;
    
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSMutableArray *removeTypes = [[NSMutableArray alloc] init];
    
    if (address != nil)
        [values addObject:address];
    
    if (document != nil)
        [values addObject:document];
    else if (type != TGPassportTypeAddress || address == nil)
        [removeTypes addObject:@(type)];
    
    if (errors != nil)
        _errors = errors;
    
    form = [form updateWithValues:values removeValueTypes:removeTypes];
    _form = form;
    [self reloadItems];
}

- (void)updatePhone:(TGPassportDecryptedValue *)phone
{
    TGPassportDecryptedForm *form = [self decryptedForm];
    if (form == nil)
        return;
    
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSMutableArray *removeTypes = [[NSMutableArray alloc] init];
    
    if (phone != nil)
        [values addObject:phone];
    else
        [removeTypes addObject:@(TGPassportTypePhone)];
    
    form = [form updateWithValues:values removeValueTypes:removeTypes];
    _form = form;
    [self reloadItems];
}

- (void)updateEmail:(TGPassportDecryptedValue *)email
{
    TGPassportDecryptedForm *form = [self decryptedForm];
    if (form == nil)
        return;
    
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSMutableArray *removeTypes = [[NSMutableArray alloc] init];
    
    if (email != nil)
        [values addObject:email];
    else
        [removeTypes addObject:@(TGPassportTypeEmail)];
    
    form = [form updateWithValues:values removeValueTypes:removeTypes];
    _form = form;
    [self reloadItems];
}

#pragma mark -

- (void)pushViewController:(TGViewController *)viewController animated:(bool)animated {
    for (TGViewController *viewController in self.navigationController.childViewControllers) {
        if ([viewController isKindOfClass:[TGMenuSheetController class]]) {
            TGMenuSheetController *menuController = (TGMenuSheetController *)viewController;
            [menuController dismissAnimated:false];
            break;
        }
    }
    
    [self.navigationController pushViewController:viewController animated:animated];
}

- (void)identityPressed
{
    NSDictionary *identityData = self.identityData;
    if (identityData == nil)
        return;
    
    NSArray *acceptedTypes = identityData[@"acceptedTypes"];
    
    if (_request == nil)
    {
        NSDictionary *values = identityData[@"allValues"];
        bool selfieRequired = true;
        
        __weak TGPassportRequestController *weakSelf = self;
        TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
        _menuController = controller;
        controller.dismissesByOutsideTap = true;
        controller.hasSwipeGesture = true;
        controller.narrowInLandscape = true;
        controller.permittedArrowDirections = UIPopoverArrowDirectionAny;
        controller.sourceRect = ^CGRect
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [strongSelf->_identityItem.view convertRect:strongSelf->_identityItem.view.bounds toView:strongSelf.view];
            return CGRectZero;
        };
        
        __weak TGMenuSheetController *weakController = controller;
        NSMutableArray *items = [[NSMutableArray alloc] init];
        {
            TGPassportDecryptedValue *detailsValue = values[@(TGPassportTypePersonalDetails)];
            NSString *title = detailsValue ? TGLocalized(@"Passport.Identity.EditPersonalDetails") : TGLocalized(@"Passport.Identity.AddPersonalDetails");
            
            TGMenuSheetButtonItemView *personalItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:title type:TGMenuSheetButtonTypeDefault action:^
            {
                __strong TGMenuSheetController *strongController = weakController;
                if (strongController == nil)
                    return;
                
                __strong TGPassportRequestController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf identityDocumentTypePressed:TGPassportTypePersonalDetails detailsValue:detailsValue documentValue:nil selfieRequired:selfieRequired menuController:strongController];
            }];
            [items addObject:personalItem];
        }
        
        {
            TGPassportDecryptedValue *documentValue = values[@(TGPassportTypePassport)];
            NSString *title = documentValue ? TGLocalized(@"Passport.Identity.EditPassport") : TGLocalized(@"Passport.Identity.AddPassport");
            
            TGMenuSheetButtonItemView *passportItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:title type:TGMenuSheetButtonTypeDefault action:^
            {
                __strong TGMenuSheetController *strongController = weakController;
                if (strongController == nil)
                    return;
                
                __strong TGPassportRequestController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf identityDocumentTypePressed:TGPassportTypePassport detailsValue:nil documentValue:documentValue selfieRequired:selfieRequired menuController:strongController];
            }];
            [items addObject:passportItem];
        }
        
        {
            TGPassportDecryptedValue *documentValue = values[@(TGPassportTypeIdentityCard)];
            NSString *title = documentValue ? TGLocalized(@"Passport.Identity.EditIdentityCard") : TGLocalized(@"Passport.Identity.AddIdentityCard");
            
            TGMenuSheetButtonItemView *identityCardItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:title type:TGMenuSheetButtonTypeDefault action:^
            {
                __strong TGMenuSheetController *strongController = weakController;
                if (strongController == nil)
                    return;
                
                __strong TGPassportRequestController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf identityDocumentTypePressed:TGPassportTypeIdentityCard detailsValue:nil documentValue:documentValue selfieRequired:selfieRequired menuController:strongController];
            }];
            [items addObject:identityCardItem];
        }
        
        {
            TGPassportDecryptedValue *documentValue = values[@(TGPassportTypeDriversLicense)];
            NSString *title = documentValue ? TGLocalized(@"Passport.Identity.EditDriversLicense") : TGLocalized(@"Passport.Identity.AddDriversLicense");
            
            TGMenuSheetButtonItemView *driversLicenseItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:title type:TGMenuSheetButtonTypeDefault action:^
            {
                __strong TGMenuSheetController *strongController = weakController;
                if (strongController == nil)
                    return;
                
                __strong TGPassportRequestController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf identityDocumentTypePressed:TGPassportTypeDriversLicense detailsValue:nil documentValue:documentValue selfieRequired:selfieRequired menuController:strongController];
            }];
            [items addObject:driversLicenseItem];
        }
        
        {
            TGPassportDecryptedValue *documentValue = values[@(TGPassportTypeInternalPassport)];
            NSString *title = documentValue ? TGLocalized(@"Passport.Identity.EditInternalPassport") : TGLocalized(@"Passport.Identity.AddInternalPassport");
            
            TGMenuSheetButtonItemView *driversLicenseItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:title type:TGMenuSheetButtonTypeDefault action:^
            {
                __strong TGMenuSheetController *strongController = weakController;
                if (strongController == nil)
                    return;
                
                __strong TGPassportRequestController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf identityDocumentTypePressed:TGPassportTypeInternalPassport detailsValue:nil documentValue:documentValue selfieRequired:selfieRequired menuController:strongController];
            }];
            [items addObject:driversLicenseItem];
        }
        
        TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
        {
            __strong TGMenuSheetController *strongController = weakController;
            if (strongController == nil)
                return;
            
            [strongController dismissAnimated:true manual:true];
        }];
        [items addObject:cancelItem];
        
        [controller setItemViews:items];
        
        [controller presentInViewController:self sourceView:self.view animated:true];
    }
    else
    {
        TGPassportType type = (TGPassportType)[identityData[@"type"] integerValue];
        TGPassportDecryptedValue *detailsValue = identityData[@"info"];
        TGPassportDecryptedValue *documentValue = identityData[@"value"];
        bool selfieRequired = [identityData[@"selfie"] boolValue];
        
        if (documentValue == nil && type != TGPassportTypePersonalDetails)
        {
            if (acceptedTypes.count == 1)
            {
                [self identityDocumentTypePressed:type detailsValue:detailsValue documentValue:nil selfieRequired:selfieRequired menuController:nil];
            }
            else
            {
                __weak TGPassportRequestController *weakSelf = self;
                TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
                _menuController = controller;
                controller.dismissesByOutsideTap = true;
                controller.hasSwipeGesture = true;
                controller.narrowInLandscape = true;
                controller.permittedArrowDirections = UIPopoverArrowDirectionAny;
                controller.sourceRect = ^CGRect
                {
                    __strong TGPassportRequestController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                        return [strongSelf->_identityItem.view convertRect:strongSelf->_identityItem.view.bounds toView:strongSelf.view];
                    return CGRectZero;
                };
                
                __weak TGMenuSheetController *weakController = controller;
                NSMutableArray *items = [[NSMutableArray alloc] init];
            
                if ([acceptedTypes containsObject:@(TGPassportTypePassport)])
                {
                    TGMenuSheetButtonItemView *passportItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Passport.Identity.TypePassport") type:TGMenuSheetButtonTypeDefault action:^
                    {
                        __strong TGMenuSheetController *strongController = weakController;
                        if (strongController == nil)
                            return;
                        
                        __strong TGPassportRequestController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                            [strongSelf identityDocumentTypePressed:TGPassportTypePassport detailsValue:detailsValue documentValue:nil selfieRequired:selfieRequired menuController:strongController];
                    }];
                    [items addObject:passportItem];
                }
                
                if ([acceptedTypes containsObject:@(TGPassportTypeIdentityCard)])
                {
                    TGMenuSheetButtonItemView *identityCardItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Passport.Identity.TypeIdentityCard") type:TGMenuSheetButtonTypeDefault action:^
                    {
                        __strong TGMenuSheetController *strongController = weakController;
                        if (strongController == nil)
                            return;
                        
                        __strong TGPassportRequestController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                            [strongSelf identityDocumentTypePressed:TGPassportTypeIdentityCard detailsValue:detailsValue documentValue:nil selfieRequired:selfieRequired menuController:strongController];
                    }];
                    [items addObject:identityCardItem];
                }
                
                if ([acceptedTypes containsObject:@(TGPassportTypeDriversLicense)])
                {
                    TGMenuSheetButtonItemView *driversLicenseItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Passport.Identity.TypeDriversLicense") type:TGMenuSheetButtonTypeDefault action:^
                    {
                        __strong TGMenuSheetController *strongController = weakController;
                        if (strongController == nil)
                            return;
                        
                        __strong TGPassportRequestController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                            [strongSelf identityDocumentTypePressed:TGPassportTypeDriversLicense detailsValue:detailsValue documentValue:nil selfieRequired:selfieRequired menuController:strongController];
                    }];
                    [items addObject:driversLicenseItem];
                }
                
                if ([acceptedTypes containsObject:@(TGPassportTypeInternalPassport)])
                {
                    TGMenuSheetButtonItemView *driversLicenseItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Passport.Identity.TypeInternalPassport") type:TGMenuSheetButtonTypeDefault action:^
                    {
                        __strong TGMenuSheetController *strongController = weakController;
                        if (strongController == nil)
                            return;
                        
                        __strong TGPassportRequestController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                            [strongSelf identityDocumentTypePressed:TGPassportTypeInternalPassport detailsValue:detailsValue documentValue:nil selfieRequired:selfieRequired menuController:strongController];
                    }];
                    [items addObject:driversLicenseItem];
                }
                
                TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
                {
                    __strong TGMenuSheetController *strongController = weakController;
                    if (strongController == nil)
                        return;
                    
                    [strongController dismissAnimated:true manual:true];
                }];
                [items addObject:cancelItem];
                
                [controller setItemViews:items];
                
                [controller presentInViewController:self sourceView:self.view animated:true];
            }
        }
        else
        {
            [self identityDocumentTypePressed:type detailsValue:detailsValue documentValue:documentValue selfieRequired:selfieRequired menuController:nil];
        }
    }
}

- (void)addressPressed
{
    NSDictionary *addressData = self.addressData;
    if (addressData == nil)
        return;
    
    NSArray *acceptedTypes = addressData[@"acceptedTypes"];
    
    if (_request == nil)
    {
        NSDictionary *values = addressData[@"allValues"];
        
        __weak TGPassportRequestController *weakSelf = self;
        TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
        _menuController = controller;
        controller.dismissesByOutsideTap = true;
        controller.hasSwipeGesture = true;
        controller.narrowInLandscape = true;
        controller.permittedArrowDirections = UIPopoverArrowDirectionAny;
        controller.sourceRect = ^CGRect
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [strongSelf->_addressItem.view convertRect:strongSelf->_addressItem.view.bounds toView:strongSelf.view];
            return CGRectZero;
        };
        
        __weak TGMenuSheetController *weakController = controller;
        NSMutableArray *items = [[NSMutableArray alloc] init];
        {
            TGPassportDecryptedValue *addressValue = values[@(TGPassportTypeAddress)];
            NSString *title = addressValue ? TGLocalized(@"Passport.Address.EditResidentialAddress") : TGLocalized(@"Passport.Address.AddResidentialAddress");
            
            TGMenuSheetButtonItemView *addressItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:title type:TGMenuSheetButtonTypeDefault action:^
            {
                __strong TGMenuSheetController *strongController = weakController;
                if (strongController == nil)
                    return;
                
                __strong TGPassportRequestController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf addressDocumentTypePressed:TGPassportTypeAddress addressValue:addressValue documentValue:nil menuController:strongController];
            }];
            [items addObject:addressItem];
        }
        
        {
            TGPassportDecryptedValue *documentValue = values[@(TGPassportTypeUtilityBill)];
            NSString *title = documentValue ? TGLocalized(@"Passport.Address.EditUtilityBill") : TGLocalized(@"Passport.Address.AddUtilityBill");
            
            TGMenuSheetButtonItemView *billItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:title type:TGMenuSheetButtonTypeDefault action:^
            {
                __strong TGMenuSheetController *strongController = weakController;
                if (strongController == nil)
                    return;
                
                __strong TGPassportRequestController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf addressDocumentTypePressed:TGPassportTypeUtilityBill addressValue:nil documentValue:documentValue menuController:strongController];
            }];
            [items addObject:billItem];
        }
        
        {
            TGPassportDecryptedValue *documentValue = values[@(TGPassportTypeBankStatement)];
            NSString *title = documentValue ? TGLocalized(@"Passport.Address.EditBankStatement") : TGLocalized(@"Passport.Address.AddBankStatement");
            
            TGMenuSheetButtonItemView *statementItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:title type:TGMenuSheetButtonTypeDefault action:^
            {
                __strong TGMenuSheetController *strongController = weakController;
                if (strongController == nil)
                    return;
                
                __strong TGPassportRequestController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf addressDocumentTypePressed:TGPassportTypeBankStatement addressValue:nil documentValue:documentValue menuController:strongController];
            }];
            [items addObject:statementItem];
        }
        
        {
            TGPassportDecryptedValue *documentValue = values[@(TGPassportTypeRentalAgreement)];
            NSString *title = documentValue ? TGLocalized(@"Passport.Address.EditRentalAgreement") : TGLocalized(@"Passport.Address.AddRentalAgreement");
            
            TGMenuSheetButtonItemView *rentalItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:title type:TGMenuSheetButtonTypeDefault action:^
            {
                __strong TGMenuSheetController *strongController = weakController;
                if (strongController == nil)
                    return;
                
                __strong TGPassportRequestController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf addressDocumentTypePressed:TGPassportTypeRentalAgreement addressValue:nil documentValue:documentValue menuController:strongController];
            }];
            [items addObject:rentalItem];
        }
        
        {
            TGPassportDecryptedValue *documentValue = values[@(TGPassportTypePassportRegistration)];
            NSString *title = documentValue ? TGLocalized(@"Passport.Address.EditPassportRegistration") : TGLocalized(@"Passport.Address.AddPassportRegistration");
            
            TGMenuSheetButtonItemView *registrationItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:title type:TGMenuSheetButtonTypeDefault action:^
            {
                __strong TGMenuSheetController *strongController = weakController;
                if (strongController == nil)
                    return;
                
                __strong TGPassportRequestController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf addressDocumentTypePressed:TGPassportTypePassportRegistration addressValue:nil documentValue:documentValue menuController:strongController];
            }];
            [items addObject:registrationItem];
        }
        
        {
            TGPassportDecryptedValue *documentValue = values[@(TGPassportTypeTemporaryRegistration)];
            NSString *title = documentValue ? TGLocalized(@"Passport.Address.EditTemporaryRegistration") : TGLocalized(@"Passport.Address.AddTemporaryRegistration");
            
            TGMenuSheetButtonItemView *tempRegistrationItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:title type:TGMenuSheetButtonTypeDefault action:^
            {
                __strong TGMenuSheetController *strongController = weakController;
                if (strongController == nil)
                    return;
                
                __strong TGPassportRequestController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf addressDocumentTypePressed:TGPassportTypeTemporaryRegistration addressValue:nil documentValue:documentValue menuController:strongController];
            }];
            [items addObject:tempRegistrationItem];
        }
        
        TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
        {
            __strong TGMenuSheetController *strongController = weakController;
            if (strongController == nil)
                return;
            
            [strongController dismissAnimated:true manual:true];
        }];
        [items addObject:cancelItem];
        
        [controller setItemViews:items];
        
        [controller presentInViewController:self sourceView:self.view animated:true];
    }
    else
    {
        TGPassportType type = (TGPassportType)[addressData[@"type"] integerValue];
        TGPassportDecryptedValue *addressValue = addressData[@"info"];
        TGPassportDecryptedValue *documentValue = addressData[@"value"];
        
        if (documentValue == nil && type != TGPassportTypeAddress)
        {
            if (acceptedTypes.count == 1)
            {
                [self addressDocumentTypePressed:type addressValue:addressValue documentValue:nil menuController:nil];
            }
            else
            {
                __weak TGPassportRequestController *weakSelf = self;
                TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
                _menuController = controller;
                controller.dismissesByOutsideTap = true;
                controller.hasSwipeGesture = true;
                controller.narrowInLandscape = true;
                controller.permittedArrowDirections = UIPopoverArrowDirectionAny;
                controller.sourceRect = ^CGRect
                {
                    __strong TGPassportRequestController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                        return [strongSelf->_addressItem.view convertRect:strongSelf->_addressItem.view.bounds toView:strongSelf.view];
                    return CGRectZero;
                };
                
                __weak TGMenuSheetController *weakController = controller;
                NSMutableArray *items = [[NSMutableArray alloc] init];
                
                if ([acceptedTypes containsObject:@(TGPassportTypeUtilityBill)])
                {
                    TGMenuSheetButtonItemView *billItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Passport.Address.TypeUtilityBill") type:TGMenuSheetButtonTypeDefault action:^
                    {
                        __strong TGMenuSheetController *strongController = weakController;
                        if (strongController == nil)
                            return;
                        
                        __strong TGPassportRequestController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                            [strongSelf addressDocumentTypePressed:TGPassportTypeUtilityBill addressValue:addressValue documentValue:nil menuController:strongController];
                    }];
                    [items addObject:billItem];
                }
                
                if ([acceptedTypes containsObject:@(TGPassportTypeBankStatement)])
                {
                    TGMenuSheetButtonItemView *statementItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Passport.Address.TypeBankStatement") type:TGMenuSheetButtonTypeDefault action:^
                    {
                        __strong TGMenuSheetController *strongController = weakController;
                        if (strongController == nil)
                            return;
                        
                        __strong TGPassportRequestController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                            [strongSelf addressDocumentTypePressed:TGPassportTypeBankStatement addressValue:addressValue documentValue:nil menuController:strongController];
                    }];
                    [items addObject:statementItem];
                }
                
                if ([acceptedTypes containsObject:@(TGPassportTypeRentalAgreement)])
                {
                    TGMenuSheetButtonItemView *rentalItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Passport.Address.TypeRentalAgreement") type:TGMenuSheetButtonTypeDefault action:^
                    {
                        __strong TGMenuSheetController *strongController = weakController;
                        if (strongController == nil)
                            return;
                        
                        __strong TGPassportRequestController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                            [strongSelf addressDocumentTypePressed:TGPassportTypeRentalAgreement addressValue:addressValue documentValue:nil menuController:strongController];
                    }];
                    [items addObject:rentalItem];
                }
                
                if ([acceptedTypes containsObject:@(TGPassportTypePassportRegistration)])
                {
                    TGMenuSheetButtonItemView *rentalItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Passport.Address.TypePassportRegistration") type:TGMenuSheetButtonTypeDefault action:^
                    {
                        __strong TGMenuSheetController *strongController = weakController;
                        if (strongController == nil)
                            return;
                        
                        __strong TGPassportRequestController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                            [strongSelf addressDocumentTypePressed:TGPassportTypePassportRegistration addressValue:addressValue documentValue:nil menuController:strongController];
                    }];
                    [items addObject:rentalItem];
                }
                
                if ([acceptedTypes containsObject:@(TGPassportTypeTemporaryRegistration)])
                {
                    TGMenuSheetButtonItemView *rentalItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Passport.Address.TypeTemporaryRegistration") type:TGMenuSheetButtonTypeDefault action:^
                    {
                        __strong TGMenuSheetController *strongController = weakController;
                        if (strongController == nil)
                            return;
                        
                        __strong TGPassportRequestController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                            [strongSelf addressDocumentTypePressed:TGPassportTypeTemporaryRegistration addressValue:addressValue documentValue:nil menuController:strongController];
                    }];
                    [items addObject:rentalItem];
                }
                
                TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
                {
                    __strong TGMenuSheetController *strongController = weakController;
                    if (strongController == nil)
                        return;
                    
                    [strongController dismissAnimated:true manual:true];
                }];
                [items addObject:cancelItem];
                
                [controller setItemViews:items];
                
                [controller presentInViewController:self sourceView:self.view animated:true];
            }
        }
        else
        {
            [self addressDocumentTypePressed:type addressValue:addressValue documentValue:documentValue menuController:nil];
        }
    }
}

- (void)phonePressed
{
    NSDictionary *phoneData = self.phoneData;
    if (phoneData == nil)
        return;
    
    TGPassportDecryptedValue *phoneValue = phoneData[@"value"];
    
    __weak TGPassportRequestController *weakSelf = self;
    if (phoneValue == nil)
    {
        TGPassportPhoneController *controller = [[TGPassportPhoneController alloc] initWithSettings:_passwordSettingsVariable];
        controller.completionBlock = ^(TGPassportDecryptedValue *phone)
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf updatePhone:phone];
        };
        [self pushViewController:controller animated:true];
    }
    else
    {
        TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
        _menuController = controller;
        controller.dismissesByOutsideTap = true;
        controller.hasSwipeGesture = true;
        controller.narrowInLandscape = true;
        controller.permittedArrowDirections = UIPopoverArrowDirectionAny;
        controller.sourceRect = ^CGRect
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [strongSelf->_phoneItem.view convertRect:strongSelf->_phoneItem.view.bounds toView:strongSelf.view];
            return CGRectZero;
        };
        
        __weak TGMenuSheetController *weakController = controller;
        TGMenuSheetButtonItemView *deleteItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Passport.Phone.Delete") type:TGMenuSheetButtonTypeDestructive action:^
        {
            __strong TGMenuSheetController *strongController = weakController;
            if (strongController == nil)
                return;
            
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf->_saveDisposable setDisposable:[[TGPassportSignals deleteSecureValueTypes:@[@(TGPassportTypePhone)]] startWithNext:nil]];
                [strongSelf updatePhone:nil];
            }
            
             [strongController dismissAnimated:true manual:true];
        }];
        
        TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
        {
            __strong TGMenuSheetController *strongController = weakController;
            if (strongController == nil)
                return;
            
            [strongController dismissAnimated:true manual:true];
        }];
        
        [controller setItemViews:@[ deleteItem, cancelItem ]];
        
        [controller presentInViewController:self sourceView:self.view animated:true];
    }
}

- (void)emailPressed
{
    NSDictionary *emailData = self.emailData;
    if (emailData == nil)
        return;
    
    TGPassportDecryptedValue *emailValue = emailData[@"value"];
    
    __weak TGPassportRequestController *weakSelf = self;
    if (emailValue == nil)
    {
        [[_passwordSettingsVariable.signal take:1] startWithNext:^(TGPassportPasswordRequest *next)
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                TGPassportEmailController *controller = [[TGPassportEmailController alloc] initWithSettings:strongSelf->_passwordSettingsVariable email:next.settings.email];
                controller.completionBlock = ^(TGPassportDecryptedValue *email)
                {
                    __strong TGPassportRequestController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                        [strongSelf updateEmail:email];
                };
                [strongSelf pushViewController:controller animated:true];
            }
        }];
    }
    else
    {
        TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
        _menuController = controller;
        controller.dismissesByOutsideTap = true;
        controller.hasSwipeGesture = true;
        controller.narrowInLandscape = true;
        controller.permittedArrowDirections = UIPopoverArrowDirectionAny;
        controller.sourceRect = ^CGRect
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [strongSelf->_emailItem.view convertRect:strongSelf->_emailItem.view.bounds toView:strongSelf.view];
            return CGRectZero;
        };
        
        __weak TGMenuSheetController *weakController = controller;
        TGMenuSheetButtonItemView *deleteItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Passport.Email.Delete") type:TGMenuSheetButtonTypeDestructive action:^
        {
            __strong TGMenuSheetController *strongController = weakController;
            if (strongController == nil)
                return;
            
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf->_saveDisposable setDisposable:[[TGPassportSignals deleteSecureValueTypes:@[@(TGPassportTypeEmail)]] startWithNext:nil]];
                [strongSelf updateEmail:nil];
            }
            
            [strongController dismissAnimated:true manual:true];
        }];
        
        TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
        {
            __strong TGMenuSheetController *strongController = weakController;
            if (strongController == nil)
                return;
            
            [strongController dismissAnimated:true manual:true];
        }];
        
        [controller setItemViews:@[ deleteItem, cancelItem ]];
        
        [controller presentInViewController:self sourceView:self.view animated:true];
    }
}

- (void)identityDocumentTypePressed:(TGPassportType)type detailsValue:(TGPassportDecryptedValue *)detailsValue documentValue:(TGPassportDecryptedValue *)documentValue selfieRequired:(bool)selfieRequired menuController:(TGMenuSheetController *)menuController
{
    if (type == TGPassportTypePersonalDetails || documentValue != nil)
    {
        [menuController dismissAnimated:true];
        
        TGPassportPersonalDetailsData *detailsData = nil;
        if ([detailsValue.data isKindOfClass:[TGPassportPersonalDetailsData class]])
            detailsData = (TGPassportPersonalDetailsData *)detailsValue.data;
        
        __weak TGPassportRequestController *weakSelf = self;
        TGPassportIdentityController *controller = [[TGPassportIdentityController alloc] initWithType:type details:detailsValue document:documentValue documentOnly:(type != TGPassportTypePersonalDetails && _request == nil) selfie:selfieRequired settings:_passwordSettingsVariable errors:_errors];
        if (_request != nil && selfieRequired && documentValue != nil && documentValue.selfie == nil)
            [controller setScrollToSelfie];
        controller.completionBlock = ^(TGPassportDecryptedValue *details, TGPassportDecryptedValue *document, TGPassportErrors *errors)
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf updatePersonalDetails:details type:type document:document errors:errors];
        };
        controller.removalBlock = ^(TGPassportType type)
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf updatePersonalDetails:nil type:type document:nil errors:nil];
        };
        [self pushViewController:controller animated:true];
    }
    else
    {
        __weak TGPassportRequestController *weakSelf = self;
        TGPassportAttachIntent intent = type == TGPassportTypeIdentityCard || type == TGPassportTypeDriversLicense ? TGPassportAttachIntentIdentityCard : TGPassportAttachIntentDefault;
        [self presentImageUploadWithMenuController:menuController intent:intent sourceRect:^CGRect {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [strongSelf->_identityItem.view convertRect:strongSelf->_identityItem.view.bounds toView:strongSelf.view];
            return CGRectZero;
        } completion:^(NSArray *uploads)
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            TGPassportIdentityController *controller = [[TGPassportIdentityController alloc] initWithType:type details:detailsValue documentOnly:_request == nil selfie:selfieRequired upload:uploads.firstObject settings:strongSelf->_passwordSettingsVariable errors:strongSelf->_errors];
            controller.completionBlock = ^(TGPassportDecryptedValue *details, TGPassportDecryptedValue *document, __unused TGPassportErrors *errors)
            {
                __strong TGPassportRequestController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf updatePersonalDetails:details type:type document:document errors:errors];
            };
            [strongSelf pushViewController:controller animated:false];
        }];
    }
}

- (void)addressDocumentTypePressed:(TGPassportType)type addressValue:(TGPassportDecryptedValue *)addressValue documentValue:(TGPassportDecryptedValue *)documentValue menuController:(TGMenuSheetController *)menuController
{
    if (type == TGPassportTypeAddress || documentValue != nil)
    {
        [menuController dismissAnimated:true];
        
        __weak TGPassportRequestController *weakSelf = self;
        TGPassportAddressController *controller = [[TGPassportAddressController alloc] initWithType:type address:addressValue document:documentValue documentOnly:(type != TGPassportTypeAddress && _request == nil) settings:_passwordSettingsVariable errors:_errors];
        controller.completionBlock = ^(TGPassportDecryptedValue *address, TGPassportDecryptedValue *document, TGPassportErrors *errors)
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf updateAddress:address type:type document:document errors:errors];
        };
        controller.removalBlock = ^(TGPassportType type)
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf updateAddress:nil type:type document:nil errors:nil];
        };
        [self pushViewController:controller animated:true];
    }
    else
    {
        __weak TGPassportRequestController *weakSelf = self;
        [self presentImageUploadWithMenuController:menuController intent:TGPassportAttachIntentMultiple sourceRect:^CGRect {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [strongSelf->_addressItem.view convertRect:strongSelf->_addressItem.view.bounds toView:strongSelf.view];
            return CGRectZero;
        } completion:^(NSArray *uploads)
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            TGPassportAddressController *controller = [[TGPassportAddressController alloc] initWithType:type address:addressValue documentOnly:_request == nil uploads:uploads settings:strongSelf->_passwordSettingsVariable errors:strongSelf->_errors];
            controller.completionBlock = ^(TGPassportDecryptedValue *address, TGPassportDecryptedValue *document, TGPassportErrors *errors)
            {
                __strong TGPassportRequestController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf updateAddress:address type:type document:document errors:errors];
            };
            [strongSelf pushViewController:controller animated:false];
        }];
    }
}

- (void)presentImageUploadWithMenuController:(TGMenuSheetController *)menuController intent:(TGPassportAttachIntent)intent sourceRect:(CGRect (^)(void))sourceRect completion:(void (^)(NSArray *))completion
{
    _menuController = [TGPassportAttachMenu presentWithContext:[TGLegacyComponentsContext shared] parentController:self menuController:menuController title:nil intent:intent uploadAction:^(SSignal *resultSignal, void (^dismissPicker)(void))
    {
        [[[[resultSignal mapToSignal:^SSignal *(id value)
        {
            if ([value isKindOfClass:[NSDictionary class]])
            {
                return [SSignal single:value];
            }
            else if ([value isKindOfClass:[NSURL class]])
            {
                return [[TGPassportICloud fetchICloudFileWith:value] map:^id(NSURL *url)
                {
                    UIImage *image = [[UIImage alloc] initWithContentsOfFile:url.path];
                    
                    CGFloat maxSide = 2048.0f;
                    CGSize imageSize = TGFitSize(image.size, CGSizeMake(maxSide, maxSide));
                    UIImage *scaledImage = MAX(image.size.width, image.size.height) > maxSide ? TGScaleImageToPixelSize(image, imageSize) : image;
                    
                    CGFloat thumbnailSide = 60.0f * TGScreenScaling();
                    CGSize thumbnailSize = TGFitSize(scaledImage.size, CGSizeMake(thumbnailSide, thumbnailSide));
                    UIImage *thumbnailImage = TGScaleImageToPixelSize(scaledImage, thumbnailSize);
                    
                    return @{@"image": image, @"thumbnail": thumbnailImage };
                }];
            }
            return [SSignal complete];
        }] reduceLeft:[[NSMutableArray alloc] init] with:^NSMutableArray *(NSMutableArray *array, NSDictionary *next)
        {
            [array addObject:next];
            return array;
        }] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *next)
        {
            NSMutableArray *uploads = [[NSMutableArray alloc] init];
            for (id desc in next)
            {
                TGPassportFileUpload *upload = [[TGPassportFileUpload alloc] initWithImage:desc[@"image"] thumbnailImage:desc[@"thumbnail"] date:(int32_t)[[NSDate date] timeIntervalSince1970]];
                [uploads addObject:upload];
            }
            
            completion(uploads);
            dismissPicker();
        }];
    } sourceView:self.view sourceRect:sourceRect barButtonItem:nil];
}

- (void)authorizeButtonPressed
{
    bool failed = false;
    
    NSDictionary *identityData = self.identityData;
    if (identityData != nil)
    {
        NSArray *acceptedTypes = identityData[@"acceptedTypes"];
        if (identityData[@"info"] == nil || (identityData[@"value"] == nil && ![acceptedTypes containsObject:@(TGPassportTypePersonalDetails)]))
        {
            failed = true;
            _identityItem.isRequired = true;
        }
        else
        {
            if (identityData != nil || _request == nil)
            {
                TGPassportDecryptedValue *detailsValue = identityData[@"info"];
                TGPassportDecryptedValue *documentValue = identityData[@"value"];
                
                NSMutableArray *errors = [[NSMutableArray alloc] init];
                for (TGPassportError *error in [_errors errorsForType:detailsValue.type])
                {
                    [errors addObject:error.text];
                }
                for (TGPassportError *error in [_errors errorsForType:documentValue.type])
                {
                    [errors addObject:error.text];
                }
                
                if (errors.count > 0)
                    failed = true;
            }
        }
    }
    
    NSDictionary *addressData = self.addressData;
    if (addressData != nil)
    {
        NSArray *acceptedTypes = addressData[@"acceptedTypes"];
        if (addressData[@"info"] == nil || (addressData[@"value"] == nil && ![acceptedTypes containsObject:@(TGPassportTypeAddress)]))
        {
            failed = true;
            _addressItem.isRequired = true;
        }
        else
        {
            if (identityData != nil || _request == nil)
            {
                TGPassportDecryptedValue *addressValue = addressData[@"info"];
                TGPassportDecryptedValue *documentValue = addressData[@"value"];
    
                NSMutableArray *errors = [[NSMutableArray alloc] init];
                for (TGPassportError *error in [_errors errorsForType:addressValue.type])
                {
                    [errors addObject:error.text];
                }
                for (TGPassportError *error in [_errors errorsForType:documentValue.type])
                {
                    [errors addObject:error.text];
                }
                
                if (errors.count > 0)
                    failed = true;
            }
        }
    }
    
    NSDictionary *phoneData = self.phoneData;
    if (phoneData != nil && phoneData[@"value"] == nil)
    {
        failed = true;
        _phoneItem.isRequired = true;
    }
    
    NSDictionary *emailData = self.emailData;
    if (emailData != nil && emailData[@"value"] == nil)
    {
        failed = true;
        _emailItem.isRequired = true;
    }
    
    if (!failed)
    {
        __weak TGPassportRequestController *weakSelf = self;
        [_saveDisposable setDisposable:[[[TGPassportSignals acceptAuthorizationForBotId:_request.botId scope:_request.scope publicKey:_request.publicKey finalForm:[self decryptedForm] payload:_request.payload] deliverOn:[SQueue mainQueue]] startWithNext:^(__unused id next)
        {
            
        } completed:^
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            [strongSelf.presentingViewController dismissViewControllerAnimated:true completion:nil];
            
            if (strongSelf->_request.callbackUrl.length > 0)
            {
                NSString *url = nil;
                if ([strongSelf->_request.callbackUrl hasPrefix:@"tgbot"]) {
                    url = [NSString stringWithFormat:@"tgbot%d://passport/success", strongSelf->_request.botId];
                } else {
                    url = [TGPassportRequestController urlString:strongSelf->_request.callbackUrl byAppendingQueryString:@"tg_passport=success"];
                }
                [(TGApplication *)[TGApplication sharedApplication] nativeOpenURL:[NSURL URLWithString:url]];
            }
        }]];
    }
}

- (void)cancelPressed
{
    if (_request != nil && _request.callbackUrl.length > 0)
    {
        NSString *url = nil;
        if ([_request.callbackUrl hasPrefix:@"tgbot"]) {
            url = [NSString stringWithFormat:@"tgbot%d://passport/cancel", _request.botId];
        } else {
            url = [TGPassportRequestController urlString:_request.callbackUrl byAppendingQueryString:@"tg_passport=cancel"];
        }
        [(TGApplication *)[TGApplication sharedApplication] nativeOpenURL:[NSURL URLWithString:url]];
    }
    [self.presentingViewController dismissViewControllerAnimated:false completion:nil];
}

- (void)infoPressed
{
    NSMutableAttributedString *string = [[TGLocalized(@"Passport.InfoText") attributedFormattedStringWithRegularFont:TGSystemFontOfSize(13) boldFont:TGBoldSystemFontOfSize(13) lineSpacing:1.0f paragraphSpacing:0.0f alignment:NSTextAlignmentLeft] mutableCopy];
    [string addAttribute:NSForegroundColorAttributeName value:self.presentation.pallete.textColor range:NSMakeRange(0, string.length)];
    
    [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"Passport.InfoTitle") attributedMessage:string cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:TGLocalized(@"Passport.InfoLearnMore") completionBlock:^(bool okButtonPressed)
    {
        if (okButtonPressed)
        {
            [TGAppDelegateInstance handleOpenInstantView:TGLocalized(@"Settings.FAQ_URL") disableActions:false];
        }
    } disableKeyboardWorkaround:false];
}

+ (NSString *)urlString:(NSString *)urlString byAppendingQueryString:(NSString *)queryString {
    if (queryString.length == 0)
        return urlString;

    return [NSString stringWithFormat:@"%@%@%@", urlString,
            [urlString rangeOfString:@"?"].length > 0 ? @"&" : @"?", queryString];
}

#pragma mark -

- (void)deletePressed
{
    __weak TGPassportRequestController *weakSelf = self;
    TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
    _menuController = controller;
    controller.dismissesByOutsideTap = true;
    controller.hasSwipeGesture = true;
    controller.narrowInLandscape = true;
    controller.permittedArrowDirections = UIPopoverArrowDirectionAny;
    controller.sourceRect = ^CGRect
    {
        __strong TGPassportRequestController *strongSelf = weakSelf;
        if (strongSelf != nil)
            return [strongSelf->_deleteItem.view convertRect:strongSelf->_deleteItem.view.bounds toView:strongSelf.view];
        return CGRectZero;
    };
    
    TGMenuSheetTitleItemView *titleItem = [[TGMenuSheetTitleItemView alloc] initWithTitle:nil subtitle:TGLocalized(@"Passport.DeletePassportConfirmation") solidSubtitle:true];
    
    __weak TGMenuSheetController *weakController = controller;
    TGMenuSheetButtonItemView *deleteItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Delete") type:TGMenuSheetButtonTypeDestructive action:^
    {
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        [strongController dismissAnimated:true manual:true];
        
        __strong TGPassportRequestController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf performDelete];
    }];
    
    TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
    {
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        [strongController dismissAnimated:true manual:true];
    }];
    
    [controller setItemViews:@[ titleItem, deleteItem, cancelItem ]];
    
    [controller presentInViewController:self sourceView:self.view animated:true];
}

- (void)performDelete
{
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow showWithDelay:0.45];
    
    __weak TGPassportRequestController *weakSelf = self;
    [_saveDisposable setDisposable:[[[TGPassportSignals deleteAllSecureValues] deliverOn:[SQueue mainQueue]] startWithNext:nil error:^(__unused id error)
    {
        NSString *displayText = TGLocalized(@"Login.UnknownError");
        
        NSString *errorText = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
        [TGCustomAlertView presentAlertWithTitle:displayText message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
        
        [progressWindow dismiss:true];
    } completed:^
    {
        [progressWindow dismiss:true];
        __strong TGPassportRequestController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf.navigationController popViewControllerAnimated:true];
    }]];
}

#pragma mark -

- (void)setupTwoStepAuth:(bool)__unused waiting
{
    __weak TGPassportRequestController *weakSelf = self;
    TGFastTwoStepVerificationSetupController *controller = [[TGFastTwoStepVerificationSetupController alloc] initWithTwoStepConfig:[[_twoStepConfig signal] take:1] passport:true completion:^(__unused bool success, TGTwoStepConfig *config, NSString *password)
    {
        __strong TGPassportRequestController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (!success)
            {
                [strongSelf.navigationController popToRootViewControllerAnimated:true];
            }
            else
            {
                [strongSelf->_twoStepConfig set:[SSignal single:config]];
                
                TGPassportRequestState state = TGPassportPasswordRequestStateWaitingForEntry;
                if (password.length > 0)
                {
                    state = TGPassportPasswordRequestStateSettingNewPassword;
                    [strongSelf->_passwordVariable set:[SSignal single:password]];
                }
                
                [strongSelf setForm:strongSelf->_form passwordRequest:[TGPassportPasswordRequest requestWithState:state settings:nil hasRecovery:nil passwordHint:nil error:nil]];
                [strongSelf.presentedViewController dismissViewControllerAnimated:true completion:nil];
            }
        }
    }];
    controller.twoStepConfigUpdated = ^(TGTwoStepConfig *value)
    {
        __strong TGPassportRequestController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf->_twoStepConfig set:[SSignal single:value]];
    };
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithRootController:controller];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleDefault;
        navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)restorePassword
{
    if (!_passwordRequest.hasRecovery)
    {
        [TGCustomAlertView presentAlertWithTitle:nil message:TGLocalized(@"TwoStepAuth.RecoveryUnavailable") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil disableKeyboardWorkaround:false];
    }
    else
    {
        [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"Passport.ForgottenPassword") message:TGLocalized(@"Passport.PasswordReset") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Login.ResetAccountProtected.Reset") completionBlock:^(bool okButtonPressed)
        {
            if (okButtonPressed)
            {
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                [progressWindow show:true];
                
                __weak TGPassportRequestController *weakSelf = self;
                [_requestRecoveryDisposable setDisposable:[[[[TGTwoStepRecoverySignals requestPasswordRecovery] deliverOn:[SQueue mainQueue]] onDispose:^
                {
                    TGDispatchOnMainThread(^
                    {
                        [progressWindow dismiss:true];
                    });
                }] startWithNext:^(NSString *emailPattern)
                {
                    __strong TGPassportRequestController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        TGPasswordRecoveryController *controller = [[TGPasswordRecoveryController alloc] initWithEmailPattern:emailPattern];
                        controller.completion = ^(bool success, __unused int32_t userId)
                        {
                            __strong TGPassportRequestController *strongSelf = weakSelf;
                            if (strongSelf != nil)
                            {
                                if (success)
                                {
                                    [strongSelf setForm:strongSelf->_form passwordRequest:[TGPassportPasswordRequest requestWithState:TGPassportPasswordRequestStateSettingNewPassword settings:nil hasRecovery:false passwordHint:nil error:nil]];
                                    [strongSelf->_twoStepConfig set:[TGTwoStepConfigSignal twoStepConfig]];
                                    [strongSelf dismissViewControllerAnimated:true completion:^
                                    {
                                    }];
                                }
                                else
                                {
                                    [strongSelf dismissViewControllerAnimated:true completion:nil];
                                    
                                    [TGCustomAlertView presentAlertWithTitle:nil message:TGLocalized(@"TwoStepAuth.RecoveryFailed") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                                }
                            }
                        };
                        controller.cancelled = ^
                        {
                            __strong TGPassportRequestController *strongSelf = weakSelf;
                            if (strongSelf != nil)
                            {
                                [strongSelf dismissViewControllerAnimated:true completion:nil];
                            }
                        };
                        
                        TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller]];
                        [strongSelf presentViewController:navigationController animated:true completion:nil];
                    }
                } error:^(id error)
                {
                    NSString *errorText = TGLocalized(@"Login.UnknownError");
                    if ([error hasPrefix:@"FLOOD_WAIT"])
                        errorText = TGLocalized(@"TwoStepAuth.FloodError");
                    [TGCustomAlertView presentAlertWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:^(__unused bool okButtonPressed)
                    {
                        //__strong TGPassportRequestController *strongSelf = weakSelf;
                        //if (strongSelf != nil)
                        //    [strongSelf->_passwordItem becomeFirstResponder];
                    }];
                } completed:nil]];
            }
        } disableKeyboardWorkaround:false];
        
    }
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset {
    [super controllerInsetUpdated:previousInset];
    
    _activityIndicator.center = CGPointMake(self.view.frame.size.width / 2.0f, self.view.frame.size.height / 2.0f);
    _headerView.safeAreaInset = [self calculatedSafeAreaInset];
}

- (void)layoutControllerForSize:(CGSize)size duration:(NSTimeInterval)duration {
    [super layoutControllerForSize:size duration:duration];
    
    _activityIndicator.center = CGPointMake(size.width / 2.0f, size.height / 2.0f);
    
    [self layoutHeader:size];
    [self layoutButton:size];
    [self layoutPassword:size];
}

- (void)layoutButton:(CGSize)size
{
    UIEdgeInsets safeAreaInset = [self calculatedSafeAreaInset];
    
    CGFloat containerHeight = 76.0f + safeAreaInset.bottom;
    CGFloat containerOffset = _passwordRequest.state != TGPassportPasswordRequestStateAuthorized ? containerHeight : 0.0f;
    
    _authorizeButton.frame = CGRectMake(15.0f + safeAreaInset.left, 14.0f, size.width - 30.0f - safeAreaInset.left - safeAreaInset.right, 48.0f);
    _authorizeButtonContainer.frame = CGRectMake(0.0f, size.height - containerHeight + containerOffset, size.width, containerHeight);
}

- (void)layoutHeader:(CGSize)size
{
    CGFloat firstTopOffset = 35.0f;
    CGFloat secondTopOffset = 0.0f;
    switch ((int)TGScreenSize().height)
    {
        case 480:
        case 568:
            firstTopOffset = -6.0f;
            secondTopOffset = -6.0f;
            break;
            
        default:
            break;
    }
    _headerView.frame = CGRectMake(0.0f, _passwordRequest.state != TGPassportPasswordRequestStateAuthorized ? firstTopOffset : secondTopOffset, size.width, 170.0f);
}

- (void)layoutPassword:(CGSize)size
{
    CGFloat topOffset = 0.0f;
    CGFloat height = 100.0f;
    switch ((int)TGScreenSize().height)
    {
        case 480:
            topOffset = _request == nil ? 110.0f : 150.0f;
            height = 60.0f;
            break;
            
        case 568:
            topOffset = 224.0f;
            height = 60.0f;
            break;
            
        case 812:
            topOffset = 276.0f;
            break;
            
        default:
            topOffset = 276.0f;
            break;
    }
    
    _passwordView.frame = CGRectMake(0.0f, topOffset, size.width, height);
}

- (CGFloat)topInset
{
    switch ((int)TGScreenSize().height)
    {
        case 480:
            return _request != nil ? 95.0f : 32.0f;
            
        default:
            return _request != nil ? 174.0f : 32.0f;
    }
}

- (BOOL)shouldAutorotate
{
    return false;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end


@implementation TGPassportPasswordRequest

+ (instancetype)requestWithState:(TGPassportRequestState)state settings:(TGPasswordSettings *)settings hasRecovery:(bool)hasRecovery passwordHint:(NSString *)passwordHint error:(NSString *)error
{
    TGPassportPasswordRequest *request = [[TGPassportPasswordRequest alloc] init];
    request->_state = state;
    request->_settings = settings;
    request->_hasRecovery = hasRecovery;
    request->_passwordHint = passwordHint;
    request->_error = error;
    return request;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGPassportPasswordRequest class]]  && ((TGPassportPasswordRequest *)object)->_state == _state && TGObjectCompare(((TGPassportPasswordRequest *)object)->_settings, _settings) && ((TGPassportPasswordRequest *)object)->_hasRecovery == _hasRecovery && TGObjectCompare(((TGPassportPasswordRequest *)object)->_passwordHint, _passwordHint) && TGObjectCompare(((TGPassportPasswordRequest *)object)->_error, _error);
}

@end
