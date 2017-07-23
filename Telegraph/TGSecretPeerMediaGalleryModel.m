#import "TGSecretPeerMediaGalleryModel.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"
#import "TGStringUtils.h"

#import "TGSecretPeerMediaGalleryImageItem.h"
#import "TGSecretPeerMediaGalleryVideoItem.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGObserverProxy.h"

#import "TGModernSendSecretMessageActor.h"

#import "TGGenericPeerMediaGalleryDefaultFooterView.h"

#import "TGPeerIdAdapter.h"

@interface TGSecretPeerMediaGalleryModel () <ASWatcher>
{
    int64_t _peerId;
    int32_t _messageId;
    
    TGObserverProxy *_screenshotObserver;
    NSString *_footerMessage;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGSecretPeerMediaGalleryModel

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        
        if (iosMajorVersion() >= 7)
        {
            _screenshotObserver = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(somethingChanged:) name:UIApplicationUserDidTakeScreenshotNotification];
        }
        
        _peerId = peerId;
        _messageId = messageId;
        
        id<TGModernGalleryItem> item = nil;
        
        TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:messageId peerId:_peerId];
        if (message != nil)
        {
            bool initiatedCountdown = false;
            NSTimeInterval messageCountdownTime = 0.0;
            if (!message.outgoing)
            {
                messageCountdownTime = [TGDatabaseInstance() messageCountdownLocalTime:message.mid enqueueIfNotQueued:true initiatedCountdown:&initiatedCountdown];
            }
            if (initiatedCountdown)
            {
                [ActionStageInstance() requestActor:@"/tg/service/synchronizeserviceactions/(settings)" options:nil watcher:TGTelegraphInstance];
            }
            
            bool isVideo = false;
            for (id attachment in message.mediaAttachments)
            {
                if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
                {
                    TGImageMediaAttachment *imageMedia = attachment;
                    
                    NSString *legacyCacheUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:NULL pickLargest:true];
                    
                    int64_t localImageId = 0;
                    if (imageMedia.imageId == 0 && legacyCacheUrl.length != 0)
                        localImageId = murMurHash32(legacyCacheUrl);
                    
                    TGSecretPeerMediaGalleryImageItem *imageItem = [[TGSecretPeerMediaGalleryImageItem alloc] initWithImageId:imageMedia.imageId orLocalId:localImageId peerId:_peerId messageId:message.mid legacyImageInfo:imageMedia.imageInfo messageCountdownTime:messageCountdownTime messageLifetime:message.messageLifetime];
                    imageItem.author = [TGDatabaseInstance() loadUser:(int32_t)message.fromUid];
                    imageItem.peer = [TGDatabaseInstance() loadUser:(int32_t)message.toUid];
                    imageItem.date = message.date;
                    
                    item = imageItem;
                    break;
                }
                else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
                {
                    TGVideoMediaAttachment *videoMedia = attachment;
                    if (videoMedia.roundMessage)
                        continue;
                    
                    TGSecretPeerMediaGalleryVideoItem *videoItem = [[TGSecretPeerMediaGalleryVideoItem alloc] initWithVideoMedia:videoMedia peerId:_peerId messageId:message.mid messageCountdownTime:messageCountdownTime messageLifetime:message.messageLifetime];
                    videoItem.author = [TGDatabaseInstance() loadUser:(int32_t)message.fromUid];
                    videoItem.peer = [TGDatabaseInstance() loadUser:(int32_t)message.toUid];
                    videoItem.date = message.date;
                    
                    item = videoItem;
                    isVideo = true;
                    break;
                }
            }
            
            if (item != nil)
                [self _replaceItems:@[item] focusingOnItem:item];
        }
        
        [ActionStageInstance() watchForPath:[NSString stringWithFormat:@"/tg/conversation/(%lld)/messagesDeleted", _peerId] watcher:self];
        [ActionStageInstance() watchForPath:[NSString stringWithFormat:@"/messagesEditedInConversation/(%lld)", _peerId] watcher:self];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesDeleted", _peerId]])
    {
        for (NSNumber *nMid in ((SGraphObjectNode *)resource).object)
        {
            if ([nMid intValue] == _messageId)
            {
                TGDispatchOnMainThread(^
                {
                    if (self.dismissWhenReady)
                        self.dismissWhenReady(true);
                });
                break;
            }
        }
    } else if ([path isEqualToString:[NSString stringWithFormat:@"/messagesEditedInConversation/(%lld)", _peerId]]) {
        for (TGMessage *message in resource) {
            if (message.mid == _messageId)
            {
                TGDispatchOnMainThread(^
                {
                    if ([message hasExpiredMedia]) {
                        if (self.dismissWhenReady)
                            self.dismissWhenReady(true);
                    }
                });
                break;
            }
        }
    }
}

- (void)somethingChanged:(id)__unused arg
{
    [TGDatabaseInstance() dispatchOnDatabaseThread:^
    {
        int messageFlags = [TGDatabaseInstance() secretMessageFlags:_messageId];
        //if ((messageFlags & TGSecretMessageFlagScreenshot) == 0)
        {
            messageFlags |= TGSecretMessageFlagScreenshot;
            TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:_messageId peerId:_peerId];
            if (message != nil && !message.outgoing)
            {
                if (TGPeerIdIsSecretChat(_peerId)) {
                    [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%" PRId64 ")/messageFlagChanges", message.cid] resource:@{@(_messageId): @(messageFlags)}];
                    
                    int64_t encryptedConversationId = [TGDatabaseInstance() encryptedConversationIdForPeerId:message.cid];
                    int64_t randomId = [TGDatabaseInstance() randomIdForMessageId:_messageId];
                    int64_t actionRandomId = 0;
                    arc4random_buf(&actionRandomId, 8);
                    
                    if (encryptedConversationId != 0 && randomId != 0)
                    {
                        int64_t peerId = [TGDatabaseInstance() peerIdForEncryptedConversationId:encryptedConversationId createIfNecessary:false];
                        
                        NSUInteger peerLayer = [TGDatabaseInstance() peerLayer:peerId];
                        
                        NSData *messageData = [TGModernSendSecretMessageActor decryptedServiceMessageActionWithLayer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) screenshotMessagesWithRandomIds:@[@(message.randomId)] randomId:actionRandomId];
                        
                        if (messageData != nil)
                        {
                            [TGModernSendSecretMessageActor enqueueOutgoingServiceMessageForPeerId:peerId layer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) keyId:0 randomId:actionRandomId messageData:messageData];
                        }
                    }
                } else {
                    TGDatabaseAction action = { .type = TGDatabaseActionScreenshotMessage, .subject = _peerId, .arg0 = _messageId, .arg1 = 0};
                    [TGDatabaseInstance() storeQueuedActions:[NSArray arrayWithObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]]];
                    [ActionStageInstance() requestActor:@"/tg/service/synchronizeactionqueue/(global)" options:nil watcher:TGTelegraphInstance];
                }
            }
        }
    } synchronous:false];
}

@end
