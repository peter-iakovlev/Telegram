#import "TGNeoChatsController.h"

#import "WKInterfaceTable+TGDataDrivenTable.h"
#import "TGTableDeltaUpdater.h"
#import "TGInterfaceMenu.h"

#import "TGBridgeContext.h"
#import "TGBridgeUser.h"
#import "TGBridgeChat.h"
#import "TGBridgeUserCache.h"

#import "TGBridgeClient.h"
#import "TGBridgeChatListSignals.h"

#import "TGNeoChatRowController.h"

#import "TGNeoConversationController.h"
#import "TGComposeController.h"

#import "TGExtensionDelegate.h"
#import "TGFileCache.h"

NSString *const TGNeoChatsControllerIdentifier = @"TGNeoChatsController";

NSString *const TGContextNotification = @"TGContextNotification";
NSString *const TGContextNotificationKey = @"context";

NSString *const TGSynchronizationStateNotification = @"TGSynchronizationStateNotification";
NSString *const TGSynchronizationStateKey = @"state";

const NSUInteger TGNeoChatsControllerInitialCount = 3;
const NSUInteger TGNeoChatsControllerLimit = 12;
const NSUInteger TGNeoChatsControllerForwardLimit = 20;

@implementation TGNeoChatsControllerContext

@end


@interface TGNeoChatsController () <TGTableDataSource>
{
    TGBridgeContext *_context;
    bool _forForward;
    
    bool _initialized;
    bool _loadedStartup;
    
    bool _reachable;
    TGNeoChatsControllerContext *_forwardContext;
    
    SMetaDisposable *_reachabilityDisposable;
    SMetaDisposable *_contextDisposable;
    SMetaDisposable *_chatsDisposable;
    SMetaDisposable *_stateDisposable;
    
    NSArray *_rowModels;
    NSArray *_pendingRowModels;
    
    TGBridgeSynchronizationStateValue _syncState;
    
    TGInterfaceMenu *_menu;
}
@end

@implementation TGNeoChatsController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _reachabilityDisposable = [[SMetaDisposable alloc] init];
        _contextDisposable = [[SMetaDisposable alloc] init];
        _chatsDisposable = [[SMetaDisposable alloc] init];
        _stateDisposable = [[SMetaDisposable alloc] init];
        
        self.table.tableDataSource = self;
        [self.table _setInitialHidden:true];
    }
    return self;
}

- (void)dealloc
{
    [_reachabilityDisposable dispose];
    [_contextDisposable dispose];
    [_chatsDisposable dispose];
    [_stateDisposable dispose];
}

- (void)configureWithContext:(id<TGInterfaceContext>)context
{
    if (context == nil)
        [self configureWithRootContext];
    else
        [self configureWithForwardContext:context];
}

- (void)configureWithRootContext
{
    __weak TGNeoChatsController *weakSelf = self;
    
    [_reachabilityDisposable setDisposable:[[[TGBridgeClient instance] reachabilitySignal] startWithNext:^(NSNumber *next)
    {
        __strong TGNeoChatsController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        bool reachable = next.boolValue;
        strongSelf->_reachable = reachable;
        
        if (strongSelf->_initialized)
        {
            [strongSelf performInterfaceUpdate:^(bool animated)
            {
                [strongSelf reloadData];
            }];
        }
    }]];
    
    [_contextDisposable setDisposable:[[[[TGBridgeClient instance] contextSignal] deliverOn:[SQueue mainQueue]] startWithNext:^(TGBridgeContext *next)
    {
        __strong TGNeoChatsController *strongSelf = weakSelf;
        if (strongSelf == nil || [strongSelf->_context isEqual:next])
            return;
        
        if (strongSelf->_context.micAccessAllowed != next.micAccessAllowed)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:TGContextNotification object:nil userInfo:@{ TGContextNotificationKey: next }];
        }
        
        strongSelf->_initialized = true;
        strongSelf->_context = next;
        
        if (next.authorized && next.userId != 0)
        {
            void (^updateBlock)(NSDictionary *) = ^(NSDictionary *models)
            {
                __strong TGNeoChatsController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                strongSelf->_pendingRowModels = models[TGBridgeChatsArrayKey];
                [[TGBridgeUserCache instance] storeUsers:[models[TGBridgeUsersDictionaryKey] allValues]];
                
                [strongSelf performInterfaceUpdate:^(bool animated)
                {
                    [strongSelf reloadData];
                }];
            };
            
            if (!strongSelf->_loadedStartup)
            {
                NSDictionary *contextStartupData = next.startupData;
                
                if (contextStartupData != nil)
                    updateBlock(contextStartupData);
                
                strongSelf->_loadedStartup = true;
            }
            
            [strongSelf->_chatsDisposable setDisposable:[[[TGBridgeChatListSignals chatListWithLimit:TGNeoChatsControllerLimit] deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *models)
            {
                updateBlock(models);
            }]];
        }
        else
        {
            [strongSelf performInterfaceUpdate:^(bool animated)
            {
                [strongSelf reloadData];
            }];
        }
    }]];
    
//    [_stateDisposable setDisposable:[[[TGBridgeStateSignal synchronizationState] deliverOn:[SQueue mainQueue]] startWithNext:^(NSNumber *next)
//    {
//        TGBridgeSynchronizationStateValue value = (TGBridgeSynchronizationStateValue)[next integerValue];
//        
//        __strong TGNeoChatsController *strongSelf = weakSelf;
//        if (strongSelf == nil)
//            return;
//        
//        strongSelf->_syncState = value;
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:TGSynchronizationStateNotification object:nil userInfo:@{ TGSynchronizationStateKey: @(value) }];
//        
//        if (strongSelf.isVisible)
//            [strongSelf updateTitle];
//    }]];
}

- (void)configureWithForwardContext:(TGNeoChatsControllerContext *)context
{
    self.title = nil;
    
    _forForward = true;
    _forwardContext = context;
    _context = _forwardContext.context;
    
    SSignal *signal = [[SSignal single:context.initialChats] then:[[TGBridgeChatListSignals chatListWithLimit:TGNeoChatsControllerForwardLimit] deliverOn:[SQueue mainQueue]]];
    
    __weak TGNeoChatsController *weakSelf = self;
    [_chatsDisposable setDisposable:[signal startWithNext:^(id models)
    {
        __strong TGNeoChatsController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        NSArray *chats = nil;
        if ([models isKindOfClass:[NSDictionary class]])
        {
            chats = models[TGBridgeChatsArrayKey];
            [[TGBridgeUserCache instance] storeUsers:[models[TGBridgeUsersDictionaryKey] allValues]];
        }
        else if ([models isKindOfClass:[NSArray class]])
        {
            chats = models;
        }
        
        strongSelf->_pendingRowModels = chats;
        
        [strongSelf performInterfaceUpdate:^(bool animated)
        {
            [strongSelf reloadData];
        }];
    }]];
}

- (void)willActivate
{
    [super willActivate];
    
    [self.table notifyVisiblityChange];
}

- (void)popAllControllers
{
    [self popToRootController];
    [self dismissAudioRecorderController];
    [self dismissTextInputController];
}

- (void)resetLocalization
{
    [self popAllControllers];
    
    [self performInterfaceUpdate:^(bool animated)
    {
        [self reloadData];        
    }];
}

- (void)reloadData
{
    [[TGBridgeClient instance] updateReachability];
    _reachable = [[TGBridgeClient instance] isServerReachable];
    
    [self updateTitle];
    
    if (!_reachable && !_forForward)
    {
        [self popAllControllers];
        
        self.activityIndicator.hidden = true;
        self.table.hidden = true;
        self.authAlertGroup.hidden = false;
        self.authAlertImageGroup.hidden = true;
        self.authAlertDescLabel.hidden = false;
        self.authAlertLabel.text = TGLocalized(@"Watch.NoConnection");
        self.authAlertDescLabel.text = TGLocalized(@"Watch.ConnectionDescription");
        
        return;
    }
    
    if ((_context.authorized && _context.userId != 0) || _forForward)
    {
        NSArray *currentRowModels = _rowModels;
        bool initial = (currentRowModels.count == 0);
        
        bool partialLoad = false;
        
        if (initial && _pendingRowModels.count > TGNeoChatsControllerInitialCount)
        {
            partialLoad = true;
            _rowModels = [_pendingRowModels subarrayWithRange:NSMakeRange(0, TGNeoChatsControllerInitialCount)];
        }
        else
        {
            _rowModels = _pendingRowModels;
        }
        
        if (_rowModels.count == 0)
        {
            self.activityIndicator.hidden = true;
            self.table.hidden = true;
            self.authAlertGroup.hidden = false;
            self.authAlertImageGroup.hidden = true;
            self.authAlertDescLabel.hidden = false;
            self.authAlertLabel.text = TGLocalized(@"Watch.ChatList.NoConversationsTitle");
            self.authAlertDescLabel.text = TGLocalized(@"Watch.ChatList.NoConversationsText");
            return;
        }
        
        bool tableHidden = false;
        bool spinnerHidden = false;
        if (currentRowModels == nil && _rowModels == nil)
        {
            tableHidden = true;
            spinnerHidden = false;
        }
        else if (_rowModels.count == 0)
        {
            tableHidden = true;
            spinnerHidden = true;
        }
        else
        {
            tableHidden = false;
            spinnerHidden = true;
        }
        
        if (!initial)
        {
            [TGTableDeltaUpdater updateTable:self.table oldData:currentRowModels newData:_rowModels controllerClassForIndexPath:^Class(TGIndexPath *indexPath)
            {
                return [self table:self.table rowControllerClassAtIndexPath:indexPath];
            }];
        }
        else
        {
            [self.table reloadData];
            
            if (partialLoad)
            {
                TGDispatchAfter(1.0, dispatch_get_main_queue(), ^
                {
                    [self reloadData];
                });
            }
        }
     
        self.authAlertGroup.hidden = true;
        self.activityIndicator.hidden = spinnerHidden;
        self.table.hidden = tableHidden;
        
        [self updateMenuItems];
    }
    else
    {
        [self popAllControllers];
        
        _rowModels = nil;
        _pendingRowModels = nil;
        [self.table reloadData];
        
        if (!_context.authorized && _context.passcodeEnabled && _context.passcodeEncrypted)
        {
            self.activityIndicator.hidden = true;
            self.table.hidden = true;
            self.authAlertGroup.hidden = false;
            self.authAlertLabel.text = TGLocalized(@"Watch.UnlockRequired");
            self.authAlertImageGroup.hidden = false;
            [self.authAlertImage setImageNamed:@"PasscodeIcon"];
            self.authAlertDescLabel.hidden = true;
        }
        else
        {
            self.activityIndicator.hidden = true;
            self.table.hidden = true;
            self.authAlertGroup.hidden = false;
            self.authAlertLabel.text = TGLocalized(@"Watch.AuthRequired");
            self.authAlertImageGroup.hidden = false;
            [self.authAlertImage setImageNamed:@"LoginIcon"];
            self.authAlertDescLabel.hidden = true;
        }
    }
}

- (void)updateTitle
{
    if (_forForward)
    {
        self.title = nil;
        return;
    }
    //NSString *state = [TGNeoChatsController stringForSyncState:_syncState];
    //if (!_context.authorized || state == nil || !_reachable)
        self.title = TGLocalized(@"Watch.AppName");
    //else
    //    self.title = state;
}

+ (NSString *)stringForSyncState:(TGBridgeSynchronizationStateValue)value
{
    switch (value)
    {
        case TGBridgeSynchronizationStateSynchronized:
            return nil;
            
        case TGBridgeSynchronizationStateConnecting:
            return TGLocalized(@"Watch.State.Connecting");
            
        case TGBridgeSynchronizationStateUpdating:
            return TGLocalized(@"Watch.State.Updating");
            
        case TGBridgeSynchronizationStateWaitingForNetwork:
            return TGLocalized(@"Watch.State.WaitingForNetwork");
            
        default:
            break;
    }
    
    return nil;
}

#pragma mark - 

- (void)updateMenuItems
{
    [_menu clearItems];
    
    if (!_context.authorized || !_reachable)
        return;
    
    if (_menu == nil)
        _menu = [[TGInterfaceMenu alloc] initForInterfaceController:self];
    
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    
    __weak TGNeoChatsController *weakSelf = self;
    TGInterfaceMenuItem *composeItem = [[TGInterfaceMenuItem alloc] initWithImageNamed:@"Compose" title:TGLocalized(@"Watch.ChatList.Compose") actionBlock:^(TGInterfaceController *controller, TGInterfaceMenuItem *sender)
    {
        __strong TGNeoChatsController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf presentControllerWithClass:[TGComposeController class] context:nil];
    }];
    [menuItems addObject:composeItem];
    
//    TGInterfaceMenuItem *clearCacheItem = [[TGInterfaceMenuItem alloc] initWithItemIcon:WKMenuItemIconTrash title:@"Clear Cache" actionBlock:^(TGInterfaceController *controller, TGInterfaceMenuItem *sender)
//    {
//        [[[TGExtensionDelegate instance] imageCache] clearCacheSynchronous:false];
//    }];
//    [menuItems addObject:clearCacheItem];
    
    [_menu addItems:menuItems];
}

#pragma mark -

- (Class)table:(WKInterfaceTable *)table rowControllerClassAtIndexPath:(TGIndexPath *)indexPath
{
    return [TGNeoChatRowController class];
}

- (NSUInteger)numberOfRowsInTable:(WKInterfaceTable *)table section:(NSUInteger)section
{
    return _rowModels.count;
}

- (void)table:(WKInterfaceTable *)table updateRowController:(TGNeoChatRowController *)controller forIndexPath:(TGIndexPath *)indexPath
{
    __weak TGNeoChatsController *weakSelf = self;
    controller.isVisible = ^bool
    {
        __strong TGNeoChatsController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return false;
        
        return strongSelf.isVisible;
    };
    
    TGBridgeChat *chat = _rowModels[indexPath.row];
    [controller updateWithChat:chat forForward:_forForward context:_context];
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndexPath:(TGIndexPath *)indexPath
{
    if (indexPath.row >= _rowModels.count)
        return;
    
    if (_forForward)
    {
        [self dismissController];
        
        if (_forwardContext.completionBlock != nil)
            _forwardContext.completionBlock(_rowModels[indexPath.row]);
    }
    else
    {
        TGNeoConversationControllerContext *context = [[TGNeoConversationControllerContext alloc] initWithChat:_rowModels[indexPath.row]];
        context.context = _context;
        [self pushControllerWithClass:[TGNeoConversationController class] context:context];
    }
}

#pragma mark -

- (NSArray *)chats
{
    return _pendingRowModels;
}

#pragma mark -

+ (NSString *)identifier
{
    return TGNeoChatsControllerIdentifier;
}

@end
