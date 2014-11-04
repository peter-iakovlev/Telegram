#import "TGModernSendCommonMessageActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGPreparedTextMessage.h"
#import "TGPreparedMapMessage.h"
#import "TGPreparedLocalImageMessage.h"
#import "TGPreparedRemoteImageMessage.h"
#import "TGPreparedLocalVideoMessage.h"
#import "TGPreparedRemoteVideoMessage.h"
#import "TGPreparedForwardedMessage.h"
#import "TGPreparedContactMessage.h"
#import "TGPreparedLocalDocumentMessage.h"
#import "TGPreparedRemoteDocumentMessage.h"
#import "TGPreparedLocalAudioMessage.h"
#import "TGPreparedDownloadImageMessage.h"
#import "TGPreparedDownloadDocumentMessage.h"

#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"
#import "TGDatabase.h"

#import "TGRemoteImageView.h"
#import "TGImageDownloadActor.h"
#import "TGVideoDownloadActor.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "TGMessage+Telegraph.h"

#import "TGMediaStoreContext.h"

#import "PSLMDBKeyValueStore.h"

@interface TGModernSendCommonMessageActor ()
{
    int64_t _conversationId;
    
    bool _shouldPostAlmostDeliveredMessage;
}

@end

@implementation TGModernSendCommonMessageActor

+ (PSLMDBKeyValueStore *)uploadedMediaStore
{
    static PSLMDBKeyValueStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0];
        store = [PSLMDBKeyValueStore storeWithPath:[documentsPath stringByAppendingPathComponent:@"misc/remotefiles"] size:4 * 1024 * 1024];
    });
    return store;
}

+ (TGDocumentMediaAttachment *)remoteDocumentByGiphyId:(NSString *)giphyId
{
    if (giphyId.length == 0)
        return nil;
    
    __block NSData *documentData = nil;
    [[self uploadedMediaStore] readInTransaction:^(id<PSKeyValueReader> reader)
    {
        NSMutableData *keyData = [[NSMutableData alloc] init];
        int8_t keyspace = 0;
        [keyData appendBytes:&keyspace length:1];
        [keyData appendData:[giphyId dataUsingEncoding:NSUTF8StringEncoding]];
        PSData key = {.data = (uint8_t *)keyData.bytes, .length = keyData.length};
        PSData value;
        if ([reader readValueForRawKey:&key value:&value])
            documentData = [[NSData alloc] initWithBytes:value.data length:value.length];
    }];
    
    if (documentData != nil)
    {
        id attachment = [TGMessage parseMediaAttachments:documentData].firstObject;
        if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
            return attachment;
    }
    return nil;
}

+ (void)setRemoteDocumentForGiphyId:(NSString *)giphyId document:(TGDocumentMediaAttachment *)document
{
    if (giphyId.length == 0 || document == nil)
        return;
    
    NSData *documentData = [TGMessage serializeMediaAttachments:true attachments:@[document]];
    if (documentData != nil)
    {
        [[self uploadedMediaStore] readWriteInTransaction:^(id<PSKeyValueReader,PSKeyValueWriter> writer)
        {
            NSMutableData *keyData = [[NSMutableData alloc] init];
            int8_t keyspace = 0;
            [keyData appendBytes:&keyspace length:1];
            [keyData appendData:[giphyId dataUsingEncoding:NSUTF8StringEncoding]];
            PSData key = {.data = (uint8_t *)keyData.bytes, .length = keyData.length};
            PSData value = {.data = (uint8_t *)documentData.bytes, .length = documentData.length};
            [writer writeValueForRawKey:key.data keyLength:key.length value:value.data valueLength:value.length];
        }];
    }
}

+ (TGImageMediaAttachment *)remoteImageByRemoteUrl:(NSString *)url
{
    if (url.length == 0)
        return nil;
    
    __block NSData *imageData = nil;
    [[self uploadedMediaStore] readInTransaction:^(id<PSKeyValueReader> reader)
    {
        NSMutableData *keyData = [[NSMutableData alloc] init];
        int8_t keyspace = 1;
        [keyData appendBytes:&keyspace length:1];
        [keyData appendData:[url dataUsingEncoding:NSUTF8StringEncoding]];
        PSData key = {.data = (uint8_t *)keyData.bytes, .length = keyData.length};
        PSData value;
        if ([reader readValueForRawKey:&key value:&value])
            imageData = [[NSData alloc] initWithBytes:value.data length:value.length];
    }];
    
    if (imageData != nil)
    {
        id attachment = [TGMessage parseMediaAttachments:imageData].firstObject;
        if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
            return attachment;
    }
    return nil;
}

+ (void)setRemoteImageForRemoteUrl:(NSString *)url image:(TGImageMediaAttachment *)image
{
    if (url.length == 0 || image == nil)
        return;
    
    NSData *imageData = [TGMessage serializeMediaAttachments:true attachments:@[image]];
    if (imageData != nil)
    {
        [[self uploadedMediaStore] readWriteInTransaction:^(id<PSKeyValueReader,PSKeyValueWriter> writer)
        {
            NSMutableData *keyData = [[NSMutableData alloc] init];
            int8_t keyspace = 1;
            [keyData appendBytes:&keyspace length:1];
            [keyData appendData:[url dataUsingEncoding:NSUTF8StringEncoding]];
            PSData key = {.data = (uint8_t *)keyData.bytes, .length = keyData.length};
            PSData value = {.data = (uint8_t *)imageData.bytes, .length = imageData.length};
            [writer writeValueForRawKey:key.data keyLength:key.length value:value.data valueLength:value.length];
        }];
    }
}

+ (void)clearRemoteMediaMapping
{
    [[self uploadedMediaStore] readWriteInTransaction:^(id<PSKeyValueReader,PSKeyValueWriter> writer)
    {
        [writer deleteAllValues];
    }];
}

+ (NSString *)genericPath
{
    return @"/tg/sendCommonMessage/@/@";
}

- (void)prepare:(NSDictionary *)options
{
    [super prepare:options];
    
    _conversationId = [options[@"conversationId"] longLongValue];
}

- (int64_t)peerId
{
    return _conversationId;
}

- (int64_t)conversationIdForActivity
{
    return _conversationId;
}

- (void)_commitSend
{
    if (_conversationId == 0)
        [self _fail];
    else
    {
        if ([self.preparedMessage isKindOfClass:[TGPreparedTextMessage class]])
        {
            TGPreparedTextMessage *textMessage = (TGPreparedTextMessage *)self.preparedMessage;
            
            if (self.preparedMessage.randomId != 0 && self.preparedMessage.mid != 0)
                [TGDatabaseInstance() setTempIdForMessageId:textMessage.mid tempId:textMessage.randomId];
            
            _shouldPostAlmostDeliveredMessage = true;
            
            [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
            self.cancelToken = [TGTelegraphInstance doConversationSendMessage:_conversationId messageText:textMessage.text geo:nil messageGuid:nil tmpId:textMessage.randomId actor:self];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedMapMessage class]])
        {
            TGPreparedMapMessage *mapMessage = (TGPreparedMapMessage *)self.preparedMessage;
            
            TLInputGeoPoint$inputGeoPoint *geoPoint = [[TLInputGeoPoint$inputGeoPoint alloc] init];
            geoPoint.lat = mapMessage.latitude;
            geoPoint.n_long = mapMessage.longitude;
            
            [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
            self.cancelToken = [TGTelegraphInstance doConversationSendMessage:_conversationId messageText:nil geo:geoPoint messageGuid:nil tmpId:mapMessage.randomId actor:self];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalImageMessage class]])
        {
            TGPreparedLocalImageMessage *localImageMessage = (TGPreparedLocalImageMessage *)self.preparedMessage;
            
            [self setupFailTimeout:[TGModernSendCommonMessageActor defaultTimeoutInterval]];
            
            [self uploadFilesWithExtensions:@[@[localImageMessage.localImageDataPath, @"jpg", @(true)]]];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedRemoteImageMessage class]])
        {
            TGPreparedRemoteImageMessage *remoteImageMessage = (TGPreparedRemoteImageMessage *)self.preparedMessage;
            
            TLInputMedia$inputMediaPhoto *remotePhoto = [[TLInputMedia$inputMediaPhoto alloc] init];
            TLInputPhoto$inputPhoto *inputId = [[TLInputPhoto$inputPhoto alloc] init];
            inputId.n_id = remoteImageMessage.imageId;
            inputId.access_hash = remoteImageMessage.accessHash;
            remotePhoto.n_id = inputId;
            
            [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId media:remotePhoto messageGuid:nil tmpId:remoteImageMessage.randomId actor:self];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalVideoMessage class]])
        {
            TGPreparedLocalVideoMessage *localVideoMessage = (TGPreparedLocalVideoMessage *)self.preparedMessage;
            
            UIImage *thumbnailImage = [[UIImage alloc] initWithContentsOfFile:[self pathForLocalImagePath:localVideoMessage.localThumbnailDataPath]];
            CGSize thumbnailSize = TGFitSize(thumbnailImage.size, CGSizeMake(90, 90));
            NSData *thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(thumbnailImage, thumbnailSize), 0.6f);
            
            [self setupFailTimeout:[TGModernSendCommonMessageActor defaultTimeoutInterval]];
            
            NSMutableArray *desc = [[NSMutableArray alloc] initWithArray:@[[localVideoMessage localVideoPath], @"mp4", @(true)]];
            if (localVideoMessage.liveData != nil)
                [desc addObject:localVideoMessage.liveData];
            
            [self uploadFilesWithExtensions:@[desc, @[thumbnailData, @"jpg", @(false)]]];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedRemoteVideoMessage class]])
        {
            TGPreparedRemoteVideoMessage *remoteVideoMessage = (TGPreparedRemoteVideoMessage *)self.preparedMessage;
            
            TLInputMedia$inputMediaVideo *remoteVideo = [[TLInputMedia$inputMediaVideo alloc] init];
            TLInputVideo$inputVideo *inputVideo = [[TLInputVideo$inputVideo alloc] init];
            inputVideo.n_id = remoteVideoMessage.videoId;
            inputVideo.access_hash = remoteVideoMessage.accessHash;
            remoteVideo.n_id = inputVideo;
            
            [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId media:remoteVideo messageGuid:nil tmpId:remoteVideoMessage.randomId actor:self];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalDocumentMessage class]])
        {
            TGPreparedLocalDocumentMessage *localDocumentMessage = (TGPreparedLocalDocumentMessage *)self.preparedMessage;
            
            [self setupFailTimeout:[TGModernSendCommonMessageActor defaultTimeoutInterval]];
            
            NSMutableArray *uploadFiles = [[NSMutableArray alloc] init];
            
            [uploadFiles addObject:@[
                [[localDocumentMessage localDocumentDirectory] stringByAppendingPathComponent:[localDocumentMessage localDocumentFileName]], @"bin", @(true)
            ]];
            
            if (localDocumentMessage.localThumbnailDataPath != nil)
            {
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:[self pathForLocalImagePath:localDocumentMessage.localThumbnailDataPath]];
                if (image != nil)
                {
                    NSData *thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(image, TGFitSize(image.size, CGSizeMake(90, 90))), 0.6f);
                    if (thumbnailData != nil)
                        [uploadFiles addObject:@[thumbnailData, @"jpg", @(false)]];
                }
            }
            
            [self uploadFilesWithExtensions:uploadFiles];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedRemoteDocumentMessage class]])
        {
            TGPreparedRemoteDocumentMessage *remoteDocumentMessage = (TGPreparedRemoteDocumentMessage *)self.preparedMessage;
            
            TLInputMedia$inputMediaDocument *remoteDocument = [[TLInputMedia$inputMediaDocument alloc] init];
            TLInputDocument$inputDocument *inputDocument = [[TLInputDocument$inputDocument alloc] init];
            inputDocument.n_id = remoteDocumentMessage.documentId;
            inputDocument.access_hash = remoteDocumentMessage.accessHash;
            remoteDocument.n_id = inputDocument;
            
            [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId media:remoteDocument messageGuid:nil tmpId:remoteDocumentMessage.randomId actor:self];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedForwardedMessage class]])
        {
            TGPreparedForwardedMessage *forwardedMessage = (TGPreparedForwardedMessage *)self.preparedMessage;
            
            [self setupFailTimeout:[TGModernSendCommonMessageActor defaultTimeoutInterval]];
            self.cancelToken = [TGTelegraphInstance doConversationForwardMessage:_conversationId messageId:forwardedMessage.forwardMid tmpId:forwardedMessage.randomId actor:self];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedContactMessage class]])
        {
            TGPreparedContactMessage *contactMessage = (TGPreparedContactMessage *)self.preparedMessage;
            
            [self setupFailTimeout:[TGModernSendCommonMessageActor defaultTimeoutInterval]];
            
            TLInputMedia$inputMediaContact *inputContact = [[TLInputMedia$inputMediaContact alloc] init];
            inputContact.first_name = contactMessage.firstName;
            inputContact.last_name = contactMessage.lastName;
            inputContact.phone_number = contactMessage.phoneNumber;
            
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId media:inputContact messageGuid:nil tmpId:contactMessage.randomId actor:self];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalAudioMessage class]])
        {
            TGPreparedLocalAudioMessage *localAudioMessage = (TGPreparedLocalAudioMessage *)self.preparedMessage;
            
            [self setupFailTimeout:[TGModernSendCommonMessageActor defaultTimeoutInterval]];
            
            NSString *pathExtension = [[localAudioMessage localAudioFilePath1] pathExtension];
            if (pathExtension.length == 0)
                pathExtension = @"m4a";
            
            NSMutableArray *desc = [[NSMutableArray alloc] initWithArray:@[[localAudioMessage localAudioFilePath1], pathExtension, @(true)]];
            if (localAudioMessage.liveData != nil)
                [desc addObject:localAudioMessage.liveData];
            [self uploadFilesWithExtensions:@[desc]];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadImageMessage class]])
        {
            TGPreparedDownloadImageMessage *downloadImageMessage = (TGPreparedDownloadImageMessage *)self.preparedMessage;
            
            [self setupFailTimeout:[TGModernSendCommonMessageActor defaultTimeoutInterval]];
            
            bool dispatchThumbnail = false;
            NSString *url = [downloadImageMessage.imageInfo imageUrlForLargestSize:NULL];
            NSString *imagePath = [self filePathForLocalImageUrl:url];
            [[NSFileManager defaultManager] createDirectoryAtPath:[imagePath stringByDeletingLastPathComponent] withIntermediateDirectories:true attributes:nil error:nil];
            NSData *imageData = [[NSData alloc] initWithContentsOfFile:imagePath];
            if (imageData == nil)
            {
                imageData = [[[TGMediaStoreContext instance] temporaryFilesCache] getValueForKey:[url dataUsingEncoding:NSUTF8StringEncoding]];
                if (imageData != nil)
                {
                    [imageData writeToFile:imagePath atomically:false];
                    
                    dispatchThumbnail = true;
                }
            }
            
            if (imageData != nil)
            {
                [self _uploadDownloadedData:imageData dispatchThumbnail:dispatchThumbnail];
            }
            else
            {
                self.uploadProgressContainsPreDownloads = true;
                
                NSString *path = [[NSString alloc] initWithFormat:@"/temporaryDownload/(%@)", url];
                [ActionStageInstance() requestActor:path options:@{@"url": url, @"file": imagePath, @"queue": @"messagePreDownloads"} flags:0 watcher:self];
                
                [self beginUploadProgress];
            }
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadDocumentMessage class]])
        {
            TGPreparedDownloadDocumentMessage *downloadDocumentMessage = (TGPreparedDownloadDocumentMessage *)self.preparedMessage;
            
            bool dispatchThumbnail = false;
            
            NSString *documentPath = [self filePathForLocalDocumentId:downloadDocumentMessage.localDocumentId fileName:downloadDocumentMessage.fileName];
            NSData *documentData = [[NSData alloc] initWithContentsOfFile:documentPath];
            if (documentData == nil)
            {
                documentData = [[[TGMediaStoreContext instance] temporaryFilesCache] getValueForKey:[downloadDocumentMessage.documentUrl dataUsingEncoding:NSUTF8StringEncoding]];
                if (documentData != nil)
                {
                    [[NSFileManager defaultManager] createDirectoryAtPath:[documentPath stringByDeletingLastPathComponent] withIntermediateDirectories:true attributes:nil error:nil];
                    [documentData writeToFile:documentPath atomically:false];
                    
                    dispatchThumbnail = true;
                }
            }
            
            if (documentData != nil)
            {
                [self _uploadDownloadedData:documentData dispatchThumbnail:dispatchThumbnail];
            }
            else
            {
                [self setupFailTimeout:[TGModernSendCommonMessageActor defaultTimeoutInterval]];
                self.uploadProgressContainsPreDownloads = true;
                
                NSString *path = [[NSString alloc] initWithFormat:@"/temporaryDownload/(%@)", downloadDocumentMessage.documentUrl];
                [ActionStageInstance() requestActor:path options:@{@"url": downloadDocumentMessage.documentUrl, @"path": documentPath, @"queue": @"messagePreDownloads"} flags:0 watcher:self];
                
                [self beginUploadProgress];
            }
        }
        else
            [self _fail];
    }
}

- (NSString *)filePathForLocalDocumentId:(int64_t)localDocumentId fileName:(NSString *)fileName
{
    NSString *directory = nil;
    directory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:localDocumentId];
    
    NSString *filePath = [directory stringByAppendingPathComponent:[TGDocumentMediaAttachment safeFileNameForFileName:fileName]];
    return filePath;
}

- (NSString *)filePathForLocalImageUrl:(NSString *)localImageUrl
{
    static NSString *filesDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        filesDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0] stringByAppendingPathComponent:@"files"];
    });
    
    int64_t localImageId = murMurHash32(localImageUrl);
    
    NSString *photoDirectoryName = [[NSString alloc] initWithFormat:@"image-local-%" PRIx64 "", localImageId];
    NSString *photoDirectory = [filesDirectory stringByAppendingPathComponent:photoDirectoryName];
    
    NSString *imagePath = [photoDirectory stringByAppendingPathComponent:@"image.jpg"];
    return imagePath;
}

- (NSString *)filePathForRemoteImageId:(int64_t)remoteImageId
{
    static NSString *filesDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        filesDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0] stringByAppendingPathComponent:@"files"];
    });
    
    NSString *photoDirectoryName = [[NSString alloc] initWithFormat:@"image-remote-%" PRIx64 "", remoteImageId];
    NSString *photoDirectory = [filesDirectory stringByAppendingPathComponent:photoDirectoryName];
    
    NSString *imagePath = [photoDirectory stringByAppendingPathComponent:@"image.jpg"];
    return imagePath;
}

- (void)_fail
{
    std::vector<TGDatabaseMessageFlagValue> flags;
    flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDeliveryState, .value = TGMessageDeliveryStateFailed});
    [TGDatabaseInstance() updateMessage:self.preparedMessage.mid flags:flags media:nil dispatch:true];
    
    [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"messageDeliveryFailed" message:@{
        @"previousMid": @(self.preparedMessage.mid)
    }];
    
    [super _fail];
}

#pragma mark -

- (void)_uploadDownloadedData:(NSData *)data dispatchThumbnail:(bool)dispatchThumbnail
{
    if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadImageMessage class]])
    {
        TGPreparedDownloadImageMessage *downloadImageMessage = (TGPreparedDownloadImageMessage *)self.preparedMessage;
        if (dispatchThumbnail)
        {
            NSString *thumbnailUrl = [downloadImageMessage.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
            if (thumbnailUrl != nil)
            {
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/as/media/imageThumbnailUpdated"] resource:thumbnailUrl];
            }
        }
        
        [self uploadFilesWithExtensions:@[@[data, @"jpg", @(true)]]];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadDocumentMessage class]])
    {
        TGPreparedDownloadDocumentMessage *downloadDocumentMessage = (TGPreparedDownloadDocumentMessage *)self.preparedMessage;
        if (dispatchThumbnail)
        {
            NSString *thumbnailUrl = [downloadDocumentMessage.thumbnailInfo imageUrlForLargestSize:NULL];
            if (thumbnailUrl != nil)
            {
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/as/media/imageThumbnailUpdated"] resource:thumbnailUrl];
            }
        }
        
        NSMutableArray *files = [[NSMutableArray alloc] init];
        [files addObject:@[data, @"gif", @(true)]];
        
        UIImage *image = [[UIImage alloc] initWithData:data];
        NSData *thumbnailData = nil;
        if (image != nil)
        {
            image = TGScaleImageToPixelSize(image, TGFitSize(image.size, CGSizeMake(90, 90)));
            if (image != nil)
                thumbnailData = UIImageJPEGRepresentation(image, 0.6f);
            if (thumbnailData != nil)
                [files addObject:@[thumbnailData, @"jpg", @(false)]];
        }
        [self uploadFilesWithExtensions:files];
    }
    else
        [self _fail];
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/temporaryDownload/"])
    {
        if (status == ASStatusSuccess)
        {
            if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadDocumentMessage class]])
            {
                NSData *documentData = result;
                TGPreparedDownloadDocumentMessage *downloadDocumentMessage = (TGPreparedDownloadDocumentMessage *)self.preparedMessage;
                NSString *documentPath = [self filePathForLocalDocumentId:downloadDocumentMessage.localDocumentId fileName:downloadDocumentMessage.fileName];
                [[NSFileManager defaultManager] createDirectoryAtPath:[documentPath stringByDeletingLastPathComponent] withIntermediateDirectories:true attributes:nil error:nil];
                [documentData writeToFile:documentPath atomically:false];
            }
            else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadImageMessage class]])
            {
                NSData *imageData = result;
                TGPreparedDownloadImageMessage *downloadImageMessage = (TGPreparedDownloadImageMessage *)self.preparedMessage;
                NSString *imagePath = [self filePathForLocalImageUrl:[downloadImageMessage.imageInfo imageUrlForLargestSize:NULL]];
                [[NSFileManager defaultManager] createDirectoryAtPath:[imagePath stringByDeletingLastPathComponent] withIntermediateDirectories:true attributes:nil error:nil];
                [imageData writeToFile:imagePath atomically:false];
            }
            [self _uploadDownloadedData:result dispatchThumbnail:true];
        }
        else
            [self _fail];
    }
    
    [super actorCompleted:status path:path result:result];
}

- (void)actorMessageReceived:(NSString *)path messageType:(NSString *)messageType message:(id)message
{
    if ([path hasPrefix:@"/temporaryDownload/"])
    {
        [self restartFailTimeoutIfRunning];
        
        [self updatePreDownloadsProgress:[message floatValue]];
    }
    
    if ([self.superclass instancesRespondToSelector:@selector(actorMessageReceived:messageType:message:)])
        [super actorMessageReceived:path messageType:messageType message:message];
}

#pragma mark -

- (void)uploadsStarted
{
    [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
}

- (void)uploadProgressChanged
{
    [self restartFailTimeoutIfRunning];
}

- (void)uploadsCompleted:(NSDictionary *)filePathToUploadedFile
{
    [self restartFailTimeoutIfRunning];
    
    if ([self.preparedMessage isKindOfClass:[TGPreparedLocalImageMessage class]])
    {
        TGPreparedLocalImageMessage *localImageMessage = (TGPreparedLocalImageMessage *)self.preparedMessage;
        
        NSDictionary *fileInfo = filePathToUploadedFile[localImageMessage.localImageDataPath];
        if (fileInfo != nil)
        {
            TLInputMedia$inputMediaUploadedPhoto *uploadedPhoto = [[TLInputMedia$inputMediaUploadedPhoto alloc] init];
            uploadedPhoto.file = fileInfo[@"file"];
            
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId media:uploadedPhoto messageGuid:nil tmpId:localImageMessage.randomId actor:self];
        }
        else
            [self _fail];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalVideoMessage class]])
    {
        TGPreparedLocalVideoMessage *localVideoMessage = (TGPreparedLocalVideoMessage *)self.preparedMessage;
        
        NSDictionary *videoFileInfo = filePathToUploadedFile[[localVideoMessage localVideoPath]];
        NSDictionary *thumbnailFileInfo = filePathToUploadedFile[@"embedded-data://0"];
        if (videoFileInfo != nil && thumbnailFileInfo != nil)
        {
            TLInputMedia$inputMediaUploadedThumbVideo *uploadedVideo = [[TLInputMedia$inputMediaUploadedThumbVideo alloc] init];
            uploadedVideo.file = videoFileInfo[@"file"];
            uploadedVideo.thumb = thumbnailFileInfo[@"file"];
            uploadedVideo.duration = (int32_t)localVideoMessage.duration;
            uploadedVideo.w = (int32_t)localVideoMessage.videoSize.width;
            uploadedVideo.h = (int32_t)localVideoMessage.videoSize.height;
            
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId media:uploadedVideo messageGuid:nil tmpId:localVideoMessage.randomId actor:self];
        }
        else
            [self _fail];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalDocumentMessage class]])
    {
        TGPreparedLocalDocumentMessage *localDocumentMessage = (TGPreparedLocalDocumentMessage *)self.preparedMessage;
        
        NSDictionary *documentFileInfo = filePathToUploadedFile[[[localDocumentMessage localDocumentDirectory] stringByAppendingPathComponent:[localDocumentMessage localDocumentFileName]]];
        NSDictionary *thumbnailFileInfo = filePathToUploadedFile[@"embedded-data://0"];
        
        if (documentFileInfo != nil)
        {
            id uploadedDocument = nil;
            
            if (localDocumentMessage.localThumbnailDataPath != nil && thumbnailFileInfo != nil)
            {
                TLInputMedia$inputMediaUploadedThumbDocument *thumbUploadedDocument = [[TLInputMedia$inputMediaUploadedThumbDocument alloc] init];
                thumbUploadedDocument.file = documentFileInfo[@"file"];
                thumbUploadedDocument.file_name = localDocumentMessage.fileName;
                thumbUploadedDocument.mime_type = localDocumentMessage.mimeType.length == 0 ? @"application/octet-stream" : localDocumentMessage.mimeType;
                thumbUploadedDocument.thumb = thumbnailFileInfo[@"file"];
                
                uploadedDocument = thumbUploadedDocument;
            }
            else
            {
                TLInputMedia$inputMediaUploadedDocument *plainUploadedDocument = [[TLInputMedia$inputMediaUploadedDocument alloc] init];
                plainUploadedDocument.file = documentFileInfo[@"file"];
                plainUploadedDocument.file_name = localDocumentMessage.fileName;
                plainUploadedDocument.mime_type = localDocumentMessage.mimeType.length == 0 ? @"application/octet-stream" : localDocumentMessage.mimeType;
                
                uploadedDocument = plainUploadedDocument;
            }
            
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId media:uploadedDocument messageGuid:nil tmpId:localDocumentMessage.randomId actor:self];
        }
        else
            [self _fail];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalAudioMessage class]])
    {
        TGPreparedLocalAudioMessage *localAudioMessage = (TGPreparedLocalAudioMessage *)self.preparedMessage;
        
        NSDictionary *audioFileInfo = filePathToUploadedFile[[localAudioMessage localAudioFilePath1]];
        if (audioFileInfo != nil)
        {
            TLInputMedia$inputMediaUploadedAudio *uploadedAudio = [[TLInputMedia$inputMediaUploadedAudio alloc] init];
            uploadedAudio.file = audioFileInfo[@"file"];
            uploadedAudio.duration = localAudioMessage.duration;
            
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId media:uploadedAudio messageGuid:nil tmpId:localAudioMessage.randomId actor:self];
        }
        else
            [self _fail];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadImageMessage class]])
    {
        TGPreparedDownloadImageMessage *downloadImageMessage = (TGPreparedDownloadImageMessage *)self.preparedMessage;
        
        NSDictionary *fileInfo = filePathToUploadedFile[@"embedded-data://0"];
        if (fileInfo != nil)
        {
            TLInputMedia$inputMediaUploadedPhoto *uploadedPhoto = [[TLInputMedia$inputMediaUploadedPhoto alloc] init];
            uploadedPhoto.file = fileInfo[@"file"];
            
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId media:uploadedPhoto messageGuid:nil tmpId:downloadImageMessage.randomId actor:self];
        }
        else
            [self _fail];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadDocumentMessage class]])
    {
        TGPreparedDownloadDocumentMessage *downloadDocumentMessage = (TGPreparedDownloadDocumentMessage *)self.preparedMessage;
        
        NSDictionary *documentFileInfo = filePathToUploadedFile[@"embedded-data://0"];
        NSDictionary *thumbnailFileInfo = filePathToUploadedFile[@"embedded-data://1"];
        if (documentFileInfo != nil)
        {
            id uploadedDocument = nil;
            
            if (thumbnailFileInfo != nil)
            {
                TLInputMedia$inputMediaUploadedThumbDocument *thumbUploadedDocument = [[TLInputMedia$inputMediaUploadedThumbDocument alloc] init];
                thumbUploadedDocument.file = documentFileInfo[@"file"];
                thumbUploadedDocument.file_name = downloadDocumentMessage.fileName;
                thumbUploadedDocument.mime_type = downloadDocumentMessage.mimeType.length == 0 ? @"application/octet-stream" : downloadDocumentMessage.mimeType;
                thumbUploadedDocument.thumb = thumbnailFileInfo[@"file"];
                
                uploadedDocument = thumbUploadedDocument;
            }
            else
            {
                TLInputMedia$inputMediaUploadedDocument *plainUploadedDocument = [[TLInputMedia$inputMediaUploadedDocument alloc] init];
                plainUploadedDocument.file = documentFileInfo[@"file"];
                plainUploadedDocument.file_name = downloadDocumentMessage.fileName;
                plainUploadedDocument.mime_type = downloadDocumentMessage.mimeType.length == 0 ? @"application/octet-stream" : downloadDocumentMessage.mimeType;
                
                uploadedDocument = plainUploadedDocument;
            }
            
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId media:uploadedDocument messageGuid:nil tmpId:downloadDocumentMessage.randomId actor:self];
        }
        else
            [self _fail];
    }
    else
        [self _fail];
    
    [super uploadsCompleted:filePathToUploadedFile];
}

#pragma mark -

- (void)conversationSendMessageRequestSuccess:(id)result
{
#warning link update
    
    if ([result isKindOfClass:[TLmessages_SentMessage class]])
    {
        TLmessages_SentMessage *sentMessage = result;
        
        std::vector<TGDatabaseMessageFlagValue> flags;
        flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDeliveryState, .value = TGMessageDeliveryStateDelivered});
        flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagMid, .value = sentMessage.n_id});
        flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDate, .value = sentMessage.date});
        [TGDatabaseInstance() updateMessage:self.preparedMessage.mid flags:flags media:nil dispatch:true];
        
        if (self.preparedMessage.randomId != 0)
            [TGDatabaseInstance() removeTempIds:@[@(self.preparedMessage.randomId)]];
        
        [[TGTelegramNetworking instance] updatePts:sentMessage.pts date:0 seq:sentMessage.seq];
        
        [self _success:@{
            @"previousMid": @(self.preparedMessage.mid),
            @"mid": @(sentMessage.n_id),
            @"date": @(sentMessage.date)
        }];
    }
    else if ([result isKindOfClass:[TLmessages_StatedMessage class]])
    {
        TLmessages_StatedMessage *statedMessage = result;
        
        int32_t date = 0;
        if ([statedMessage.message isKindOfClass:[TLMessage$message class]])
            date = ((TLMessage$message *)statedMessage.message).date;
        else if ([statedMessage.message isKindOfClass:[TLMessage$messageForwarded class]])
            date = ((TLMessage$message *)statedMessage.message).date;
        else if ([statedMessage.message isKindOfClass:[TLMessage$messageService class]])
            date = ((TLMessage$message *)statedMessage.message).date;
        
        TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:statedMessage.message];
        if (message == nil)
            [self _fail];
        else
        {   
            if ([self.preparedMessage isKindOfClass:[TGPreparedLocalImageMessage class]])
            {
                TGPreparedLocalImageMessage *localImageMessage = (TGPreparedLocalImageMessage *)self.preparedMessage;
                
                NSMutableArray *imageFilePaths = [[NSMutableArray alloc] init];
                if (localImageMessage.localImageDataPath != nil)
                    [imageFilePaths addObject:localImageMessage.localImageDataPath];
                if (localImageMessage.localThumbnailDataPath != nil)
                    [imageFilePaths addObject:localImageMessage.localThumbnailDataPath];
                
                for (TGMediaAttachment *attachment in message.mediaAttachments)
                {
                    if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
                    {
                        TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
                        
                        NSString *imageUrl = [imageAttachment.imageInfo closestImageUrlWithSize:localImageMessage.imageSize resultingSize:NULL];
                        if (imageUrl != nil && localImageMessage.localImageDataPath != nil)
                        {
                            [[TGRemoteImageView sharedCache] moveToCache:[self pathForLocalImagePath:localImageMessage.localImageDataPath] cacheUrl:imageUrl];
                            [imageFilePaths removeObject:localImageMessage.localImageDataPath];
                            [TGImageDownloadActor addUrlRewrite:localImageMessage.localImageDataPath newUrl:imageUrl];
                        }
                        
                        NSString *thumbnailUrl = [imageAttachment.imageInfo closestImageUrlWithSize:localImageMessage.thumbnailSize resultingSize:NULL];
                        if (thumbnailUrl != nil && localImageMessage.localThumbnailDataPath != nil)
                        {
                            [[TGRemoteImageView sharedCache] moveToCache:[self pathForLocalImagePath:localImageMessage.localThumbnailDataPath] cacheUrl:thumbnailUrl];
                            [imageFilePaths removeObject:localImageMessage.localThumbnailDataPath];
                            [TGImageDownloadActor addUrlRewrite:localImageMessage.localThumbnailDataPath newUrl:thumbnailUrl];
                        }
                        
                        if (localImageMessage.assetUrl.length != 0)
                            [TGImageDownloadActor addServerMediaSataForAssetUrl:localImageMessage.assetUrl attachment:imageAttachment];
                        
                        [TGDatabaseInstance() updateLastUseDateForMediaType:2 mediaId:imageAttachment.imageId messageId:message.mid];
                        
                        break;
                    }
                }
                
                if (imageFilePaths.count != 0)
                {
                    NSMutableArray *absolutePathsToRemove = [[NSMutableArray alloc] init];
                    for (NSString *path in imageFilePaths)
                    {
                        [absolutePathsToRemove addObject:[self pathForLocalImagePath:path]];
                    }
                    
                    dispatch_async([TGCache diskCacheQueue], ^
                    {
                        for (NSString *path in absolutePathsToRemove)
                        {
                            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                        }
                    });
                }
            }
            else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalVideoMessage class]])
            {
                TGPreparedLocalVideoMessage *localVideoMessage = (TGPreparedLocalVideoMessage *)self.preparedMessage;
                
                NSMutableArray *dataFilePaths = [[NSMutableArray alloc] init];
                if (localVideoMessage.localThumbnailDataPath != nil)
                    [dataFilePaths addObject:localVideoMessage.localThumbnailDataPath];
                if ([localVideoMessage localVideoPath] != nil)
                    [dataFilePaths addObject:[localVideoMessage localVideoPath]];
                
                for (TGMediaAttachment *attachment in message.mediaAttachments)
                {
                    if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
                    {
                        TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
                        
                        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) objectAtIndex:0];
                        NSString *videosDirectory = [documentsDirectory stringByAppendingPathComponent:@"video"];
                        if (![[NSFileManager defaultManager] fileExistsAtPath:videosDirectory])
                            [[NSFileManager defaultManager] createDirectoryAtPath:videosDirectory withIntermediateDirectories:true attributes:nil error:nil];
                        
                        NSString *updatedVideoPath = [videosDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"remote%llx.mov", videoAttachment.videoId]];
                        [[NSFileManager defaultManager] moveItemAtPath:[localVideoMessage localVideoPath] toPath:updatedVideoPath error:nil];
                        [dataFilePaths removeObject:[localVideoMessage localVideoPath]];
                        
                        NSString *remoteUrl = [videoAttachment.videoInfo urlWithQuality:1 actualQuality:NULL actualSize:NULL];
                        if (remoteUrl != nil)
                        {
                            [TGVideoDownloadActor rewriteLocalFilePath:[[NSString alloc] initWithFormat:@"local-video:local%llx.mov", localVideoMessage.localVideoId] remoteUrl:remoteUrl];
                        }
                        
                        [[TGRemoteImageView sharedCache] changeCacheItemUrl:[[NSString alloc] initWithFormat:@"video-thumbnail-local%llx.jpg", localVideoMessage.localVideoId] newUrl:[[NSString alloc] initWithFormat:@"video-thumbnail-remote%llx.jpg", videoAttachment.videoId]];
                        
                        NSString *thumbnailUrl = [videoAttachment.thumbnailInfo closestImageUrlWithSize:localVideoMessage.thumbnailSize resultingSize:NULL];
                        if (thumbnailUrl != nil && localVideoMessage.localThumbnailDataPath != nil)
                        {
                            [[TGRemoteImageView sharedCache] moveToCache:[self pathForLocalImagePath:localVideoMessage.localThumbnailDataPath] cacheUrl:thumbnailUrl];
                            [dataFilePaths removeObject:localVideoMessage.localThumbnailDataPath];
                            [TGImageDownloadActor addUrlRewrite:localVideoMessage.localThumbnailDataPath newUrl:thumbnailUrl];
                        }
                        
                        if (localVideoMessage.assetUrl.length != 0)
                            [TGImageDownloadActor addServerMediaSataForAssetUrl:localVideoMessage.assetUrl attachment:videoAttachment];
                        
                        [TGDatabaseInstance() updateLastUseDateForMediaType:1 mediaId:videoAttachment.videoId messageId:message.mid];
                    }
                }
                
                if (dataFilePaths.count != 0)
                {
                    NSMutableArray *absolutePathsToRemove = [[NSMutableArray alloc] init];
                    for (NSString *path in dataFilePaths)
                    {
                        [absolutePathsToRemove addObject:[self pathForLocalImagePath:path]];
                    }
                    
                    dispatch_async([TGCache diskCacheQueue], ^
                    {
                        for (NSString *path in absolutePathsToRemove)
                        {
                            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                        }
                    });
                }
            }
            else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalDocumentMessage class]])
            {
                TGPreparedLocalDocumentMessage *localDocumentMessage = (TGPreparedLocalDocumentMessage *)self.preparedMessage;
                
                NSMutableArray *dataFilePaths = [[NSMutableArray alloc] init];
                if (localDocumentMessage.localThumbnailDataPath != nil)
                    [dataFilePaths addObject:localDocumentMessage.localThumbnailDataPath];
                if ([localDocumentMessage localDocumentDirectory] != nil)
                    [dataFilePaths addObject:[localDocumentMessage localDocumentDirectory]];
                
                for (TGMediaAttachment *attachment in message.mediaAttachments)
                {
                    if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
                    {
                        TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                        
                        if (documentAttachment.thumbnailInfo != nil && localDocumentMessage.localThumbnailDataPath != nil)
                        {
                            NSString *thumbnailUri = [[documentAttachment thumbnailInfo] imageUrlForLargestSize:NULL];
                            if (thumbnailUri != nil)
                            {
                                [[TGRemoteImageView sharedCache] moveToCache:[self pathForLocalImagePath:localDocumentMessage.localThumbnailDataPath] cacheUrl:thumbnailUri];
                                [dataFilePaths removeObject:localDocumentMessage.localThumbnailDataPath];
                            }
                        }
                        
                        NSString *updatedDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:documentAttachment.documentId];
                        [[NSFileManager defaultManager] moveItemAtPath:[localDocumentMessage localDocumentDirectory] toPath:updatedDocumentDirectory error:nil];
                        
                        [TGDatabaseInstance() updateLastUseDateForMediaType:3 mediaId:documentAttachment.documentId messageId:message.mid];
                    }
                }
                
                if (dataFilePaths.count != 0)
                {
                    NSMutableArray *absolutePathsToRemove = [[NSMutableArray alloc] init];
                    for (NSString *path in dataFilePaths)
                    {
                        [absolutePathsToRemove addObject:[self pathForLocalImagePath:path]];
                    }
                    
                    dispatch_async([TGCache diskCacheQueue], ^
                    {
                        for (NSString *path in absolutePathsToRemove)
                        {
                            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                        }
                    });
                }
            }
            else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalAudioMessage class]])
            {
                TGPreparedLocalAudioMessage *localAudioMessage = (TGPreparedLocalAudioMessage *)self.preparedMessage;
                
                NSMutableArray *dataFilePaths = [[NSMutableArray alloc] init];
                if ([localAudioMessage localAudioFileDirectory] != nil)
                    [dataFilePaths addObject:[localAudioMessage localAudioFileDirectory]];
                
                for (TGMediaAttachment *attachment in message.mediaAttachments)
                {
                    if ([attachment isKindOfClass:[TGAudioMediaAttachment class]])
                    {
                        TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
                        
                        [[NSFileManager defaultManager] moveItemAtPath:[localAudioMessage localAudioFileDirectory] toPath:[TGPreparedLocalAudioMessage localAudioFileDirectoryForRemoteAudioId:audioAttachment.audioId] error:nil];
                        
                        [TGDatabaseInstance() updateLastUseDateForMediaType:4 mediaId:audioAttachment.audioId messageId:message.mid];
                    }
                }
                
                if (dataFilePaths.count != 0)
                {
                    NSMutableArray *absolutePathsToRemove = [[NSMutableArray alloc] init];
                    for (NSString *path in dataFilePaths)
                    {
                        [absolutePathsToRemove addObject:[self pathForLocalImagePath:path]];
                    }
                    
                    dispatch_async([TGCache diskCacheQueue], ^
                    {
                        for (NSString *path in absolutePathsToRemove)
                        {
                            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                        }
                    });
                }
            }
            else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadImageMessage class]])
            {
                TGPreparedDownloadImageMessage *downloadImageMessage = (TGPreparedDownloadImageMessage *)self.preparedMessage;
                
                for (TGMediaAttachment *attachment in message.mediaAttachments)
                {
                    if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
                    {
                        TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
                        
                        NSString *localImageUrl = [downloadImageMessage.imageInfo imageUrlForLargestSize:NULL];
                        
                        NSString *localImageDirectory = [[self filePathForLocalImageUrl:localImageUrl] stringByDeletingLastPathComponent];
                        NSString *updatedImageDirectory = [[self filePathForRemoteImageId:imageAttachment.imageId] stringByDeletingLastPathComponent];
                        [[NSFileManager defaultManager] moveItemAtPath:localImageDirectory toPath:updatedImageDirectory error:nil];
                        
                        [TGModernSendCommonMessageActor setRemoteImageForRemoteUrl:localImageUrl image:imageAttachment];
                        
                        [TGDatabaseInstance() updateLastUseDateForMediaType:2 mediaId:imageAttachment.imageId messageId:message.mid];
                        
                        break;
                    }
                }
            }
            else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadDocumentMessage class]])
            {
                TGPreparedDownloadDocumentMessage *downloadDocumentMessage = (TGPreparedDownloadDocumentMessage *)self.preparedMessage;
                
                for (TGMediaAttachment *attachment in message.mediaAttachments)
                {
                    if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
                    {
                        TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                        
                        NSString *updatedDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:documentAttachment.documentId];
                        
                        NSString *localDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:downloadDocumentMessage.localDocumentId];
                        [[NSFileManager defaultManager] moveItemAtPath:localDirectory toPath:updatedDocumentDirectory error:nil];
                        
                        [TGModernSendCommonMessageActor setRemoteDocumentForGiphyId:downloadDocumentMessage.giphyId document:documentAttachment];
                        
                        [TGDatabaseInstance() updateLastUseDateForMediaType:3 mediaId:documentAttachment.documentId messageId:message.mid];
                    }
                }
            }
            
            std::vector<TGDatabaseMessageFlagValue> flags;
            flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDeliveryState, .value = TGMessageDeliveryStateDelivered});
            flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagMid, .value = statedMessage.message.n_id});
            if (date != 0)
                flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDate, .value = date});
            [TGDatabaseInstance() updateMessage:self.preparedMessage.mid flags:flags media:message.mediaAttachments dispatch:true];
            
            if (self.preparedMessage.randomId != 0)
                [TGDatabaseInstance() removeTempIds:@[@(self.preparedMessage.randomId)]];
        
            [[TGTelegramNetworking instance] updatePts:statedMessage.pts date:0 seq:statedMessage.seq];
            
            int64_t conversationId = _conversationId;
            id resource = [[SGraphObjectNode alloc] initWithObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:self.preparedMessage.mid], message, nil]];
            
            [self _success:@{
                @"previousMid": @(self.preparedMessage.mid),
                @"mid": @(statedMessage.message.n_id),
                @"date": @(date),
                @"message": message
            }];
            
            [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesChanged", conversationId] resource:resource];
        }
    }
    else
        [self _fail];
}

- (void)conversationSendMessageQuickAck
{
    if (_shouldPostAlmostDeliveredMessage)
    {
        std::vector<TGDatabaseMessageFlagValue> flags;
        flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDeliveryState, .value = TGMessageDeliveryStateDelivered});
        [TGDatabaseInstance() updateMessage:self.preparedMessage.mid flags:flags media:nil dispatch:true];
        
        [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"messageAlmostDelivered" message:@{
            @"previousMid": @(self.preparedMessage.mid)
        }];
    }
}

- (void)conversationSendMessageRequestFailed
{
    [self _fail];
}

@end
