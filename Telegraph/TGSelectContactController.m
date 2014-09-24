#import "TGSelectContactController.h"

#import "TGAppDelegate.h"
#import "TGTabletMainViewController.h"

#import "TGToolbarButton.h"

#import "TGUser.h"
#import "TGInterfaceManager.h"

#import "SGraphObjectNode.h"

#import "TGMessage+Telegraph.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"

#import "TGProgressWindow.h"

#import "TGCreateGroupController.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGAlertView.h"

@interface TGSelectContactController ()
{
    UIView *_titleContainer;
    UILabel *_titleLabel;
    UILabel *_counterLabel;
}

@property (nonatomic, strong) TGCreateGroupController *createGroupController;

@property (nonatomic) bool createEncrypted;
@property (nonatomic) bool createBroadcast;

@property (nonatomic, strong) TGProgressWindow *progressWindow;

@property (nonatomic) TGUser *currentEncryptedUser;

@end

@implementation TGSelectContactController

- (id)initWithCreateGroup:(bool)createGroup createEncrypted:(bool)createEncrypted createBroadcast:(bool)createBroadcast
{
    int contactsMode = TGContactsModeRegistered;
    if (createEncrypted)
    {
        _createEncrypted = true;
    }
    else
    {
        _createBroadcast = createBroadcast;
        
        if (createGroup)
            contactsMode |= TGContactsModeCompose;
        else
        {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Close") style:UIBarButtonItemStylePlain target:self action:@selector(closePressed)]];
            }
            
            contactsMode |= TGContactsModeCreateGroupOption;
        }
    }
    
    self = [super initWithContactsMode:contactsMode];
    if (self)
    {
#if TARGET_IPHONE_SIMULATOR
        self.usersSelectedLimit = 10;
#else
        self.usersSelectedLimit = 199;
#endif
        
        NSData *data = [TGDatabaseInstance() customProperty:@"maxChatParticipants"];
        if (data.length >= 4)
        {
            int32_t maxChatParticipants = 0;
            [data getBytes:&maxChatParticipants length:4];
            self.usersSelectedLimit = MAX(99, maxChatParticipants - 1);
        }
    }
    return self;
}

- (void)closePressed
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        TGAppDelegateInstance.tabletMainViewController.detailViewController = nil;
    }
}

- (void)backPressed
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)actionItemSelected
{
    TGSelectContactController *createGroupController = [[TGSelectContactController alloc] initWithCreateGroup:true createEncrypted:false createBroadcast:false];
    [self.navigationController pushViewController:createGroupController animated:true];
}

- (void)encryptionItemSelected
{
    TGSelectContactController *selectContactController = [[TGSelectContactController alloc] initWithCreateGroup:false createEncrypted:true createBroadcast:false];
    [self.navigationController pushViewController:selectContactController animated:true];
}

- (NSString *)baseTitle
{
    return _createBroadcast ? TGLocalized(@"Compose.NewBroadcast") : TGLocalized(@"Compose.NewGroup");
}

- (void)loadView
{
    [super loadView];
    
    if ((self.contactsMode & TGContactsModeCompose) == TGContactsModeCompose)
    {
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Next") style:UIBarButtonItemStylePlain target:self action:@selector(createButtonPressed:)]];
        self.navigationItem.rightBarButtonItem.enabled = [self selectedContactsCount] != 0;
        
        self.titleText = [self baseTitle];
        
        _titleContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 2)];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGBoldSystemFontOfSize(17.0f);
        _titleLabel.text = [self baseTitle];
        [_titleLabel sizeToFit];
        [_titleContainer addSubview:_titleLabel];
        
        _counterLabel = [[UILabel alloc] init];
        _counterLabel.backgroundColor = [UIColor clearColor];
        _counterLabel.textColor = UIColorRGB(0x8e8e93);
        _counterLabel.font = TGSystemFontOfSize(15.0f);
        _counterLabel.text = @"0/199";
        [_titleContainer addSubview:_counterLabel];
        
        [self setTitleView:_titleContainer];
    }
    else if (_createEncrypted)
    {
        self.titleText = TGLocalized(@"Compose.NewEncryptedChat");
    }
    else
    {
        self.titleText = TGLocalized(@"Compose.NewMessage");
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Back") style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self _layoutTitleViews:toInterfaceOrientation];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self _layoutTitleViews:self.interfaceOrientation];
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
    
    [_counterLabel sizeToFit];
    CGSize counterSize = _counterLabel.frame.size;
    
    CGRect titleLabelFrame = _titleLabel.frame;
    titleLabelFrame.origin = CGPointMake(CGFloor((_titleContainer.frame.size.width - titleLabelFrame.size.width) / 2.0f - counterSize.width / 2.0f), CGFloor((_titleContainer.frame.size.height - titleLabelFrame.size.height) / 2.0f) + (UIInterfaceOrientationIsPortrait(orientation) ? portraitOffset : landscapeOffset));
    _titleLabel.frame = titleLabelFrame;
    
    _counterLabel.frame = CGRectMake(CGRectGetMaxX(titleLabelFrame) + 4, titleLabelFrame.origin.y + 2 - TGRetinaPixel, counterSize.width, counterSize.height);
}

- (void)createButtonPressed:(id)__unused sender
{
    NSArray *contacts = [self selectedContactsList];
    if (contacts.count == 0)
        return;
    else
    {
        if (_createGroupController == nil)
        {
            _createGroupController = [[TGCreateGroupController alloc] initWithCreateBroadcast:_createBroadcast];
            _createGroupController.onCreateBroadcastList = _onCreateBroadcastList;
        }
        
        NSMutableArray *userIds = [[NSMutableArray alloc] init];
        for (TGUser *user in [self selectedComposeUsers])
        {
            [userIds addObject:@(user.uid)];
        }
        [_createGroupController setUserIds:userIds];
        
        [self.navigationController pushViewController:_createGroupController animated:true];
    }
}

- (void)contactSelected:(TGUser *)user
{
    int count = [self selectedContactsCount];
    self.navigationItem.rightBarButtonItem.enabled = count != 0;
    
    [super contactSelected:user];
    
    [self updateCount:count];
}

- (void)updateCount:(int)count
{
    _counterLabel.text = [[NSString alloc] initWithFormat:@"%d/%d", count, 199];
    [self _layoutTitleViews:self.interfaceOrientation];
}

- (void)singleUserSelected:(TGUser *)user
{
    if (_createEncrypted)
    {
        if ([self.tableView indexPathForSelectedRow] != nil)
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:true];
        
        _progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_progressWindow show:true];
        
        _currentEncryptedUser = user;
        
        static int actionId = 0;
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/encrypted/createChat/(profile%d)", actionId++] options:@{@"uid": @(user.uid)} flags:0 watcher:self];
    }
    else
    {
        [super singleUserSelected:user];
    }
}

- (void)contactDeselected:(TGUser *)user
{
    int count = [self selectedContactsCount];
    self.navigationItem.rightBarButtonItem.enabled = count != 0;
    
    [super contactDeselected:user];
    
    [self updateCount:count];
}

#pragma mark -

- (void)actionStageActionRequested:(NSString *)action options:(NSDictionary *)options
{
    if ([action isEqualToString:@"chatCreated"])
    {
        _shouldBeRemovedFromNavigationAfterHiding = true;
    }
    
    if ([[self superclass] instancesRespondToSelector:@selector(actionStageActionRequested:options:)])
        [super actionStageActionRequested:action options:options];
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/tg/encrypted/createChat/"])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [_progressWindow dismiss:true];
            _progressWindow = nil;
            
            if (status == ASStatusSuccess)
            {
                TGConversation *conversation = result[@"conversation"];
                [[TGInterfaceManager instance] navigateToConversationWithId:conversation.conversationId conversation:conversation];
            }
            else
            {
                [[[TGAlertView alloc] initWithTitle:nil message:status == -2 ? [[NSString alloc] initWithFormat:TGLocalized(@"Profile.CreateEncryptedChatOutdatedError"), _currentEncryptedUser.displayFirstName, _currentEncryptedUser.displayFirstName] : TGLocalized(@"Profile.CreateEncryptedChatError") delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil] show];
            }
        });
    }
    
    if ([[self superclass] instancesRespondToSelector:@selector(actorCompleted:path:result:)])
        [super actorCompleted:status path:path result:result];
}

@end
