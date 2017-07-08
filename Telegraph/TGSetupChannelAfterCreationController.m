#import "TGSetupChannelAfterCreationController.h"

#import "TGConversation.h"
#import "TGChannelManagementSignals.h"
#import "TGDatabase.h"

#import "TGHeaderCollectionItem.h"
#import "TGCheckCollectionItem.h"
#import "TGUsernameCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGTelegramNetworking.h"

#import "TGCollectionMultilineInputItem.h"

#import "TGSwitchCollectionItem.h"

#import "TGProgressWindow.h"
#import "TGAlertView.h"

#import "TGSelectContactController.h"
#import "TGGroupInfoShareLinkController.h"

#import "TGGroupManagementSignals.h"
#import "TGRevokeLinkConversationItem.h"

typedef enum {
    TGUsernameControllerUsernameStateNone,
    TGUsernameControllerUsernameStateValid,
    TGUsernameControllerUsernameStateTooShort,
    TGUsernameControllerUsernameStateInvalidCharacters,
    TGUsernameControllerUsernameStateStartsWithNumber,
    TGUsernameControllerUsernameStateTaken,
    TGUsernameControllerUsernameStateChecking,
    TGUsernameControllerUsernameStateTooManyUsernames
} TGUsernameControllerUsernameState;

@interface TGSetupChannelAfterCreationController () {
    TGConversation *_conversation;
    NSString *_exportedLink;
    
    UIBarButtonItem *_nextItem;
    
    bool _isPrivate;
    TGCheckCollectionItem *_publicItem;
    TGCheckCollectionItem *_privateItem;
    TGCommentCollectionItem *_typeHelpItem;
    
    TGUsernameCollectionItem *_usernameItem;
    TGCommentCollectionItem *_invalidUsernameItem;
    
    TGCollectionMultilineInputItem *_privateLinkItem;
    
    TGCollectionMenuSection *_linkPrivateSection;
    TGCollectionMenuSection *_linkPublicSection;
    
    SMetaDisposable *_checkUsernameDisposable;
    SMetaDisposable *_updateUsernameDisposable;
    
    TGSwitchCollectionItem *_commentsEnabledItem;
    
    TGUsernameControllerUsernameState _usernameState;
    
    bool _modal;
    
    SVariable *_conversationsToBeRemovedToAssignPublicUsernames;
    SMetaDisposable *_conversationsToBeRemovedToAssignPublicUsernamesDisposable;
    TGCollectionMenuSection *_removeExistingInfoSection;
    TGCollectionMenuSection *_removeExistingConversationsSection;
    NSArray<TGConversation *> *_conversationsToDelete;
    
    TGCollectionMenuSection *_typeSection;
}

@end

@implementation TGSetupChannelAfterCreationController

- (instancetype)initWithConversation:(TGConversation *)conversation exportedLink:(NSString *)exportedLink modal:(bool)modal conversationsToDeleteForPublicUsernames:(NSArray *)conversationsToDeleteForPublicUsernames checkConversationsToDeleteForPublicUsernames:(bool)checkConversationsToDeleteForPublicUsernames {
    self = [super init];
    if (self != nil) {
        _conversationsToBeRemovedToAssignPublicUsernames = [[SVariable alloc] init];
        
        self.title = conversation.isChannelGroup ? TGLocalized(@"Conversation.InfoGroup") : TGLocalized(@"Channel.Setup.Title");
        
        _modal = modal;
        
        if (modal) {
            [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)] animated:false];
            _nextItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(nextPressed)];
            [self setRightBarButtonItem:_nextItem animated:false];
        } else {
            [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Next") style:UIBarButtonItemStyleDone target:self action:@selector(nextPressed)] animated:false];
        }
        
        _conversation = conversation;
        _exportedLink = exportedLink;
        _isPrivate = _conversation.isChannelGroup ? _conversation.username.length == 0 : false;
        
        _checkUsernameDisposable = [[SMetaDisposable alloc] init];
        _updateUsernameDisposable = [[SMetaDisposable alloc] init];
        
        TGHeaderCollectionItem *typeItem = [[TGHeaderCollectionItem alloc] initWithTitle:conversation.isChannelGroup ? TGLocalized(@"Group.Setup.TypeHeader") : TGLocalized(@"Channel.Setup.TypeHeader")];
        _publicItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Setup.TypePublic") action:@selector(publicPressed)];
        _privateItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Setup.TypePrivate") action:@selector(privatePressed)];
        _typeHelpItem = [[TGCommentCollectionItem alloc] initWithFormattedText:@""];
        
        _typeSection =  [[TGCollectionMenuSection alloc] initWithItems:@[typeItem, _publicItem, _privateItem, _typeHelpItem]];
        UIEdgeInsets topSectionInsets = _typeSection.insets;
        topSectionInsets.top = 32.0f;
        _typeSection.insets = topSectionInsets;
        [self.menuSections addSection:_typeSection];
        
        _usernameItem = [[TGUsernameCollectionItem alloc] init];
        _usernameItem.username = _conversation.username;
        _usernameItem.usernameValid = true;
        _usernameItem.placeholder = @"";
        _usernameItem.title = @"";
        _usernameItem.prefix = @"t.me/";
        __weak TGSetupChannelAfterCreationController *weakSelf = self;
        _usernameItem.usernameChanged = ^(NSString *username)
        {
            __strong TGSetupChannelAfterCreationController *strongSelf = weakSelf;
            [strongSelf usernameChanged:username];
        };
        
        TGCommentCollectionItem *publicCommentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:_conversation.isChannelGroup ? TGLocalized(@"Group.Username.CreatePublicLinkHelp") : TGLocalized(@"Channel.Username.CreatePublicLinkHelp")];
        publicCommentItem.topInset = 1.0f;
        
        TGCommentCollectionItem *privateCommentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:_conversation.isChannelGroup ? TGLocalized(@"Group.Username.CreatePrivateLinkHelp") : TGLocalized(@"Channel.Username.CreatePrivateLinkHelp")];
        privateCommentItem.topInset = 1.0f;
        
        _invalidUsernameItem = [[TGCommentCollectionItem alloc] init];
        _invalidUsernameItem.topInset = 6.0f;
        _invalidUsernameItem.alpha = 0.0f;
        _invalidUsernameItem.hidden = true;
        
        _linkPublicSection = [[TGCollectionMenuSection alloc] initWithItems:@[_usernameItem, _invalidUsernameItem, publicCommentItem]];
        
        _privateLinkItem = [[TGCollectionMultilineInputItem alloc] init];
        _privateLinkItem.text = _exportedLink;
        _privateLinkItem.editable = false;
        _privateLinkItem.deselectAutomatically = true;
        _privateLinkItem.selected = ^{
            __strong TGSetupChannelAfterCreationController *strongSelf = weakSelf;
            [strongSelf privateLinkPressed];
        };
        
        _linkPrivateSection = [[TGCollectionMenuSection alloc] initWithItems:@[_privateLinkItem, privateCommentItem]];
        
        if (_isPrivate) {
            [self.menuSections addSection:_linkPrivateSection];
        } else {
            [self.menuSections addSection:_linkPublicSection];
        }
        
        _commentsEnabledItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Username.CreateCommentsEnabled") isOn:!conversation.channelIsReadOnly];
        TGCommentCollectionItem *commentsCommentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Channel.Username.CreateCommentsHelp")];
        commentsCommentItem.topInset = 1.0f;
        
        _nextItem.enabled = _conversation.username.length != 0 || _isPrivate;
        
        [self updateIsPrivate];
        
        TGCommentCollectionItem *removeCommentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Group.Username.RemoveExistingUsernamesInfo")];
        removeCommentItem.textColor = UIColorRGB(0xcf3030);
        _removeExistingInfoSection = [[TGCollectionMenuSection alloc] initWithItems:@[removeCommentItem]];
        _removeExistingInfoSection.insets = UIEdgeInsetsMake(16.0f, 0.0f, 0.0f, 0.0f);
        _removeExistingConversationsSection = [[TGCollectionMenuSection alloc] initWithItems:@[]];
        _removeExistingConversationsSection.insets = UIEdgeInsetsMake(8.0f, 0.0f, 8.0f, 0.0f);
        
        _conversationsToBeRemovedToAssignPublicUsernamesDisposable = [[SMetaDisposable alloc] init];
        [_conversationsToBeRemovedToAssignPublicUsernamesDisposable setDisposable:[[_conversationsToBeRemovedToAssignPublicUsernames.signal deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *conversations) {
            __strong TGSetupChannelAfterCreationController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf setConversationsToDelete:conversations force:false];
            }
        }]];
        [_conversationsToBeRemovedToAssignPublicUsernames set:[SSignal single:conversationsToDeleteForPublicUsernames]];
        
        if (checkConversationsToDeleteForPublicUsernames) {
            [self updateCanCreateUsernames];
        }
    }
    return self;
}

- (void)dealloc {
    [_conversationsToBeRemovedToAssignPublicUsernamesDisposable dispose];
}

- (void)updateCanCreateUsernames {
    [_conversationsToBeRemovedToAssignPublicUsernames set:[TGGroupManagementSignals conversationsToBeRemovedToAssignPublicUsernames:_conversation.conversationId accessHash:_conversation.accessHash]];
}

- (void)loadView {
    [super loadView];
    
    [self enterEditingMode:false];
}

- (void)cancelPressed {
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)nextPressed {
    if (!_isPrivate && _usernameState == TGUsernameControllerUsernameStateChecking) {
        return;
    }
    
    if (!_isPrivate && (_usernameItem.username.length == 0 || _usernameState != TGUsernameControllerUsernameStateValid)) {
        __weak TGSetupChannelAfterCreationController *weakSelf = self;
        [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Channel.Setup.PublicNoLink") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:^(__unused bool okButtonPressed) {
            __strong TGSetupChannelAfterCreationController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf->_usernameItem becomeFirstResponder];
            }
        }] show];
        return;
    }
    
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow show:true];
    
    SSignal *setupCommentsSignal = [SSignal complete];
    SSignal *setupLinkSignal = [SSignal complete];
    
    NSString *username = _isPrivate ? @"" : _usernameItem.username;
    
    if (!TGStringCompare(_conversation.username, username)) {
        setupLinkSignal = [TGChannelManagementSignals updateChannelUsername:_conversation.conversationId accessHash:_conversation.accessHash username:username];
    }
    
    __weak TGSetupChannelAfterCreationController *weakSelf = self;
    [[[[SSignal combineSignals:@[setupCommentsSignal, setupLinkSignal]] deliverOn:[SQueue mainQueue]] onDispose:^{
        TGDispatchOnMainThread(^{
            [progressWindow dismiss:true];
        });
    }] startWithNext:nil completed:^{
        __strong TGSetupChannelAfterCreationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (strongSelf->_modal) {
                [strongSelf.presentingViewController dismissViewControllerAnimated:true completion:nil];
            } else {
                TGSelectContactController *createGroupController = [[TGSelectContactController alloc] initWithCreateGroup:false createEncrypted:false createBroadcast:false createChannel:true inviteToChannel:false showLink:false];
                createGroupController.channelConversation = strongSelf->_conversation;
                
                NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:strongSelf.navigationController.viewControllers];
                if (viewControllers.count != 1) {
                    [viewControllers removeObjectsInRange:NSMakeRange(1, viewControllers.count - 1)];
                }
                [viewControllers addObject:createGroupController];
                [strongSelf.navigationController setViewControllers:viewControllers animated:true];
            }
        }
    }];
}

- (void)_resetCollectionView {
    [super _resetCollectionView];
    
    if (iosMajorVersion() >= 7) {
        self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
}

- (void)updateIsPrivate {
    [self.collectionView deselectItemAtIndexPath:self.collectionView.indexPathsForSelectedItems.firstObject animated:false];
    
    if (_isPrivate) {
        [_privateItem setIsChecked:true];
        [_publicItem setIsChecked:false];
        
        _typeHelpItem.text = _conversation.isChannelGroup ? TGLocalized(@"Group.Setup.TypePrivateHelp") : TGLocalized(@"Channel.Setup.TypePrivateHelp");
        
        [self setConversationsToDelete:_conversationsToDelete force:true];
        
        NSIndexPath *indexPath = [self indexPathForItem:_privateItem];
        [self.collectionView selectItemAtIndexPath:indexPath animated:false scrollPosition:UICollectionViewScrollPositionNone];
        [self.collectionView deselectItemAtIndexPath:indexPath animated:true];
    } else {
        [_privateItem setIsChecked:false];
        [_publicItem setIsChecked:true];
        
        _typeHelpItem.text = _conversation.isChannelGroup ? TGLocalized(@"Group.Setup.TypePublicHelp") : TGLocalized(@"Channel.Setup.TypePublicHelp");
        
        [self setConversationsToDelete:_conversationsToDelete force:true];
        
        /*NSUInteger index = [self indexForSection:_linkPrivateSection];
        if (index != NSNotFound) {
            [self.menuSections deleteSection:index];
            [self.menuSections insertSection:_linkPublicSection atIndex:index];
            [self.collectionView reloadData];
        }*/
        
        NSIndexPath *indexPath = [self indexPathForItem:_publicItem];
        [self.collectionView selectItemAtIndexPath:indexPath animated:false scrollPosition:UICollectionViewScrollPositionNone];
        [self.collectionView deselectItemAtIndexPath:indexPath animated:true];
    }
    
    _nextItem.enabled = _usernameState == TGUsernameControllerUsernameStateValid || _isPrivate;
}

- (void)setUsernameState:(TGUsernameControllerUsernameState)state username:(NSString *)username
{
    _usernameState = state;
    bool valid = false;
    switch (state)
    {
        case TGUsernameControllerUsernameStateNone:
            break;
        case TGUsernameControllerUsernameStateValid:
            valid = true;
            _invalidUsernameItem.showProgress = false;
            break;
        case TGUsernameControllerUsernameStateTooShort:
            _invalidUsernameItem.showProgress = false;
            break;
        case TGUsernameControllerUsernameStateInvalidCharacters:
            _invalidUsernameItem.showProgress = false;
            break;
        case TGUsernameControllerUsernameStateStartsWithNumber:
            _invalidUsernameItem.showProgress = false;
            break;
        case TGUsernameControllerUsernameStateTaken:
            _invalidUsernameItem.showProgress = false;
            break;
        case TGUsernameControllerUsernameStateTooManyUsernames:
            _invalidUsernameItem.showProgress = false;
            break;
        case TGUsernameControllerUsernameStateChecking:
            _invalidUsernameItem.showProgress = true;
            break;
    }
    
    _nextItem.enabled = valid || _isPrivate;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
     {
         switch (state)
         {
             case TGUsernameControllerUsernameStateNone:
                 _invalidUsernameItem.alpha = 0.0f;
                 _invalidUsernameItem.hidden = true;
                 break;
             case TGUsernameControllerUsernameStateValid:
                 [_invalidUsernameItem setText:[[NSString alloc] initWithFormat:TGLocalized(@"Channel.Username.UsernameIsAvailable"), username]];
                 _invalidUsernameItem.alpha = 1.0f;
                 _invalidUsernameItem.hidden = false;
                 _invalidUsernameItem.showProgress = false;
                 [_invalidUsernameItem setTextColor:UIColorRGB(0x26972c)];
                 break;
             case TGUsernameControllerUsernameStateTooShort:
                 [_invalidUsernameItem setText:_conversation.isChannelGroup ? TGLocalized(@"Group.Username.InvalidTooShort") : TGLocalized(@"Channel.Username.InvalidTooShort")];
                 _invalidUsernameItem.alpha = 1.0f;
                 _invalidUsernameItem.hidden = false;
                 _invalidUsernameItem.showProgress = false;
                 [_invalidUsernameItem setTextColor:UIColorRGB(0xcf3030)];
                 break;
             case TGUsernameControllerUsernameStateInvalidCharacters:
                 [_invalidUsernameItem setText:TGLocalized(@"Channel.Username.InvalidCharacters")];
                 _invalidUsernameItem.alpha = 1.0f;
                 _invalidUsernameItem.hidden = false;
                 _invalidUsernameItem.showProgress = false;
                 [_invalidUsernameItem setTextColor:UIColorRGB(0xcf3030)];
                 break;
             case TGUsernameControllerUsernameStateStartsWithNumber:
                 [_invalidUsernameItem setText:_conversation.isChannelGroup ? TGLocalized(@"Group.Username.InvalidStartsWithNumber") :  TGLocalized(@"Channel.Username.InvalidStartsWithNumber")];
                 _invalidUsernameItem.alpha = 1.0f;
                 _invalidUsernameItem.hidden = false;
                 _invalidUsernameItem.showProgress = false;
                 [_invalidUsernameItem setTextColor:UIColorRGB(0xcf3030)];
                 break;
             case TGUsernameControllerUsernameStateTaken:
                 [_invalidUsernameItem setText:TGLocalized(@"Channel.Username.InvalidTaken")];
                 _invalidUsernameItem.alpha = 1.0f;
                 _invalidUsernameItem.hidden = false;
                 _invalidUsernameItem.showProgress = false;
                 [_invalidUsernameItem setTextColor:UIColorRGB(0xcf3030)];
                 break;
             case TGUsernameControllerUsernameStateTooManyUsernames:
                 [_invalidUsernameItem setText:TGLocalized(@"Channel.Username.InvalidTooManyUsernames")];
                 _invalidUsernameItem.alpha = 1.0f;
                 _invalidUsernameItem.hidden = false;
                 _invalidUsernameItem.showProgress = false;
                 [_invalidUsernameItem setTextColor:UIColorRGB(0xcf3030)];
                 break;
             case TGUsernameControllerUsernameStateChecking:
                 [_invalidUsernameItem setText:[[NSString alloc] initWithFormat:@"       %@", TGLocalized(@"Channel.Username.CheckingUsername")]];
                 _invalidUsernameItem.alpha = 1.0f;
                 _invalidUsernameItem.hidden = false;
                 _invalidUsernameItem.showProgress = true;
                 [_invalidUsernameItem setTextColor:UIColorRGB(0x6d6d72)];
                 break;
         }
         
         [self.collectionLayout invalidateLayout];
         [self.collectionView layoutSubviews];
     } completion:nil];
}

- (void)usernameChanged:(NSString *)username
{
    [_checkUsernameDisposable setDisposable:nil];
    
    if (username.length == 0)
    {
        [self setUsernameState:TGUsernameControllerUsernameStateNone username:username];
    }
    else if (![self usernameIsValid:username])
    {
        unichar c = [username characterAtIndex:0];
        TGUsernameControllerUsernameState state;
        if (c >= '0' && c <= '9')
            state = TGUsernameControllerUsernameStateStartsWithNumber;
        else
            state = TGUsernameControllerUsernameStateInvalidCharacters;
        [self setUsernameState:state username:username];
    }
    else if (username.length < 5)
    {
        [self setUsernameState:TGUsernameControllerUsernameStateTooShort username:username];
    }
    else
    {
        [self setUsernameState:TGUsernameControllerUsernameStateChecking username:username];
        
        SSignal *checkSignal = [[[SSignal complete] delay:0.2 onQueue:[SQueue mainQueue]] then:[TGChannelManagementSignals checkChannelUsername:_conversation.conversationId accessHash:_conversation.accessHash username:username]];
        
        __weak TGSetupChannelAfterCreationController *weakSelf = self;
        [_checkUsernameDisposable setDisposable:[[checkSignal deliverOn:[SQueue mainQueue]] startWithNext:nil error:^(id error) {
            __strong TGSetupChannelAfterCreationController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                NSString *errorText = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
                TGUsernameControllerUsernameState state = TGUsernameControllerUsernameStateTaken;
                if ([errorText isEqual:@"CHANNELS_ADMIN_PUBLIC_TOO_MUCH"]) {
                    state = TGUsernameControllerUsernameStateTooManyUsernames;
                }
                [strongSelf setUsernameState:state username:strongSelf->_usernameItem.username];
            }
        } completed:^{
            __strong TGSetupChannelAfterCreationController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                strongSelf->_usernameItem.usernameChecking = false;
                [strongSelf setUsernameState:TGUsernameControllerUsernameStateValid username:strongSelf->_usernameItem.username];
            }
        }]];
    }
}

- (bool)usernameIsValid:(NSString *)username
{
    for (NSUInteger i = 0; i < username.length; i++)
    {
        unichar c = [username characterAtIndex:i];
        if (c == '_' && i != 0 && i != username.length - 1)
            continue;
        if (!((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (i > 0 && c >= '0' && c <= '9')))
            return false;
    }
    
    return true;
}

- (void)publicPressed {
    if (_isPrivate) {
        _isPrivate = false;
        [self updateIsPrivate];
    }
}

- (void)privatePressed {
    if (!_isPrivate) {
        _isPrivate = true;
        [self updateIsPrivate];
    }
}

- (void)privateLinkPressed {
    if (!_modal)
        return;
    
    __weak TGSetupChannelAfterCreationController *weakSelf = self;
    TGGroupInfoShareLinkController *controller = [[TGGroupInfoShareLinkController alloc] initWithPeerId:_conversation.conversationId accessHash:_conversation.accessHash currentLink:_exportedLink];
    controller.linkChanged = ^(NSString *link) {
        __strong TGSetupChannelAfterCreationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_exportedLink = link;
        strongSelf->_privateLinkItem.text = link;
        [strongSelf.collectionLayout invalidateLayout];
        [strongSelf.collectionView layoutSubviews];
    };
    [self.navigationController pushViewController:controller animated:true];
}

- (void)setConversationsToDelete:(NSArray<TGConversation *> *)conversationsToDelete force:(bool)force {
    if ([_conversationsToDelete isEqual:conversationsToDelete] && !force) {
        return;
    }
    
    _conversationsToDelete = conversationsToDelete;
    
    while (self.menuSections.sections.count != 0) {
        [self.menuSections deleteSection:0];
    }
    
    [self.menuSections addSection:_typeSection];
    if (_isPrivate) {
        [self.menuSections addSection:_linkPrivateSection];
    } else {
        if (_conversationsToDelete.count == 0) {
            [self.menuSections addSection:_linkPublicSection];
        } else {
            while (_removeExistingConversationsSection.items.count != 0) {
                [_removeExistingConversationsSection deleteItemAtIndex:0];
            }
            
            __weak TGSetupChannelAfterCreationController *weakSelf = self;
            for (TGConversation *conversation in _conversationsToDelete) {
                TGRevokeLinkConversationItem *item = [[TGRevokeLinkConversationItem alloc] initWithConversation:conversation];
                item.revoke = ^{
                    __strong TGSetupChannelAfterCreationController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [strongSelf revokeUsernameFromConversation:conversation];
                    }
                };
                [_removeExistingConversationsSection addItem:item];
            }
            
            [self.menuSections addSection:_removeExistingInfoSection];
            [self.menuSections addSection:_removeExistingConversationsSection];
        }
    }
    
    [self.collectionView reloadData];
}

- (void)revokeUsernameFromConversation:(TGConversation *)conversation {
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow showWithDelay:0.1];
    
    __weak TGSetupChannelAfterCreationController *weakSelf = self;
    [[[[[[TGChannelManagementSignals updateChannelUsername:conversation.conversationId accessHash:conversation.accessHash username:@""] mapToSignal:^SSignal *(__unused id result) {
        return [SSignal complete];
    }] then:[TGGroupManagementSignals conversationsToBeRemovedToAssignPublicUsernames:_conversation.conversationId accessHash:_conversation.accessHash]] deliverOn:[SQueue mainQueue]] onDispose:^{
        TGDispatchOnMainThread(^{
            [progressWindow dismiss:true];;
        });
    }] startWithNext:^(NSArray *conversations) {
        __strong TGSetupChannelAfterCreationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf->_conversationsToBeRemovedToAssignPublicUsernames set:[SSignal single:conversations]];
        }
    }];
}

@end
