#import "TGChatsController.h"

#import "TGBridgeClient.h"
#import "TGBridgeContext.h"
#import "TGBridgeChatListSignals.h"
#import "TGBridgeChat.h"
#import "TGBridgeUser.h"
#import "TGBridgeUserCache.h"

#import "TGBridgeSendMessageSignals.h"

#import "TGInputController.h"

#import "WKInterfaceTable+TGDataDrivenTable.h"
#import "TGTableDeltaUpdater.h"
#import "TGInterfaceMenu.h"

#import "TGChatsRowController.h"

#import "TGComposeController.h"

#import "TGNeoConversationController.h"

#import "TGExtensionDelegate.h"

#import "TGFileCache.h"

NSString *const TGChatsControllerIdentifier = @"TGChatsController";
const NSUInteger TGChatsControllerInitialCount = 3;
const NSUInteger TGChatsControllerLimit = 12;

@interface TGChatsController() <TGTableDataSource>
{
    SMetaDisposable *_reachabilityDisposable;
    SMetaDisposable *_contextDisposable;
    SMetaDisposable *_chatListDisposable;
    SMetaDisposable *_stateDisposable;
    
    SMetaDisposable *_replyDisposable;
    
    bool _initialized;
    bool _loadedStartup;
    
    bool _reachable;
    TGBridgeContext *_context;
    TGBridgeSynchronizationStateValue _syncState;
    
    NSArray *_chatModels;
    NSArray *_currentChatModels;
    
    TGInterfaceMenu *_menu;
}

@property (nonatomic, copy) void (^replyRestoreBlock)(void);

@end

@implementation TGChatsController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _reachabilityDisposable = [[SMetaDisposable alloc] init];
        _contextDisposable = [[SMetaDisposable alloc] init];
        _chatListDisposable = [[SMetaDisposable alloc] init];
        _stateDisposable = [[SMetaDisposable alloc] init];
        _replyDisposable = [[SMetaDisposable alloc] init];
        
        self.title = TGLocalized(@"App.Name");
        
        _menu = [[TGInterfaceMenu alloc] initForInterfaceController:self];
        self.table.tableDataSource = self;
        
        [self.table _setInitialHidden:true];
        [self.authAlertGroup _setInitialHidden:true];
        [self.authAlertDescLabel _setInitialHidden:true];
    }
    return self;
}

- (void)dealloc
{
    [_reachabilityDisposable dispose];
    [_chatListDisposable dispose];
    [_stateDisposable dispose];
    [_replyDisposable dispose];
}

- (void)configureWithContext:(id<TGInterfaceContext>)context
{
    __weak TGChatsController *weakSelf = self;
    
    [_reachabilityDisposable setDisposable:[[[TGBridgeClient instance] reachabilitySignal] startWithNext:^(NSNumber *next)
    {
        __strong TGChatsController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        bool reachable = next.boolValue;
        strongSelf->_reachable = reachable;
        
        if (strongSelf->_initialized)
        {
            [strongSelf performInterfaceUpdate:^(bool animated)
            {
                __strong TGChatsController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                 
                [strongSelf reloadData];
            }];
        }
    }]];
    
    [_contextDisposable setDisposable:[[[[TGBridgeClient instance] contextSignal] deliverOn:[SQueue mainQueue]] startWithNext:^(TGBridgeContext *next)
    {
        __strong TGChatsController *strongSelf = weakSelf;
        if (strongSelf == nil || [strongSelf->_context isEqual:next])
            return;
        
        strongSelf->_initialized = true;
        strongSelf->_context = next;
        
        if (next.authorized && next.userId != 0)
        {
            void (^updateBlock)(NSDictionary *) = ^(NSDictionary *models)
            {
                __strong TGChatsController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                strongSelf->_chatModels = models[TGBridgeChatsArrayKey];
                [[TGBridgeUserCache instance] storeUsers:[models[TGBridgeUsersDictionaryKey] allValues]];
                
                [strongSelf performInterfaceUpdate:^(bool animated)
                {
                    __strong TGChatsController *strongSelf = weakSelf;
                    if (strongSelf == nil)
                        return;
                    
                    [strongSelf reloadData];
                }];
            };
            
            TGTick;
            if (!strongSelf->_loadedStartup)
            {
                NSDictionary *localStartupData = [TGBridgeClient instance].startupData;
                NSDictionary *contextStartupData = next.startupData;
                
                if (localStartupData != nil || contextStartupData != nil)
                {
                    NSDictionary *startupData = [localStartupData[TGBridgeContextStartupDataVersion] int32Value] > [contextStartupData[TGBridgeContextStartupDataVersion] int32Value] ? localStartupData : contextStartupData;
                    
                    updateBlock(startupData);
                }
            }
            TGTock;
            
            strongSelf->_loadedStartup = true;
            
            [strongSelf->_chatListDisposable setDisposable:[[[TGBridgeChatListSignals chatListWithLimit:TGChatsControllerLimit] deliverOn:[SQueue mainQueue]] startWithNext:^(id models)
            {
                __strong TGChatsController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                updateBlock(models);
                [strongSelf _updateStartupData:models];
            }]];
        }
        else if (!next.authorized && next.passcodeEnabled && next.passcodeEncrypted)
        {
            strongSelf->_chatModels = nil;
            strongSelf->_currentChatModels = nil;
            
            [strongSelf performInterfaceUpdate:^(bool animated)
            {
                __strong TGChatsController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                 
                strongSelf.activityIndicator.hidden = true;
                strongSelf.table.hidden = true;
                strongSelf.authAlertGroup.hidden = false;
                strongSelf.authAlertLabel.text = TGLocalized(@"Passcode.UnlockRequired");
                strongSelf.authAlertImageGroup.hidden = false;
                [strongSelf.authAlertImage setImageNamed:@"PasscodeIcon"];
                strongSelf.authAlertDescLabel.hidden = true;
            }];
        }
        else
        {
            [strongSelf popToRootController];
            [strongSelf dismissTextInputController];
            
            strongSelf->_chatModels = nil;
            strongSelf->_currentChatModels = nil;
            
            [strongSelf performInterfaceUpdate:^(bool animated)
            {
                __strong TGChatsController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                strongSelf.activityIndicator.hidden = true;
                strongSelf.table.hidden = true;
                strongSelf.authAlertGroup.hidden = false;
                strongSelf.authAlertLabel.text = TGLocalized(@"Auth.LoginRequired");
                strongSelf.authAlertImageGroup.hidden = false;
                [strongSelf.authAlertImage setImageNamed:@"LoginIcon"];
                strongSelf.authAlertDescLabel.hidden = true;
            }];
        }
    }]];
}

- (void)_updateStartupData:(NSDictionary *)dataObject
{
    NSDictionary *startupData = dataObject;
    if (startupData != nil)
    {
        NSMutableDictionary *trimmedData = [startupData mutableCopy];
        NSArray *chatsArray = trimmedData[TGBridgeChatsArrayKey];
        if (chatsArray.count > 6)
        {
            NSArray *trimmedArray = [chatsArray subarrayWithRange:NSMakeRange(0, 6)];
            trimmedData[TGBridgeChatsArrayKey] = trimmedArray;
            startupData = trimmedData;
        }
    }
    [[TGBridgeClient instance] saveStartupData:startupData];
}

- (void)updateTitle
{
    NSString *state = [TGChatsController stringForSyncState:_syncState];
    if (!_context.authorized || state == nil)
        self.title = TGLocalized(@"App.Name");
    else
        self.title = state;
}

- (void)reloadData
{
    if (!_reachable)
    {
        
        return;
    }
    
    [self updateMenuItems];
    
    NSArray *currentChatModels = _currentChatModels;
    bool initial = (currentChatModels.count == 0);
    
    bool partialLoad = false;
    
//    if (initial && _chatModels.count > TGChatsControllerInitialCount)
//    {
//        partialLoad = true;
//        _currentChatModels = [_chatModels subarrayWithRange:NSMakeRange(0, TGChatsControllerInitialCount)];
//    }
//    else
//    {
        _currentChatModels = _chatModels;
//    }
    
    if (currentChatModels == nil && _currentChatModels == nil)
    {
        self.activityIndicator.hidden = false;
        self.table.hidden = true;
        self.authAlertGroup.hidden = true;
    }
    else if (self->_currentChatModels.count == 0)
    {
        self.activityIndicator.hidden = true;
        self.table.hidden = true;
        self.authAlertGroup.hidden = false;
        self.authAlertImageGroup.hidden = true;
        self.authAlertDescLabel.hidden = false;
        self.authAlertLabel.text = TGLocalized(@"ChatList.NoConversationsTitle");
        self.authAlertDescLabel.text = TGLocalized(@"ChatList.NoConversationsText");
    }
    else
    {
        self.activityIndicator.hidden = true;
        self.table.hidden = false;
        self.authAlertGroup.hidden = true;
    }
    
    if (!initial && self->_currentChatModels.count > 0)
    {
        [TGTableDeltaUpdater updateTable:self.table oldData:currentChatModels newData:_currentChatModels controllerClassForIndexPath:^Class(TGIndexPath *indexPath)
         {
             return [self table:self.table rowControllerClassAtIndexPath:indexPath];
         }];
    }
    else
    {
        [self.table reloadData];
        
        if (partialLoad)
        {
            TGDispatchAfter(0.8, dispatch_get_main_queue(), ^
            {
                [self reloadData];
            });
        }
    }
}

+ (NSString *)stringForSyncState:(TGBridgeSynchronizationStateValue)value
{
    switch (value)
    {
        case TGBridgeSynchronizationStateSynchronized:
            return nil;
            
        case TGBridgeSynchronizationStateConnecting:
            return TGLocalized(@"State.Connecting");
            
        case TGBridgeSynchronizationStateUpdating:
            return TGLocalized(@"State.Updating");
            
        case TGBridgeSynchronizationStateWaitingForNetwork:
            return TGLocalized(@"State.WaitingForNetwork");
            
        default:
            break;
    }
    
    return nil;
}

- (void)willActivate
{
    [super willActivate];
    
    [self.table notifyVisiblityChange];
    
    NSString *state = [TGChatsController stringForSyncState:_syncState];
    
    if (!_context.authorized || state == nil)
        self.title = TGLocalized(@"App.Name");
    else
        self.title = state;
}

- (void)didDeactivate
{
    [super didDeactivate];
}

#pragma mark - 

- (void)updateMenuItems
{
    [_menu clearItems];
    
    if (!_context.authorized)
        return;
    
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    
    __weak TGChatsController *weakSelf = self;
    TGInterfaceMenuItem *composeItem = [[TGInterfaceMenuItem alloc] initWithImageNamed:@"Compose" title:TGLocalized(@"ChatList.Compose") actionBlock:^(TGInterfaceController *controller, TGInterfaceMenuItem *sender)
    {
        __strong TGChatsController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf presentControllerWithClass:[TGComposeController class] context:nil];
    }];
    [menuItems addObject:composeItem];
    
    TGInterfaceMenuItem *clearCacheItem = [[TGInterfaceMenuItem alloc] initWithItemIcon:WKMenuItemIconTrash title:@"Clear Cache" actionBlock:^(TGInterfaceController *controller, TGInterfaceMenuItem *sender)
    {
        //[[[TGBridgeClient instance] fileCache] clearCacheSynchronous:false];
    }];
    [menuItems addObject:clearCacheItem];
    
    [_menu addItems:menuItems];
}

#pragma mark - 

- (void)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)remoteNotification
{
    NSString *fromId = remoteNotification[@"from_id"];
    NSString *chatId = remoteNotification[@"chat_id"];
    
    int64_t peerId = (chatId != nil) ? [chatId integerValue] : [fromId integerValue];
    
    if ([identifier isEqualToString:@"reply"] && peerId != 0)
        [self replyToPeerWithId:peerId];
}

- (void)handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)localNotification
{
    int64_t peerId = [localNotification.userInfo[@"cid"] int64Value];
    
    if ([identifier isEqualToString:@"reply"] && peerId != 0)
        [self replyToPeerWithId:peerId];
}

- (void)replyToPeerWithId:(int64_t)peerId
{
    __weak TGChatsController *weakSelf = self;
    void (^replyBlock)(void) = ^
    {
        __strong TGChatsController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [TGInputController presentInputControllerForInterfaceController:self suggestionsForText:nil completion:^(NSString *text)
        {
            __block bool openedChat = false;
            
            [strongSelf->_replyDisposable setDisposable:[[TGBridgeSendMessageSignals sendMessageWithPeerId:peerId text:text replyToMid:0] startWithNext:^(id next)
            {
                if (!openedChat)
                {
                    openedChat = true;
  
                }
            }]];
        }];
    };
    
    if (!_context.authorized && _context.passcodeEnabled && _context.passcodeEncrypted)
    {
        _replyRestoreBlock = replyBlock;
        return;
    }
    
    replyBlock();
}

#pragma mark - Table Data Source & Delegate

- (NSUInteger)numberOfRowsInTable:(WKInterfaceTable *)table section:(NSUInteger)section
{
    return _currentChatModels.count;
}

- (Class)table:(WKInterfaceTable *)table rowControllerClassAtIndexPath:(TGIndexPath *)indexPath
{
    return [TGChatsRowController class];
}

- (void)table:(WKInterfaceTable *)table updateRowController:(TGChatsRowController *)controller forIndexPath:(TGIndexPath *)indexPath
{
    __weak TGChatsController *weakSelf = self;
    controller.isVisible = ^bool
    {
        __strong TGChatsController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return false;
        
        return strongSelf.isVisible;
    };
    
    [controller updateWithChat:_currentChatModels[indexPath.row] context:_context];
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndexPath:(TGIndexPath *)indexPath
{
    //TGChatsRowController *rowController = (TGChatsRowController *)[table controllerForRowAtIndexPath:indexPath];
    //[rowController hideUnreadCountBadge];
}

//- (id<TGInterfaceContext>)contextForSegueWithIdentifer:(NSString *)segueIdentifier table:(WKInterfaceTable *)table indexPath:(TGIndexPath *)indexPath
//{
//    TGChatsRowController *rowController = (TGChatsRowController *)[table controllerForRowAtIndexPath:indexPath];
//    [rowController hideUnreadCountBadge];
//    
//    TGConversationControllerContext *context = [[TGConversationControllerContext alloc] initWithChat:_currentChatModels[indexPath.row]];
//    context.context = _context;
//    return context;
//}

#pragma mark - 

+ (NSString *)identifier
{
    return TGChatsControllerIdentifier;
}

@end
