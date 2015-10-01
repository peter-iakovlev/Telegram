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
}

@end

@implementation TGSetupChannelAfterCreationController

- (instancetype)initWithConversation:(TGConversation *)conversation exportedLink:(NSString *)exportedLink {
    self = [super init];
    if (self != nil) {
        self.title = TGLocalized(@"Channel.Setup.Title");
        
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Next") style:UIBarButtonItemStyleDone target:self action:@selector(nextPressed)] animated:false];
        
        _conversation = conversation;
        _exportedLink = exportedLink;
        _isPrivate = false;
        
        _checkUsernameDisposable = [[SMetaDisposable alloc] init];
        _updateUsernameDisposable = [[SMetaDisposable alloc] init];
        
        TGHeaderCollectionItem *typeItem = [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Setup.TypeHeader")];
        _publicItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Setup.TypePublic") action:@selector(publicPressed)];
        _privateItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Setup.TypePrivate") action:@selector(privatePressed)];
        _typeHelpItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Channel.Setup.TypePrivateHelp")];
        
        TGCollectionMenuSection *typeSection =  [[TGCollectionMenuSection alloc] initWithItems:@[typeItem, _publicItem, _privateItem, _typeHelpItem]];
        UIEdgeInsets topSectionInsets = typeSection.insets;
        topSectionInsets.top = 32.0f;
        typeSection.insets = topSectionInsets;
        [self.menuSections addSection:typeSection];
        
        _usernameItem = [[TGUsernameCollectionItem alloc] init];
        _usernameItem.username = _conversation.username;
        _usernameItem.usernameValid = true;
        _usernameItem.placeholder = @"";
        _usernameItem.title = @"";
        _usernameItem.prefix = @"telegram.me/";
        __weak TGSetupChannelAfterCreationController *weakSelf = self;
        _usernameItem.usernameChanged = ^(NSString *username)
        {
            __strong TGSetupChannelAfterCreationController *strongSelf = weakSelf;
            [strongSelf usernameChanged:username];
        };
        
        TGCommentCollectionItem *publicCommentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Channel.Username.CreatePublicLinkHelp")];
        publicCommentItem.topInset = 1.0f;
        
        TGCommentCollectionItem *privateCommentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Channel.Username.CreatePrivateLinkHelp")];
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
        
        _linkPrivateSection = [[TGCollectionMenuSection alloc] initWithItems:@[_privateLinkItem, privateCommentItem]];
        
        if (_isPrivate) {
            [self.menuSections addSection:_linkPrivateSection];
        } else {
            [self.menuSections addSection:_linkPublicSection];
        }
        
        _commentsEnabledItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Username.CreateCommentsEnabled") isOn:!conversation.channelIsReadOnly];
        TGCommentCollectionItem *commentsCommentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Channel.Username.CreateCommentsHelp")];
        commentsCommentItem.topInset = 1.0f;
        
        TGCollectionMenuSection *commentsSection = [[TGCollectionMenuSection alloc] initWithItems:@[_commentsEnabledItem, commentsCommentItem]];
        //[self.menuSections addSection:commentsSection];
        
        [self updateIsPrivate];
    }
    return self;
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
    
    if (_commentsEnabledItem.isOn != !_conversation.channelIsReadOnly) {
        setupCommentsSignal = [TGChannelManagementSignals toggleChannelCommentsEnabled:_conversation.conversationId accessHash:_conversation.accessHash enabled:_commentsEnabledItem.isOn];
    }
    
    if (!_isPrivate && _usernameItem.username.length != 0) {
        setupLinkSignal = [TGChannelManagementSignals updateChannelUsername:_conversation.conversationId accessHash:_conversation.accessHash username:_usernameItem.username];
    }
    
    __weak TGSetupChannelAfterCreationController *weakSelf = self;
    [[[[SSignal combineSignals:@[setupCommentsSignal, setupLinkSignal]] deliverOn:[SQueue mainQueue]] onDispose:^{
        TGDispatchOnMainThread(^{
            [progressWindow dismiss:true];
        });
    }] startWithNext:nil completed:^{
        __strong TGSetupChannelAfterCreationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            TGSelectContactController *createGroupController = [[TGSelectContactController alloc] initWithCreateGroup:false createEncrypted:false createBroadcast:false createChannel:true inviteToChannel:false];
            createGroupController.channelConversation = strongSelf->_conversation;
            
            NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:strongSelf.navigationController.viewControllers];
            if (viewControllers.count != 1) {
                [viewControllers removeObjectsInRange:NSMakeRange(1, viewControllers.count - 1)];
            }
            [viewControllers addObject:createGroupController];
            [strongSelf.navigationController setViewControllers:viewControllers animated:true];
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
        
        _typeHelpItem.text = TGLocalized(@"Channel.Setup.TypePrivateHelp");
        
        NSUInteger index = [self indexForSection:_linkPublicSection];
        if (index != NSNotFound) {
            [self.menuSections deleteSection:index];
            [self.menuSections insertSection:_linkPrivateSection atIndex:index];
            [self.collectionView reloadData];
        }
        
        NSIndexPath *indexPath = [self indexPathForItem:_privateItem];
        [self.collectionView selectItemAtIndexPath:indexPath animated:false scrollPosition:UICollectionViewScrollPositionNone];
        [self.collectionView deselectItemAtIndexPath:indexPath animated:true];
    } else {
        [_privateItem setIsChecked:false];
        [_publicItem setIsChecked:true];
        
        _typeHelpItem.text = TGLocalized(@"Channel.Setup.TypePublicHelp");
        
        NSUInteger index = [self indexForSection:_linkPrivateSection];
        if (index != NSNotFound) {
            [self.menuSections deleteSection:index];
            [self.menuSections insertSection:_linkPublicSection atIndex:index];
            [self.collectionView reloadData];
        }
        
        NSIndexPath *indexPath = [self indexPathForItem:_publicItem];
        [self.collectionView selectItemAtIndexPath:indexPath animated:false scrollPosition:UICollectionViewScrollPositionNone];
        [self.collectionView deselectItemAtIndexPath:indexPath animated:true];
    }
}

- (void)setUsernameState:(TGUsernameControllerUsernameState)state username:(NSString *)username
{
    _usernameState = state;
    switch (state)
    {
        case TGUsernameControllerUsernameStateNone:
            break;
        case TGUsernameControllerUsernameStateValid:
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
                 [_invalidUsernameItem setText:TGLocalized(@"Channel.Username.InvalidTooShort")];
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
                 [_invalidUsernameItem setText:TGLocalized(@"Channel.Username.InvalidStartsWithNumber")];
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

@end
