#import "TGMusicPlayerItemSignals.h"

#import "ActionStage.h"

#import "TGDocumentMediaAttachment.h"
#import "TGPreparedLocalDocumentMessage.h"
#import "TGMessage.h"

#import "TGDownloadManager.h"
#import "TGVideoDownloadActor.h"

#import "TGBotContextResult.h"
#import "TGBotContextExternalResult.h"
#import "TGBotContextMediaResult.h"

#import "TGStringUtils.h"
#import "TGMediaStoreContext.h"

#import "TL/TLMetaScheme.h"

#import "TGTelegramNetworking.h"

static TLInputFileLocation$inputDocumentFileLocation *fileLocationForDocument(TGDocumentMediaAttachment *document) {
    TLInputFileLocation$inputDocumentFileLocation *location = [[TLInputFileLocation$inputDocumentFileLocation alloc] init];
    location.n_id = document.documentId;
    location.access_hash = document.accessHash;
    return location;
}

NSString *cacheKeyForDocument(TGDocumentMediaAttachment *document) {
    TLInputFileLocation$inputDocumentFileLocation *location = fileLocationForDocument(document);
    return [[NSString alloc] initWithFormat:@"inputDocumentFileLocation-%lld", location.n_id];
}

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
    NSString *_downloadPath;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGMusicPlayerItemDownloadHelper

- (TGMediaId *)mediaIdForItem:(TGMusicPlayerItem *)item
{
    if ([item.media isKindOfClass:[TGDocumentMediaAttachment class]]) {
        TGDocumentMediaAttachment *document = item.media;
        if (document.documentId != 0)
            return [[TGMediaId alloc] initWithType:3 itemId:document.documentId];
        else if (document.localDocumentId != 0 && document.documentUri.length != 0)
            return [[TGMediaId alloc] initWithType:3 itemId:document.localDocumentId];
    } else if ([item.media isKindOfClass:[TGAudioMediaAttachment class]]) {
        TGAudioMediaAttachment *audio = item.media;
        return [[TGMediaId alloc] initWithType:4 itemId:audio.audioId != 0 ? audio.audioId : audio.localAudioId];
    } else if ([item.media isKindOfClass:[TGVideoMediaAttachment class]]) {
        TGVideoMediaAttachment *video = item.media;
        return [[TGMediaId alloc] initWithType:1 itemId:video.videoId != 0 ? video.videoId : video.localVideoId];
    }
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
        
        if (_mediaId != nil && [(NSNumber *)_item.key intValue] != 0) {
            [[TGDownloadManager instance] requestState:self.actionHandle];
            [self requestDownloadItem:priority];
        } else {
            if ([item.media isKindOfClass:[TGBotContextExternalResult class]]) {
                TGBotContextExternalResult *externalResult = item.media;
                _downloadPath = [[NSString alloc] initWithFormat:@"/temporaryDownload/(%@,%@)", [TGStringUtils stringByEscapingForActorURL:externalResult.originalUrl], @"path"];
                [ActionStageInstance() requestActor:_downloadPath options:@{@"url": externalResult.originalUrl, @"cache": [[TGMediaStoreContext instance] temporaryFilesCache], @"returnPath": @true, @"mediaTypeTag": @(TGNetworkMediaTypeTagAudio)} flags:0 watcher:self];
            } else if ([item.media isKindOfClass:[TGBotContextMediaResult class]]) {
                TGBotContextMediaResult *mediaResult = item.media;
                if (mediaResult.document != nil) {
                    _downloadPath = [[NSString alloc] initWithFormat:@"/temporaryDownload/(%@,%@)", [TGStringUtils stringByEscapingForActorURL:cacheKeyForDocument(mediaResult.document)], @"path"];
                    [ActionStageInstance() requestActor:_downloadPath options:@{@"cacheKey": [cacheKeyForDocument(mediaResult.document) dataUsingEncoding:NSUTF8StringEncoding], @"cache": [[TGMediaStoreContext instance] temporaryFilesCache], @"returnPath": @true, @"inputLocation": fileLocationForDocument(mediaResult.document), @"datacenterId": @(mediaResult.document.datacenterId), @"size": @(mediaResult.document.size), @"mediaTypeTag": @(TGNetworkMediaTypeTagAudio)} flags:0 watcher:self];
                }
            } else if ([item.media isKindOfClass:[TGDocumentMediaAttachment class]]) {
                TGDocumentMediaAttachment *document = ((TGDocumentMediaAttachment *)item.media);
                _downloadPath = [[NSString alloc] initWithFormat:@"/temporaryDownload/(%@,%@)", [TGStringUtils stringByEscapingForActorURL:cacheKeyForDocument(document)], @"path"];
                [ActionStageInstance() requestActor:_downloadPath options:@{@"cacheKey": [cacheKeyForDocument(document) dataUsingEncoding:NSUTF8StringEncoding], @"cache": [[TGMediaStoreContext instance] temporaryFilesCache], @"returnPath": @true, @"inputLocation": fileLocationForDocument(document), @"datacenterId": @(document.datacenterId), @"size": @(document.size), @"mediaTypeTag": @(TGNetworkMediaTypeTagAudio)} flags:0 watcher:self];
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

- (void)requestDownloadItem:(bool)priority
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if ([_item.media isKindOfClass:[TGDocumentMediaAttachment class]]) {
            TGDocumentMediaAttachment *documentAttachment = _item.media;
            if (documentAttachment.documentId != 0 || documentAttachment.documentUri.length != 0)
            {
                id mediaId = [[TGMediaId alloc] initWithType:3 itemId:documentAttachment.documentId != 0 ? documentAttachment.documentId : documentAttachment.localDocumentId];
                [[TGDownloadManager instance] requestItem:[NSString stringWithFormat:@"/tg/media/document/(%d:%" PRId64 ":%@)", documentAttachment.datacenterId, documentAttachment.documentId, documentAttachment.documentUri.length != 0 ? documentAttachment.documentUri : @""] options:[[NSDictionary alloc] initWithObjectsAndKeys:documentAttachment, @"documentAttachment", nil] changePriority:priority messageId:[(NSNumber *)_item.key intValue] itemId:mediaId groupId:[_item peerId] itemClass:TGDownloadItemClassDocument];
            }
        } else if ([_item.media isKindOfClass:[TGAudioMediaAttachment class]]) {
            TGAudioMediaAttachment *audio = _item.media;
            if (audio.audioId != 0 || audio.audioUri.length != 0) {
                id mediaId = [[TGMediaId alloc] initWithType:4 itemId:audio.audioId != 0 ? audio.audioId : audio.localAudioId];
                
                [[TGDownloadManager instance] requestItem:[NSString stringWithFormat:@"/tg/media/audio/(%" PRId32 ":%" PRId64 ":%@)", audio.datacenterId, audio.audioId, audio.audioUri.length != 0 ? audio.audioUri : @""] options:[[NSDictionary alloc] initWithObjectsAndKeys:audio, @"audioAttachment", nil] changePriority:priority messageId:[(NSNumber *)_item.key intValue] itemId:mediaId groupId:[_item peerId] itemClass:TGDownloadItemClassAudio];
            }
        } else if ([_item.media isKindOfClass:[TGVideoMediaAttachment class]]) {
            TGVideoMediaAttachment *video = _item.media;
            if (video.videoId != 0) {
                id mediaId = [[TGMediaId alloc] initWithType:1 itemId:video.videoId];
            
                NSString *videoUri = [video.videoInfo urlWithQuality:0 actualQuality:NULL actualSize:NULL];
                if (videoUri != nil)
                {
                    [[TGDownloadManager instance] requestItem:[NSString stringWithFormat:@"/as/media/video/(%@)", videoUri] options:[[NSDictionary alloc] initWithObjectsAndKeys:video, @"videoAttachment", nil] changePriority:priority messageId:[(NSNumber *)_item.key intValue] itemId:mediaId groupId:[_item peerId]  itemClass:TGDownloadItemClassVideo];
                }
            }
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

- (void)actorMessageReceived:(NSString *)path messageType:(NSString *)messageType message:(id)message {
    if ([messageType isEqualToString:@"progress"]) {
        if ([path isEqualToString:_downloadPath]) {
            TGMusicPlayerItemAvailability availability = {.downloaded = false, .downloading = true, .progress = (CGFloat)[message floatValue]};
            if (_updated)
                _updated(availability);
        }
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)__unused result {
    if ([path isEqualToString:_downloadPath]) {
        if (status == ASStatusSuccess) {
            TGMusicPlayerItemAvailability availability = {.downloaded = true, .downloading = false, .progress = 1.0f};
            if (_updated)
                _updated(availability);
        } else {
            TGMusicPlayerItemAvailability availability = {.downloaded = false, .downloading = false, .progress = 0.0f};
            if (_updated)
                _updated(availability);
        }
    }
}

@end

@implementation TGMusicPlayerItemSignals

+ (NSString *)pathForItem:(TGMusicPlayerItem *)item
{
    if ([item.media isKindOfClass:[TGDocumentMediaAttachment class]]) {
        TGDocumentMediaAttachment *document = item.media;
        
        if ([(NSNumber *)item.key intValue] != 0) {
            NSString *path = nil;
            if (document.documentId != 0)
                path = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId version:document.version];
            else
            {
                path = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:document.localDocumentId version:document.version];
            }
            
            path = [path stringByAppendingPathComponent:[document safeFileName]];
            return path;
        } else {
            NSString *cacheKey = cacheKeyForDocument(document);
            return [[[TGMediaStoreContext instance] temporaryFilesCache] _filePathForKey:[cacheKey dataUsingEncoding:NSUTF8StringEncoding]];
        }
    } else if ([item.media isKindOfClass:[TGAudioMediaAttachment class]]) {
        TGAudioMediaAttachment *audio = item.media;
        NSString *path = nil;
        if (audio.audioId != 0)
            path = [TGAudioMediaAttachment localAudioFilePathForRemoteAudioId:audio.audioId];
        else
        {
            path = [TGAudioMediaAttachment localAudioFilePathForLocalAudioId:audio.localAudioId];
        }
        
        return path;
    } else if ([item.media isKindOfClass:[TGBotContextResult class]]) {
        TGBotContextResult *result = item.media;
        if ([result isKindOfClass:[TGBotContextMediaResult class]]) {
            TGDocumentMediaAttachment *document = ((TGBotContextMediaResult *)result).document;
            NSString *cacheKey = cacheKeyForDocument(document);
            return [[[TGMediaStoreContext instance] temporaryFilesCache] _filePathForKey:[cacheKey dataUsingEncoding:NSUTF8StringEncoding]];
            /*if (document != nil) {
                NSString *path = nil;
                if (document.documentId != 0) {
                    path = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId];
                } else {
                    path = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:document.localDocumentId];
                }
                path = [path stringByAppendingPathComponent:[document safeFileName]];
                return path;
            }*/
        } else if ([result isKindOfClass:[TGBotContextExternalResult class]]) {
            TGBotContextExternalResult *externalResult = (TGBotContextExternalResult *)result;
            if (externalResult.originalUrl.length != 0) {
                NSString *path = [[[TGMediaStoreContext instance] temporaryFilesCache] _filePathForKey:[externalResult.originalUrl dataUsingEncoding:NSUTF8StringEncoding]];
                return path;
            }
        }
    } else if ([item.media isKindOfClass:[TGVideoMediaAttachment class]]) {
        return [TGVideoDownloadActor localPathForVideoUrl:[((TGVideoMediaAttachment *)item.media).videoInfo urlWithQuality:0 actualQuality:NULL actualSize:NULL]];
    }
    return nil;
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
