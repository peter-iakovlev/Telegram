/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCreateGroupController.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGDatabase.h"

#import "TGInterfaceManager.h"

#import "TGGroupInfoCollectionItem.h"
#import "TGGroupInfoUserCollectionItem.h"

#import "TGProgressWindow.h"

#import "TGAlertView.h"

@interface TGCreateGroupController ()
{
    NSArray *_userIds;
    bool _createBroadcast;
    
    TGGroupInfoCollectionItem *_groupInfoItem;
    
    TGCollectionMenuSection *_usersSection;
    
    TGProgressWindow *_progressWindow;
    
    bool _makeFieldFirstResponder;
}

@end

@implementation TGCreateGroupController

- (instancetype)init
{
    return [self initWithCreateBroadcast:false];
}

- (instancetype)initWithCreateBroadcast:(bool)createBroadcast
{
    self = [super init];
    if (self)
    {
        _createBroadcast = createBroadcast;
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        [self setTitleText:_createBroadcast ? TGLocalized(@"Compose.Recipients") : TGLocalized(@"Compose.NewGroup")];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Create") style:UIBarButtonItemStyleDone target:self action:@selector(createPressed)]];
        self.navigationItem.rightBarButtonItem.enabled = _createBroadcast;
        
        _groupInfoItem = [[TGGroupInfoCollectionItem alloc] init];
        _groupInfoItem.isBroadcast = _createBroadcast;
        _groupInfoItem.interfaceHandle = _actionHandle;
        [_groupInfoItem setConversation:nil];
        [_groupInfoItem setEditing:true];
        TGCollectionMenuSection *groupInfoSection = [[TGCollectionMenuSection alloc] initWithItems:@[_groupInfoItem]];
        [self.menuSections addSection:groupInfoSection];
        
        _usersSection = [[TGCollectionMenuSection alloc] init];
        [self.menuSections addSection:_usersSection];
        
        _makeFieldFirstResponder = true;
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)createPressed
{
    if (_userIds.count != 0 && (_groupInfoItem.editingTitle.length != 0 || _createBroadcast))
    {
        if (_createBroadcast)
        {
            if (_onCreateBroadcastList != nil)
                _onCreateBroadcastList(_groupInfoItem.editingTitle, _userIds);
        }
        else
        {
            _progressWindow = [[TGProgressWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            [_progressWindow show:true];
            
            static int actionId = 0;
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/createChat/(%d)", actionId++] options:@{
                @"uids": _userIds,
                @"title": [_groupInfoItem.editingTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
            } watcher:self];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (_makeFieldFirstResponder)
    {
        _makeFieldFirstResponder = false;
        [_groupInfoItem makeNameFieldFirstResponder];
    }
}

- (void)setUserIds:(NSArray *)userIds
{
    _userIds = userIds;
    
    NSMutableArray *users = [[NSMutableArray alloc] init];
    for (NSNumber *nUid in _userIds)
    {
        TGUser *user = [TGDatabaseInstance() loadUser:[nUid int32Value]];
        if (user != nil)
            [users addObject:user];
    }
    
    NSUInteger usersSectionIndex = [self indexForSection:_usersSection];
    if (usersSectionIndex != NSNotFound)
    {
        for (int i = _usersSection.items.count - 1; i >= 0; i--)
        {
            [self.menuSections deleteItemFromSection:usersSectionIndex atIndex:0];
        }
    }
    
    for (TGUser *user in users)
    {
        TGGroupInfoUserCollectionItem *userItem = [[TGGroupInfoUserCollectionItem alloc] init];
        [userItem setUser:user];
        userItem.selectable = false;
        [userItem setCanEdit:false];
        [self.menuSections addItemToSection:usersSectionIndex item:userItem];
    }
    
    [self.collectionView reloadData];
}

#pragma mark -

- (void)actionStageActionRequested:(NSString *)action options:(id)__unused options
{
    if ([action isEqualToString:@"editedTitleChanged"])
    {
        self.navigationItem.rightBarButtonItem.enabled = _createBroadcast || [_groupInfoItem.editingTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length != 0;
        TGConversation *conversation = [[TGConversation alloc] init];
        conversation.chatTitle = _groupInfoItem.editingTitle;
        [_groupInfoItem setConversation:conversation];
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/tg/conversation/createChat/"])
    {
        TGDispatchOnMainThread(^
        {
            [_progressWindow dismiss:true];
            
            if (status == ASStatusSuccess)
            {
                TGConversation *conversation = ((SGraphObjectNode *)result).object;
                [[TGInterfaceManager instance] navigateToConversationWithId:conversation.conversationId conversation:nil];
            }
            else
            {
                TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"ConversationProfile.ErrorCreatingConversation") delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil];
                [alertView show];
            }
        });
    }
}

@end
