#import "TGModernSendCommonMessageActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGPeerIdAdapter.h"

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
#import "TGPreparedCloudDocumentMessage.h"

#import "TGLinkPreviewsContentProperty.h"

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

#import "TLMessage$modernMessage.h"
#import "TLMessage$modernMessageService.h"
#import "TLUpdates$updateShortSentMessage.h"

#import "TLUpdates+TG.h"

#import <WebP/decode.h>

#import "TGAppDelegate.h"

#import "TGChannelManagementSignals.h"

@interface TGModernSendCommonMessageActor ()
{
    int64_t _conversationId;
    int64_t _accessHash;
    bool _postAsChannel;
    
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
        NSString *documentsPath = [TGAppDelegate documentsPath];
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
    _accessHash = [options[@"accessHash"] longLongValue];
    _postAsChannel = [options[@"asChannel"] boolValue];
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
                [TGDatabaseInstance() setTempIdForMessageId:textMessage.mid peerId:_conversationId tempId:textMessage.randomId];
            
            _shouldPostAlmostDeliveredMessage = true;
            
            [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
            self.cancelToken = [TGTelegraphInstance doConversationSendMessage:_conversationId accessHash:_accessHash messageText:textMessage.text messageGuid:nil tmpId:textMessage.randomId replyMessageId:textMessage.replyMessage.mid disableLinkPreviews:textMessage.disableLinkPreviews postAsChannel:_postAsChannel actor:self];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedMapMessage class]])
        {
            TGPreparedMapMessage *mapMessage = (TGPreparedMapMessage *)self.preparedMessage;

            [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
            self.cancelToken = [TGTelegraphInstance doConversationSendLocation:_conversationId accessHash:_accessHash latitude:mapMessage.latitude longitude:mapMessage.longitude venue:mapMessage.venue messageGuid:nil tmpId:mapMessage.randomId replyMessageId:mapMessage.replyMessage.mid postAsChannel:_postAsChannel actor:self];
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
            remotePhoto.caption = remoteImageMessage.caption;
            
            [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:remotePhoto messageGuid:nil tmpId:remoteImageMessage.randomId replyMessageId:remoteImageMessage.replyMessage.mid postAsChannel:_postAsChannel actor:self];
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
            remoteVideo.caption = remoteVideoMessage.caption;
            
            [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:remoteVideo messageGuid:nil tmpId:remoteVideoMessage.randomId replyMessageId:remoteVideoMessage.replyMessage.mid postAsChannel:_postAsChannel actor:self];
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
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:remoteDocument messageGuid:nil tmpId:remoteDocumentMessage.randomId replyMessageId:remoteDocumentMessage.replyMessage.mid postAsChannel:_postAsChannel actor:self];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedForwardedMessage class]])
        {
            TGPreparedForwardedMessage *forwardedMessage = (TGPreparedForwardedMessage *)self.preparedMessage;
            
            int64_t fromPeerAccessHash = 0;
            if (TGPeerIdIsChannel(forwardedMessage.forwardPeerId)) {
                fromPeerAccessHash = ((TGConversation *)[TGDatabaseInstance() loadChannels:@[@(forwardedMessage.forwardPeerId)]][@(forwardedMessage.forwardPeerId)]).accessHash;
            }
            
            [self setupFailTimeout:[TGModernSendCommonMessageActor defaultTimeoutInterval]];
            self.cancelToken = [TGTelegraphInstance doConversationForwardMessage:_conversationId accessHash:_accessHash messageId:forwardedMessage.forwardMid fromPeer:forwardedMessage.forwardPeerId fromPeerAccessHash:fromPeerAccessHash postAsChannel:_postAsChannel tmpId:forwardedMessage.randomId actor:self];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedContactMessage class]])
        {
            TGPreparedContactMessage *contactMessage = (TGPreparedContactMessage *)self.preparedMessage;
            
            [self setupFailTimeout:[TGModernSendCommonMessageActor defaultTimeoutInterval]];
            
            TLInputMedia$inputMediaContact *inputContact = [[TLInputMedia$inputMediaContact alloc] init];
            inputContact.first_name = contactMessage.firstName;
            inputContact.last_name = contactMessage.lastName;
            inputContact.phone_number = contactMessage.phoneNumber;
            
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:inputContact messageGuid:nil tmpId:contactMessage.randomId replyMessageId:contactMessage.replyMessage.mid postAsChannel:_postAsChannel actor:self];
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
            
            NSString *documentPath = [self filePathForLocalDocumentId:downloadDocumentMessage.localDocumentId attributes:downloadDocumentMessage.attributes];
            NSData *documentData = [[NSData alloc] initWithContentsOfFile:documentPath];
            if (documentData == nil)
            {
                NSString *documentUrl = downloadDocumentMessage.documentUrl;
                if ([documentUrl isKindOfClass:[NSURL class]])
                    documentUrl = [(NSURL *)documentUrl path];
                
                documentData = [[[TGMediaStoreContext instance] temporaryFilesCache] getValueForKey:[documentUrl dataUsingEncoding:NSUTF8StringEncoding]];
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
                
                NSString *path = [[NSString alloc] initWithFormat:@"/temporaryDownload/(%@)", [TGStringUtils stringByEscapingForActorURL:downloadDocumentMessage.documentUrl]];
                [ActionStageInstance() requestActor:path options:@{@"url": downloadDocumentMessage.documentUrl, @"size": @(downloadDocumentMessage.size), @"path": documentPath, @"queue": @"messagePreDownloads"} flags:0 watcher:self];
                
                [self beginUploadProgress];
            }
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedCloudDocumentMessage class]])
        {
            TGPreparedCloudDocumentMessage *cloudDocumentMessage = (TGPreparedCloudDocumentMessage *)self.preparedMessage;
            
            bool dispatchThumbnail = false;
            
            NSString *documentPath = [self filePathForLocalDocumentId:cloudDocumentMessage.localDocumentId attributes:cloudDocumentMessage.attributes];
            NSData *documentData = [[NSData alloc] initWithContentsOfFile:documentPath];
            if (documentData == nil)
            {
                NSString *documentUrl = [cloudDocumentMessage.documentUrl path];
                if ([documentUrl isKindOfClass:[NSURL class]])
                    documentUrl = [(NSURL *)documentUrl path];
                
                documentData = [[[TGMediaStoreContext instance] temporaryFilesCache] getValueForKey:[documentUrl dataUsingEncoding:NSUTF8StringEncoding]];
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
            else if (cloudDocumentMessage.documentUrl != nil)
            {
                [self setupFailTimeout:[TGModernSendCommonMessageActor defaultTimeoutInterval]];
                self.uploadProgressContainsPreDownloads = true;
                
                NSString *path = [[NSString alloc] initWithFormat:@"/iCloudDownload/(%@)", [TGStringUtils stringByEscapingForActorURL:cloudDocumentMessage.documentUrl.absoluteString]];
                [ActionStageInstance() requestActor:path options:@{@"url": cloudDocumentMessage.documentUrl, @"path": documentPath, @"queue": @"messagePreDownloads"} flags:0 watcher:self];
                
                [self beginUploadProgress];
            }
            else
                [self _fail];
        }
        else
            [self _fail];
    }
}

- (NSString *)filePathForLocalDocumentId:(int64_t)localDocumentId attributes:(NSArray *)attributes
{
    NSString *directory = nil;
    directory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:localDocumentId];
    
    NSString *fileName = @"file";
    for (id attribute in attributes)
    {
        if ([attribute isKindOfClass:[TGDocumentAttributeFilename class]])
        {
            fileName = ((TGDocumentAttributeFilename *)attribute).filename;
            break;
        }
    }
    
    NSString *filePath = [directory stringByAppendingPathComponent:[TGDocumentMediaAttachment safeFileNameForFileName:fileName]];
    return filePath;
}

- (NSString *)filePathForLocalImageUrl:(NSString *)localImageUrl
{
    static NSString *filesDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        filesDirectory = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"files"];
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
        filesDirectory = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"files"];
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
    [TGDatabaseInstance() updateMessage:self.preparedMessage.mid peerId:_conversationId flags:flags media:nil dispatch:true];
    
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
        
        TGDocumentAttributeFilename *fileNameAttribute;
        NSArray *attributes = downloadDocumentMessage.attributes;
        bool hasImageSizeAttribute = false;
        bool hasStickerAttribute = false;
        for (id attribute in attributes)
        {
            if ([attribute isKindOfClass:[TGDocumentAttributeFilename class]])
                fileNameAttribute = (TGDocumentAttributeFilename *)attribute;
            if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]])
                hasImageSizeAttribute = true;
            if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                hasStickerAttribute = true;
        }
        
        NSString *fileExtension = @"gif";
        if (fileNameAttribute != nil)
            fileExtension = [fileNameAttribute.filename pathExtension];
        
        if (fileExtension == nil)
            fileExtension = @"";
        
        if (data == nil)
        {
            [self _fail];
            return;
        }

        NSMutableArray *files = [[NSMutableArray alloc] init];
        [files addObject:@[data, fileExtension, @(true)]];
        
        if ([fileExtension isEqualToString:@"webp"])
        {
            CGSize imageSize = CGSizeZero;
            int width = 0, height = 0;
            if(WebPGetInfo((uint8_t const *)data.bytes, data.length, &width, &height))
                imageSize = CGSizeMake(width, height);
            
            NSMutableArray *documentAttributes = [downloadDocumentMessage.attributes mutableCopy];
            if (!hasImageSizeAttribute)
            {
                if (imageSize.width > FLT_EPSILON && imageSize.height > FLT_EPSILON)
                    [documentAttributes addObject:[[TGDocumentAttributeImageSize alloc] initWithSize:imageSize]];
            }
            if (!hasStickerAttribute)
                [documentAttributes addObject:[[TGDocumentAttributeSticker alloc] init]];
            
            downloadDocumentMessage.attributes = documentAttributes;
        }
        
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
    else if ([self.preparedMessage isKindOfClass:[TGPreparedCloudDocumentMessage class]])
    {
        TGPreparedCloudDocumentMessage *cloudDocumentMessage = (TGPreparedCloudDocumentMessage *)self.preparedMessage;
        if (dispatchThumbnail)
        {
            NSString *thumbnailUrl = [cloudDocumentMessage.thumbnailInfo imageUrlForLargestSize:NULL];
            if (thumbnailUrl != nil)
            {
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/as/media/imageThumbnailUpdated"] resource:thumbnailUrl];
            }
        }
        
        TGDocumentAttributeFilename *fileNameAttribute;
        NSArray *attributes = cloudDocumentMessage.attributes;
        bool hasImageSizeAttribute = false;
        bool hasStickerAttribute = false;
        for (id attribute in attributes)
        {
            if ([attribute isKindOfClass:[TGDocumentAttributeFilename class]])
                fileNameAttribute = (TGDocumentAttributeFilename *)attribute;
            if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]])
                hasImageSizeAttribute = true;
            if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                hasStickerAttribute = true;
        }
        
        NSString *fileExtension = @"gif";
        if (fileNameAttribute != nil)
            fileExtension = [fileNameAttribute.filename pathExtension];
        
        if (fileExtension == nil)
            fileExtension = @"";
        
        if (data == nil)
        {
            [self _fail];
            return;
        }
        
        if ([fileExtension isEqualToString:@"webp"])
        {
            CGSize imageSize = CGSizeZero;
            int width = 0, height = 0;
            if(WebPGetInfo((uint8_t const *)data.bytes, data.length, &width, &height))
                imageSize = CGSizeMake(width, height);
            
            NSMutableArray *documentAttributes = [cloudDocumentMessage.attributes mutableCopy];
            if (!hasImageSizeAttribute)
            {
                if (imageSize.width > FLT_EPSILON && imageSize.height > FLT_EPSILON)
                    [documentAttributes addObject:[[TGDocumentAttributeImageSize alloc] initWithSize:imageSize]];
            }
            if (!hasStickerAttribute)
                [documentAttributes addObject:[[TGDocumentAttributeSticker alloc] init]];
            
            cloudDocumentMessage.attributes = documentAttributes;
        }
        
        NSMutableArray *files = [[NSMutableArray alloc] init];
        [files addObject:@[data, fileExtension, @(true)]];
        
        UIImage *image = [[UIImage alloc] initWithData:data];
        if (image != nil)
        {
            NSData *thumbnailData = nil;
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
                NSString *documentPath = [self filePathForLocalDocumentId:downloadDocumentMessage.localDocumentId attributes:downloadDocumentMessage.attributes];
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
    else if ([path hasPrefix:@"/iCloudDownload/"])
    {
        if (status == ASStatusSuccess)
        {
            TGPreparedCloudDocumentMessage *cloudDocumentMessage = (TGPreparedCloudDocumentMessage *)self.preparedMessage;
            NSString *documentPath = [self filePathForLocalDocumentId:cloudDocumentMessage.localDocumentId attributes:cloudDocumentMessage.attributes];
            NSError *error;
            NSData *documentData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:documentPath]
                                                         options:NSDataReadingMappedIfSafe
                                                           error:&error];
            
            [self _uploadDownloadedData:documentData dispatchThumbnail:true];
        }
        else
            [self _fail];
    }
    
    [super actorCompleted:status path:path result:result];
}

- (void)actorMessageReceived:(NSString *)path messageType:(NSString *)messageType message:(id)message
{
    if ([path hasPrefix:@"/temporaryDownload/"] || [path hasPrefix:@"/iCloudDownload/"])
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

- (NSArray *)attributesForNativeAttributes:(NSArray *)nativeAttributes
{
    NSMutableArray *attributes = [[NSMutableArray alloc] init];
    for (id attribute in nativeAttributes)
    {
        if ([attribute isKindOfClass:[TGDocumentAttributeFilename class]])
        {
            TLDocumentAttribute$documentAttributeFilename *concreteAttribute = [[TLDocumentAttribute$documentAttributeFilename alloc] init];
            concreteAttribute.file_name = ((TGDocumentAttributeFilename *)attribute).filename;
            [attributes addObject:concreteAttribute];
        }
        else if ([attribute isKindOfClass:[TGDocumentAttributeAnimated class]])
        {
            [attributes addObject:[[TLDocumentAttribute$documentAttributeAnimated alloc] init]];
        }
        else if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]])
        {
            TLDocumentAttribute$documentAttributeImageSize *concreteAttribute = [[TLDocumentAttribute$documentAttributeImageSize alloc] init];
            concreteAttribute.w = (int32_t)((TGDocumentAttributeImageSize *)attribute).size.width;
            concreteAttribute.h = (int32_t)((TGDocumentAttributeImageSize *)attribute).size.height;
            [attributes addObject:concreteAttribute];
        }
        else if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
        {
            [attributes addObject:[[TLDocumentAttribute$documentAttributeSticker alloc] init]];
        }
    }
    return attributes;
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
            uploadedPhoto.caption = localImageMessage.caption;
            
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:uploadedPhoto messageGuid:nil tmpId:localImageMessage.randomId replyMessageId:localImageMessage.replyMessage.mid postAsChannel:_postAsChannel actor:self];
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
            uploadedVideo.caption = localVideoMessage.caption;
            
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:uploadedVideo messageGuid:nil tmpId:localVideoMessage.randomId replyMessageId:localVideoMessage.replyMessage.mid postAsChannel:_postAsChannel actor:self];
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
                thumbUploadedDocument.attributes = [self attributesForNativeAttributes:localDocumentMessage.attributes];
                thumbUploadedDocument.mime_type = localDocumentMessage.mimeType.length == 0 ? @"application/octet-stream" : localDocumentMessage.mimeType;
                thumbUploadedDocument.thumb = thumbnailFileInfo[@"file"];
                
                uploadedDocument = thumbUploadedDocument;
            }
            else
            {
                TLInputMedia$inputMediaUploadedDocument *plainUploadedDocument = [[TLInputMedia$inputMediaUploadedDocument alloc] init];
                plainUploadedDocument.file = documentFileInfo[@"file"];
                plainUploadedDocument.attributes = [self attributesForNativeAttributes:localDocumentMessage.attributes];
                plainUploadedDocument.mime_type = localDocumentMessage.mimeType.length == 0 ? @"application/octet-stream" : localDocumentMessage.mimeType;
                
                uploadedDocument = plainUploadedDocument;
            }
            
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:uploadedDocument messageGuid:nil tmpId:localDocumentMessage.randomId replyMessageId:localDocumentMessage.replyMessage.mid postAsChannel:_postAsChannel actor:self];
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
            
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:uploadedAudio messageGuid:nil tmpId:localAudioMessage.randomId replyMessageId:localAudioMessage.replyMessage.mid postAsChannel:_postAsChannel actor:self];
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
            uploadedPhoto.caption = downloadImageMessage.caption;
            
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:uploadedPhoto messageGuid:nil tmpId:downloadImageMessage.randomId replyMessageId:downloadImageMessage.replyMessage.mid postAsChannel:_postAsChannel actor:self];
        }
        else
            [self _fail];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadDocumentMessage class]] || [self.preparedMessage isKindOfClass:[TGPreparedCloudDocumentMessage class]])
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
                thumbUploadedDocument.attributes = [self attributesForNativeAttributes:downloadDocumentMessage.attributes];
                thumbUploadedDocument.mime_type = downloadDocumentMessage.mimeType.length == 0 ? @"application/octet-stream" : downloadDocumentMessage.mimeType;
                thumbUploadedDocument.thumb = thumbnailFileInfo[@"file"];
                
                uploadedDocument = thumbUploadedDocument;
            }
            else
            {
                TLInputMedia$inputMediaUploadedDocument *plainUploadedDocument = [[TLInputMedia$inputMediaUploadedDocument alloc] init];
                plainUploadedDocument.file = documentFileInfo[@"file"];
                plainUploadedDocument.attributes = [self attributesForNativeAttributes:downloadDocumentMessage.attributes];
                plainUploadedDocument.mime_type = downloadDocumentMessage.mimeType.length == 0 ? @"application/octet-stream" : downloadDocumentMessage.mimeType;
                
                uploadedDocument = plainUploadedDocument;
            }
            
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:uploadedDocument messageGuid:nil tmpId:downloadDocumentMessage.randomId replyMessageId:downloadDocumentMessage.replyMessage.mid postAsChannel:_postAsChannel actor:self];
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
    if ([result isKindOfClass:[TLUpdates$updateShortSentMessage class]])
    {
        TLUpdates$updateShortSentMessage *sentMessage = result;
        
        std::vector<TGDatabaseMessageFlagValue> flags;
        flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDeliveryState, .value = TGMessageDeliveryStateDelivered});
        flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagMid, .value = sentMessage.n_id});
        flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDate, .value = sentMessage.date});
        flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagPts, .value = sentMessage.pts});
        
        bool unread = true;
        if (_conversationId > 0)
        {
            TGUser *user = [TGDatabaseInstance() loadUser:(int)_conversationId];
            if (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot)
            {
                flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagUnread, .value = 0});
                unread = false;
            }
        }
        
        TGMessage *updatedMessage = nil;
        if ([sentMessage.media isKindOfClass:[TLMessageMedia$messageMediaWebPage class]])
        {
            updatedMessage = [[TGDatabaseInstance() loadMessageWithMid:self.preparedMessage.mid peerId:_conversationId] copy];
            if (updatedMessage != nil)
            {
                NSMutableArray *attachments = [[NSMutableArray alloc] initWithArray:updatedMessage.mediaAttachments];
                for (id attachment in attachments)
                {
                    if ([attachment isKindOfClass:[TGWebPageMediaAttachment class]])
                    {
                        [attachments removeObject:attachment];
                        break;
                    }
                }
                [attachments addObjectsFromArray:[TGMessage parseTelegraphMedia:sentMessage.media]];
                updatedMessage.mediaAttachments = attachments;
            }
        }
        
        NSMutableArray *entities = [[NSMutableArray alloc] init];
        for (id entity in sentMessage.entities)
        {
            if ([entity isKindOfClass:[TLMessageEntity$messageEntityUrl class]])
            {
                TLMessageEntity$messageEntityUrl *urlEntity = entity;
                [entities addObject:[[TGMessageEntityUrl alloc] initWithRange:NSMakeRange(urlEntity.offset, urlEntity.length)]];
            }
            else if ([entity isKindOfClass:[TLMessageEntity$messageEntityTextUrl class]])
            {
                TLMessageEntity$messageEntityTextUrl *urlEntity = entity;
                [entities addObject:[[TGMessageEntityTextUrl alloc] initWithRange:NSMakeRange(urlEntity.offset, urlEntity.length) url:urlEntity.url]];
            }
            else if ([entity isKindOfClass:[TLMessageEntity$messageEntityEmail class]])
            {
                TLMessageEntity$messageEntityEmail *emailEntity = entity;
                [entities addObject:[[TGMessageEntityEmail alloc] initWithRange:NSMakeRange(emailEntity.offset, emailEntity.length)]];
            }
        }
        if (entities.count != 0)
        {
            TGMessageEntitiesAttachment *entitiesAttachment = [[TGMessageEntitiesAttachment alloc] init];
            entitiesAttachment.entities = entities;
            
            NSMutableArray *attachments = [[NSMutableArray alloc] initWithArray:updatedMessage.mediaAttachments];
            for (id attachment in attachments)
            {
                if ([attachment isKindOfClass:[TGMessageEntitiesAttachment class]])
                {
                    [attachments removeObject:attachment];
                    break;
                }
            }
            [attachments addObject:entitiesAttachment];
            updatedMessage.mediaAttachments = attachments;
        }
        
        [TGDatabaseInstance() updateMessage:self.preparedMessage.mid peerId:_conversationId flags:flags media:updatedMessage.mediaAttachments dispatch:true];
        
        if (self.preparedMessage.randomId != 0)
            [TGDatabaseInstance() removeTempIds:@[@(self.preparedMessage.randomId)]];
        
        if (TGPeerIdIsChannel(_conversationId)) {
            [TGChannelManagementSignals updateChannelState:_conversationId pts:sentMessage.pts ptsCount:sentMessage.pts_count];
        } else {
            [[TGTelegramNetworking instance] updatePts:sentMessage.pts ptsCount:sentMessage.pts_count seq:0];
        }
        
        NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
        resultDict[@"previousMid"] = @(self.preparedMessage.mid);
        resultDict[@"mid"] = @(sentMessage.n_id);
        resultDict[@"date"] = @(sentMessage.date);
        if (updatedMessage != nil)
            resultDict[@"message"] = updatedMessage;
        resultDict[@"unread"] = @(unread);
        
        if (updatedMessage == nil)
        {
            updatedMessage = [[self.preparedMessage message] copy];
            updatedMessage.mid = sentMessage.n_id;
            updatedMessage.date = sentMessage.date;
            updatedMessage.outgoing = true;
            updatedMessage.fromUid = TGTelegraphInstance.clientUserId;
            updatedMessage.unread = unread;
        }
        
        int64_t conversationId = _conversationId;
        id resource = [[SGraphObjectNode alloc] initWithObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:self.preparedMessage.mid], updatedMessage, nil]];
        
        [self _success:resultDict];
        
        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesChanged", conversationId] resource:resource];
    }
    else if ([result isKindOfClass:[TLUpdates class]])
    {
        TLUpdates *updates = result;
        
        TLMessage *updateMessage = updates.messages.firstObject;
        
        int32_t date = 0;
        if ([updateMessage isKindOfClass:[TLMessage$modernMessage class]])
            date = ((TLMessage$message *)updateMessage).date;
        else if ([updateMessage isKindOfClass:[TLMessage$modernMessageService class]])
            date = ((TLMessage$modernMessageService *)updateMessage).date;
        
        bool waitForFileQueue = false;
        
        TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:updateMessage];
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
                            waitForFileQueue = true;
                        }
                        
                        NSString *thumbnailUrl = [imageAttachment.imageInfo closestImageUrlWithSize:localImageMessage.thumbnailSize resultingSize:NULL];
                        if (thumbnailUrl != nil && localImageMessage.localThumbnailDataPath != nil)
                        {
                            [[TGRemoteImageView sharedCache] moveToCache:[self pathForLocalImagePath:localImageMessage.localThumbnailDataPath] cacheUrl:thumbnailUrl];
                            [imageFilePaths removeObject:localImageMessage.localThumbnailDataPath];
                            [TGImageDownloadActor addUrlRewrite:localImageMessage.localThumbnailDataPath newUrl:thumbnailUrl];
                            waitForFileQueue = true;
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
                        
                        NSString *documentsDirectory = [TGAppDelegate documentsPath];
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
                        
                        [[NSFileManager defaultManager] removeItemAtPath:updatedDocumentDirectory error:nil];
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
                        
                        [[NSFileManager defaultManager] removeItemAtPath:updatedImageDirectory error:nil];
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
                        
                        [[NSFileManager defaultManager] removeItemAtPath:updatedDocumentDirectory error:nil];
                        [[NSFileManager defaultManager] moveItemAtPath:localDirectory toPath:updatedDocumentDirectory error:nil];
                        
                        if (downloadDocumentMessage.giphyId != nil)
                            [TGModernSendCommonMessageActor setRemoteDocumentForGiphyId:downloadDocumentMessage.giphyId document:documentAttachment];
                        
                        [TGDatabaseInstance() updateLastUseDateForMediaType:3 mediaId:documentAttachment.documentId messageId:message.mid];
                    }
                }
            }
            else if ([self.preparedMessage isKindOfClass:[TGPreparedCloudDocumentMessage class]])
            {
                TGPreparedCloudDocumentMessage *cloudDocumentMessage = (TGPreparedCloudDocumentMessage *)self.preparedMessage;
                
                for (TGMediaAttachment *attachment in message.mediaAttachments)
                {
                    if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
                    {
                        TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                        
                        NSString *updatedDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:documentAttachment.documentId];
                        
                        NSString *localDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:cloudDocumentMessage.localDocumentId];
                        
                        [[NSFileManager defaultManager] removeItemAtPath:updatedDocumentDirectory error:nil];
                        [[NSFileManager defaultManager] moveItemAtPath:localDirectory toPath:updatedDocumentDirectory error:nil];
                        
                        [TGDatabaseInstance() updateLastUseDateForMediaType:3 mediaId:documentAttachment.documentId messageId:message.mid];
                    }
                }
            }
            
            std::vector<TGDatabaseMessageFlagValue> flags;
            flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDeliveryState, .value = TGMessageDeliveryStateDelivered});
            int32_t maxPts = 0;
            [updates maxPtsAndCount:&maxPts ptsCount:NULL];
            flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagPts, .value = maxPts});
            bool unread = true;
            if (TGPeerIdIsChannel(_conversationId))
            {
                flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagUnread, .value = 0});
                unread = false;
            }
            else
            {
                if (_conversationId > 0)
                {
                    TGUser *user = [TGDatabaseInstance() loadUser:(int)_conversationId];
                    if (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot)
                    {
                        flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagUnread, .value = 0});
                        unread = false;
                    }
                }
            }
            flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagMid, .value = updateMessage.n_id});
            if (date != 0)
                flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDate, .value = date});
            [TGDatabaseInstance() updateMessage:self.preparedMessage.mid peerId:_conversationId flags:flags media:message.mediaAttachments dispatch:true];
            
            if (self.preparedMessage.randomId != 0)
                [TGDatabaseInstance() removeTempIds:@[@(self.preparedMessage.randomId)]];
            
            int64_t conversationId = _conversationId;
            id resource = [[SGraphObjectNode alloc] initWithObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:self.preparedMessage.mid], message, nil]];
            
            dispatch_block_t completion = ^{
                [self _success:@{
                    @"previousMid": @(self.preparedMessage.mid),
                    @"mid": @(updateMessage.n_id),
                    @"date": @(date),
                    @"message": message,
                    @"unread": @(unread)
                }];
                
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesChanged", conversationId] resource:resource];
                
                [[TGTelegramNetworking instance] addUpdates:updates];
            };
            
            if (waitForFileQueue)
                dispatch_async([TGCache diskCacheQueue], completion);
            else
                completion();
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
        [TGDatabaseInstance() updateMessage:self.preparedMessage.mid peerId:_conversationId flags:flags media:nil dispatch:true];
        
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
