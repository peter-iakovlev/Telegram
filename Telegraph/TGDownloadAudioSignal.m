#import "TGDownloadAudioSignal.h"

#import "ActionStage.h"
#import "TGDownloadManager.h"

#import "TGBridgeSignalManager.h"

#import "TGMessage.h"
#import "TGPreparedLocalDocumentMessage.h"

@interface TGDownloadMediaAdapter : NSObject <ASWatcher>
{
    TGMediaAttachment *_attachment;
    TGMediaId *_mediaId;
    
    CGFloat _progress;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, copy) void(^completionBlock)(NSString *path);
@property (nonatomic, copy) void(^progressBlock)(CGFloat progress);

@end

@implementation TGDownloadMediaAdapter

- (instancetype)initWithAttachment:(TGMediaAttachment *)attachment conversationId:(int64_t)cid messageId:(int32_t)mid
{
    self = [super init];
    if (self != nil)
    {
        self.actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
        
        [ActionStageInstance() watchForPaths:@
        [
            @"downloadManagerStateChanged"
        ] watcher:self];
        
        if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
        {
            TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
            if (documentAttachment.documentId != 0 || documentAttachment.documentUri.length != 0)
            {
                _mediaId = [[TGMediaId alloc] initWithType:3 itemId:documentAttachment.documentId != 0 ? documentAttachment.documentId : documentAttachment.localDocumentId];
                
                [[TGDownloadManager instance] requestItem:[NSString stringWithFormat:@"/tg/media/document/(%d:%" PRId64 ":%@)", documentAttachment.datacenterId, documentAttachment.documentId, documentAttachment.documentUri.length != 0 ? documentAttachment.documentUri : @""] options:[[NSDictionary alloc] initWithObjectsAndKeys:documentAttachment, @"documentAttachment", nil] changePriority:true messageId:mid itemId:_mediaId groupId:cid itemClass:TGDownloadItemClassDocument];
                
                _attachment = attachment;
            }
            else
            {
                return nil;
            }
        }
        else if ([attachment isKindOfClass:[TGAudioMediaAttachment class]])
        {
            TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
            if (audioAttachment.audioId != 0 || audioAttachment.audioUri.length != 0)
            {
                _mediaId = [[TGMediaId alloc] initWithType:4 itemId:audioAttachment.audioId != 0 ? audioAttachment.audioId : audioAttachment.localAudioId];
                
                [[TGDownloadManager instance] requestItem:[NSString stringWithFormat:@"/tg/media/audio/(%" PRId32 ":%" PRId64 ":%@)", audioAttachment.datacenterId, audioAttachment.audioId, audioAttachment.audioUri.length != 0 ? audioAttachment.audioUri : @""] options:[[NSDictionary alloc] initWithObjectsAndKeys:audioAttachment, @"audioAttachment", nil] changePriority:true messageId:mid itemId:_mediaId groupId:cid itemClass:TGDownloadItemClassAudio];
                
                _attachment = attachment;
            }
            else
            {
                return nil;
            }
        }
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    [[TGDownloadManager instance] cancelItem:_mediaId];
}

- (void)startWithCompletion:(void (^)(NSString *))completion progress:(void (^)(CGFloat))progress
{
    self.completionBlock = completion;
    self.progressBlock = progress;
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)arguments
{
    if ([path isEqualToString:@"downloadManagerStateChanged"])
    {
        NSDictionary *mediaList = resource;
        NSMutableDictionary *messageDownloadProgress = [[NSMutableDictionary alloc] init];
        
        if (mediaList == nil || mediaList.count == 0)
        {
            [messageDownloadProgress removeAllObjects];
        }
        else
        {
            [mediaList enumerateKeysAndObjectsUsingBlock:^(__unused NSString *path, TGDownloadItem *item, __unused BOOL *stop)
            {
                if (item.itemId != nil)
                    [messageDownloadProgress setObject:[[NSNumber alloc] initWithFloat:item.progress] forKey:item.itemId];
            }];
        }
        
        NSNumber *nProgress = messageDownloadProgress[_mediaId];
        if (nProgress != nil && fabs(nProgress.floatValue - _progress) > FLT_EPSILON)
        {
            _progress = nProgress.floatValue;
            if (self.progressBlock != nil)
                self.progressBlock(_progress);
        }
        
        if (arguments != nil)
        {
            NSMutableDictionary *completedItemStatuses = [[NSMutableDictionary alloc] init];
            for (id mediaId in [arguments objectForKey:@"completedItemIds"])
                [completedItemStatuses setObject:@(true) forKey:mediaId];
            
            for (id mediaId in [arguments objectForKey:@"failedItemIds"])
                [completedItemStatuses setObject:@(false) forKey:mediaId];
            
            NSNumber *nResult = completedItemStatuses[_mediaId];
            if (nResult != nil)
            {
                bool succeed = nResult.boolValue;
                if (self.completionBlock != nil)
                {
                    if (succeed)
                    {
                        NSString *path = nil;
                        if ([_attachment isKindOfClass:[TGDocumentMediaAttachment class]])
                            path = [TGDownloadAudioSignal pathForDocumentMediaAttachment:(TGDocumentMediaAttachment *)_attachment];
                        else if ([_attachment isKindOfClass:[TGAudioMediaAttachment class]])
                            path = ((TGAudioMediaAttachment *)_attachment).localFilePath;
                        
                        self.completionBlock(path);
                    }
                    else
                    {
                        self.completionBlock(nil);
                    }
                }
            }
        }
    }
}

@end


@implementation TGDownloadAudioSignal

+ (SSignal *)downloadAudioWithAttachment:(TGMediaAttachment *)attachment conversationId:(int64_t)cid messageId:(int32_t)mid
{
    if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]] && ((TGDocumentMediaAttachment *)attachment).documentId == 0 && ((TGDocumentMediaAttachment *)attachment).localDocumentId == 0)
        return [SSignal fail:nil];
    else if ([attachment isKindOfClass:[TGAudioMediaAttachment class]] && ((TGAudioMediaAttachment *)attachment).audioId == 0 && ((TGAudioMediaAttachment *)attachment).localAudioId == 0)
        return [SSignal fail:nil];
    
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGDownloadMediaAdapter *adapter = [[TGDownloadMediaAdapter alloc] initWithAttachment:attachment conversationId:cid messageId:mid];
        [adapter startWithCompletion:^(NSString *path)
        {
            if (path != nil)
            {
                [subscriber putNext:path];
                [subscriber putCompletion];
            }
            else
            {
                [subscriber putError:nil];
            }
        } progress:nil];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [adapter description];
        }];
    }];
}

+ (TGBridgeSignalManager *)signalManager
{
    static dispatch_once_t onceToken;
    static TGBridgeSignalManager *signalManager;
    dispatch_once(&onceToken, ^
    {
        signalManager = [[TGBridgeSignalManager alloc] init];
    });
    return signalManager;
}

+ (NSString *)pathForDocumentMediaAttachment:(TGDocumentMediaAttachment *)documentMedia
{
    if (documentMedia.localDocumentId != 0)
    {
        NSString *path = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:documentMedia.localDocumentId version:documentMedia.version] stringByAppendingPathComponent:documentMedia.safeFileName];
        return path;
    }
    
    NSString *path = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:documentMedia.documentId version:documentMedia.version] stringByAppendingPathComponent:documentMedia.safeFileName];
    return path;
}

@end
