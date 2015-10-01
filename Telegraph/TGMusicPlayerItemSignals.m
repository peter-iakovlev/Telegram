#import "TGMusicPlayerItemSignals.h"

#import "ActionStage.h"

#import "TGDocumentMediaAttachment.h"
#import "TGPreparedLocalDocumentMessage.h"
#import "TGMessage.h"

#import "TGDownloadManager.h"

TGMusicPlayerItemAvailability TGMusicPlayerItemAvailabilityUnpack(int64_t value)
{
    TGMusicPlayerItemAvailability result;
    result.downloaded = value & 1;
    result.downloading = value & 2;
    int32_t progress = (value >> 32) & 0xffffffff;
    Float32 floatProgress = 0;
    memcpy(&floatProgress, &progress, 4);
    result.progress = floatProgress;
    
    return result;
}

static int64_t TGMusicPlayerItemAvailabilityPack(TGMusicPlayerItemAvailability value)
{
    int64_t result = 0;
    if (value.downloaded)
        result |= 1;
    if (value.downloading)
        result |= 2;
    Float32 floatProgress = (Float32)value.progress;
    int32_t progress = 0;
    memcpy(&progress, &floatProgress, 4);
    result |= (((int64_t)progress) << 32);
    
    return result;
}

@interface TGMusicPlayerItemDownloadHelper : NSObject <ASWatcher>
{
    TGMusicPlayerItem *_item;
    void (^_updated)(TGMusicPlayerItemAvailability);
    
    TGMediaId *_mediaId;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGMusicPlayerItemDownloadHelper

- (TGMediaId *)mediaIdForItem:(TGMusicPlayerItem *)item
{
    if (item.document.documentId != 0)
        return [[TGMediaId alloc] initWithType:3 itemId:item.document.documentId];
    else if (item.document.localDocumentId != 0 && item.document.documentUri.length != 0)
        return [[TGMediaId alloc] initWithType:3 itemId:item.document.localDocumentId];
    return nil;
}

- (instancetype)initWithItem:(TGMusicPlayerItem *)item priority:(bool)priority updated:(void (^)(TGMusicPlayerItemAvailability))updated
{
    self = [super init];
    if (self != nil)
    {
        _item = item;
        _updated = [updated copy];
        _mediaId = [self mediaIdForItem:_item];
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        
        [ActionStageInstance() watchForPaths:@[
            @"downloadManagerStateChanged"
        ] watcher:self];
        [[TGDownloadManager instance] requestState:self.actionHandle];
        [self requestDownloadItem:priority];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    [[TGDownloadManager instance] cancelItem:_mediaId];
}

- (void)requestDownloadItem:(bool)priority
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        TGDocumentMediaAttachment *documentAttachment = _item.document;
        if (documentAttachment.documentId != 0 || documentAttachment.documentUri.length != 0)
        {
            id mediaId = [[TGMediaId alloc] initWithType:3 itemId:documentAttachment.documentId != 0 ? documentAttachment.documentId : documentAttachment.localDocumentId];
            [[TGDownloadManager instance] requestItem:[NSString stringWithFormat:@"/tg/media/document/(%d:%" PRId64 ":%@)", documentAttachment.datacenterId, documentAttachment.documentId, documentAttachment.documentUri.length != 0 ? documentAttachment.documentUri : @""] options:[[NSDictionary alloc] initWithObjectsAndKeys:documentAttachment, @"documentAttachment", nil] changePriority:priority messageId:[(NSNumber *)_item.key intValue] itemId:mediaId groupId:[_item peerId] itemClass:TGDownloadItemClassDocument];
        }
    }];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"downloadManagerStateChanged"])
    {
        NSDictionary *mediaList = resource;
        [mediaList enumerateKeysAndObjectsUsingBlock:^(__unused NSString *path, TGDownloadItem *item, __unused BOOL *stop)
        {
            if ([item.itemId isEqual:_mediaId])
            {
                TGMusicPlayerItemAvailability availability = {.downloaded = false, .downloading = true, .progress = (CGFloat)item.progress};
                if (_updated)
                    _updated(availability);
                if (stop)
                    *stop = true;
            }
        }];
        
        for (id mediaId in [arguments objectForKey:@"completedItemIds"])
        {
            if ([_mediaId isEqual:mediaId])
            {
                TGMusicPlayerItemAvailability availability = {.downloaded = true, .downloading = false, .progress = 1.0f};
                if (_updated)
                    _updated(availability);
            }
        }
        
        for (id mediaId in [arguments objectForKey:@"failedItemIds"])
        {
            if ([_mediaId isEqual:mediaId])
            {
                TGMusicPlayerItemAvailability availability = {.downloaded = false, .downloading = false, .progress = 0.0f};
                if (_updated)
                    _updated(availability);
            }
        }
    }
}

@end

@implementation TGMusicPlayerItemSignals

+ (NSString *)pathForItem:(TGMusicPlayerItem *)item
{
    NSString *path = nil;
    if (item.document.documentId != 0)
        path = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:item.document.documentId];
    else
    {
        path = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:item.document.localDocumentId];
    }
    
    path = [path stringByAppendingPathComponent:[item.document safeFileName]];
    return path;
}

+ (SSignal *)downloadItem:(TGMusicPlayerItem *)item priority:(bool)priority
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGMusicPlayerItemAvailability availability = {.downloaded = false, .downloading = true, .progress = 0.0f};
        [subscriber putNext:@(TGMusicPlayerItemAvailabilityPack(availability))];
        
        TGMusicPlayerItemDownloadHelper *helper = [[TGMusicPlayerItemDownloadHelper alloc] initWithItem:item priority:priority updated:^(TGMusicPlayerItemAvailability availability)
        {
            [subscriber putNext:@(TGMusicPlayerItemAvailabilityPack(availability))];
        }];
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [helper description]; //keep reference
        }];
    }];
}

+ (SSignal *)itemAvailability:(TGMusicPlayerItem *)item priority:(bool)priority
{
    return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        NSString *path = [self pathForItem:item];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            TGMusicPlayerItemAvailability availability = {.downloaded = true, .downloading = false, .progress = 1.0f};
            [subscriber putNext:@(TGMusicPlayerItemAvailabilityPack(availability))];
        }
        else
            [subscriber putError:nil];
        return nil;
    }] catch:^SSignal *(__unused id error)
    {
        return [self downloadItem:item priority:priority];
    }];
}

@end
