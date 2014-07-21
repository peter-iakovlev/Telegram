#import "TGGenericPeerMediaGalleryModel.h"

#import "ActionStage.h"

#import "ATQueue.h"

#import "TGDatabase.h"

#import "TGGenericPeerMediaGalleryImageItem.h"
#import "TGGenericPeerMediaGalleryVideoItem.h"

#import "TGGenericPeerMediaGalleryDefaultFooterView.h"

@interface TGGenericPeerMediaGalleryModel ()
{
    ATQueue *_queue;
    
    NSArray *_modelItems;
}

@end

@implementation TGGenericPeerMediaGalleryModel

- (instancetype)initWithPeerId:(int64_t)peerId atMessageId:(int32_t)atMessageId
{
    self = [super init];
    if (self != nil)
    {
        _queue = [[ATQueue alloc] init];
        
        _peerId = peerId;
        
        [self _loadItemsAtMessageId:atMessageId];
    }
    return self;
}

- (void)_loadItemsAtMessageId:(int32_t)atMessageId
{
    //[_queue dispatch:^
    {
        if (_modelItems == nil)
        {
            int count = 0;
            NSArray *messages = [TGDatabaseInstance() loadMediaInConversation:_peerId atMessageId:atMessageId limitAfter:128 count:&count];
            
            NSMutableArray *updatedModelItems = [[NSMutableArray alloc] init];
            
            id<TGModernGalleryItem> focusItem = nil;
            
            for (TGMessage *message in messages)
            {
                for (id attachment in message.mediaAttachments)
                {
                    if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
                    {
                        TGImageMediaAttachment *imageMedia = attachment;
                        TGGenericPeerMediaGalleryImageItem *imageItem = [[TGGenericPeerMediaGalleryImageItem alloc] initWithImageInfo:imageMedia.imageInfo];
                        imageItem.author = [TGDatabaseInstance() loadUser:(int32_t)message.fromUid];
                        imageItem.date = message.date;
                        imageItem.messageId = message.mid;
                        [updatedModelItems insertObject:imageItem atIndex:0];
                        
                        if (atMessageId == message.mid)
                            focusItem = imageItem;
                    }
                    else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
                    {
                        TGVideoMediaAttachment *videoMedia = attachment;
                        TGGenericPeerMediaGalleryVideoItem *videoItem = [[TGGenericPeerMediaGalleryVideoItem alloc] initWithVideoMedia:videoMedia];
                        videoItem.author = [TGDatabaseInstance() loadUser:(int32_t)message.fromUid];
                        videoItem.date = message.date;
                        videoItem.messageId = message.mid;
                        [updatedModelItems insertObject:videoItem atIndex:0];
                        
                        if (atMessageId == message.mid)
                            focusItem = videoItem;
                    }
                }
            }
            
            _modelItems = updatedModelItems;
            
            [self _replaceItems:_modelItems focusingOnItem:focusItem];
        }
    }//];
}

- (Class<TGModernGalleryDefaultFooterView>)defaultFooterViewClass
{
    return [TGGenericPeerMediaGalleryDefaultFooterView class];
}

@end
