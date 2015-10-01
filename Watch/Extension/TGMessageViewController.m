#import "TGMessageViewController.h"

#import "TGBridgeSendMessageSignals.h"
#import "TGBridgeRemoteSignals.h"

#import "TGBridgeChat.h"
#import "TGBridgeUser.h"
#import "TGBridgeMessage.h"
#import "TGBridgeUserCache.h"

#import "WKInterfaceTable+TGDataDrivenTable.h"

#import "TGInputController.h"

#import "TGUserRowController.h"
#import "TGMessageViewMessageRowController.h"
#import "TGMessageViewWebPageRowController.h"
#import "TGMessageViewFooterController.h"

#import "TGUserInfoController.h"
#import "TGNeoChatsController.h"

#import "TGExtensionDelegate.h"

NSString *const TGMessageViewControllerIdentifier = @"TGMessageViewController";

@implementation TGMessageViewControllerContext

- (instancetype)initWithMessage:(TGBridgeMessage *)message peerId:(int64_t)peerId
{
    self = [super init];
    if (self != nil)
    {
        _message = message;
        _peerId = peerId;
    }
    return self;
}

- (instancetype)initWithMessage:(TGBridgeMessage *)message channel:(TGBridgeChat *)channel
{
    self = [super init];
    if (self != nil)
    {
        _message = message;
        _peerId = channel.identifier;
        _channel = channel;
    }
    return self;
}

@end

@interface TGMessageViewController () <TGTableDataSource>
{
    TGMessageViewControllerContext *_context;
    
    SMetaDisposable *_sendMessageDisposable;
    SMetaDisposable *_remoteActionDisposable;
}
@end

@implementation TGMessageViewController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _sendMessageDisposable = [[SMetaDisposable alloc] init];
        _remoteActionDisposable = [[SMetaDisposable alloc] init];
        
        [self.table _setInitialHidden:true];
        self.table.tableDataSource = self;
    }
    return self;
}

- (void)dealloc
{
    [_sendMessageDisposable dispose];
    [_remoteActionDisposable dispose];
}

- (void)configureWithContext:(TGMessageViewControllerContext *)context
{
    _context = context;
    
    [self configureHandoff];
    
    self.title = TGLocalized(@"MessageView.Title");

    __weak TGMessageViewController *weakSelf = self;
    [self performInterfaceUpdate:^(bool animated)
    {
        __strong TGMessageViewController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf.table.hidden = false;
        strongSelf.activityIndicator.hidden = true;
        [strongSelf.table reloadData];
    }];
}

- (void)configureHandoff
{
//    int64_t peerId = _context.peerId;
//    bool isGroup = _context.peerId < 0;
//    
//    if (isGroup)
//        peerId = -peerId;
//    
//    NSMutableDictionary *peerDict = [[NSMutableDictionary alloc] init];
//    peerDict[@"type"] = isGroup ? @"group" : @"user";
//    peerDict[@"id"] = @(peerId);
//    
//    NSMutableDictionary *messageDict = [[NSMutableDictionary alloc] init];
//    messageDict[@"autoplay"] = @false;
//    messageDict[@"id"] = @(_context.message.identifier);
//    
//    NSDictionary *userInfo = @{@"user_id": @(_context.authorizedContext.userId), @"peer": peerDict, @"message": messageDict};
//    [self updateUserActivity:@"org.telegram.message" userInfo:userInfo webpageURL:[NSURL URLWithString:@"https://telegram.org/dl"]];
}

- (void)willActivate
{
    [super willActivate];
    
    [self configureHandoff];
    
    [self.table notifyVisiblityChange];
}

- (void)didDeactivate
{
    [super didDeactivate];
}

#pragma mark -

- (Class)headerControllerClassForTable:(WKInterfaceTable *)table
{
    return [TGUserRowController class];
}

- (void)table:(WKInterfaceTable *)table updateHeaderController:(TGUserRowController *)controller
{
    if (_context.channel != nil)
    {
        [controller updateWithChannel:_context.channel context:_context.context];
    }
    else
    {
        TGBridgeUser *user = [[TGBridgeUserCache instance] userWithId:(int32_t)_context.message.fromUid];
        [controller updateWithUser:user context:_context.context];
    }
}

- (void)tableDidSelectHeader:(WKInterfaceTable *)table
{
    if (_context.channel != nil)
    {
        TGUserInfoControllerContext *context = [[TGUserInfoControllerContext alloc] initWithChannel:_context.channel];
        context.disallowCompose = true;
        [self pushControllerWithClass:[TGUserInfoController class] context:context];
    }
    else
    {
        TGUserInfoControllerContext *context = [[TGUserInfoControllerContext alloc] initWithUserId:(int32_t)_context.message.fromUid];
        [self pushControllerWithClass:[TGUserInfoController class] context:context];
    }
}

- (Class)footerControllerClassForTable:(WKInterfaceTable *)table
{
    return [TGMessageViewFooterController class];
}

- (void)table:(WKInterfaceTable *)table updateFooterController:(TGMessageViewFooterController *)controller
{
    __weak TGMessageViewController *weakSelf = self;
    controller.forwardPressed = ^
    {
        __strong TGMessageViewController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        TGNeoChatsControllerContext *context = [[TGNeoChatsControllerContext alloc] init];
        context.context = strongSelf->_context.context;
        context.initialChats = [[TGExtensionDelegate instance] chatsController].chats;
        context.completionBlock = ^(TGBridgeChat *peer)
        {
            __strong TGMessageViewController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf->_sendMessageDisposable setDisposable:[[TGBridgeSendMessageSignals forwardMessageWithPeerId:peer.identifier mid:strongSelf->_context.message.identifier] startWithNext:^(TGBridgeMessage *message)
            {
                
            }]];
        };
        [strongSelf presentControllerWithClass:[TGNeoChatsController class] context:context];
    };
    controller.replyPressed = ^
    {
        __strong TGMessageViewController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [TGInputController presentInputControllerForInterfaceController:strongSelf suggestionsForText:strongSelf->_context.message.text completion:^(NSString *text)
        {
            [strongSelf->_sendMessageDisposable setDisposable:[[TGBridgeSendMessageSignals sendMessageWithPeerId:strongSelf->_context.peerId text:text replyToMid:strongSelf->_context.message.identifier] startWithNext:^(TGBridgeMessage *message)
            {
                
            }]];
        }];
    };
    controller.viewPressed = ^
    {
        __strong TGMessageViewController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_remoteActionDisposable setDisposable:[[TGBridgeRemoteSignals openRemoteMessageWithPeerId:strongSelf->_context.peerId messageId:strongSelf->_context.message.identifier type:0 autoPlay:false] startWithNext:^(id next)
        {
                                                                
        }]];
    };
    
    [controller updateWithMessage:_context.message channel:(_context.channel != nil)];
}

- (NSUInteger)numberOfRowsInTable:(WKInterfaceTable *)table section:(NSUInteger)section
{
    return 1 + [self _messageHasWebPage];
}

- (Class)table:(WKInterfaceTable *)table rowControllerClassAtIndexPath:(TGIndexPath *)indexPath
{
    if (indexPath.row == 1)
        return [TGMessageViewWebPageRowController class];
    
    return [TGMessageViewMessageRowController class];
}

- (void)table:(WKInterfaceTable *)table updateRowController:(TGTableRowController *)rowController forIndexPath:(NSIndexPath *)indexPath
{
    __weak TGMessageViewController *weakSelf = self;
    rowController.isVisible = ^bool
    {
        __strong TGMessageViewController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return false;
        
        return strongSelf.isVisible;
    };
    
    if ([rowController isKindOfClass:[TGMessageViewMessageRowController class]])
    {
        TGMessageViewMessageRowController *controller = (TGMessageViewMessageRowController *)rowController;
        [controller updateWithMessage:_context.message context:_context.context];
        
        void (^openUserInfo)(int32_t) = ^(int32_t userId)
        {
            __strong TGMessageViewController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (userId != 0)
            {
                TGUserInfoControllerContext *context = [[TGUserInfoControllerContext alloc] initWithUserId:userId];
                [strongSelf pushControllerWithClass:[TGUserInfoController class] context:context];
            }
        };
        
        void (^openRemote)(void) = ^
        {
            __strong TGMessageViewController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf->_remoteActionDisposable setDisposable:[[TGBridgeRemoteSignals openRemoteMessageWithPeerId:strongSelf->_context.peerId messageId:strongSelf->_context.message.identifier type:0 autoPlay:true] startWithNext:^(id next)
            {
                
            }]];
        };
        
        for (TGBridgeMediaAttachment *attachment in _context.message.media)
        {
            if ([attachment isKindOfClass:[TGBridgeForwardedMessageMediaAttachment class]])
            {
                TGBridgeForwardedMessageMediaAttachment *forwardAttachment = (TGBridgeForwardedMessageMediaAttachment *)attachment;
                
                controller.forwardPressed = ^
                {
                    openUserInfo(forwardAttachment.uid);
                };
            }
            else if ([attachment isKindOfClass:[TGBridgeContactMediaAttachment class]])
            {
                TGBridgeContactMediaAttachment *contactAttachment = (TGBridgeContactMediaAttachment *)attachment;
                
                controller.contactPressed = ^
                {
                    openUserInfo(contactAttachment.uid);
                };
            }
            else if ([attachment isKindOfClass:[TGBridgeVideoMediaAttachment class]])
            {
                controller.playPressed = ^
                {
                    openRemote();
                };
            }
            else if ([attachment isKindOfClass:[TGBridgeAudioMediaAttachment class]])
            {
                controller.playPressed = ^
                {
                    openRemote();
                };
            }
        }
    }
    else if ([rowController isKindOfClass:[TGMessageViewWebPageRowController class]])
    {
        TGMessageViewWebPageRowController *controller = (TGMessageViewWebPageRowController *)rowController;
        
        TGBridgeWebPageMediaAttachment *pageAttachment = nil;
        for (TGBridgeMediaAttachment *attachment in _context.message.media)
        {
            if ([attachment isKindOfClass:[TGBridgeWebPageMediaAttachment class]])
            {
                pageAttachment = (TGBridgeWebPageMediaAttachment *)attachment;
                break;
            }
        }
        
        [controller updateWithAttachment:pageAttachment];
    }
}

- (bool)_messageHasWebPage
{
    for (TGBridgeMediaAttachment *attachment in _context.message.media)
    {
        if ([attachment isKindOfClass:[TGBridgeWebPageMediaAttachment class]])
            return true;
    }
    
    return false;
}

+ (NSString *)identifier
{
    return TGMessageViewControllerIdentifier;
}

@end
