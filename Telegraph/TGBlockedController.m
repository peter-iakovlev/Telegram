/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGBlockedController.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGTelegraph.h"
#import "TGAppDelegate.h"
#import "TGTelegraphDialogListCompanion.h"
#import "TGInterfaceManager.h"

#import "TGButtonCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGUserCollectionItem.h"

#import "TGForwardTargetController.h"
#import "TGUser.h"
#import "TGConversation.h"

#import "TGBlockListRequestActor.h"

@interface TGBlockedController ()

@end

@implementation TGBlockedController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        [self setTitleText:TGLocalized(@"BlockedUsers.Title")];
        
        NSMutableArray *usersSectionItems = [[NSMutableArray alloc] init];
        [usersSectionItems addObject:[[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"BlockedUsers.AddNew") action:@selector(addNewPressed)]];
        
        TGCollectionMenuSection *usersSection = [[TGCollectionMenuSection alloc] initWithItems:usersSectionItems];
        UIEdgeInsets topSectionInsets = usersSection.insets;
        topSectionInsets.top = 32.0f;
        usersSection.insets = topSectionInsets;
        [self.menuSections addSection:usersSection];
        
        TGCollectionMenuSection *infoSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"BlockedUsers.Info")]
        ]];
        [self.menuSections addSection:infoSection];
        
        [self _copyUsersToCurrentList:[TGBlockListRequestActor loadCachedListSync]];
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            [ActionStageInstance() watchForPath:@"/tg/blockedUsers" watcher:self];
            [ActionStageInstance() requestActor:@"/tg/blockedUsers/(cached)" options:nil watcher:self];
        }];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

#pragma mark -

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

#pragma mark -

- (void)addNewPressed
{
    TGForwardTargetController *selectionController = [[TGForwardTargetController alloc] initWithSelectBlockTarget];
    selectionController.watcherHandle = _actionHandle;
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[selectionController]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

#pragma mark -

- (void)_unblockUserWithUid:(int32_t)uid
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
    
    if (wasEmpty != (((TGCollectionMenuSection *)self.menuSections.sections[0]).items.count <= 1))
        [self _updateEmptyState:true];
    
    static int actionId = 0;
    [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/changePeerBlockedStatus/(%d)", actionId++] options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithLongLong:uid], @"peerId", [[NSNumber alloc] initWithBool:false], @"block", nil] watcher:TGTelegraphInstance];
}

#pragma mark -

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"userItemDeleteRequested"])
    {
        int32_t uid = [options[@"uid"] int32Value];
        if (uid != 0)
            [self _unblockUserWithUid:uid];
    }
    else if ([action isEqualToString:@"userItemSelected"])
    {
        int32_t uid = [options[@"uid"] int32Value];
        if (uid != 0)
        {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [[TGInterfaceManager instance] navigateToProfileOfUser:uid];
            else
                [[TGInterfaceManager instance] navigateToConversationWithId:uid conversation:nil];
        }
    }
    else if ([action isEqualToString:@"blockUser"])
    {
        TGUser *user = options;
        if (user.uid != 0)
        {
            TGUser *user = options;
            if (user != nil)
            {
                int32_t uid = user.uid;
                bool alreadyInList = false;
                for (id item in ((TGCollectionMenuSection *)self.menuSections.sections[0]).items)
                {
                    if ([item isKindOfClass:[TGUserCollectionItem class]])
                    {
                        if (((TGUserCollectionItem *)item).user.uid == uid)
                        {
                            alreadyInList = true;
                            break;
                        }
                    }
                }
                
                if (alreadyInList)
                    [self dismissViewControllerAnimated:true completion:nil];
                else
                {
                    bool wasEmpty = ((TGCollectionMenuSection *)self.menuSections.sections[0]).items.count <= 1;
                    
                    TGUserCollectionItem *userItem = [[TGUserCollectionItem alloc] init];
                    userItem.user = user;
                    userItem.interfaceHandle = _actionHandle;
                    userItem.deselectAutomatically = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
                    
                    [self.menuSections insertItem:userItem toSection:0 atIndex:0];
                    [self.collectionView reloadData];
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                    {
                        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:false scrollPosition:UICollectionViewScrollPositionTop];
                    }
                    
                    static int actionId = 0;
                    [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/changePeerBlockedStatus/(%d)", actionId++] options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithLongLong:user.uid], @"peerId", [[NSNumber alloc] initWithBool:true], @"block", nil] watcher:TGTelegraphInstance];
                    
                    if (wasEmpty != (((TGCollectionMenuSection *)self.menuSections.sections[0]).items.count <= 1))
                        [self _updateEmptyState:false];
                    
                    [self dismissViewControllerAnimated:true completion:nil];
                }
            }
        }
    }
    else if ([action isEqualToString:@"leaveConversation"])
    {
        TGConversation *conversation = options;
        if (conversation.conversationId != 0)
        {
            [TGAppDelegateInstance.rootController.dialogListController.dialogListCompanion deleteItem:[[TGConversation alloc] initWithConversationId:conversation.conversationId unreadCount:0 serviceUnreadCount:0] animated:false];
            
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path hasPrefix:@"/tg/blockedUsers"])
    {
        [self actorCompleted:ASStatusSuccess path:path result:resource];
    }
}

- (bool)_isCurrentListEqualToUsers:(NSArray *)users
{
    NSArray *items = ((TGCollectionMenuSection *)self.menuSections.sections[0]).items;
    
    if (users.count != items.count - 1)
        return false;
    
    for (int i = 0; i < (int)users.count; i++)
    {
        if (((TGUserCollectionItem *)items[i]).user.uid != ((TGUser *)users[i]).uid)
            return false;
    }
    
    return true;
}

- (void)_copyUsersToCurrentList:(NSArray *)users
{
    if (self.menuSections.sections.count < 1)
        return;
    
    int insertIndex = MAX(0, (int)((TGCollectionMenuSection *)self.menuSections.sections[0]).items.count - 1);
    
    for (TGUser *user in users)
    {
        TGUserCollectionItem *item = [[TGUserCollectionItem alloc] init];
        item.user = user;
        item.interfaceHandle = _actionHandle;
        item.deselectAutomatically = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
        
        [self.menuSections insertItem:item toSection:0 atIndex:insertIndex];
        insertIndex++;
    }
    
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

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/tg/blockedUsers"])
    {
        if (status == ASStatusSuccess)
        {
            NSArray *currentUsers = ((SGraphObjectNode *)result).object;
            
            TGDispatchOnMainThread(^
            {
                if (![self _isCurrentListEqualToUsers:currentUsers])
                {
                    for (int i = (int)((TGCollectionMenuSection *)self.menuSections.sections[0]).items.count - 1; i >= 0; i--)
                    {
                        [self.menuSections deleteItemFromSection:0 atIndex:i];
                    }
                    
                    [self _copyUsersToCurrentList:currentUsers];
                    [self.collectionView reloadData];
                }
            });
        }
    }
}

@end
