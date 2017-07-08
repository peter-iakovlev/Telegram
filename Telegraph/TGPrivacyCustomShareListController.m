#import "TGPrivacyCustomShareListController.h"

#import "ActionStage.h"

#import "TGButtonCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGUserCollectionItem.h"

#import "TGUser.h"
#import "TGConversation.h"
#import "TGForwardTargetController.h"
#import "TGDatabase.h"

#import "TGTelegraph.h"

#import "TGInterfaceManager.h"

@interface TGPrivacyCustomShareListControllerAddCoordinator : NSObject <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic, copy) void (^completion)(NSArray *);

@end

@implementation TGPrivacyCustomShareListControllerAddCoordinator

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
    }
    return self;
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"blockUser"])
    {
        TGUser *user = options;
        if (user.uid != 0)
        {
            TGUser *user = options;
            if (user != nil)
            {
                int32_t uid = user.uid;
                if (_completion)
                    _completion(@[@(uid)]);
            }
        }
    }
    else if ([action isEqualToString:@"leaveConversation"])
    {
        TGConversation *conversation = options;
        if (conversation.conversationId != 0)
        {
            if (_completion)
                _completion(conversation.chatParticipants.chatParticipantUids);
        }
    }
    else if ([action isEqualToString:@"multipleUsersSelected"])
    {
        NSMutableArray *userIds = [[NSMutableArray alloc] init];
        for (TGUser *user in options)
        {
            if (user.uid != TGTelegraphInstance.clientUserId)
                [userIds addObject:@(user.uid)];
        }
        if (_completion)
            _completion(userIds);
    }
}

@end

@interface TGPrivacyCustomShareListController () <ASWatcher>
{
    NSString *_contactSearchPlaceholder;
    
    TGCollectionMenuSection *_usersSection;
    NSArray *_users;
    bool _dialogs;
    
    void (^_userIdsChanged)(NSArray *);
    
    TGPrivacyCustomShareListControllerAddCoordinator *_coordinator;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGPrivacyCustomShareListController

- (instancetype)initWithTitle:(NSString *)title contactSearchPlaceholder:(NSString *)contactSearchPlaceholder userIds:(NSArray *)userIds dialogs:(bool)dialogs userIdsChanged:(void (^)(NSArray *))userIdsChanged
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        _userIdsChanged = [userIdsChanged copy];
        _dialogs = dialogs;
        
        _contactSearchPlaceholder = contactSearchPlaceholder;
        
        self.title = title;
        
        NSMutableArray *usersSectionItems = [[NSMutableArray alloc] init];
        TGButtonCollectionItem *addButton = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"BlockedUsers.AddNew") action:@selector(addNewPressed)];
        addButton.leftInset = 15.0f + 40.0f + 8.0f;
        [usersSectionItems addObject:addButton];
        
        _usersSection = [[TGCollectionMenuSection alloc] initWithItems:usersSectionItems];
        UIEdgeInsets topSectionInsets = _usersSection.insets;
        topSectionInsets.top = 32.0f;
        _usersSection.insets = topSectionInsets;
        [self.menuSections addSection:_usersSection];
        
        [self setUserIds:userIds];
    }
    return self;
}

+ (id)presentAddInterfaceWithTitle:(NSString *)title contactSearchPlaceholder:(NSString *)contactSearchPlaceholder onController:(UIViewController *)controller dialogs:(bool)dialogs completion:(void (^)(NSArray *))completion
{
    TGPrivacyCustomShareListControllerAddCoordinator *coordinator = [[TGPrivacyCustomShareListControllerAddCoordinator alloc] init];
    coordinator.completion = completion;
    
    TGForwardTargetController *selectionController = [[TGForwardTargetController alloc] initWithSelectPrivacyTarget:title placeholder:contactSearchPlaceholder dialogs:dialogs];
    selectionController.watcherHandle = coordinator.actionHandle;
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[selectionController]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [controller presentViewController:navigationController animated:true completion:nil];
    return coordinator;
}

- (void)editButtonPressed
{
    [self enterEditingMode:true];
}

- (void)doneButtonPressed
{
    [self leaveEditingMode:true];
}

- (void)didEnterEditingMode:(bool)animated
{
    [super didEnterEditingMode:animated];
    
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)] animated:animated];
}

- (void)didLeaveEditingMode:(bool)animated
{
    [super didLeaveEditingMode:animated];
    
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed)] animated:animated];
}

- (void)addNewPressed
{
    __weak TGPrivacyCustomShareListController *weakSelf = self;
    _coordinator = [TGPrivacyCustomShareListController presentAddInterfaceWithTitle:self.title contactSearchPlaceholder:_contactSearchPlaceholder onController:self dialogs:_dialogs completion:^(NSArray *userIds)
    {
        __strong TGPrivacyCustomShareListController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            NSMutableArray *updatedUserIds = [[NSMutableArray alloc] init];
            for (TGUser *user in strongSelf->_users)
            {
                [updatedUserIds addObject:@(user.uid)];
            }
            
            for (NSNumber *nUserId in userIds)
            {
                if (TGTelegraphInstance.clientUserId == [nUserId intValue])
                    continue;
                
                if (![updatedUserIds containsObject:nUserId])
                    [updatedUserIds addObject:nUserId];
            }
            
            [strongSelf setUserIds:updatedUserIds];
            if (strongSelf->_userIdsChanged)
                strongSelf->_userIdsChanged(updatedUserIds);
            
            [strongSelf dismissViewControllerAnimated:true completion:nil];
            strongSelf->_coordinator = nil;
        }
    }];
}

- (void)setUserIds:(NSArray *)userIds
{
    NSMutableArray *users = [[NSMutableArray alloc] init];
    
    for (NSNumber *nUserId in userIds)
    {
        TGUser *user = [TGDatabaseInstance() loadUser:[nUserId intValue]];
        if (user != nil)
            [users addObject:user];
    }
    
    _users = users;
    [self _copyUsersToCurrentList:_users];
}

- (void)_copyUsersToCurrentList:(NSArray *)users
{
    if (self.menuSections.sections.count < 1)
        return;
    
    users = [users sortedArrayUsingComparator:^NSComparisonResult(TGUser *user1, TGUser *user2)
    {
        NSComparisonResult result = [user1.lastName compare:user2.lastName];
        if (result == NSOrderedSame)
        result = [user1.firstName compare:user2.firstName];
        return result;
    }];
    
    while (_usersSection.items.count > 1)
    {
        [self.menuSections deleteItemFromSection:0 atIndex:0];
    }
    
    NSMutableArray *userIds = [[NSMutableArray alloc] init];
    int insertIndex = 0;
    for (TGUser *user in users)
    {
        [userIds addObject:@(user.uid)];
        TGUserCollectionItem *item = [[TGUserCollectionItem alloc] init];
        item.deleteActionTitle = TGLocalized(@"PrivacyLastSeenSettings.CustomShareSettings.Delete");
        item.user = user;
        item.interfaceHandle = _actionHandle;
        item.showAvatar = true;
        item.deselectAutomatically = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
        
        [self.menuSections insertItem:item toSection:0 atIndex:insertIndex];
        insertIndex++;
    }
    
    [self.collectionView reloadData];
    
    if (_userIdsChanged)
        _userIdsChanged(userIds);
    
    [self _updateEmptyState:false];
}

- (void)_updateEmptyState:(bool)animated
{
    if (((TGCollectionMenuSection *)self.menuSections.sections[0]).items.count == 1)
    {
        [self leaveEditingMode:animated];
        
        [self setRightBarButtonItem:nil animated:animated];
    }
    else
    {
        if (self.collectionView.editing)
        {
            [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)] animated:animated];
        }
        else
        {
            [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed)] animated:animated];
        }
    }
}

- (void)_deleteUserWithUid:(int32_t)uid
{
    bool wasEmpty = ((TGCollectionMenuSection *)self.menuSections.sections[0]).items.count <= 1;
    
    int index = -1;
    for (id item in ((TGCollectionMenuSection *)self.menuSections.sections[0]).items)
    {
        index++;
        
        if ([item isKindOfClass:[TGUserCollectionItem class]])
        {
            if (((TGUserCollectionItem *)item).user.uid == uid)
            {
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
                if (cell != nil)
                    [cell.superview sendSubviewToBack:cell];
                
                [self.menuSections beginRecordingChanges];
                [self.menuSections deleteItemFromSection:0 atIndex:index];
                [self.menuSections commitRecordedChanges:self.collectionView];
                
                break;
            }
        }
    }
    
    NSMutableArray *users = [[NSMutableArray alloc] initWithArray:_users];
    for (NSUInteger i = 0; i < users.count; i++)
    {
        TGUser *user = users[i];
        if (user.uid == uid)
        {
            [users removeObjectAtIndex:i];
            break;
        }
    }
    _users = users;
    
    if (wasEmpty != (((TGCollectionMenuSection *)self.menuSections.sections[0]).items.count <= 1))
        [self _updateEmptyState:true];
    
    NSMutableArray *userIds = [[NSMutableArray alloc] init];
    for (TGUser *user in _users)
    {
        [userIds addObject:@(user.uid)];
    }
    
    if (_userIdsChanged)
        _userIdsChanged(userIds);
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"userItemDeleteRequested"])
    {
        int32_t uid = [options[@"uid"] int32Value];
        if (uid != 0)
            [self _deleteUserWithUid:uid];
    }
    else if ([action isEqualToString:@"userItemSelected"])
    {
        int32_t uid = [options[@"uid"] int32Value];
        if (uid != 0)
        {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [[TGInterfaceManager instance] navigateToProfileOfUser:uid shareVCard:nil];
            else
                [[TGInterfaceManager instance] navigateToConversationWithId:uid conversation:nil];
        }
    }
}

@end
