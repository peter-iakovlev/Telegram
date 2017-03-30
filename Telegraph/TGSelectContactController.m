#import "TGSelectContactController.h"

#import "TGAppDelegate.h"
#import "TGRootController.h"

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
#import "TGApplicationFeatures.h"

#import "TGChannelManagementSignals.h"

#import "TGTelegramNetworking.h"

#import "TGGroupInfoContactListCreateLinkCell.h"

@interface TGSelectContactController ()
{
    UIView *_titleContainer;
    UILabel *_titleLabel;
    UILabel *_counterLabel;
    
    int _displayUserCountLimit;
}

@property (nonatomic, strong) TGCreateGroupController *createGroupController;

@property (nonatomic) bool createEncrypted;
@property (nonatomic) bool createBroadcast;
@property (nonatomic) bool createChannel;
@property (nonatomic) bool inviteToChannel;
@property (nonatomic) bool call;

@property (nonatomic, strong) TGProgressWindow *progressWindow;

@property (nonatomic) TGUser *currentEncryptedUser;

@end

@implementation TGSelectContactController

- (id)initWithCreateGroup:(bool)createGroup createEncrypted:(bool)createEncrypted createBroadcast:(bool)createBroadcast createChannel:(bool)createChannel inviteToChannel:(bool)inviteToChannel showLink:(bool)showLink
{
    return [self initWithCreateGroup:createGroup createEncrypted:createEncrypted createBroadcast:createBroadcast createChannel:createChannel inviteToChannel:inviteToChannel showLink:showLink call:false];
}

- (id)initWithCreateGroup:(bool)createGroup createEncrypted:(bool)createEncrypted createBroadcast:(bool)createBroadcast createChannel:(bool)createChannel inviteToChannel:(bool)inviteToChannel showLink:(bool)showLink call:(bool)call
{
    int contactsMode = TGContactsModeRegistered;
    if (createEncrypted)
    {
        _createEncrypted = true;
    }
    else
    {
        _createBroadcast = createBroadcast;
        _createChannel = createChannel;
        _inviteToChannel = inviteToChannel;
        _call = call;
        
        if (createGroup)
            contactsMode |= TGContactsModeCompose;
        else if (createChannel || inviteToChannel) {
            contactsMode |= (TGContactsModeCompose | TGContactsModeSearchGlobal);
            if (showLink) {
                contactsMode |= TGContactsModeCreateGroupLink | TGContactsModeManualFirstSection;
            }
        }
        else if (!call)
        {
            contactsMode |= TGContactsModeCreateGroupOption;
        }
        
        if (call)
            contactsMode |= TGContactsModeCalls;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Close") style:UIBarButtonItemStylePlain target:self action:@selector(closePressed)]];
        }
    }
    
    self = [super initWithContactsMode:contactsMode];
    if (self)
    {
        if (createChannel || inviteToChannel) {
            self.usersSelectedLimit = 0;
            self.composePlaceholder = TGLocalized(@"Compose.ChannelTokenListPlaceholder");
        } else {
            self.usersSelectedLimit = 199;
            
            NSData *data = [TGDatabaseInstance() customProperty:@"maxChatParticipants"];
            if (data.length >= 4)
            {
                int32_t maxChatParticipants = 0;
                [data getBytes:&maxChatParticipants length:4];
                if (maxChatParticipants == 0)
                    self.usersSelectedLimit = 99;
                else
                    self.usersSelectedLimit = MAX(0, maxChatParticipants - 1);
            }
            
#if TARGET_IPHONE_SIMULATOR
            //self.usersSelectedLimit = 10;
#endif
            
            if (createEncrypted || call) {
                self.ignoreBots = true;
            }
            
            _displayUserCountLimit = self.usersSelectedLimit + 1;
            
            data = [TGDatabaseInstance() customProperty:@"maxChannelGroupMembers"];
            if (data.length >= 4)
            {
                int32_t maxChannelGroupMembers = 0;
                [data getBytes:&maxChannelGroupMembers length:4];
                if (maxChannelGroupMembers != 0) {
                    _displayUserCountLimit = MAX(_displayUserCountLimit, maxChannelGroupMembers);
                }
            }
            
            self.usersSelectedLimitAlert = TGLocalized(@"CreateGroup.SoftUserLimitAlert");
            
            self.composePlaceholder = TGLocalized(@"Compose.TokenListPlaceholder");
        }
    }
    return self;
}

- (void)closePressed
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [TGAppDelegateInstance.rootController clearContentControllers];
    }
}

- (void)backPressed
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)channelNextPressed {
    NSArray *users = [self selectedComposeUsers];
    if (users.count == 0) {
        [[TGInterfaceManager instance] navigateToConversationWithId:_channelConversation.conversationId conversation:_channelConversation];
    } else {
        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
        [progressWindow show:true];
        
        [[[[TGChannelManagementSignals inviteUsers:_channelConversation.conversationId accessHash:_channelConversation.accessHash users:users] deliverOn:[SQueue mainQueue]] onDispose:^{
            TGDispatchOnMainThread(^{
                [progressWindow dismiss:true];
                
                TGConversation *conversation = [TGDatabaseInstance() loadChannels:@[@(_channelConversation.conversationId)]][@(_channelConversation.conversationId)];
                
                [[TGInterfaceManager instance] navigateToConversationWithId:conversation.conversationId conversation:conversation];
            });
        }] startWithNext:nil completed:nil];
    }
}

- (void)cancelPressed {
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)inviteChannelNextPressed {
    NSArray *users = [self selectedComposeUsers];
    if (users.count == 0) {
        [self cancelPressed];
    } else {
        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
        [progressWindow show:true];

        TGConversation *conversation = _channelConversation;
        __weak TGSelectContactController *weakSelf = self;
        [[[[[[TGChannelManagementSignals inviteUsers:_channelConversation.conversationId accessHash:_channelConversation.accessHash users:users] onCompletion:^ {
            [TGDatabaseInstance() updateChannelCachedData:conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                if (data == nil) {
                    data = [[TGCachedConversationData alloc] init];
                }
                
                NSMutableArray *userIds = [[NSMutableArray alloc] init];
                for (TGUser *user in users) {
                    [userIds addObject:@(user.uid)];
                }
                
                return [data addMembers:userIds timestamp:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime]];
            }];
        }] deliverOn:[SQueue mainQueue]] onDispose:^{
            TGDispatchOnMainThread(^{
                [progressWindow dismiss:true];
            });
        }] onCompletion:^{
            __strong TGSelectContactController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (strongSelf->_onChannelMembersInvited) {
                    strongSelf->_onChannelMembersInvited(users);
                }
                [strongSelf cancelPressed];
            }
        }] startWithNext:nil error:^(id error) {
            NSString *errorType = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
            NSString *errorText = TGLocalized(@"Profile.CreateEncryptedChatError");
            if ([errorType isEqual:@"USER_BLOCKED"]) {
                errorText = _channelConversation.isChannelGroup ? TGLocalized(@"Group.ErrorAddBlocked") : TGLocalized(@"Channel.ErrorAddBlocked");
            } else if ([errorType isEqual:@"USERS_TOO_MUCH"]) {
                if (_channelConversation.isChannelGroup) {
                    errorText = TGLocalized(@"Group.ErrorAddTooMuch");
                } else {
                    errorText = TGLocalized(@"Channel.ErrorAddTooMuch");
                }
            } else if ([errorType isEqual:@"BOTS_TOO_MUCH"]) {
                errorText = TGLocalized(@"Group.ErrorAddTooMuchBots");
            } else if ([errorType isEqual:@"USER_NOT_MUTUAL_CONTACT"]) {
                errorText = TGLocalized(@"Group.ErrorNotMutualContact");
            } else if ([errorType isEqualToString:@"USER_PRIVACY_RESTRICTED"]) {
                if (users.count == 1) {
                    NSString *format = conversation.isChannelGroup ? TGLocalized(@"Privacy.GroupsAndChannels.InviteToGroupError") : TGLocalized(@"Privacy.GroupsAndChannels.InviteToChannelError");
                    TGUser *user = users.firstObject;
                    errorText = [[NSString alloc] initWithFormat:format, user.displayFirstName, user.displayFirstName];
                } else {
                    errorText = TGLocalized(@"Privacy.GroupsAndChannels.InviteToChannelMultipleError");
                }
            }
            
            [[[TGAlertView alloc] initWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
        } completed:nil];
    }
}

- (void)actionItemSelected
{
    __autoreleasing NSString *disabledMessage = nil;
    if (![TGApplicationFeatures isGroupCreationEnabled:&disabledMessage])
    {
        if ([self.tableView indexPathForSelectedRow])
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:true];
        [[[TGAlertView alloc] initWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
        return;
    }
    
    TGSelectContactController *createGroupController = [[TGSelectContactController alloc] initWithCreateGroup:true createEncrypted:false createBroadcast:false createChannel:false inviteToChannel:false showLink:false];
    [self.navigationController pushViewController:createGroupController animated:true];
}

- (void)encryptionItemSelected
{
    TGSelectContactController *selectContactController = [[TGSelectContactController alloc] initWithCreateGroup:false createEncrypted:true createBroadcast:false createChannel:false inviteToChannel:false showLink:false];
    [self.navigationController pushViewController:selectContactController animated:true];
}

- (NSString *)baseTitle
{
    if (_createChannel || _inviteToChannel) {
        return TGLocalized(@"Compose.ChannelMembers");
    }
    return _createBroadcast ? TGLocalized(@"Compose.NewBroadcast") : TGLocalized(@"Compose.NewGroup");
}

- (void)loadView
{
    [super loadView];
    
    if ((self.contactsMode & TGContactsModeCompose) == TGContactsModeCompose)
    {
        if (!_createChannel && !_inviteToChannel) {
            [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Next") style:UIBarButtonItemStylePlain target:self action:@selector(createButtonPressed:)]];
        } else if (_createChannel){
            [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Next") style:UIBarButtonItemStyleDone target:self action:@selector(channelNextPressed)]];
        } else if (_inviteToChannel) {
            [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStyleDone target:self action:@selector(cancelPressed)]];
            [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(inviteChannelNextPressed)]];
        }
        
        if (!self.createChannel) {
            self.navigationItem.rightBarButtonItem.enabled = [self selectedContactsCount] != 0;
        }
        
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
        _counterLabel.text = [[NSString alloc] initWithFormat:@"0/%d", _displayUserCountLimit];
        if (!_createChannel && !_inviteToChannel) {
            [_titleContainer addSubview:_counterLabel];
        }
        
        [self setTitleView:_titleContainer];
    }
    else if (_createEncrypted)
    {
        self.titleText = TGLocalized(@"Compose.NewEncryptedChat");
    }
    else if (_call)
    {
        self.titleText = TGLocalized(@"Calls.NewCall");
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
    
    if (_createChannel || _inviteToChannel) {
        titleLabelFrame.origin = CGPointMake(CGFloor((_titleContainer.frame.size.width - titleLabelFrame.size.width) / 2.0f), CGFloor((_titleContainer.frame.size.height - titleLabelFrame.size.height) / 2.0f) + (UIInterfaceOrientationIsPortrait(orientation) ? portraitOffset : landscapeOffset));
        _titleLabel.frame = titleLabelFrame;
    } else {
        titleLabelFrame.origin = CGPointMake(CGFloor((_titleContainer.frame.size.width - titleLabelFrame.size.width) / 2.0f - counterSize.width / 2.0f), CGFloor((_titleContainer.frame.size.height - titleLabelFrame.size.height) / 2.0f) + (UIInterfaceOrientationIsPortrait(orientation) ? portraitOffset : landscapeOffset));
        _titleLabel.frame = titleLabelFrame;
        
        _counterLabel.frame = CGRectMake(CGRectGetMaxX(titleLabelFrame) + 4, titleLabelFrame.origin.y + 2 - TGRetinaPixel, counterSize.width, counterSize.height);
    }
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
            _createGroupController = [[TGCreateGroupController alloc] initWithCreateChannel:false createChannelGroup:false];
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
    
    if (!_createChannel) {
        self.navigationItem.rightBarButtonItem.enabled = count != 0;
    }
    
    [super contactSelected:user];
    
    [self updateCount:count];
}

- (void)updateCount:(int)count
{
    _counterLabel.text = [[NSString alloc] initWithFormat:@"%d/%d", count, _displayUserCountLimit];
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
    else if (_call)
    {
        if (self.onCall != nil)
            self.onCall(user);
    }
    else
    {
        [super singleUserSelected:user];
    }
}

- (void)contactDeselected:(TGUser *)user
{
    int count = [self selectedContactsCount];
    
    if (!_createChannel) {
        self.navigationItem.rightBarButtonItem.enabled = count != 0;
    }
    
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

- (UITableViewCell *)cellForRowInFirstSection:(NSInteger)__unused row
{
    TGGroupInfoContactListCreateLinkCell *cell = (TGGroupInfoContactListCreateLinkCell *)[self.tableView dequeueReusableCellWithIdentifier:@"TGGroupInfoContactListCreateLinkCell"];
    if (cell == nil)
    {
        cell = [[TGGroupInfoContactListCreateLinkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TGGroupInfoContactListCreateLinkCell"];
    }
    
    return cell;
}

- (NSInteger)numberOfRowsInFirstSection
{
    if (self.contactsMode & TGContactsModeCreateGroupLink)
        return 1;
    return 0;
}

- (CGFloat)itemHeightForFirstSection
{
    return 48.0f;
}

- (void)didSelectRowInFirstSection:(NSInteger)__unused row
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:true];
    if (_onCreateLink) {
        _onCreateLink();
    }
}

@end
