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
#import "TGTwoStepUtils.h"

#import "TGPassportICloud.h"
#import "TGPassportFile.h"
#import "TGPassportLanguageMap.h"

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

@interface TGPassportDocumentOption : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) void (^action)(TGMenuSheetController *);

+ (instancetype)optionWithTitle:(NSString *)title action:(void (^)(TGMenuSheetController *))action;
 
@end

@interface TGPassportRequestController ()
{
    TGPassportFormRequest *_request;
    TGPassportErrors *_errors;
    
    SVariable *_twoStepConfig;
    SVariable *_passwordVariable;
    SVariable *_formVariable;
    SVariable *_failedVariable;
    
    SVariable *_viewAppeared;
    
    SVariable *_passwordSettingsVariable;
    SVariable *_langMapVariable;
    TGPassportLanguageMap *_languageMap;
    
    TGPassportForm *_form;
    TGPassportPasswordRequest *_passwordRequest;
    
    SMetaDisposable *_disposable;
    SMetaDisposable *_saveDisposable;
    SMetaDisposable *_requestRecoveryDisposable;
    SMetaDisposable *_langDisposable;
    
    UIActivityIndicatorView *_activityIndicator;
    UIButton *_authorizeButton;
    UIView *_authorizeButtonContainer;
    UIView *_authorizeSeparatorView;
    
    TGModernBarButton *_barButton;
    TGPassportHeaderView *_headerView;
    TGPassportPasswordView *_passwordView;
    TGPassportSetupPasswordView *_setupPasswordView;
    
    TGCollectionMenuSection *_mainSection;
    TGCommentCollectionItem *_privacyItem;
    
    TGCollectionMenuSection *_passwordSection;
    TGButtonCollectionItem *_passwordItem;
    
    TGCollectionMenuSection *_deleteSection;
    TGButtonCollectionItem *_deleteItem;
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
        _langDisposable = [[SMetaDisposable alloc] init];
        
        _twoStepConfig = [[SVariable alloc] init];
        [_twoStepConfig set:[TGTwoStepConfigSignal twoStepConfig]];
        
        _formVariable = [[SVariable alloc] init];
        _passwordSettingsVariable = [[SVariable alloc] init];
        _passwordVariable = [[SVariable alloc] init];
        _failedVariable = [[SVariable alloc] init];
        [_failedVariable set:[SSignal single:@false]];
        
        _langMapVariable = [[SVariable alloc] init];
        [_langMapVariable set:[TGPassportSignals languageMap]];
        
        __weak TGPassportRequestController *weakSelf = self;
        [_langDisposable setDisposable:[[_langMapVariable.signal deliverOn:[SQueue mainQueue]] startWithNext:^(TGPassportLanguageMap *next)
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
                strongSelf->_languageMap = next;
        }]];
        
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
    [_langDisposable dispose];
}

#pragma mark - View

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

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    _barButton.image = presentation.images.callsInfoIcon;
    [_headerView setPresentation:presentation];
    [_passwordView setPresentation:presentation];
    [_setupPasswordView setPresentation:presentation];
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

#pragma mark - Data Setup

- (void)setupForRequest
{
    bool requiresNonce = [_request.scope hasPrefix:@"{"] && [_request.scope hasSuffix:@"}"];
    if (requiresNonce)
    {
        if (_request.nonce.length == 0) {
            [self failWithError:@"NONCE_EMPTY"];
            return;
        }
    }
    else
    {
        if (_request.payload.length == 0) {
            [self failWithError:@"PAYLOAD_EMPTY"];
            return;
        }
    }
    
    SSignal *displaySignal = [SSignal combineSignals:@[ _passwordSettingsVariable.signal, [_formVariable.signal mapToSignal:^SSignal *(id value) {
        if (![value isKindOfClass:[TGPassportForm class]])
            return [SSignal fail:value];
        else
            return [SSignal single:value];
    }]]];
    [_passwordSettingsVariable set:[[self passwordSignal] ignoreRepeated]];
    [_formVariable set:[self formRequestSignal]];

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
    
    [_passwordSettingsVariable set:[[self passwordSignal] ignoreRepeated]];
    
    __weak TGPassportRequestController *weakSelf = self;
    [_disposable setDisposable:[[displaySignal deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *values)
    {
        __strong TGPassportRequestController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        TGPassportPasswordRequest *passwordRequest = values[@"password"];
        TGPassportForm *form = values[@"form"];
        
        [strongSelf setForm:form passwordRequest:passwordRequest];
    } error:^(id error)
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
      @"PAYLOAD_EMPTY",
      @"NONCE_EMPTY"
    ];
    
    __weak TGPassportRequestController *weakSelf = self;
    bool shouldReturnError = [returnedErrors containsObject:error];
    NSString *errorText = TGLocalized(@"Login.UnknownError");
    [TGCustomAlertView presentAlertWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:^(__unused bool okButtonPressed)
     {
         __strong TGPassportRequestController *strongSelf = weakSelf;
         if (strongSelf != nil)
         {
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
         }
     }];
}

- (TGPassportDecryptedForm *)decryptedForm
{
    if (![_form isKindOfClass:[TGPassportDecryptedForm class]])
        return nil;
    
    return (TGPassportDecryptedForm *)_form;
}

+ (NSString *)urlString:(NSString *)urlString byAppendingQueryString:(NSString *)queryString
{
    if (queryString.length == 0)
        return urlString;
    
    return [NSString stringWithFormat:@"%@%@%@", urlString, [urlString rangeOfString:@"?"].length > 0 ? @"&" : @"?", queryString];
}

#pragma mark - Setup Signals

- (SSignal *)passwordSignal
{
    TGPassportFormRequest *request = _request;
    SVariable *twoStepConfigVar = _twoStepConfig;
    SVariable *passwordVar = _passwordVariable;
    SVariable *failedVar = _failedVariable;
    return [[[twoStepConfigVar.signal ignoreRepeated] mapToSignal:^SSignal *(TGTwoStepConfig *twoStepConfig) {
        return [[failedVar.signal take:1] map:^id(NSNumber *failed) {
            return @[twoStepConfig, failed];
        }];
    }] mapToSignal:^SSignal *(NSArray *next)
    {
        TGTwoStepConfig *twoStepConfig = next.firstObject;
        bool failed = [next.lastObject boolValue];
        
        if (!twoStepConfig.hasPassword)
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
                settingsSignal = [TGTwoStepVerifyPasswordSignal passwordHashSettings:passwordHash secretPasswordHash:secretPasswordHash config:twoStepConfig];
            
            SSignal *statusSignal = settingsSignal != nil ? [SSignal single:[TGPassportPasswordRequest requestWithState:TGPassportPasswordRequestStateLoggingInProgress settings:nil hasRecovery:twoStepConfig.hasRecovery passwordHint:twoStepConfig.currentHint error:nil]] : [SSignal single:[TGPassportPasswordRequest requestWithState:TGPassportPasswordRequestStateWaitingForEntry settings:nil hasRecovery:twoStepConfig.hasRecovery passwordHint:twoStepConfig.currentHint error:nil]];
            
            SSignal *proceedSignal = settingsSignal != nil ? [SSignal single:nil] : passwordVar.signal;
            if (failed)
            {
                [failedVar set:[SSignal single:@false]];
                statusSignal = [SSignal single:[TGPassportPasswordRequest requestWithState:TGPassportPasswordRequestStateAccessDenied settings:nil hasRecovery:twoStepConfig.hasRecovery passwordHint:twoStepConfig.currentHint error:nil]];
                proceedSignal = passwordVar.signal;
            }
            
            return [statusSignal then:[proceedSignal mapToSignal:^SSignal *(NSString *password)
            {
                NSData *passwordHash = nil;
                if (settingsSignal == nil)
                    settingsSignal = [TGTwoStepVerifyPasswordSignal passwordSettings:password config:twoStepConfig outPasswordHash:&passwordHash];
                
                SSignal *initial = [SSignal single:[TGPassportPasswordRequest requestWithState:TGPassportPasswordRequestStateLoggingInProgress settings:nil hasRecovery:twoStepConfig.hasRecovery passwordHint:twoStepConfig.currentHint error:nil]];
                
                SSignal *process = [[[settingsSignal onNext:^(TGPasswordSettings *next)
                {
                    TGDispatchOnMainThread(^
                    {
                        if (passwordHash != nil)
                        {
                            NSData *secretPasswordHash = [TGTwoStepUtils securePasswordHashWithPassword:password secureAlgo:next.secureAlgo];
                            [TGPassportSignals storePasswordHash:passwordHash secretPasswordHash:secretPasswordHash];
                        }
                    });
                }] mapToSignal:^SSignal *(TGPasswordSettings *settings)
                {
                    int64_t calculatedHash =  [TGPassportSignals secureSecretId:settings.secret];
                    if (settings.secret.length == 0)
                    {
                        NSData *secret = [TGPassportSignals secretWithSecretRandom:twoStepConfig.secureRandom];
                        return [[TGTwoStepSetPaswordSignal setSecureSecret:secret nextSecureAlgo:twoStepConfig.nextSecureAlgo currentPassword:settings.password currentAlgo:twoStepConfig.currentAlgo recoveryEmail:settings.email srpId:twoStepConfig.srpId srpB:twoStepConfig.srpB] mapToSignal:^SSignal *(TGTwoStepConfig *newTwoStepConfig)
                        {
                            return [[TGTwoStepVerifyPasswordSignal passwordSettings:password config:newTwoStepConfig] mapToSignal:^SSignal *(TGPasswordSettings *newSettings)
                            {
                                return [SSignal single:[TGPassportPasswordRequest requestWithState:TGPassportPasswordRequestStateAuthorized settings:newSettings hasRecovery:newTwoStepConfig.hasRecovery passwordHint:newTwoStepConfig.currentHint error:nil]];
                            }];
                        }];
                    }
                    else if (calculatedHash != settings.secretHash)
                    {
                        return [[TGTwoStepSetPaswordSignal setSecureSecret:nil nextSecureAlgo:twoStepConfig.nextSecureAlgo currentPassword:settings.password currentAlgo:twoStepConfig.currentAlgo recoveryEmail:settings.email srpId:twoStepConfig.srpId srpB:twoStepConfig.srpB] mapToSignal:^SSignal *(TGTwoStepConfig *newTwoStepConfig)
                        {
                            NSData *secret = [TGPassportSignals secretWithSecretRandom:newTwoStepConfig.secureRandom];
                            return [[TGTwoStepSetPaswordSignal setSecureSecret:secret nextSecureAlgo:newTwoStepConfig.nextSecureAlgo currentPassword:settings.password currentAlgo:newTwoStepConfig.currentAlgo recoveryEmail:settings.email srpId:newTwoStepConfig.srpId srpB:newTwoStepConfig.srpB] mapToSignal:^SSignal *(TGTwoStepConfig *newTwoStepConfig)
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
                    
                    if ([error rangeOfString:@"PASSWORD_HASH_INVALID"].location != NSNotFound || [error rangeOfString:@"SRP_PASSWORD_CHANGED"].location != NSNotFound)
                    {
                        [TGPassportSignals clearStoredPasswordHashes];
                        [passwordVar set:[SSignal never]];
                        [twoStepConfigVar set:[TGTwoStepConfigSignal twoStepConfig]];
                        if (automaticLogin)
                        {
                            return [SSignal single:[TGPassportPasswordRequest requestWithState:TGPassportPasswordRequestStateWaitingForEntry settings:nil hasRecovery:twoStepConfig.hasRecovery passwordHint:twoStepConfig.currentHint error:nil]];
                        }
                        else
                        {
                            [failedVar set:[SSignal single:@true]];
                            return [SSignal single:[TGPassportPasswordRequest requestWithState:TGPassportPasswordRequestStateAccessDenied settings:nil hasRecovery:twoStepConfig.hasRecovery passwordHint:twoStepConfig.currentHint error:error]];
                        }
                    }
                    else if ([error rangeOfString:@"SRP_ID_INVALID"].location != NSNotFound)
                    {
                        [twoStepConfigVar set:[TGTwoStepConfigSignal twoStepConfig]];
                        return [SSignal complete];
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

- (SSignal *)formRequestSignal
{
    return [[TGPassportSignals authorizationFormForBotId:_request.botId scope:_request.scope publicKey:_request.publicKey] catch:^SSignal *(id error) {
        return [SSignal single:error];
    }];
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
    bool editing = _request == nil;
    
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
                _setupPasswordView.request = !editing;
                
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
                
                _headerView.logoHidden = !editing || (int)TGScreenSize().height == 480;
                _headerView.avatarHidden = editing || (int)TGScreenSize().height == 480;
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

                TGHeaderCollectionItem *headerItem = [[TGHeaderCollectionItem alloc] initWithTitle:!editing ? TGLocalized(@"Passport.RequestedInformation") : TGLocalized(@"Passport.PassportInformation")];
                [_mainSection addItem:headerItem];
                
                void (^setupIdentityItem)(bool, TGPassportRequiredType *, NSArray *, TGPassportDecryptedValue *, TGPassportDecryptedValue *, bool, bool) = ^(bool oneOf, TGPassportRequiredType *type, NSArray *acceptedTypes, TGPassportDecryptedValue *detailsValue, TGPassportDecryptedValue *documentValue, bool includesDetails, bool exclusive)
                {
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
                    if (!editing && !oneOf)
                    {
                        singleType = true;
                        title = [TGPassportRequestController titleForType:type.type];
                        uploadSubtitle = [TGPassportRequestController uploadSubtitleForType:type.type];
                    }
                    else if (oneOf)
                    {
                        if (acceptedTypes.count == 2)
                        {
                            title = [NSString stringWithFormat:TGLocalized(@"Passport.FieldOneOf.Or"), [TGPassportRequestController titleForType:[(TGPassportRequiredType *)acceptedTypes[0] type]], [TGPassportRequestController titleForType:[(TGPassportRequiredType *)acceptedTypes[1] type]]];
                        }
                        if (!exclusive)
                            uploadSubtitle = [TGPassportRequestController uploadSubtitleWithFormat:TGLocalized(@"Passport.Identity.UploadOneOfScan") types:acceptedTypes];
                    }
                    
                    bool selfieRequired = false;
                    bool translationRequired = false;
                    if (type.type != TGPassportTypeUndefined)
                    {
                        TGPassportRequiredType *requiredType = [self requiredTypeForType:type.type];
                        selfieRequired = requiredType.selfieRequired;
                        translationRequired = requiredType.translationRequired;
                    }
                    else
                    {
                        TGPassportRequiredType *requiredType = [self requiredTypeForType:((TGPassportRequiredType *)acceptedTypes.firstObject).type];
                        selfieRequired = requiredType.selfieRequired;
                        translationRequired = requiredType.translationRequired;
                    }
                    bool nativeNames = false;
                    if (type.type == TGPassportTypePersonalDetails || includesDetails)
                    {
                        TGPassportRequiredType *requiredType = [self requiredTypeForType:TGPassportTypePersonalDetails];
                        nativeNames = requiredType.includeNativeNames;
                    }
                    
                    TGPassportFieldCollectionItem *item = [[TGPassportFieldCollectionItem alloc] initWithTitle:title action:@selector(identityPressed:)];
                    item.type = type;
                    item.acceptedTypes = acceptedTypes;
                    
                    bool checked = !editing;
                    if (editing)
                    {
                        NSArray *types = [TGPassportSignals identityTypes];
                        NSMutableArray *components = [[NSMutableArray alloc] init];
                        for (TGPassportDecryptedValue *value in self.decryptedForm.values)
                        {
                            if ([types containsObject:@(value.type)])
                            {
                                NSString *typeName = [TGPassportIdentityController documentDisplayNameForType:value.type];
                                [components addObject:typeName];
                            }
                        }
                        
                        if (components.count > 0)
                            item.subtitle = [components componentsJoinedByString:@", "];
                        else
                            item.subtitle = uploadSubtitle;
                    }
                    else
                    {
                        TGPassportPersonalDetailsData *detailsData = (TGPassportPersonalDetailsData *)detailsValue.data;
                        TGPassportDocumentData *documentData = (TGPassportDocumentData *)documentValue.data;
                        if (type.type == TGPassportTypePersonalDetails)
                        {
                            if (!detailsData.isCompleted)
                            {
                                item.subtitle = TGLocalized(@"Passport.FieldIdentityDetailsHelp");
                                checked = false;
                            }
                            else
                            {
                                if (nativeNames && !detailsData.hasNativeName && [self requiresNativeNameForCountry:detailsData.residenceCountryCode])
                                {
                                    item.subtitle = TGLocalized(@"Passport.FieldIdentityDetailsHelp");
                                    checked = false;
                                }
                                else
                                {
                                    NSMutableArray *components = [[NSMutableArray alloc] init];
                                    NSMutableArray *nameComponents = [[NSMutableArray alloc] init];
                                    if (nativeNames && detailsData.firstNameNative.length > 0)
                                    {
                                        if (detailsData.firstNameNative.length > 0)
                                            [nameComponents addObject:detailsData.firstNameNative];
                                        if (detailsData.lastNameNative.length > 0)
                                            [nameComponents addObject:detailsData.lastNameNative];
                                    }
                                    else
                                    {
                                        if (detailsData.firstName.length > 0)
                                            [nameComponents addObject:detailsData.firstName];
                                        if (detailsData.lastName.length > 0)
                                            [nameComponents addObject:detailsData.lastName];
                                    }
                                    [components addObject:[nameComponents componentsJoinedByString:@" "]];
                                    
                                    NSString *birthdate = [NSDateFormatter localizedStringFromDate:[[TGPassportIdentityController dateFormatter] dateFromString:detailsData.birthDate] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
                                    if (birthdate != nil)
                                        [components addObject:birthdate];
                                    
                                    item.subtitle = [components componentsJoinedByString:@", "];
                                }
                            }
                        }
                        else
                        {
                            if (documentValue == nil || !documentData.isCompleted)
                            {
                                item.subtitle = uploadSubtitle;
                                checked = false;
                            }
                            else if (translationRequired && documentValue.translation.count == 0)
                            {
                                item.subtitle = TGLocalized(@"Passport.FieldIdentityTranslationHelp");
                                checked = false;
                            }
                            else if (selfieRequired && documentValue.selfie == nil)
                            {
                                item.subtitle = TGLocalized(@"Passport.FieldIdentitySelfieHelp");
                                checked = false;
                            }
                            else if (includesDetails && (!detailsData.isCompleted || (nativeNames && detailsData != nil && !detailsData.hasNativeName && [self requiresNativeNameForCountry:detailsData.residenceCountryCode])))
                            {
                                item.subtitle = TGLocalized(@"Passport.FieldIdentityDetailsHelp");
                                checked = false;
                            }
                            else
                            {
                                NSMutableArray *components = [[NSMutableArray alloc] init];
                                if (!singleType)
                                    [components addObject:[TGPassportIdentityController documentDisplayNameForType:documentValue.type]];
                                
                                NSMutableArray *nameComponents = [[NSMutableArray alloc] init];
                                if (detailsData.firstName.length > 0)
                                    [nameComponents addObject:detailsData.firstName];
                                if (detailsData.lastName.length > 0)
                                    [nameComponents addObject:detailsData.lastName];
                                
                                if (nameComponents.count > 0)
                                    [components addObject:[nameComponents componentsJoinedByString:@" "]];
                                
                                if (documentData.documentNumber.length > 0)
                                    [components addObject:documentData.documentNumber];
                                
                                item.subtitle = [components componentsJoinedByString:@", "];
                            }
                        }
                    }
                    
                    if (errors.count > 0)
                        checked = false;
                    item.errors = errors;
                    item.isChecked = checked;
                    item.isRequired = errors.count > 0;
                    
                    item.deselectAutomatically = true;
                    [_mainSection addItem:item];
                };
                
                void (^setupAddressItem)(bool, TGPassportRequiredType *, NSArray *, TGPassportDecryptedValue *, TGPassportDecryptedValue *, bool, bool) = ^(bool oneOf, TGPassportRequiredType *type, NSArray *acceptedTypes, TGPassportDecryptedValue *addressValue, TGPassportDecryptedValue *documentValue, bool includesAddress, bool exclusive)
                {
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
                    NSString *uploadSubtitle = TGLocalized(@"Passport.FieldAddressUploadHelp");
                    bool singleType = false;
                    if (!editing && !oneOf)
                    {
                        singleType = true;
                        title = [TGPassportRequestController titleForType:type.type];
                        uploadSubtitle = [TGPassportRequestController uploadSubtitleForType:type.type];
                    }
                    else if (oneOf)
                    {
                        if (acceptedTypes.count == 2)
                        {
                            title = [NSString stringWithFormat:TGLocalized(@"Passport.FieldOneOf.Or"), [TGPassportRequestController titleForType:[(TGPassportRequiredType *)acceptedTypes[0] type]], [TGPassportRequestController titleForType:[(TGPassportRequiredType *)acceptedTypes[1] type]]];
                        }
                        if (!exclusive)
                            uploadSubtitle = [TGPassportRequestController uploadSubtitleWithFormat:TGLocalized(@"Passport.Address.UploadOneOfScan") types:acceptedTypes];
                    }
                    
                    bool translationRequired = false;
                    if (type.type != TGPassportTypeUndefined)
                    {
                        TGPassportRequiredType *requiredType = [self requiredTypeForType:type.type];
                        translationRequired = requiredType.translationRequired;
                    }
                    else
                    {
                        TGPassportRequiredType *requiredType = [self requiredTypeForType:((TGPassportRequiredType *)acceptedTypes.firstObject).type];
                        translationRequired = requiredType.translationRequired;
                    }
                    TGPassportFieldCollectionItem *item = [[TGPassportFieldCollectionItem alloc] initWithTitle:title action:@selector(addressPressed:)];
                    item.type = type;
                    item.acceptedTypes = acceptedTypes;
                    
                    bool checked = !editing;
                    if (editing)
                    {
                        NSArray *types = [TGPassportSignals addressTypes];
                        NSMutableArray *components = [[NSMutableArray alloc] init];
                        for (TGPassportDecryptedValue *value in self.decryptedForm.values)
                        {
                            if ([types containsObject:@(value.type)])
                            {
                                NSString *typeName = [TGPassportAddressController documentDisplayNameForType:value.type];
                                [components addObject:typeName];
                            }
                        }
                        
                        if (components.count > 0)
                            item.subtitle = [components componentsJoinedByString:@", "];
                        else
                            item.subtitle = uploadSubtitle;
                    }
                    else
                    {
                        TGPassportAddressData *addressData = (TGPassportAddressData *)addressValue.data;
                        if (type.type == TGPassportTypeAddress)
                        {
                            if (!addressData.isCompleted)
                            {
                                item.subtitle = TGLocalized(@"Passport.FieldAddressHelp");
                                checked = false;
                            }
                            else
                            {
                                NSMutableArray *components = [[NSMutableArray alloc] init];
                                if (!singleType)
                                    [components addObject:[TGPassportAddressController documentDisplayNameForType:documentValue.type]];
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
                                    NSString *countryName = [TGLoginCountriesController localizedCountryNameByCountryId:addressData.countryCode code:NULL];
                                    if (countryName.length > 0)
                                        [components addObject:countryName];
                                }
                                
                                item.subtitle = [components componentsJoinedByString:@", "];
                            }
                        }
                        else
                        {
                            if (documentValue == nil)
                            {
                                item.subtitle = uploadSubtitle;
                                checked = false;
                            }
                            else if (translationRequired && documentValue.translation.count == 0)
                            {
                                item.subtitle = TGLocalized(@"Passport.FieldAddressTranslationHelp");
                                checked = false;
                            }
                            else if (includesAddress && !addressData.isCompleted)
                            {
                                item.subtitle = TGLocalized(@"Passport.FieldAddressHelp");
                                checked = false;
                            }
                            else
                            {
                                if (includesAddress)
                                {
                                    NSMutableArray *components = [[NSMutableArray alloc] init];
                                    if (!singleType)
                                        [components addObject:[TGPassportAddressController documentDisplayNameForType:documentValue.type]];
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
                                        NSString *countryName = [TGLoginCountriesController localizedCountryNameByCountryId:addressData.countryCode code:NULL];
                                        if (countryName.length > 0)
                                            [components addObject:countryName];
                                    }
                                    
                                    item.subtitle = [components componentsJoinedByString:@", "];
                                }
                                else if (documentValue.files.count > 0)
                                {
                                    item.subtitle = [effectiveLocalization() getPluralized:@"Passport.Scans" count:(int32_t)documentValue.files.count];
                                }
                            }
                        }
                    }
                    
                    if (errors.count > 0)
                        checked = false;
                    item.errors = errors;
                    item.isChecked = checked;
                    item.isRequired = errors.count > 0;
                    
                    item.deselectAutomatically = true;
                    [_mainSection addItem:item];
                };
                
                void (^setupPhoneItem)(TGPassportRequiredType *, TGPassportDecryptedValue *) = ^(TGPassportRequiredType *type, TGPassportDecryptedValue *value)
                {
                    TGPassportFieldCollectionItem *item = [[TGPassportFieldCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.FieldPhone") action:@selector(phonePressed:)];
                    item.type = type;
                    
                    if (value != nil)
                    {
                        TGPassportPhoneData *phoneData = (TGPassportPhoneData *)value.plainData;
                        item.subtitle = [TGPhoneUtils formatPhone:phoneData.phone forceInternational:true];
                        item.isChecked = !editing;
                    }
                    else
                    {
                        item.subtitle = TGLocalized(@"Passport.FieldPhoneHelp");
                    }
                    item.deselectAutomatically = true;
                    [_mainSection addItem:item];
                };
                
                void (^setupEmailItem)(TGPassportRequiredType *, TGPassportDecryptedValue *) = ^(TGPassportRequiredType *type, TGPassportDecryptedValue *value)
                {
                    TGPassportFieldCollectionItem *item = [[TGPassportFieldCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.FieldEmail") action:@selector(emailPressed:)];
                    item.type = type;
                    
                    if (value != nil)
                    {
                        TGPassportEmailData *emailData = (TGPassportEmailData *)value.plainData;
                        item.subtitle = emailData.email;
                        item.isChecked = !editing;
                    }
                    else
                    {
                        item.subtitle = TGLocalized(@"Passport.FieldEmailHelp");
                    }
                    item.deselectAutomatically = true;
                    [_mainSection addItem:item];
                };
                
                if (editing)
                {
                    setupIdentityItem(true, nil, [TGPassportRequiredType requiredIdentityTypes], nil, nil, false, true);
                    setupAddressItem(true, nil, [TGPassportRequiredType requiredAddressTypes], nil, nil, false, true);
                    setupPhoneItem([TGPassportRequiredType requiredTypeForType:TGPassportTypePhone], [self.decryptedForm valueForType:TGPassportTypePhone]);
                    setupEmailItem([TGPassportRequiredType requiredTypeForType:TGPassportTypeEmail], [self.decryptedForm valueForType:TGPassportTypeEmail]);
                    
                    if (_deleteSection != nil)
                    {
                        if (self.decryptedForm.hasValues)
                            [_deleteSection addItem:_deleteItem];
                        else
                            [_deleteSection deleteItem:_deleteItem];
                    }
                }
                else
                {
                    TGPassportRequiredType *requiredPersonalDetails = nil;
                    NSInteger requiredIdentityTypes = 0;
                    TGPassportRequiredType *requiredAddress = false;
                    NSInteger requiredAddressTypes = 0;
                    
                    for (NSObject<TGPassportRequiredType> *type in self.decryptedForm.requiredTypes)
                    {
                        if ([type isKindOfClass:[TGPassportRequiredType class]])
                        {
                            TGPassportRequiredType *requiredType = (TGPassportRequiredType *)type;
                            if (requiredType.type == TGPassportTypePersonalDetails)
                                requiredPersonalDetails = requiredType;
                            else if (requiredType.type == TGPassportTypeAddress)
                                requiredAddress = requiredType;
                            else if ([TGPassportSignals isIdentityType:requiredType.type])
                                requiredIdentityTypes++;
                            else if ([TGPassportSignals isAddressType:requiredType.type])
                                requiredAddressTypes++;
                        }
                        else if ([type isKindOfClass:[TGPassportRequiredOneOfTypes class]])
                        {
                            bool isAddress = false;
                            NSArray *types = ((TGPassportRequiredOneOfTypes *)type).types;
                            for (TGPassportRequiredType *type in types)
                            {
                                if ([TGPassportSignals isAddressType:type.type])
                                    isAddress = true;
                            }
                            
                            if (!isAddress)
                                requiredIdentityTypes++;
                            else
                                requiredAddressTypes++;
                        }
                    }
                    
                    TGPassportDecryptedValue *personalDetails = requiredPersonalDetails ? [self.decryptedForm valueForType:TGPassportTypePersonalDetails] : nil;
                    TGPassportDecryptedValue *addressDetalis = requiredAddress ? [self.decryptedForm valueForType:TGPassportTypeAddress] : nil;
                    
                    for (NSObject<TGPassportRequiredType> *type in self.decryptedForm.requiredTypes)
                    {
                        if ([type isKindOfClass:[TGPassportRequiredType class]])
                        {
                            TGPassportRequiredType *requiredType = (TGPassportRequiredType *)type;
                            if (requiredType.type == TGPassportTypePhone)
                            {
                                setupPhoneItem(requiredType, [self.decryptedForm valueForType:requiredType.type]);
                            }
                            else if (requiredType.type == TGPassportTypeEmail)
                            {
                                setupEmailItem(requiredType, [self.decryptedForm valueForType:requiredType.type]);
                            }
                            else if ([TGPassportSignals isIdentityType:requiredType.type])
                            {
                                TGPassportDecryptedValue *detailsValue = requiredType.type == TGPassportTypePersonalDetails || requiredIdentityTypes == 1 ? personalDetails : nil;
                                TGPassportDecryptedValue *documentValue = requiredType.type != TGPassportTypePersonalDetails ? [self.decryptedForm valueForType:requiredType.type] : nil;
                                if (requiredType.type != TGPassportTypePersonalDetails || requiredIdentityTypes > 1 || requiredIdentityTypes == 0)
                                    setupIdentityItem(false, requiredType, nil, detailsValue, documentValue, requiredPersonalDetails != nil && requiredIdentityTypes == 1, requiredIdentityTypes == 1);
                            }
                            else if ([TGPassportSignals isAddressType:requiredType.type])
                            {
                                TGPassportDecryptedValue *detailsValue = requiredType.type == TGPassportTypeAddress || requiredAddressTypes == 1 ? addressDetalis : nil;
                                TGPassportDecryptedValue *documentValue = requiredType.type != TGPassportTypeAddress ? [self.decryptedForm valueForType:requiredType.type] : nil;
                                if (requiredType.type != TGPassportTypeAddress || requiredAddressTypes > 1 || requiredAddressTypes == 0)
                                    setupAddressItem(false, requiredType, nil, detailsValue, documentValue, requiredAddress != nil && requiredAddressTypes == 1, requiredAddressTypes == 1);
                            }
                        }
                        else if ([type isKindOfClass:[TGPassportRequiredOneOfTypes class]])
                        {
                            NSArray *types = ((TGPassportRequiredOneOfTypes *)type).types;
                            bool isAddress = false;
                            TGPassportDecryptedValue *documentValue = nil;
                            bool complete = false;
                            for (TGPassportRequiredType *type in types)
                            {
                                if ([TGPassportSignals isAddressType:type.type])
                                    isAddress = true;
                                
                                if (documentValue == nil || !complete)
                                {
                                    TGPassportDecryptedValue *value = [self.decryptedForm valueForType:type.type];
                                    if (value != nil)
                                    {
                                        NSInteger bestScore = type.translationRequired + type.selfieRequired * 2;
                                        NSInteger valueScore = (type.translationRequired ? value.translation.count > 0 : 0) + (type.selfieRequired && value.selfie != nil ? 2 : 0);
                                        if (documentValue == nil || bestScore == valueScore)
                                            documentValue = value;
                                        
                                        complete = valueScore == bestScore;
                                    }
                                }
                            }
                            
                            if (!isAddress)
                                setupIdentityItem(true, nil, types, personalDetails, documentValue, requiredPersonalDetails != nil && requiredIdentityTypes == 1, requiredIdentityTypes == 1);
                            else
                                setupAddressItem(true, nil, types, addressDetalis, documentValue, requiredAddress != nil && requiredAddressTypes == 1, requiredAddressTypes == 1);
                        }
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
                    [_mainSection addItem:_privacyItem];
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

- (TGPassportRequiredType *)requiredTypeForType:(TGPassportType)passportType
{
    for (NSObject<TGPassportRequiredType> *type in self.decryptedForm.requiredTypes)
    {
        if ([type isKindOfClass:[TGPassportRequiredType class]])
        {
            TGPassportRequiredType *requiredType = (TGPassportRequiredType *)type;
            if (requiredType.type == passportType)
                return requiredType;
        }
        else if ([type isKindOfClass:[TGPassportRequiredOneOfTypes class]])
        {
            NSArray *types = ((TGPassportRequiredOneOfTypes *)type).types;
            for (TGPassportRequiredType *requiredType in types)
            {
                if (requiredType.type == passportType)
                    return requiredType;
            }
        }
    }
    return nil;
}

#pragma mark - Value Update

- (void)updateDocumentValue:(TGPassportDecryptedValue *)details detailsType:(TGPassportType)detailsType document:(TGPassportDecryptedValue *)document type:(TGPassportType)type errors:(TGPassportErrors *)errors
{
    TGPassportDecryptedForm *form = [self decryptedForm];
    if (form == nil)
        return;
    
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSMutableArray *removeTypes = [[NSMutableArray alloc] init];
    
    if (details != nil)
        [values addObject:details];
    
    if (document != nil)
        [values addObject:document];
    else if (type != detailsType || details == nil)
        [removeTypes addObject:@(type)];
    
    if (errors != nil)
        _errors = errors;
    
    form = [form updateWithValues:values removeValueTypes:removeTypes];
    _form = form;
    [self reloadItems];
}

- (void)updateSimpleValue:(TGPassportDecryptedValue *)value type:(TGPassportType)type
{
    TGPassportDecryptedForm *form = [self decryptedForm];
    if (form == nil)
        return;
    
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSMutableArray *removeTypes = [[NSMutableArray alloc] init];
    
    if (value != nil)
        [values addObject:value];
    else
        [removeTypes addObject:@(type)];
    
    form = [form updateWithValues:values removeValueTypes:removeTypes];
    _form = form;
    [self reloadItems];
}

#pragma mark -

- (void)documentFieldPressed:(TGPassportFieldCollectionItem *)item allTypes:(NSArray *)allTypes detailsType:(TGPassportType)detailsType action:(void (^)(TGPassportType, TGPassportDecryptedValue *, TGPassportDecryptedValue *, bool, TGMenuSheetController *))action
{
    if (_request == nil)
    {
        NSMutableArray *options = [[NSMutableArray alloc] init];
        for (NSNumber *nType in allTypes)
        {
            TGPassportType type = (TGPassportType)nType.integerValue;
            TGPassportDecryptedValue *detailsValue = type == detailsType ? [self.decryptedForm valueForType:type] : nil;
            TGPassportDecryptedValue *documentValue = type != detailsType ? [self.decryptedForm valueForType:type] : nil;
            bool hasValue = type == detailsType ? (detailsValue != nil) : (documentValue != nil);
            NSString *title = [TGPassportRequestController settingsTitleForType:type exists:hasValue];
            bool documentOnly = type != detailsType;
            
            TGPassportDocumentOption *option = [TGPassportDocumentOption optionWithTitle:title action:^(TGMenuSheetController *controller)
            {
                action(type, detailsValue, documentValue, documentOnly, controller);
            }];
            [options addObject:option];
        }
        [self presentDocumentOptionsMenu:options item:item];
    }
    else
    {
        TGPassportDecryptedValue *detailsValue = nil;
        TGPassportDecryptedValue *documentValue = nil;
        
        TGPassportRequiredType *requiredDetails = nil;
        NSInteger requiredTypes = 0;
        
        for (NSObject<TGPassportRequiredType> *type in self.decryptedForm.requiredTypes)
        {
            if ([type isKindOfClass:[TGPassportRequiredType class]])
            {
                TGPassportRequiredType *requiredType = (TGPassportRequiredType *)type;
                if (requiredType.type == detailsType)
                    requiredDetails = requiredType;
                else if ([allTypes containsObject:@(requiredType.type)])
                    requiredTypes++;
            }
            else if ([type isKindOfClass:[TGPassportRequiredOneOfTypes class]])
            {
                NSArray *types = ((TGPassportRequiredOneOfTypes *)type).types;
                for (TGPassportRequiredType *type in types)
                {
                    if ([allTypes containsObject:@(type.type)])
                    {
                        requiredTypes++;
                        break;
                    }
                }
            }
        }
        
        if (item.type == TGPassportTypeUndefined)
        {
            bool complete = false;
            for (TGPassportRequiredType *type in item.acceptedTypes)
            {
                if (documentValue == nil || !complete)
                {
                    TGPassportDecryptedValue *value = [self.decryptedForm valueForType:type.type];
                    if (value != nil)
                    {
                        NSInteger bestScore = type.translationRequired + type.selfieRequired * 2;
                        NSInteger valueScore = (type.translationRequired ? value.translation.count > 0 : 0) + (type.selfieRequired && value.selfie != nil ? 2 : 0);
                        if (documentValue == nil || bestScore == valueScore)
                            documentValue = value;
                        
                        complete = valueScore == bestScore;
                    }
                }
            }
            if (requiredDetails != nil)
                detailsValue = [self.decryptedForm valueForType:detailsType];
        }
        else
        {
            TGPassportDecryptedValue *value = [self.decryptedForm valueForType:item.type.type];
            if (item.type.type == detailsType)
                detailsValue = value;
            else
                documentValue = value;
            
            if (detailsValue == nil && requiredDetails != nil && requiredTypes == 1)
                detailsValue = [self.decryptedForm valueForType:detailsType];
        }
        
        TGPassportType type = item.type.type;
        bool documentOnly = type != detailsType && (requiredDetails == nil || requiredTypes > 1);
        
        if (documentValue == nil && type != detailsType)
        {
            if (item.acceptedTypes.count < 2)
            {
                TGPassportType finalType = type;
                if (finalType == TGPassportTypeUndefined)
                    finalType = ((TGPassportRequiredType *)item.acceptedTypes.firstObject).type;
                action(finalType, detailsValue, nil, documentOnly, nil);
            }
            else
            {
                NSMutableArray *options = [[NSMutableArray alloc] init];
                
                for (TGPassportRequiredType *type in item.acceptedTypes)
                {
                    NSString *title = [TGPassportRequestController titleForType:type.type];
                    
                    TGPassportDocumentOption *option = [TGPassportDocumentOption optionWithTitle:title action:^(TGMenuSheetController *controller)
                    {
                        action(type.type, detailsValue, documentValue, documentOnly, controller);
                    }];
                    [options addObject:option];
                }
                
                [self presentDocumentOptionsMenu:options item:item];
            }
        }
        else
        {
            TGPassportType finalType = type;
            if (finalType != detailsType)
                finalType = documentValue.type;
            action(finalType, detailsValue, documentValue, documentOnly, nil);
        }
    }
}

- (void)identityPressed:(TGPassportFieldCollectionItem *)item
{
    __weak TGPassportRequestController *weakSelf = self;
    [self documentFieldPressed:item allTypes:[TGPassportSignals identityTypes] detailsType:TGPassportTypePersonalDetails action:^(TGPassportType type, TGPassportDecryptedValue *detailsValue, TGPassportDecryptedValue *documentValue, bool documentOnly, TGMenuSheetController *menuController)
    {
        __strong TGPassportRequestController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            NSMutableArray *filteredAcceptedTypes = [[NSMutableArray alloc] init];
            for (TGPassportRequiredType *acceptedType in item.acceptedTypes)
            {
                if ([strongSelf.decryptedForm valueForType:acceptedType.type].data == nil)
                    [filteredAcceptedTypes addObject:acceptedType];
            }
            [strongSelf identityDocumentTypePressed:type acceptedTypes:filteredAcceptedTypes item:item detailsValue:detailsValue documentValue:documentValue documentOnly:documentOnly menuController:menuController];
        }
    }];
}

- (void)addressPressed:(TGPassportFieldCollectionItem *)item
{
    __weak TGPassportRequestController *weakSelf = self;
    [self documentFieldPressed:item allTypes:[TGPassportSignals addressTypes] detailsType:TGPassportTypeAddress action:^(TGPassportType type, TGPassportDecryptedValue *detailsValue, TGPassportDecryptedValue *documentValue, bool documentOnly, TGMenuSheetController *menuController)
    {
        __strong TGPassportRequestController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf addressDocumentTypePressed:type item:item addressValue:detailsValue documentValue:documentValue documentOnly:documentOnly menuController:menuController];
    }];
}

- (void)phonePressed:(TGPassportFieldCollectionItem *)item
{
    TGPassportType type = item.type.type;
    TGPassportDecryptedValue *phoneValue = [self.decryptedForm valueForType:type];
    
    __weak TGPassportRequestController *weakSelf = self;
    if (phoneValue == nil)
    {
        TGPassportPhoneController *controller = [[TGPassportPhoneController alloc] initWithSettings:_passwordSettingsVariable];
        controller.completionBlock = ^(TGPassportDecryptedValue *phone)
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf updateSimpleValue:phone type:type];
        };
        [self pushViewController:controller animated:true];
    }
    else
    {
        [self presentDeleteMenu:nil buttonTitle:TGLocalized(@"Passport.Phone.Delete") item:item action:^
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf->_saveDisposable setDisposable:[[TGPassportSignals deleteSecureValueTypes:@[@(type)]] startWithNext:nil]];
                [strongSelf updateSimpleValue:nil type:type];
            }
        }];
    }
}

- (void)emailPressed:(TGPassportFieldCollectionItem *)item
{
    TGPassportType type = item.type.type;
    TGPassportDecryptedValue *emailValue = [self.decryptedForm valueForType:type];
    
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
                        [strongSelf updateSimpleValue:email type:type];
                };
                [strongSelf pushViewController:controller animated:true];
            }
        }];
    }
    else
    {
        [self presentDeleteMenu:nil buttonTitle:TGLocalized(@"Passport.Email.Delete") item:item action:^
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf->_saveDisposable setDisposable:[[TGPassportSignals deleteSecureValueTypes:@[@(type)]] startWithNext:nil]];
                [strongSelf updateSimpleValue:nil type:type];
            }
        }];
    }
}

- (void)identityDocumentTypePressed:(TGPassportType)type acceptedTypes:(NSArray *)acceptedTypes item:(TGCollectionItem *)item detailsValue:(TGPassportDecryptedValue *)detailsValue documentValue:(TGPassportDecryptedValue *)documentValue documentOnly:(bool)documentOnly menuController:(TGMenuSheetController *)menuController
{
    bool selfieRequired = false;
    bool translationRequired = false;
    bool nativeNames = false;
    
    TGPassportRequiredType *requiredType = [self requiredTypeForType:type];
    if (requiredType != nil)
    {
        selfieRequired = requiredType.selfieRequired;
        translationRequired = requiredType.translationRequired;
        if (requiredType.type == TGPassportTypePersonalDetails)
            nativeNames = requiredType.includeNativeNames;
    }
    if (!documentOnly && type != TGPassportTypePersonalDetails)
    {
        TGPassportRequiredType *requiredType = [self requiredTypeForType:TGPassportTypePersonalDetails];
        nativeNames = requiredType.includeNativeNames;
    }
    
    if (type == TGPassportTypePersonalDetails || documentValue != nil)
    {
        [menuController dismissAnimated:true];
        
        TGPassportPersonalDetailsData *detailsData = nil;
        if ([detailsValue.data isKindOfClass:[TGPassportPersonalDetailsData class]])
            detailsData = (TGPassportPersonalDetailsData *)detailsValue.data;
        
        __weak TGPassportRequestController *weakSelf = self;
        TGPassportIdentityController *controller = [[TGPassportIdentityController alloc] initWithType:type details:detailsValue document:documentValue documentOnly:documentOnly selfie:selfieRequired translation:translationRequired nativeNames:nativeNames editing:_request == nil settings:_passwordSettingsVariable errors:_errors];
        [controller setLanguagesSignal:_langMapVariable.signal];
        if (_request != nil && selfieRequired && documentValue != nil && documentValue.selfie == nil)
            [controller setScrollToSelfie];
        else if (_request != nil && translationRequired && documentValue != nil && documentValue.translation.count == 0)
            [controller setScrollToTranslation];
        else if (_request != nil && nativeNames && detailsData != nil && !detailsData.hasNativeName && [self requiresNativeNameForCountry:detailsData.residenceCountryCode])
            [controller setScrollToNativeNames];
        controller.acceptedTypes = acceptedTypes;
        controller.completionBlock = ^(TGPassportDecryptedValue *details, TGPassportDecryptedValue *document, TGPassportErrors *errors)
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf updateDocumentValue:details detailsType:TGPassportTypePersonalDetails document:document type:type errors:errors];
        };
        controller.removalBlock = ^(TGPassportType type)
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf updateDocumentValue:nil detailsType:TGPassportTypePersonalDetails document:nil type:type errors:nil];
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
                return [item.view convertRect:item.view.bounds toView:strongSelf.view];
            return CGRectZero;
        } completion:^(NSArray *uploads)
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            TGPassportIdentityController *controller = [[TGPassportIdentityController alloc] initWithType:type details:detailsValue documentOnly:documentOnly selfie:selfieRequired translation:translationRequired nativeNames:nativeNames editing:strongSelf->_request == nil upload:uploads.firstObject settings:strongSelf->_passwordSettingsVariable errors:strongSelf->_errors];
            [controller setLanguagesSignal:strongSelf->_langMapVariable.signal];
            controller.acceptedTypes = acceptedTypes;
            controller.completionBlock = ^(TGPassportDecryptedValue *details, TGPassportDecryptedValue *document, __unused TGPassportErrors *errors)
            {
                __strong TGPassportRequestController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf updateDocumentValue:details detailsType:TGPassportTypePersonalDetails document:document type:type errors:errors];
            };
            [strongSelf pushViewController:controller animated:false];
        }];
    }
}

- (void)addressDocumentTypePressed:(TGPassportType)type item:(TGCollectionItem *)item addressValue:(TGPassportDecryptedValue *)addressValue documentValue:(TGPassportDecryptedValue *)documentValue documentOnly:(bool)documentOnly menuController:(TGMenuSheetController *)menuController
{
    bool translationRequired = false;
    
    TGPassportRequiredType *requiredType = [self requiredTypeForType:type];
    if (requiredType != nil)
        translationRequired = requiredType.translationRequired;
    
    if (type == TGPassportTypeAddress || documentValue != nil)
    {
        [menuController dismissAnimated:true];
        
        __weak TGPassportRequestController *weakSelf = self;
        TGPassportAddressController *controller = [[TGPassportAddressController alloc] initWithType:type address:addressValue document:documentValue documentOnly:documentOnly translation:translationRequired editing:_request == nil settings:_passwordSettingsVariable errors:_errors];
        if (_request != nil && translationRequired && documentValue != nil && documentValue.translation.count == 0)
            [controller setScrollToTranslation];
        controller.completionBlock = ^(TGPassportDecryptedValue *address, TGPassportDecryptedValue *document, TGPassportErrors *errors)
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf updateDocumentValue:address detailsType:TGPassportTypeAddress document:document type:type errors:errors];
        };
        controller.removalBlock = ^(TGPassportType type)
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf updateDocumentValue:nil detailsType:TGPassportTypeAddress document:nil type:type errors:nil];
        };
        [self pushViewController:controller animated:true];
    }
    else
    {
        __weak TGPassportRequestController *weakSelf = self;
        [self presentImageUploadWithMenuController:menuController intent:TGPassportAttachIntentMultiple sourceRect:^CGRect {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [item.view convertRect:item.view.bounds toView:strongSelf.view];
            return CGRectZero;
        } completion:^(NSArray *uploads)
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            TGPassportAddressController *controller = [[TGPassportAddressController alloc] initWithType:type address:addressValue documentOnly:documentOnly translation:translationRequired editing:strongSelf->_request == nil uploads:uploads settings:strongSelf->_passwordSettingsVariable errors:strongSelf->_errors];
            controller.completionBlock = ^(TGPassportDecryptedValue *address, TGPassportDecryptedValue *document, TGPassportErrors *errors)
            {
                __strong TGPassportRequestController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf updateDocumentValue:address detailsType:TGPassportTypeAddress document:document type:type errors:errors];
            };
            [strongSelf pushViewController:controller animated:false];
        }];
    }
}

- (void)presentImageUploadWithMenuController:(TGMenuSheetController *)menuController intent:(TGPassportAttachIntent)intent sourceRect:(CGRect (^)(void))sourceRect completion:(void (^)(NSArray *))completion
{
    [TGPassportAttachMenu presentWithContext:[TGLegacyComponentsContext shared] parentController:self menuController:menuController title:nil intent:intent uploadAction:^(SSignal *resultSignal, void (^dismissPicker)(void))
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
            if (array.count < 20)
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
    for (TGPassportFieldCollectionItem *item in _mainSection.items)
    {
        if (![item isKindOfClass:[TGPassportFieldCollectionItem class]])
            continue;
        
        if (!item.isChecked)
        {
            failed = true;
            item.isRequired = true;
        }
    }
    
    if (!failed)
    {
        __weak TGPassportRequestController *weakSelf = self;
        [_saveDisposable setDisposable:[[[TGPassportSignals acceptAuthorizationForBotId:_request.botId scope:_request.scope publicKey:_request.publicKey finalForm:[self decryptedForm] payload:_request.payload nonce:_request.nonce] deliverOn:[SQueue mainQueue]] startWithNext:nil error:^(id error)
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            
            NSString *errorText = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
            if ([errorText isEqualToString:@"PASSWORD_REQUIRED"])
            {
                [strongSelf.navigationController.presentingViewController dismissViewControllerAnimated:true completion:nil];
            }
            
            NSString *displayText = TGLocalized(@"Login.UnknownError");
            [TGCustomAlertView presentAlertWithTitle:displayText message:nil cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
        }
        completed:^
        {
            __strong TGPassportRequestController *strongSelf = weakSelf;
            [strongSelf.presentingViewController dismissViewControllerAnimated:true completion:nil];
            
            if (strongSelf->_request.callbackUrl.length > 0)
            {
                NSString *url = nil;
                if ([strongSelf->_request.callbackUrl hasPrefix:@"tgbot"])
                    url = [NSString stringWithFormat:@"tgbot%d://passport/success", strongSelf->_request.botId];
                else
                    url = [TGPassportRequestController urlString:strongSelf->_request.callbackUrl byAppendingQueryString:@"tg_passport=success"];
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
        if ([_request.callbackUrl hasPrefix:@"tgbot"])
            url = [NSString stringWithFormat:@"tgbot%d://passport/cancel", _request.botId];
        else
            url = [TGPassportRequestController urlString:_request.callbackUrl byAppendingQueryString:@"tg_passport=cancel"];
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
            [TGAppDelegateInstance handleOpenInstantView:TGLocalized(@"Passport.InfoFAQ_URL") disableActions:false];
    } disableKeyboardWorkaround:false];
}

#pragma mark - Menus

- (void)presentDocumentOptionsMenu:(NSArray<TGPassportDocumentOption *> *)options item:(TGCollectionItem *)item
{
    __weak TGPassportRequestController *weakSelf = self;
    TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
    controller.dismissesByOutsideTap = true;
    controller.hasSwipeGesture = true;
    controller.narrowInLandscape = true;
    controller.permittedArrowDirections = UIPopoverArrowDirectionAny;
    controller.sourceRect = ^CGRect
    {
        __strong TGPassportRequestController *strongSelf = weakSelf;
        if (strongSelf != nil)
            return [item.view convertRect:item.view.bounds toView:strongSelf.view];
        return CGRectZero;
    };
    
    __weak TGMenuSheetController *weakController = controller;
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    for (TGPassportDocumentOption *option in options)
    {
        TGMenuSheetButtonItemView *optionItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:option.title type:TGMenuSheetButtonTypeDefault action:^
        {
            __strong TGMenuSheetController *strongController = weakController;
            if (strongController == nil)
                return;
            
            if (option.action != nil)
                option.action(strongController);
        }];
        [items addObject:optionItem];
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

- (void)presentDeleteMenu:(NSString *)text buttonTitle:(NSString *)buttonTitle item:(TGCollectionItem *)item action:(void (^)(void))action
{
    __weak TGPassportRequestController *weakSelf = self;
    TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
    controller.dismissesByOutsideTap = true;
    controller.hasSwipeGesture = true;
    controller.narrowInLandscape = true;
    controller.permittedArrowDirections = UIPopoverArrowDirectionAny;
    controller.sourceRect = ^CGRect
    {
        __strong TGPassportRequestController *strongSelf = weakSelf;
        if (strongSelf != nil)
            return [item.view convertRect:item.view.bounds toView:strongSelf.view];
        return CGRectZero;
    };
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    if (text.length > 0)
        [items addObject:[[TGMenuSheetTitleItemView alloc] initWithTitle:nil subtitle:text solidSubtitle:true]];
    
    __weak TGMenuSheetController *weakController = controller;
    TGMenuSheetButtonItemView *deleteItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:buttonTitle type:TGMenuSheetButtonTypeDestructive action:^
    {
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        [strongController dismissAnimated:true manual:true];
        
        if (action != nil)
            action();
    }];
    [items addObject:deleteItem];
    
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

#pragma mark - Passport Delete

- (void)deletePressed
{
    __weak TGPassportRequestController *weakSelf = self;
    [self presentDeleteMenu:TGLocalized(@"Passport.DeletePassportConfirmation") buttonTitle:TGLocalized(@"Common.Delete") item:_deleteItem action:^
    {
        __strong TGPassportRequestController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf performDelete];
    }];
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

#pragma mark - Two Step

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
                    [TGCustomAlertView presentAlertWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                } completed:nil]];
            }
        } disableKeyboardWorkaround:false];
        
    }
}

#pragma mark - Layout

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

#pragma mark - Helpers

+ (NSString *)titleForType:(TGPassportType)type
{
    switch (type)
    {
        case TGPassportTypePersonalDetails:
            return TGLocalized(@"Passport.Identity.TypePersonalDetails");
            
        case TGPassportTypePassport:
            return TGLocalized(@"Passport.Identity.TypePassport");
            
        case TGPassportTypeIdentityCard:
            return TGLocalized(@"Passport.Identity.TypeIdentityCard");
            
        case TGPassportTypeDriversLicense:
            return TGLocalized(@"Passport.Identity.TypeDriversLicense");
            
        case TGPassportTypeInternalPassport:
            return TGLocalized(@"Passport.Identity.TypeInternalPassport");
            
        case TGPassportTypeAddress:
            return TGLocalized(@"Passport.Address.TypeResidentialAddress");
            
        case TGPassportTypeUtilityBill:
            return TGLocalized(@"Passport.Address.TypeUtilityBill");
            
        case TGPassportTypeBankStatement:
            return TGLocalized(@"Passport.Address.TypeBankStatement");
            
        case TGPassportTypeRentalAgreement:
            return TGLocalized(@"Passport.Address.TypeRentalAgreement");
            
        case TGPassportTypePassportRegistration:
            return TGLocalized(@"Passport.Address.TypePassportRegistration");
            
        case TGPassportTypeTemporaryRegistration:
            return TGLocalized(@"Passport.Address.TypeTemporaryRegistration");
            
        default:
            return nil;
    }
}

+ (NSString *)uploadSubtitleForType:(TGPassportType)type
{
    switch (type)
    {
        case TGPassportTypePassport:
            return TGLocalized(@"Passport.Identity.TypePassportUploadScan");
            
        case TGPassportTypeIdentityCard:
            return TGLocalized(@"Passport.Identity.TypeIdentityCardUploadScan");
            
        case TGPassportTypeDriversLicense:
            return TGLocalized(@"Passport.Identity.TypeDriversLicenseUploadScan");
            
        case TGPassportTypeInternalPassport:
            return TGLocalized(@"Passport.Identity.TypeInternalPassportUploadScan");
            
        case TGPassportTypeUtilityBill:
            return TGLocalized(@"Passport.Address.TypeUtilityBillUploadScan");
            
        case TGPassportTypeBankStatement:
            return TGLocalized(@"Passport.Address.TypeBankStatementUploadScan");
            
        case TGPassportTypeRentalAgreement:
            return TGLocalized(@"Passport.Address.TypeRentalAgreementUploadScan");
    
        case TGPassportTypePassportRegistration:
            return TGLocalized(@"Passport.Address.TypePassportRegistrationUploadScan");
        
        case TGPassportTypeTemporaryRegistration:
            return TGLocalized(@"Passport.Address.TypeTemporaryRegistrationUploadScan");
            
        default:
            return nil;
    }
}

+ (NSString *)settingsTitleForType:(TGPassportType)type exists:(bool)exists
{
    NSString *title = nil;
    switch (type)
    {
        case TGPassportTypePersonalDetails:
            title = exists ? TGLocalized(@"Passport.Identity.EditPersonalDetails") : TGLocalized(@"Passport.Identity.AddPersonalDetails");
            break;
            
        case TGPassportTypePassport:
            title = exists ? TGLocalized(@"Passport.Identity.EditPassport") : TGLocalized(@"Passport.Identity.AddPassport");
            break;
            
        case TGPassportTypeIdentityCard:
            title = exists ? TGLocalized(@"Passport.Identity.EditIdentityCard") : TGLocalized(@"Passport.Identity.AddIdentityCard");
            break;
            
        case TGPassportTypeDriversLicense:
            title = exists ? TGLocalized(@"Passport.Identity.EditDriversLicense") : TGLocalized(@"Passport.Identity.AddDriversLicense");
            break;
            
        case TGPassportTypeInternalPassport:
            title = exists ? TGLocalized(@"Passport.Identity.EditInternalPassport") : TGLocalized(@"Passport.Identity.AddInternalPassport");
            break;
            
        case TGPassportTypeAddress:
            title = exists ? TGLocalized(@"Passport.Address.EditResidentialAddress") : TGLocalized(@"Passport.Address.AddResidentialAddress");
            break;
            
        case TGPassportTypeUtilityBill:
            title = exists ? TGLocalized(@"Passport.Address.EditUtilityBill") : TGLocalized(@"Passport.Address.AddUtilityBill");
            break;
            
        case TGPassportTypeBankStatement:
            title = exists ? TGLocalized(@"Passport.Address.EditBankStatement") : TGLocalized(@"Passport.Address.AddBankStatement");
            break;
            
        case TGPassportTypeRentalAgreement:
            title = exists ? TGLocalized(@"Passport.Address.EditRentalAgreement") : TGLocalized(@"Passport.Address.AddRentalAgreement");
            break;
            
        case TGPassportTypePassportRegistration:
            title = exists ? TGLocalized(@"Passport.Address.EditPassportRegistration") : TGLocalized(@"Passport.Address.AddPassportRegistration");
            break;
            
        case TGPassportTypeTemporaryRegistration:
            title = exists ? TGLocalized(@"Passport.Address.EditTemporaryRegistration") : TGLocalized(@"Passport.Address.AddTemporaryRegistration");
            break;
            
        default:
            break;
    }
    return title;
}

+ (NSString *)uploadSubtitleWithFormat:(NSString *)format types:(NSArray *)types
{
    NSString *(^stringForType)(TGPassportRequiredType *) = ^NSString *(TGPassportRequiredType *type)
    {
        switch (type.type)
        {
            case TGPassportTypePassport:
                return TGLocalized(@"Passport.Identity.OneOfTypePassport");
                
            case TGPassportTypeIdentityCard:
                return TGLocalized(@"Passport.Identity.OneOfTypeIdentityCard");
                
            case TGPassportTypeDriversLicense:
                return TGLocalized(@"Passport.Identity.OneOfTypeDriversLicense");
                
            case TGPassportTypeInternalPassport:
                return TGLocalized(@"Passport.Identity.OneOfTypeInternalPassport");
                
            case TGPassportTypeUtilityBill:
                return TGLocalized(@"Passport.Address.OneOfTypeUtilityBill");
                
            case TGPassportTypeBankStatement:
                return TGLocalized(@"Passport.Address.OneOfTypeBankStatement");
                
            case TGPassportTypeRentalAgreement:
                return TGLocalized(@"Passport.Address.OneOfTypeRentalAgreement");
                
            case TGPassportTypePassportRegistration:
                return TGLocalized(@"Passport.Address.OneOfTypePassportRegistration");
                
            case TGPassportTypeTemporaryRegistration:
                return TGLocalized(@"Passport.Address.OneOfTypeTemporaryRegistration");
                
            default:
                return nil;
        }
    };
    
    NSMutableString *string = [[NSMutableString alloc] init];
    [types enumerateObjectsUsingBlock:^(TGPassportRequiredType *type, NSUInteger index, __unused BOOL *stop)
    {
        NSString *typeString = stringForType(type);
        if (typeString == nil)
            return;
        
        [string appendString:typeString];
        
        if (index < types.count - 1)
        {
            NSString *delimeter = (index < types.count - 2) ? TGLocalized(@"Passport.FieldOneOf.Delimeter") : TGLocalized(@"Passport.FieldOneOf.FinalDelimeter");
            [string appendString:delimeter];
        }
    }];

    return [NSString stringWithFormat:format, string];
}

- (bool)requiresNativeNameForCountry:(NSString *)country
{
    if (country.length == 0)
        return false;
    
    NSString *lang = _languageMap.map[[country uppercaseString]];
    return ![lang isEqualToString:@"en"];
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

@implementation TGPassportDocumentOption

+ (instancetype)optionWithTitle:(NSString *)title action:(void (^)(TGMenuSheetController *))action
{
    TGPassportDocumentOption *option = [[TGPassportDocumentOption alloc] init];
    option->_title = title;
    option->_action = [action copy];
    return option;
}

@end
