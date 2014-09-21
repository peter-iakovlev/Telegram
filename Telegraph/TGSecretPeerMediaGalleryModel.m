#import "TGSecretPeerMediaGalleryModel.h"

#import "TGDatabase.h"
#import "TGStringUtils.h"

#import "TGSecretPeerMediaGalleryImageItem.h"
#import "TGSecretPeerMediaGalleryVideoItem.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

@interface TGSecretPeerMediaGalleryModel () <ASWatcher>
{
    int64_t _peerId;
    int32_t _messageId;
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
        
        _peerId = peerId;
        _messageId = messageId;
        
        id<TGModernGalleryItem> item = nil;
        
        TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:messageId];
        if (message != nil)
        {
            bool initiatedCountdown = false;
            NSTimeInterval messageCountdownTime = [TGDatabaseInstance() messageCountdownLocalTime:message.mid enqueueIfNotQueued:true initiatedCountdown:&initiatedCountdown];
            
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
                    //imageItem.author = [TGDatabaseInstance() loadUser:(int32_t)message.fromUid];
                    //imageItem.date = message.date;
                    
                    item = imageItem;
                    break;
                }
                else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
                {
                    TGVideoMediaAttachment *videoMedia = attachment;
                    TGSecretPeerMediaGalleryVideoItem *videoItem = [[TGSecretPeerMediaGalleryVideoItem alloc] initWithVideoMedia:videoMedia peerId:_peerId messageId:message.mid messageCountdownTime:messageCountdownTime messageLifetime:message.messageLifetime];
                    //videoItem.author = [TGDatabaseInstance() loadUser:(int32_t)message.fromUid];
                    //videoItem.date = message.date;
                    
                    item = videoItem;
                    break;
                }
            }
            
            if (item != nil)
                [self _replaceItems:@[item] focusingOnItem:item];
        }
        
        [ActionStageInstance() watchForPath:[NSString stringWithFormat:@"/tg/conversation/(%lld)/messagesDeleted", _peerId] watcher:self];
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
                        self.dismissWhenReady();
                });
            }
        }
    }
}

@end
