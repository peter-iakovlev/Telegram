#import "TGChannelLinkSetupController.h"

#import "TGProgressWindow.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"
#import "ActionStage.h"

#import "TGCollectionMenuSection.h"
#import "TGCommentCollectionItem.h"
#import "TGUsernameCollectionItem.h"

#import "TGCollectionMenuLayout.h"

#import "TGAlertView.h"

#import "TGChannelManagementSignals.h"

#import "TGTelegramNetworking.h"

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

@interface TGChannelLinkSetupController ()
{
    TGConversation *_conversation;
    TGUsernameCollectionItem *_usernameItem;
    TGCommentCollectionItem *_invalidUsernameItem;
    TGCommentCollectionItem *_hintItem;
    
    SMetaDisposable *_checkUsernameDisposable;
    SMetaDisposable *_updateUsernameDisposable;
    
    void (^_block)(NSString *);
}

@end

@implementation TGChannelLinkSetupController

- (instancetype)initWithConversation:(TGConversation *)conversation
{
    self = [super init];
    if (self != nil)
    {
        _conversation = conversation;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithBlock:(void (^)(NSString *username))block
{
    self = [super init];
    if (self != nil)
    {
        _block = [block copy];
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.title = TGLocalized(@"Channel.Username.Title");
    [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
    
    _usernameItem = [[TGUsernameCollectionItem alloc] init];
    _usernameItem.username = _conversation.username;
    _usernameItem.usernameValid = true;
    _usernameItem.placeholder = @"";
    _usernameItem.title = @"";
    _usernameItem.prefix = @"telegram.me/";
    __weak TGChannelLinkSetupController *weakSelf = self;
    _usernameItem.usernameChanged = ^(NSString *username)
    {
        __strong TGChannelLinkSetupController *strongSelf = weakSelf;
        [strongSelf usernameChanged:username];
    };
    
    TGCommentCollectionItem *commentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Channel.Username.Help")];
    commentItem.topInset = 1.0f;
    
    _invalidUsernameItem = [[TGCommentCollectionItem alloc] init];
    _invalidUsernameItem.topInset = 6.0f;
    _invalidUsernameItem.alpha = 0.0f;
    _invalidUsernameItem.hidden = true;
    
    _hintItem = [[TGCommentCollectionItem alloc] init];
    _hintItem.topInset = 6.0f;
    _hintItem.alpha = 1.0f;
    _hintItem.hidden = false;
    _hintItem.action = ^
    {
        __strong TGChannelLinkSetupController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (strongSelf->_usernameItem.username.length != 0)
            {
                [[UIPasteboard generalPasteboard] setString:[[NSString alloc] initWithFormat:@"http://telegram.me/%@", strongSelf->_usernameItem.username]];
                [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Username.LinkCopied") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
            }
        }
    };
    
    [self updateLinkHint:_conversation.username];
    
    TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:@[_usernameItem, _invalidUsernameItem, commentItem, _hintItem]];
    section.insets = UIEdgeInsetsMake(32.0f, 0.0f, 0.0f, 0.0f);
    [self.menuSections addSection:section];
    
    _checkUsernameDisposable = [[SMetaDisposable alloc] init];
    _updateUsernameDisposable = [[SMetaDisposable alloc] init];
}

- (void)dealloc
{
    [_checkUsernameDisposable dispose];
    [_updateUsernameDisposable dispose];
}

- (BOOL)shouldAutorotate
{
    return true;
}

- (void)cancelPressed
{
    [self.view endEditing:true];
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)donePressed
{
    if (TGStringCompare(_usernameItem.username, _conversation.username))
    {
        [self.view endEditing:true];
        [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
    }
    else if (_usernameItem.username.length != 0 && ![self usernameIsValid:_usernameItem.username])
    {
        unichar c = [_usernameItem.username characterAtIndex:0];
        if (c >= '0' && c <= '9')
        {
            [[[TGAlertView alloc] initWithTitle:TGLocalized(@"Username.InvalidStartsWithNumber") message:nil cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:nil completionBlock:nil] show];
        }
        else
        {
            [[[TGAlertView alloc] initWithTitle:TGLocalized(@"Username.InvalidCharacters") message:nil cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:nil completionBlock:nil] show];
        }
    }
    else if (_usernameItem.username.length != 0 && _usernameItem.username.length < 5)
    {
        [[[TGAlertView alloc] initWithTitle:TGLocalized(@"Username.InvalidTooShort") message:nil cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:nil completionBlock:nil] show];
    }
    else
    {
        __weak TGChannelLinkSetupController *weakSelf = self;
        
        void (^continueSetup)() = ^{
            __strong TGChannelLinkSetupController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (strongSelf->_block != nil) {
                    [self.view endEditing:true];
                    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
                    
                    strongSelf->_block(strongSelf->_usernameItem.username);
                } else {
                    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                    [progressWindow show:true];
                    
                    __weak TGChannelLinkSetupController *weakSelf = self;
                    [[[[TGChannelManagementSignals updateChannelUsername:strongSelf->_conversation.conversationId accessHash:strongSelf->_conversation.accessHash username:strongSelf->_usernameItem.username] deliverOn:[SQueue mainQueue]] onDispose:^{
                        TGDispatchOnMainThread(^{
                            [progressWindow dismiss:true];
                        });
                    }] startWithNext:nil error:^(__unused id error) {
                        __strong TGChannelLinkSetupController *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            [[[TGAlertView alloc] initWithTitle:TGLocalized(@"Username.InvalidTaken") message:nil cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
                        }
                    } completed:^{
                        __strong TGChannelLinkSetupController *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            [strongSelf.view endEditing:true];
                            [strongSelf.presentingViewController dismissViewControllerAnimated:true completion:nil];
                        }
                    }];
                }
            }
        };
        
        if (_usernameItem.username.length != 0 && _conversation.username.length == 0) {
            [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Channel.Edit.PrivatePublicLinkAlert") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed) {
                if (okButtonPressed) {
                    continueSetup();
                }
            }] show];;
        } else {
            continueSetup();
        }
    }
}

- (void)setUsernameState:(TGUsernameControllerUsernameState)state username:(NSString *)username
{
    bool valid = false;
    switch (state)
    {
        case TGUsernameControllerUsernameStateNone:
            _invalidUsernameItem.showProgress = false;
            valid = true;
            break;
        case TGUsernameControllerUsernameStateValid:
            _invalidUsernameItem.showProgress = false;
            valid = true;
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
    
    self.navigationItem.rightBarButtonItem.enabled = !_invalidUsernameItem.showProgress && valid;
    
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
        
        __weak TGChannelLinkSetupController *weakSelf = self;
        [_checkUsernameDisposable setDisposable:[[checkSignal deliverOn:[SQueue mainQueue]] startWithNext:nil error:^(id error) {
            __strong TGChannelLinkSetupController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                NSString *errorText = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
                TGUsernameControllerUsernameState state = TGUsernameControllerUsernameStateTaken;
                if ([errorText isEqual:@"CHANNELS_ADMIN_PUBLIC_TOO_MUCH"]) {
                    state = TGUsernameControllerUsernameStateTooManyUsernames;
                }
                [strongSelf setUsernameState:state username:strongSelf->_usernameItem.username];
            }
        } completed:^{
            __strong TGChannelLinkSetupController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                strongSelf->_usernameItem.usernameChecking = false;
                [strongSelf setUsernameState:TGUsernameControllerUsernameStateValid username:strongSelf->_usernameItem.username];
            }
        }]];
    }
    
    [self updateLinkHint:username];
}

- (void)updateLinkHint:(NSString *)username
{
    if (username.length == 0)
        _hintItem.text = nil;
    else
        [_hintItem setFormattedText:[[NSString alloc] initWithFormat:TGLocalized(@"Channel.Username.LinkHint"), username]];
}

@end
