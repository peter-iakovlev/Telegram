#import "TGLoginInactiveUserController.h"

#import "TGToolbarButton.h"

#import "TGProgressWindow.h"

#import "TGTelegraph.h"

#import "TGAppDelegate.h"

#import "TGDatabase.h"

#import "SGraphObjectNode.h"

#import "TGImageUtils.h"
#import "TGLetteredAvatarView.h"

#import "TGSynchronizeContactsActor.h"

#import "TGTimelineUploadPhotoRequestBuilder.h"

#import "TGContactsController.h"

#import "TGFont.h"

#import "TGModernButton.h"

#import "TGBackdropView.h"

#import "TGAlertView.h"

@interface TGLoginInactiveUserController ()
{
    UIView *_navigationBarBackgroundView;
    UIView *_stripeView;
}

@property (nonatomic, strong) TGProgressWindow *progressWindow;

@property (nonatomic, strong) TGUser *user;

@property (nonatomic, strong) UIView *interfaceContainer;
@property (nonatomic, strong) UIView *accessDisabledContainer;

@property (nonatomic, strong) TGLetteredAvatarView *avatarView;

@property (nonatomic, strong) UIImage *uploadingAvatarImage;

@property (nonatomic, strong) UIView *titleContainer;
@property (nonatomic, strong) UILabel *titleStatusLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIActivityIndicatorView *titleStatusIndicator;

@end

@implementation TGLoginInactiveUserController

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.style = TGViewControllerStyleBlack;
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        [ActionStageInstance() watchForPath:@"/tg/activation" watcher:self];
        [ActionStageInstance() watchForPath:@"/tg/contactListSynchronizationState" watcher:self];
        [ActionStageInstance() watchForPath:@"/tg/removeAndExportActionsRunning" watcher:self];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)_loadStatusViews
{
    if (_titleStatusLabel == nil)
    {
        _titleStatusLabel = [[UILabel alloc] init];
        _titleStatusLabel.clipsToBounds = false;
        _titleStatusLabel.backgroundColor = [UIColor clearColor];
        _titleStatusLabel.textColor = [UIColor blackColor];
        _titleStatusLabel.font = TGBoldSystemFontOfSize(16.0f);
        _titleStatusLabel.text = TGLocalized(@"State.Updating");
        _titleStatusLabel.hidden = true;
        [_titleStatusLabel sizeToFit];
        [_titleContainer addSubview:_titleStatusLabel];
        
        _titleStatusIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _titleStatusIndicator.hidden = true;
        [_titleContainer addSubview:_titleStatusIndicator];
    }
}

- (void)setUpdating:(bool)updating
{
    if (updating)
    {
        _titleLabel.hidden = true;
        _titleStatusLabel.hidden = false;
        _titleStatusIndicator.hidden = false;
        [_titleStatusIndicator startAnimating];
    }
    else
    {
        _titleLabel.hidden = false;
        _titleStatusLabel.hidden = true;
        _titleStatusIndicator.hidden = true;
        [_titleStatusIndicator stopAnimating];
    }
}

- (void)loadView
{
    [super loadView];
    
    CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:UIInterfaceOrientationPortrait];
    bool isWidescreen = [TGViewController isWidescreen];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _titleContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 2.0f, 2.0f)];
    [self setTitleView:_titleContainer];
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.font = TGBoldSystemFontOfSize(17.0f);
    _titleLabel.text = TGLocalized(@"WelcomeScreen.Title");
    [_titleLabel sizeToFit];
    [_titleContainer addSubview:_titleLabel];
    [self _loadStatusViews];
    [self _layoutTitleViews:self.interfaceOrientation];
    
    [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"WelcomeScreen.Logout") style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonPressed)]];
    
    CGFloat containerHeight = TGIsPad() ? 568.0f : ([TGViewController screenSizeForInterfaceOrientation:UIInterfaceOrientationPortrait].height);
    _interfaceContainer = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 320.0f) / 2.0f, ((self.view.frame.size.height - containerHeight) / 2.0f), 320.0f, containerHeight)];
    [self.view addSubview:_interfaceContainer];
    
    if (_user == nil)
        _user = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
    
    _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(CGFloor((_interfaceContainer.frame.size.width - 110) / 2.0f), isWidescreen ? 120 : 90, 110, 110)];
    [_avatarView setSingleFontSize:40.0f doubleFontSize:40.0f useBoldFont:false];
    _avatarView.fadeTransition = true;
    [_interfaceContainer addSubview:_avatarView];
    
    static UIImage *placeholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(110, 110), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //!placeholder
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 110, 110));
        CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
        CGContextSetLineWidth(context, 1.0f);
        CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, 109, 109));
        
        placeholder = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    [_avatarView loadUserPlaceholderWithSize:CGSizeMake(80.0f, 80.0f) uid:_user.uid firstName:_user.firstName lastName:_user.lastName placeholder:placeholder];
    
    UILabel *greetingLabel = [[UILabel alloc] init];
    greetingLabel.backgroundColor = [UIColor clearColor];
    greetingLabel.textColor = [UIColor blackColor];
    greetingLabel.font = TGLightSystemFontOfSize(29.0f);
    greetingLabel.text = [[NSString alloc] initWithFormat:TGLocalized(@"WelcomeScreen.Greeting"), _user.displayFirstName];
    [greetingLabel sizeToFit];
    greetingLabel.frame = CGRectMake(CGFloor((_interfaceContainer.frame.size.width - greetingLabel.frame.size.width) / 2.0f), isWidescreen ? 256.0f : 220.0f, greetingLabel.frame.size.width, greetingLabel.frame.size.height);
    [_interfaceContainer addSubview:greetingLabel];
    
    UILabel *noticeLabel = [[UILabel alloc] init];
    noticeLabel.backgroundColor = [UIColor clearColor];
    noticeLabel.textColor = [UIColor blackColor];
    noticeLabel.font = TGSystemFontOfSize(17.0f);
    noticeLabel.textAlignment = NSTextAlignmentCenter;
    noticeLabel.numberOfLines = 0;
    noticeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSString *text = TGLocalized(@"Login.InactiveHelp");
    
    if ([noticeLabel respondsToSelector:@selector(setAttributedText:)])
    {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 5;
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.alignment = NSTextAlignmentCenter;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{
            NSFontAttributeName: noticeLabel.font,
            NSForegroundColorAttributeName: noticeLabel.textColor
        }];
        
        [attributedString addAttributes:@{NSParagraphStyleAttributeName: style} range:NSMakeRange(0, attributedString.length)];
        
        NSRange range = [text rangeOfString:@"Telegram"];
        if (range.location != NSNotFound)
            [attributedString addAttributes:@{NSFontAttributeName: TGMediumSystemFontOfSize(17.0f)} range:range];
        noticeLabel.attributedText = attributedString;
    }
    else
        noticeLabel.text = text;
    
    CGSize textSize = [noticeLabel sizeThatFits:CGSizeMake(_interfaceContainer.frame.size.width - 20, CGFLOAT_MAX)];
    noticeLabel.frame = CGRectMake(CGFloor((_interfaceContainer.frame.size.width - textSize.width) / 2), isWidescreen ? 302 : 280, textSize.width, textSize.height);
    [_interfaceContainer addSubview:noticeLabel];
    
    TGModernButton *startButton = [[TGModernButton alloc] init];
    startButton.backgroundColor = [UIColor clearColor];
    [startButton setTitleColor:TGAccentColor()];
    startButton.titleLabel.font = TGSystemFontOfSize(21.0f);
    [startButton setTitle:TGLocalized(@"Login.InviteButton") forState:UIControlStateNormal];
    [startButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20.0f)];
    [startButton sizeToFit];
    CGSize buttonSize = startButton.frame.size;
    startButton.frame = CGRectMake(CGFloor((_interfaceContainer.frame.size.width - buttonSize.width) / 2.0f) + 10.0f, isWidescreen ? 430.0f : 400.0f, buttonSize.width, buttonSize.height + 20.0f);
    
    UIImageView *arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernTourButtonRightArrow.png"]];
    CGSize arrowSize = arrowView.frame.size;
    arrowView.frame = CGRectMake(startButton.frame.size.width - arrowSize.width, CGFloor((startButton.frame.size.height - arrowView.frame.size.height) / 2.0f) + 2.0f + TGRetinaPixel, arrowSize.width, arrowSize.height);
    
    [startButton addSubview:arrowView];
    [startButton addTarget:self action:@selector(inviteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_interfaceContainer addSubview:startButton];
    
    _navigationBarBackgroundView = [TGBackdropView viewWithLightNavigationBarStyle];
    _navigationBarBackgroundView.frame = CGRectMake(0.0f, 0.0f, screenSize.width, 20 + 44);
    [self.view addSubview:_navigationBarBackgroundView];
    
    _stripeView = [[UIView alloc] init];
    _stripeView.frame = CGRectMake(0.0f, _navigationBarBackgroundView.frame.size.height - (TGScreenPixel), screenSize.width, TGScreenPixel);
    _stripeView.backgroundColor = UIColorRGB(0xb2b2b2);
    _stripeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_navigationBarBackgroundView addSubview:_stripeView];
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
    
    [self updateInterface:self.interfaceOrientation];
}

- (void)doUnloadView
{
    
}

- (void)viewDidUnload
{
    [self doUnloadView];
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self rejoinActions];
    
    [self updateAccessStatus];
    
    [super viewWillAppear:animated];
    
    [self updateInterface:self.interfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self updateInterface:toInterfaceOrientation];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.navigationController.viewControllers.count > 2)
    {
        NSArray *newViewControllers = [[NSArray alloc] initWithObjects:[self.navigationController.viewControllers objectAtIndex:0], [self.navigationController.viewControllers lastObject], nil];
        [self.navigationController setViewControllers:newViewControllers animated:false];
    }
    
    [super viewDidAppear:animated];
}

- (void)rejoinActions
{
    if (_uploadingAvatarImage == nil)
    {
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            NSArray *uploadActions = [ActionStageInstance() rejoinActionsWithGenericPathNow:@"/tg/timeline/@/uploadPhoto/@" prefix:[[NSString alloc] initWithFormat:@"/tg/timeline/(%d)", TGTelegraphInstance.clientUserId] watcher:self];
            
            if (uploadActions.count != 0)
            {
                UIImage *uploadingAvatar = nil;
                if (uploadActions.count != 0)
                {
                    uploadingAvatar = ((TGTimelineUploadPhotoRequestBuilder *)[ActionStageInstance() executingActorWithPath:uploadActions.lastObject]).currentLoginBigPhoto;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    _uploadingAvatarImage = uploadingAvatar;
                    [_avatarView loadImage:_uploadingAvatarImage];
                });
            }
        }];
    }
}

- (UIView *)accessDisabledContainer
{
    if (_accessDisabledContainer == nil)
    {
        float topOffset = 30;
        
        float titleY = topOffset + ([TGViewController isWidescreen] ? 205 : 190);
        
        CGFloat containerHeight = TGIsPad() ? 568.0f : ([TGViewController screenSizeForInterfaceOrientation:UIInterfaceOrientationPortrait].height);
        
        _accessDisabledContainer = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 320.0f) / 2.0f, ((self.view.frame.size.height - containerHeight) / 2.0f), 320.0f, containerHeight)];
        [self.view addSubview:_accessDisabledContainer];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = TGSystemFontOfSize(18);
        titleLabel.textColor = UIColorRGB(0x999999);
        [_accessDisabledContainer addSubview:titleLabel];
    
        titleLabel.text = TGLocalized(@"WelcomeScreen.ContactsAccessDisabled");
        [titleLabel sizeToFit];
        titleLabel.frame = CGRectOffset(titleLabel.frame, CGFloor((_accessDisabledContainer.frame.size.width - titleLabel.frame.size.width) / 2), titleY);
        
        UILabel *noticeLabel = [[UILabel alloc] init];
        noticeLabel.font = TGSystemFontOfSize(16);
        noticeLabel.textColor = UIColorRGB(0x999999);
        noticeLabel.text = TGLocalized(@"Login.InactiveHelp");
        noticeLabel.backgroundColor = [UIColor clearColor];
        noticeLabel.lineBreakMode = NSLineBreakByWordWrapping;
        noticeLabel.textAlignment = NSTextAlignmentCenter;
        noticeLabel.contentMode = UIViewContentModeCenter;
        noticeLabel.numberOfLines = 0;
        
        NSString *model = @"iPhone";
        NSString *rawModel = [[[UIDevice currentDevice] model] lowercaseString];
        if ([rawModel rangeOfString:@"ipod"].location != NSNotFound)
            model = @"iPod";
        else if ([rawModel rangeOfString:@"ipad"].location != NSNotFound)
            model = @"iPad";
        
        NSString *baseText = [[NSString alloc] initWithFormat:TGLocalized(@"WelcomeScreen.ContactsAccessHelp"), model];
        
        if ([UILabel instancesRespondToSelector:@selector(setAttributedText:)])
        {
            UIColor *foregroundColor = UIColorRGB(0x999999);
            
            NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:14], NSFontAttributeName, foregroundColor, NSForegroundColorAttributeName, nil];
            NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:14], NSFontAttributeName, nil];
            const NSRange range = [baseText rangeOfString:TGLocalized(@"WelcomeScreen.ContactsAccessSettings")];
            
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:baseText attributes:attrs];
            [attributedText setAttributes:subAttrs range:range];
            
            [noticeLabel setAttributedText:attributedText];
        }
        else
        {
            noticeLabel.text = baseText;
        }
        CGSize size = [noticeLabel sizeThatFits:CGSizeMake(270, 1024)];
        noticeLabel.frame = CGRectMake(CGFloor((_accessDisabledContainer.frame.size.width - size.width) / 2), titleY + 34, size.width, size.height);
        [_accessDisabledContainer addSubview:noticeLabel];
        
        [self updateInterface:self.interfaceOrientation];
    }
    
    return _accessDisabledContainer;
}

- (void)updateAccessStatus
{
    TGPhonebookAccessStatus accessStatus = [TGSynchronizeContactsManager instance].phonebookAccessStatus;
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if (accessStatus == TGPhonebookAccessStatusDisabled)
        {
            _interfaceContainer.hidden = true;
            self.accessDisabledContainer.hidden = false;
        }
        else
        {
            _interfaceContainer.hidden = false;
            _accessDisabledContainer.hidden = true;
        }
    });
}

- (void)updateSynchronizationStatus
{
    bool updating = [TGSynchronizeContactsManager instance].contactsSynchronizationStatus;
    bool exporting = [TGSynchronizeContactsManager instance].removeAndExportActionsRunning;
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if (updating || exporting)
        {
            [self setUpdating:true];
        }
        else
        {
            [self setUpdating:false];
        }
    });
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    [super controllerInsetUpdated:previousInset];
    
    _navigationBarBackgroundView.frame = CGRectMake(0.0f, self.controllerInset.top - (44 + 20), self.view.frame.size.width, 20 + 44);
}

#pragma mark -

- (void)logoutButtonPressed
{
    _progressWindow = [[TGProgressWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_progressWindow show:true];
    
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/auth/logout/(%d)", TGTelegraphInstance.clientUserId] options:nil watcher:self];
}

- (void)inviteButtonPressed
{
    TGContactsController *contactsController = [[TGContactsController alloc] initWithContactsMode:TGContactsModeInvite | TGContactsModeModalInvite | TGContactsModeModalInviteWithBack];
    contactsController.loginStyle = true;
    contactsController.watcherHandle = _actionHandle;
    contactsController.drawFakeNavigationBar = true;
    [self.navigationController pushViewController:contactsController animated:true];
}

#pragma mark -

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/tg/activation"])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if ([((SGraphObjectNode *)resource).object boolValue])
                [TGAppDelegateInstance presentMainController];
        });
    }
    else if ([path isEqualToString:@"/tg/contactListSynchronizationState"])
    {
        if (![((SGraphObjectNode *)resource).object boolValue])
        {
            bool activated = [TGDatabaseInstance() haveRemoteContactUids];
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                if (activated)
                    [TGAppDelegateInstance presentMainController];
            });
        }
        else
        {
            
        }
        
        [self updateSynchronizationStatus];
        [self updateAccessStatus];
    }
    else if ([path isEqualToString:@"/tg/removeAndExportActionsRunning"])
    {
        [self updateSynchronizationStatus];
    }
}

- (void)actorCompleted:(int)resultCode path:(NSString *)path result:(id)__unused result
{
    if ([path hasPrefix:@"/tg/auth/logout/"])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [_progressWindow dismiss:true];
            _progressWindow = nil;
            
            if (resultCode != ASStatusSuccess)
            {
                [[[TGAlertView alloc] initWithTitle:nil message:@"An error occured" delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil] show];
            }
            
            [self.navigationController popToRootViewControllerAnimated:true];
        });
    }
}

- (void)_layoutTitleViews:(UIInterfaceOrientation)orientation
{
    CGFloat portraitOffset = 0.0f;
    CGFloat landscapeOffset = 0.0f;
    CGFloat indicatorOffset = 0.0f;
    if (iosMajorVersion() >= 7)
    {
        portraitOffset = 1.0f;
        landscapeOffset = 0.0f;
        indicatorOffset = -1.0f;
    }
    else
    {
        portraitOffset = -1.0f;
        landscapeOffset = 1.0f;
        indicatorOffset = 0.0f;
    }
    
    CGRect titleLabelFrame = _titleLabel.frame;
    titleLabelFrame.origin = CGPointMake(CGFloor((_titleContainer.frame.size.width - titleLabelFrame.size.width) / 2.0f), CGFloor((_titleContainer.frame.size.height - titleLabelFrame.size.height) / 2.0f) + (UIInterfaceOrientationIsPortrait(orientation) ? portraitOffset : landscapeOffset));
    _titleLabel.frame = titleLabelFrame;
    
    if (_titleStatusLabel != nil)
    {
        CGRect titleStatusLabelFrame = _titleStatusLabel.frame;
        titleStatusLabelFrame.origin = CGPointMake(CGFloor((_titleContainer.frame.size.width - titleStatusLabelFrame.size.width) / 2.0f) + 16.0f, CGFloor((_titleContainer.frame.size.height - titleStatusLabelFrame.size.height) / 2.0f) + (UIInterfaceOrientationIsPortrait(orientation) ? portraitOffset : landscapeOffset));
        _titleStatusLabel.frame = titleStatusLabelFrame;
        
        CGRect titleIndicatorFrame = _titleStatusIndicator.frame;
        titleIndicatorFrame.origin = CGPointMake(titleStatusLabelFrame.origin.x - titleIndicatorFrame.size.width - 4.0f, titleStatusLabelFrame.origin.y  + indicatorOffset);
        _titleStatusIndicator.frame = titleIndicatorFrame;
    }
}

- (void)updateInterface:(UIInterfaceOrientation)orientation
{
    CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:orientation];
    
    _navigationBarBackgroundView.frame = CGRectMake(0.0f, 0.0f, screenSize.width, 20 + 44);
    _stripeView.frame = CGRectMake(0.0f, _navigationBarBackgroundView.frame.size.height - (TGScreenPixel), screenSize.width, TGScreenPixel);
    
    _interfaceContainer.frame = CGRectMake(CGFloor((screenSize.width - _interfaceContainer.frame.size.width) / 2.0f), CGFloor((screenSize.height - _interfaceContainer.frame.size.height) / 2.0f), _interfaceContainer.frame.size.width, _interfaceContainer.frame.size.height);
    
    _accessDisabledContainer.frame = CGRectMake(CGFloor((screenSize.width - _accessDisabledContainer.frame.size.width) / 2.0f), CGFloor((screenSize.height - _accessDisabledContainer.frame.size.height) / 2.0f), _accessDisabledContainer.frame.size.width, _accessDisabledContainer.frame.size.height);
}

@end
