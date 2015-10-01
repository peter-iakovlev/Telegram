#import "TGSecretInfiniteLifetimePeerMediaGalleryModel.h"

#import "ActionStage.h"
#import "TGDatabase.h"

#import "TGObserverProxy.h"

#import "TGGenericPeerGalleryItem.h"

#import "TGModernSendSecretMessageActor.h"

@interface TGSecretInfiniteLifetimePeerMediaGalleryModel ()
{
    TGObserverProxy *_screenshotObserver;
}

@end

@implementation TGSecretInfiniteLifetimePeerMediaGalleryModel

- (instancetype)initWithPeerId:(int64_t)peerId atMessageId:(int32_t)atMessageId allowActions:(bool)allowActions important:(bool)important
{
    self = [super initWithPeerId:peerId atMessageId:atMessageId allowActions:allowActions important:important];
    if (self != nil)
    {
        if (iosMajorVersion() >= 7)
        {
            _screenshotObserver = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(somethingChanged:) name:UIApplicationUserDidTakeScreenshotNotification];
        }
    }
    return self;
}

- (void)somethingChanged:(id)__unused arg
{
    TGDispatchOnMainThread(^
    {
        NSMutableArray *messageIds = [[NSMutableArray alloc] init];
        
        if (self.visibleItems)
        {
            for (id item in self.visibleItems())
            {
                if ([item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
                {
                    id<TGGenericPeerGalleryItem> concreteItem = item;
                    [messageIds addObject:@([concreteItem messageId])];
                }
            }
        }
        
        if (messageIds.count != 0)
        {
            NSMutableDictionary *messageFlagChanges = [[NSMutableDictionary alloc] init];
            NSMutableArray *randomIds = [[NSMutableArray alloc] init];
            
            for (NSNumber *nMid in messageIds)
            {
                int32_t messageId = [nMid intValue];
                
                int messageFlags = [TGDatabaseInstance() secretMessageFlags:messageId];
                //if ((messageFlags & TGSecretMessageFlagScreenshot) == 0)
                {
                    messageFlags |= TGSecretMessageFlagScreenshot;
                    TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:messageId peerId:self.peerId];
                    if (message != nil)
                    {
                        messageFlagChanges[@(messageId)] = @(messageFlags);
                        
                        int64_t randomId = [TGDatabaseInstance() randomIdForMessageId:messageId];
                        if (randomId != 0)
                            [randomIds addObject:@(randomId)];
                    }
                }
            }
            
            int64_t encryptedConversationId = [TGDatabaseInstance() encryptedConversationIdForPeerId:self.peerId];
            if (encryptedConversationId != 0 && randomIds.count != 0)
            {
                int64_t actionRandomId = 0;
                arc4random_buf(&actionRandomId, 8);
                
                NSUInteger peerLayer = [TGDatabaseInstance() peerLayer:self.peerId];
                
                NSData *messageData = [TGModernSendSecretMessageActor decryptedServiceMessageActionWithLayer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) screenshotMessagesWithRandomIds:randomIds randomId:actionRandomId];
                
                if (messageData != nil)
                {
                    [TGModernSendSecretMessageActor enqueueOutgoingServiceMessageForPeerId:self.peerId layer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) keyId:0 randomId:actionRandomId messageData:messageData];
                }
                
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%" PRId64 ")/messageFlagChanges", self.peerId] resource:messageFlagChanges];
            }
        }
    });
}

@end
