#import "TGGifGalleryModel.h"

#import "ActionStage.h"
#import "TGTelegraph.h"

#import "TGDatabase.h"
#import "TGPeerIdAdapter.h"
#import "TGMessage.h"
#import "TGDocumentMediaAttachment.h"

#import "TGGenericPeerMediaGalleryGifItem.h"

#import "TGGenericPeerMediaGalleryActionsAccessoryView.h"
#import "TGGifGalleryAddAccessoryView.h"
#import "TGGenericPeerMediaGalleryDefaultFooterView.h"

#import "TGShareMenu.h"
#import "TGProgressWindow.h"

#import "TGRecentGifsSignal.h"

#import "TGModernConversationController.h"

@interface TGGifGalleryModel ()
{
    SQueue *_queue;
    
    TGMessage *_message;
    int64_t _peerId;
}
@end

@implementation TGGifGalleryModel

- (instancetype)initWithMessage:(TGMessage *)message
{
    self = [super init];
    if (self != nil)
    {
        _queue = [[SQueue alloc] init];
        
        TGDocumentMediaAttachment *documentMedia = nil;
        
        for (TGMediaAttachment *attachment in message.mediaAttachments)
        {
            if (attachment.type == TGDocumentMediaAttachmentType)
            {
                documentMedia = (TGDocumentMediaAttachment *)attachment;
                break;
            }
        }
        
        TGGenericPeerMediaGalleryGifItem *item = [[TGGenericPeerMediaGalleryGifItem alloc] initWithDocument:documentMedia peerId:message.cid messageId:message.mid];
        item.authorPeer = [self authorPeerForId:message.fromUid];
        item.date = message.date;
        item.messageId = message.mid;
        item.caption = documentMedia.caption;
        
        _message = message;
        _peerId = message.cid;

        [self _replaceItems:@[ item ] focusingOnItem:item];
    }
    return self;
}

- (id)authorPeerForId:(int64_t)peerId {
    if (TGPeerIdIsChannel(peerId)) {
        return [TGDatabaseInstance() loadChannels:@[@(peerId)]][@(peerId)];
    } else {
        return [TGDatabaseInstance() loadUser:(int32_t)peerId];
    }
}

- (UIView<TGModernGalleryDefaultFooterView> *)createDefaultFooterView
{
    return [[TGGenericPeerMediaGalleryDefaultFooterView alloc] init];
}

- (UIView<TGModernGalleryDefaultFooterAccessoryView> *)createDefaultLeftAccessoryView
{
    TGGenericPeerMediaGalleryActionsAccessoryView *accessoryView = [[TGGenericPeerMediaGalleryActionsAccessoryView alloc] init];
    __weak TGGenericPeerMediaGalleryActionsAccessoryView *weakAccessoryView = accessoryView;
    __weak TGGifGalleryModel *weakSelf = self;
    accessoryView.action = ^(__unused id<TGModernGalleryItem> item)
    {
        TGViewController *viewController = nil;
        if (self.viewControllerForModalPresentation)
            viewController = (TGViewController *)self.viewControllerForModalPresentation();
        
        CGRect (^sourceRect)(void) = ^CGRect
        {
            __strong TGGenericPeerMediaGalleryActionsAccessoryView *strongAccessoryView = weakAccessoryView;
            if (strongAccessoryView == nil)
                return CGRectZero;
            
            return strongAccessoryView.bounds;
        };
        
        __strong TGGenericPeerMediaGalleryActionsAccessoryView *strongAccessoryView = weakAccessoryView;
        [TGShareMenu presentInParentController:viewController menuController:nil buttonTitle:nil buttonAction:nil shareAction:^(NSArray *peerIds, NSString *caption)
        {
            __strong TGGifGalleryModel *strongSelf = weakSelf;
            
            if (strongSelf != nil && strongSelf.shareAction != nil)
                strongSelf.shareAction(strongSelf->_message, peerIds, caption);
        } externalShareItemSignal:nil sourceView:strongAccessoryView sourceRect:sourceRect barButtonItem:nil];
    };
    
    return accessoryView;
}

- (UIView<TGModernGalleryDefaultFooterAccessoryView> *)createDefaultRightAccessoryView
{
    TGGifGalleryAddAccessoryView *accessoryView = [[TGGifGalleryAddAccessoryView alloc] init];
    accessoryView.hidden = true;
    
    __weak TGGifGalleryModel *weakSelf = self;
    accessoryView.action = ^(id<TGModernGalleryItem> item, TGGifGalleryAddAccessoryView *accessoryView)
    {
        __strong TGGifGalleryModel *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        TGDocumentMediaAttachment *document = nil;
        if (![item isKindOfClass:[TGGenericPeerMediaGalleryGifItem class]])
              return;
            
        document = ((TGGenericPeerMediaGalleryGifItem *)item).media;
        
        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [progressWindow show:true];
        [TGRecentGifsSignal addRecentGifFromDocument:document];
        [progressWindow dismissWithSuccess];
        
        accessoryView.hidden = true;
    };
    return accessoryView;
}

- (void)_commitDeleteItem:(id<TGModernGalleryItem>)item
{
    if ([item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
    {
        id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
        
        NSArray *messageIds = @[@([concreteItem messageId])];
        static int actionId = 1;
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%lld)/deleteMessages/(genericPeerMedia%d)", _peerId, actionId++] options:@{@"mids": messageIds} watcher:TGTelegraphInstance];
        
    
        UIViewController *viewController = nil;
        if (self.viewControllerForModalPresentation)
            viewController = self.viewControllerForModalPresentation();
        
        if (viewController != nil)
        {
            if (self.dismiss)
                self.dismiss(false, false);
        }
    }
}

- (bool)_canDeleteItem:(id<TGModernGalleryItem>)item {
    if (TGPeerIdIsChannel(_peerId)) {
        if ([item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
        {
            id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
            TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:[concreteItem messageId] peerId:_peerId];
            if (message.outgoing) {
                return true;
            } else {
                TGConversation *conversation = [TGDatabaseInstance() loadChannels:@[@(_peerId)]][@(_peerId)];
                if (conversation != nil) {
                    if (conversation.channelRole == TGChannelRoleCreator || conversation.channelRole == TGChannelRolePublisher || conversation.channelRole == TGChannelRoleModerator) {
                        return true;
                    } else {
                        return false;
                    }
                } else {
                    return false;
                }
            }
        }
    }
    return true;
}

@end
