#import "TGGenericPeerMediaGalleryModel.h"

#import "ActionStage.h"

#import "ATQueue.h"

#import "TGDatabase.h"

#import "TGModernGalleryImageItem.h"
#import "TGModernGalleryVideoItem.h"

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
    [_queue dispatch:^
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
                        TGModernGalleryImageItem *imageItem = [[TGModernGalleryImageItem alloc] initWithImageInfo:imageMedia.imageInfo];
                        [updatedModelItems addObject:imageItem];
                        
                        if (atMessageId == message.mid)
                            focusItem = imageItem;
                    }
                    else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
                    {
                        TGVideoMediaAttachment *videoMedia = attachment;
                        TGModernGalleryVideoItem *videoItem = [[TGModernGalleryVideoItem alloc] initWithVideoMedia:videoMedia];
                        [updatedModelItems addObject:videoItem];
                        
                        if (atMessageId == message.mid)
                            focusItem = videoItem;
                    }
                }
            }
            
            _modelItems = updatedModelItems;
            
            [self _replaceItems:_modelItems focusingOnItem:focusItem];
        }
    }];
}

@end
