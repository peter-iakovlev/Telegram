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
#import "TGPreparedLocalAudioMessage.h"

#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"
#import "TGDatabase.h"

#import "TGRemoteImageView.h"
#import "TGImageDownloadActor.h"
#import "TGVideoDownloadActor.h"

#import "TGImageUtils.h"

#import "TGMessage+Telegraph.h"

@interface TGModernSendCommonMessageActor ()
{
    int64_t _conversationId;
    
    bool _shouldPostAlmostDeliveredMessage;
}

@end

@implementation TGModernSendCommonMessageActor

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
        else
            [self _fail];
    }
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
