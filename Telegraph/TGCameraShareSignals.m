#import "TGCameraShareSignals.h"

#import "TGImageUtils.h"
#import "TGCache.h"

#import "TLInputMediaUploadedPhoto.h"
#import "TLInputMediaUploadedDocument.h"

#import "TGAppDelegate.h"
#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"

#import "TGPeerIdAdapter.h"
#import "TGMessage.h"
#import "TGMessageViewedContentProperty.h"

#import "TGMediaVideoConverter.h"
#import "TGVideoEditAdjustments.h"
#import "TGMediaLiveUploadWatcher.h"

#import "TGUploadFileSignals.h"
#import "TGSendMessageSignals.h"

#import "TGImageDownloadActor.h"
#import "TGVideoDownloadActor.h"
#import "TGRemoteImageView.h"

#import "TGPreparedLocalImageMessage.h"
#import "TGPreparedAssetVideoMessage.h"
#import "TGPreparedLocalDocumentMessage.h"

@implementation TGCameraShareSignals

+ (NSArray *)_setupMessages:(TGPreparedMessage *)preparedMessage peerIds:(NSArray *)peerIds
{
    preparedMessage.date = (int)[[TGTelegramNetworking instance] approximateRemoteTime];
    
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    for (NSNumber *peerId in peerIds)
    {
        int64_t conversationId = peerId.int64Value;
        TGMessage *message = [preparedMessage message];
        message.mid = [[TGDatabaseInstance() generateLocalMids:1][0] intValue];
        message.outgoing = true;
        message.fromUid = TGTelegraphInstance.clientUserId;
        message.toUid = conversationId;
        message.deliveryState = TGMessageDeliveryStatePending;
        message.sortKey = TGMessageSortKeyMake(conversationId, TGMessageSpaceImportant, (int32_t)message.date, message.mid);
        message.cid = conversationId;
        
        if (message.randomId == 0)
        {
            int64_t randomId = 0;
            arc4random_buf(&randomId, sizeof(randomId));
            message.randomId = randomId;
        }
        
        //                if (_isGroup) {
        //                    message.sortKey = TGMessageSortKeyMake(conversationId, TGMessageSpaceUnimportant, (int32_t)message.date, message.mid);
        //                }
        //
        //                if (!_isGroup && (_adminRights.canPostMessages)/* && _postAsChannel*/) {
        //                    if (message.viewCount == nil) {
        //                        message.viewCount = [[TGMessageViewCountContentProperty alloc] initWithViewCount:1];
        //                    }
        //                }
        
        if (TGPeerIdIsChannel(conversationId)) {
            NSMutableDictionary *contentProperties = [[NSMutableDictionary alloc] initWithDictionary:message.contentProperties];
            contentProperties[@"contentsRead"] = [[TGMessageViewedContentProperty alloc] init];
            message.contentProperties = contentProperties;
        }
        
        [messages addObject:message];
    }
    
    [TGDatabaseInstance() transactionAddMessages:messages updateConversationDatas:nil notifyAdded:true];
    
    for (TGMessage *message in messages)
    {
        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messages", (long long)message.cid] resource:[[SGraphObjectNode alloc] initWithObject:@[message]]];
    }

    return messages;
}

+ (SSignal *)shareMedia:(NSDictionary *)description peerIds:(NSArray *)peerIds
{
    return [SSignal defer:^SSignal *
    {
        if ([description[@"type"] isEqualToString:@"image"])
        {
            UIImage *image = description[@"image"];
            CGSize originalSize = image.size;
            
            CGSize imageSize = TGFitSize(originalSize, CGSizeMake(1280, 1280));
            CGSize thumbnailSize = TGFitSize(originalSize, CGSizeMake(90, 90));
            
            UIImage *fullImage = MAX(image.size.width, image.size.height) > 1280.0f ? TGScaleImageToPixelSize(image, imageSize) : image;
            NSData *imageData = UIImageJPEGRepresentation(fullImage, 0.52f);
            
            CGSize preferredThumnailSize = CGSizeMake(180, 180);
            UIImage *previewImage = TGScaleImageToPixelSize(fullImage, TGFitSize(originalSize, preferredThumnailSize));
            NSData *thumbnailData = UIImageJPEGRepresentation(previewImage, 0.9f);

            TGPreparedLocalImageMessage *preparedMessage = [TGPreparedLocalImageMessage messageWithImageData:imageData imageSize:imageSize thumbnailData:thumbnailData thumbnailSize:thumbnailSize assetUrl:nil caption:description[@"caption"] replyMessage:nil replyMarkup:nil stickerDocuments:description[@"stickers"] messageLifetime:0];
            
            NSArray *messages = [self _setupMessages:preparedMessage peerIds:peerIds];
            
            return [[TGUploadFileSignals uploadedFileWithData:imageData mediaTypeTag:TGNetworkMediaTypeTagImage] mapToSignal:^SSignal *(TLInputFile *file) {
                TLInputMediaUploadedPhoto *uploadedPhoto = [[TLInputMediaUploadedPhoto alloc] init];
                uploadedPhoto.file = file;
                uploadedPhoto.caption = preparedMessage.caption;
                
                if (preparedMessage.stickerDocuments.count != 0) {
                    NSMutableArray *inputStickers = [[NSMutableArray alloc] init];
                    for (TGDocumentMediaAttachment *document in preparedMessage.stickerDocuments) {
                        if (document.documentId != 0) {
                            TLInputDocument$inputDocument *inputDocument = [[TLInputDocument$inputDocument alloc] init];
                            inputDocument.n_id = document.documentId;
                            inputDocument.access_hash = document.accessHash;
                            [inputStickers addObject:inputDocument];
                        }
                    }
                    
                    uploadedPhoto.stickers = inputStickers;
                    uploadedPhoto.flags |= (1 << 0);
                }

                SAtomic *initialAttachment = [[SAtomic alloc] init];
                SAtomic *firstMessageId = [[SAtomic alloc] init];
                
                SSignal *sendSignal = nil;
                for (TGMessage *message in messages)
                {
                    if (sendSignal == nil)
                    {
                        sendSignal = [[TGSendMessageSignals commitSendMediaWithMessage:message mediaProducer:^TLInputMedia *(__unused NSDictionary *uploadInfo) {
                            return uploadedPhoto;
                        }] onNext:^(TGMessage *sentMessage) {
                            [firstMessageId swap:@(sentMessage.mid)];
                            
                            for (TGMediaAttachment *attachment in sentMessage.mediaAttachments)
                            {
                                if (attachment.type == TGImageMediaAttachmentType)
                                {
                                    [initialAttachment swap:attachment];
                                    break;
                                }
                            }
                        }];
                    }
                    else
                    {
                        sendSignal = [sendSignal then:[TGSendMessageSignals commitSendMediaWithMessage:message mediaProducer:^TLInputMedia *(__unused NSDictionary *uploadInfo) {
                            TGImageMediaAttachment *attachment = [initialAttachment value];
                            
                            TLInputMedia$inputMediaPhoto *remotePhoto = [[TLInputMedia$inputMediaPhoto alloc] init];
                            TLInputPhoto$inputPhoto *inputPhoto = [[TLInputPhoto$inputPhoto alloc] init];
                            inputPhoto.n_id = attachment.imageId;
                            inputPhoto.access_hash = attachment.accessHash;
                            
                            remotePhoto.n_id = inputPhoto;
                            remotePhoto.caption = attachment.caption;
                            
                            return remotePhoto;
                        }]];
                    }
                }
                
                if (sendSignal == nil)
                    sendSignal = [SSignal complete];
                
                return [sendSignal then:[SSignal defer:^SSignal *
                {
                    TGImageMediaAttachment *imageAttachment = [initialAttachment value];
                    int32_t messageId = [[firstMessageId value] int32Value];
                    
                    NSMutableArray *imageFilePaths = [[NSMutableArray alloc] init];
                    if (preparedMessage.localImageDataPath != nil)
                        [imageFilePaths addObject:preparedMessage.localImageDataPath];
                    if (preparedMessage.localThumbnailDataPath != nil)
                        [imageFilePaths addObject:preparedMessage.localThumbnailDataPath];
                    
                    NSString *imageUrl = [imageAttachment.imageInfo closestImageUrlWithSize:preparedMessage.imageSize resultingSize:NULL];
                    if (imageUrl != nil && preparedMessage.localImageDataPath != nil)
                    {
                        [[TGRemoteImageView sharedCache] moveToCache:[self pathForLocalImagePath:preparedMessage.localImageDataPath] cacheUrl:imageUrl];
                        [imageFilePaths removeObject:preparedMessage.localImageDataPath];
                        [TGImageDownloadActor addUrlRewrite:preparedMessage.localImageDataPath newUrl:imageUrl];
                    }
                    
                    NSString *thumbnailUrl = [imageAttachment.imageInfo closestImageUrlWithSize:preparedMessage.thumbnailSize resultingSize:NULL];
                    if (thumbnailUrl != nil && preparedMessage.localThumbnailDataPath != nil)
                    {
                        [[TGRemoteImageView sharedCache] moveToCache:[self pathForLocalImagePath:preparedMessage.localThumbnailDataPath] cacheUrl:thumbnailUrl];
                        [imageFilePaths removeObject:preparedMessage.localThumbnailDataPath];
                        [TGImageDownloadActor addUrlRewrite:preparedMessage.localThumbnailDataPath newUrl:thumbnailUrl];
                    }
                    
                    [TGDatabaseInstance() updateLastUseDateForMediaType:2 mediaId:imageAttachment.imageId messageId:messageId];
                    
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
                    
                    return [SSignal complete];
                }]];
            }];
        }
        else if ([description[@"type"] isEqualToString:@"cameraVideo"])
        {
            UIImage *previewImage = description[@"previewImage"];
            NSData *thumbnailData = UIImageJPEGRepresentation(previewImage, 0.54f);
            NSTimeInterval duration = [description[@"duration"] doubleValue];
            CGSize dimensions = [description[@"dimensions"] CGSizeValue];
            TGMediaVideoEditAdjustments *adjustments = description[@"adjustments"];
            
            NSTimeInterval finalDuration = duration;
            CGSize finalDimensions = dimensions;
            if (!CGSizeEqualToSize(dimensions, CGSizeZero))
                finalDimensions = TGFitSize(dimensions, CGSizeMake(640, 640));
            else
                finalDimensions = TGFitSize(previewImage.size, CGSizeMake(640, 640));
            
            if (adjustments != nil)
            {
                if (adjustments.trimApplied)
                    finalDuration = adjustments.trimEndValue - adjustments.trimStartValue;
                if ([adjustments cropAppliedForAvatar:false])
                {
                    CGSize size = adjustments.cropRect.size;
                    if (adjustments.cropOrientation != UIImageOrientationUp && adjustments.cropOrientation != UIImageOrientationDown)
                        size = CGSizeMake(size.height, size.width);
                    dimensions = TGFitSize(size, CGSizeMake(640, 640));
                }
            }
            
            bool isAnimation = adjustments.sendAsGif;

            NSMutableArray *attributes = [[NSMutableArray alloc] init];
            NSString *mimeType = @"video/mp4";
            if (isAnimation)
            {
                [attributes addObject:[[TGDocumentAttributeFilename alloc] initWithFilename:@"animation.mp4"]];
                [attributes addObject:[[TGDocumentAttributeAnimated alloc] init]];
            }
            
            [attributes addObject:[[TGDocumentAttributeVideo alloc] initWithRoundMessage:false size:finalDimensions duration:(int32_t)duration]];
            
            int64_t localId = 0;
            arc4random_buf(&localId, 8);
            int64_t localVideoId = isAnimation ? 0 : localId;
            int64_t localDocumentId = isAnimation ? localId : 0;
            
            TGPreparedAssetVideoMessage *preparedMessage = [[TGPreparedAssetVideoMessage alloc] initWithAssetIdentifier:nil assetURL:description[@"url"] localVideoId:localVideoId imageInfo:nil duration:duration dimensions:finalDimensions adjustments:[adjustments dictionary] useMediaCache:false liveUpload:true passthrough:false caption:description[@"caption"] isCloud:false document:isAnimation localDocumentId:localDocumentId fileSize:INT_MAX mimeType:mimeType attributes:attributes replyMessage:nil replyMarkup:nil stickerDocuments:description[@"stickers"] roundMessage:false];
            
            [preparedMessage setImageInfoWithThumbnailData:thumbnailData thumbnailSize:finalDimensions];
            
            NSArray *messages = [self _setupMessages:preparedMessage peerIds:peerIds];
            
            AVURLAsset *avAsset = [[AVURLAsset alloc] initWithURL:preparedMessage.assetURL options:nil];
            return [[TGMediaVideoConverter convertAVAsset:avAsset adjustments:adjustments watcher:[[TGMediaLiveUploadWatcher alloc] init]] mapToSignal:^SSignal *(id value) {
                if ([value isKindOfClass:[TGMediaVideoConversionResult class]])
                {
                    TGMediaVideoConversionResult *result = (TGMediaVideoConversionResult *)value;
                    
                    preparedMessage.fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:[result.fileURL path] error:NULL][NSFileSize] intValue];
                    
                    NSData *thumbnailDataToUpload = nil;
                    
                    if (preparedMessage.isAnimation)
                    {
                        NSString *fileExtension = [preparedMessage.fileName pathExtension];
                        if (fileExtension == nil)
                            fileExtension = @"";
                        
                        NSArray *attributes = preparedMessage.attributes;
                        
                        NSString *documentPath = [self filePathForLocalDocumentId:preparedMessage.localDocumentId attributes:attributes];
                        [[NSFileManager defaultManager] createDirectoryAtPath:[documentPath stringByDeletingLastPathComponent] withIntermediateDirectories:true attributes:nil error:nil];
                        [[NSFileManager defaultManager] moveItemAtPath:[result.fileURL path] toPath:documentPath error:nil];
                        
                        NSMutableArray *files = [[NSMutableArray alloc] init];
                        [files addObject:@[documentPath, fileExtension, @(true)]];
                        
                        UIImage *thumbnailImage = result.coverImage;
                        if (thumbnailImage == nil)
                        {
                            thumbnailImage = [[UIImage alloc] initWithContentsOfFile:[self pathForLocalImagePath:preparedMessage.localThumbnailDataPath]];
                        }
                        CGSize thumbnailSize = TGFitSize(thumbnailImage.size, CGSizeMake(90, 90));
                        thumbnailDataToUpload = UIImageJPEGRepresentation(TGScaleImageToPixelSize(thumbnailImage, thumbnailSize), 0.6f);
                        
                        NSString *thumbnailUrl = [preparedMessage.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
                        if (thumbnailUrl != nil)
                            [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/as/media/imageThumbnailUpdated"] resource:thumbnailUrl];
                    }
                    else
                    {
                        if (![[result.fileURL path] isEqualToString:preparedMessage.localVideoPath])
                        {
                            [[NSFileManager defaultManager] removeItemAtPath:[preparedMessage localVideoPath] error:nil];
                            [[NSFileManager defaultManager] moveItemAtPath:[result.fileURL path] toPath:[preparedMessage localVideoPath] error:nil];
                            [[NSFileManager defaultManager] createSymbolicLinkAtPath:[result.fileURL path] withDestinationPath:[preparedMessage localVideoPath] error:nil];
                        }
                        NSString *thumbnailUrl = [preparedMessage.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
                        if (thumbnailUrl != nil)
                            [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/as/media/imageThumbnailUpdated"] resource:thumbnailUrl];
                        
                        UIImage *thumbnailImage = result.coverImage;
                        if (thumbnailImage == nil)
                        {
                            thumbnailImage = [[UIImage alloc] initWithContentsOfFile:[self pathForLocalImagePath:preparedMessage.localThumbnailDataPath]];
                        }
                        CGSize thumbnailSize = TGFitSize(thumbnailImage.size, CGSizeMake(90, 90));
                        thumbnailDataToUpload = UIImageJPEGRepresentation(TGScaleImageToPixelSize(thumbnailImage, thumbnailSize), 0.6f);
                    }
                    
                    SSignal *uploadVideoSignal = [TGUploadFileSignals uploadedFileWithPath:[preparedMessage localVideoPath] liveData:result.liveUploadData mediaTypeTag:TGNetworkMediaTypeTagVideo];
                    SSignal *uploadThumbnailSignal = [TGUploadFileSignals uploadedFileWithData:thumbnailDataToUpload mediaTypeTag:TGNetworkMediaTypeTagImage];
                    
                    return [[[SSignal combineSignals:@[uploadVideoSignal, uploadThumbnailSignal] withInitialStates:@[ [NSNull null], [NSNull null]]] filter:^bool(NSArray *values) {
                        return ![[values firstObject] isKindOfClass:[NSNull class]] && ![[values lastObject] isKindOfClass:[NSNull class]];
                    }] mapToSignal:^SSignal *(NSArray *values) {
                        TLInputFile *videoFile = values.firstObject;
                        TLInputFile *thumbnailFile = values.lastObject;
                        
                        TLInputMediaUploadedDocument *uploadedDocument = [[TLInputMediaUploadedDocument alloc] init];
                        uploadedDocument.file = videoFile;
                        uploadedDocument.thumb = thumbnailFile;
                        uploadedDocument.flags |= (1 << 2);
                        
                        TLDocumentAttribute$documentAttributeVideo *video = [[TLDocumentAttribute$documentAttributeVideo alloc] init];
                        video.duration = (int32_t)preparedMessage.duration;
                        video.w = (int32_t)preparedMessage.dimensions.width;
                        video.h = (int32_t)preparedMessage.dimensions.height;
                        
                        TLDocumentAttribute$documentAttributeFilename *filename = [[TLDocumentAttribute$documentAttributeFilename alloc] init];
                        filename.file_name = @"video.mp4";
                        
                        uploadedDocument.attributes = @[video, filename];
                        
                        uploadedDocument.caption = preparedMessage.caption;
                        
                        uploadedDocument.mime_type = @"video/mp4";
                        
                        if (preparedMessage.stickerDocuments.count != 0) {
                            NSMutableArray *inputStickers = [[NSMutableArray alloc] init];
                            for (TGDocumentMediaAttachment *document in preparedMessage.stickerDocuments) {
                                if (document.documentId != 0) {
                                    TLInputDocument$inputDocument *inputDocument = [[TLInputDocument$inputDocument alloc] init];
                                    inputDocument.n_id = document.documentId;
                                    inputDocument.access_hash = document.accessHash;
                                    [inputStickers addObject:inputDocument];
                                }
                            }
                            
                            uploadedDocument.stickers = inputStickers;
                            uploadedDocument.flags |= (1 << 0);
                        }
                        
                        SAtomic *initialAttachment = [[SAtomic alloc] init];
                        SAtomic *firstMessageId = [[SAtomic alloc] init];
                        
                        SSignal *sendSignal = nil;
                        for (TGMessage *message in messages)
                        {
                            if (sendSignal == nil)
                            {
                                sendSignal = [[TGSendMessageSignals commitSendMediaWithMessage:message mediaProducer:^TLInputMedia *(__unused NSDictionary *uploadInfo) {
                                    return uploadedDocument;
                                }] onNext:^(TGMessage *sentMessage) {
                                    [firstMessageId swap:@(sentMessage.mid)];
                                    
                                    for (TGMediaAttachment *attachment in sentMessage.mediaAttachments)
                                    {
                                        if (attachment.type == TGVideoMediaAttachmentType || attachment.type ==TGDocumentMediaAttachmentType)
                                        {
                                            [initialAttachment swap:attachment];
                                            break;
                                        }
                                    }
                                }];
                            }
                            else
                            {
                                sendSignal = [sendSignal then:[TGSendMessageSignals commitSendMediaWithMessage:message mediaProducer:^TLInputMedia *(__unused NSDictionary *uploadInfo) {
                                    TGMediaAttachment *attachment = [initialAttachment value];
                                    
                                    TLInputMedia$inputMediaDocument *remoteDocument = [[TLInputMedia$inputMediaDocument alloc] init];
                                    TLInputDocument$inputDocument *inputDocument = [[TLInputDocument$inputDocument alloc] init];
                                    if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
                                    {
                                        inputDocument.n_id = ((TGVideoMediaAttachment *)attachment).videoId;
                                        inputDocument.access_hash = ((TGVideoMediaAttachment *)attachment).accessHash;
                                        remoteDocument.caption = ((TGVideoMediaAttachment *)attachment).caption;
                                    }
                                    else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
                                    {
                                        inputDocument.n_id = ((TGDocumentMediaAttachment *)attachment).documentId;
                                        inputDocument.access_hash = ((TGDocumentMediaAttachment *)attachment).accessHash;
                                        remoteDocument.caption = ((TGDocumentMediaAttachment *)attachment).caption;
                                    }
                                    remoteDocument.n_id = inputDocument;

                                    return remoteDocument;
                                }]];
                            }
                        }
                        
                        if (sendSignal == nil)
                            sendSignal = [SSignal complete];
                        
                        return [sendSignal then:[SSignal defer:^SSignal *
                        {
                            int32_t messageId = [[firstMessageId value] int32Value];
                            
                            if (!preparedMessage.document)
                            {
                                TGVideoMediaAttachment *videoAttachment = [initialAttachment value];
                                
                                NSMutableArray *dataFilePaths = [[NSMutableArray alloc] init];
                                if (preparedMessage.localThumbnailDataPath != nil)
                                    [dataFilePaths addObject:preparedMessage.localThumbnailDataPath];
                                if ([preparedMessage localVideoPath] != nil)
                                    [dataFilePaths addObject:[preparedMessage localVideoPath]];
                                
                                NSString *documentsDirectory = [TGAppDelegate documentsPath];
                                NSString *videosDirectory = [documentsDirectory stringByAppendingPathComponent:@"video"];
                                if (![[NSFileManager defaultManager] fileExistsAtPath:videosDirectory])
                                    [[NSFileManager defaultManager] createDirectoryAtPath:videosDirectory withIntermediateDirectories:true attributes:nil error:nil];
                                
                                NSString *updatedVideoPath = [videosDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"remote%llx.mov", videoAttachment.videoId]];
                                [[NSFileManager defaultManager] moveItemAtPath:[preparedMessage localVideoPath] toPath:updatedVideoPath error:nil];
                                [dataFilePaths removeObject:[preparedMessage localVideoPath]];
                                [[NSFileManager defaultManager] createSymbolicLinkAtPath:[preparedMessage localVideoPath] withDestinationPath:updatedVideoPath error:nil];
                                
                                NSString *remoteUrl = [videoAttachment.videoInfo urlWithQuality:1 actualQuality:NULL actualSize:NULL];
                                if (remoteUrl != nil)
                                {
                                    [TGVideoDownloadActor rewriteLocalFilePath:[[NSString alloc] initWithFormat:@"local-video:local%llx.mov", preparedMessage.localVideoId] remoteUrl:remoteUrl];
                                }
                                
                                [[TGRemoteImageView sharedCache] changeCacheItemUrl:[[NSString alloc] initWithFormat:[preparedMessage localThumbnailDataPath], preparedMessage.localVideoId] newUrl:[[NSString alloc] initWithFormat:@"video-thumbnail-remote%llx.jpg", videoAttachment.videoId]];
                                
                                NSString *thumbnailUrl = [videoAttachment.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
                                if (thumbnailUrl != nil && preparedMessage.localThumbnailDataPath != nil)
                                {
                                    [[TGRemoteImageView sharedCache] moveToCache:[self pathForLocalImagePath:preparedMessage.localThumbnailDataPath] cacheUrl:thumbnailUrl];
                                    [dataFilePaths removeObject:preparedMessage.localThumbnailDataPath];
                                    [TGImageDownloadActor addUrlRewrite:preparedMessage.localThumbnailDataPath newUrl:thumbnailUrl];
                                }
                                
                                if (preparedMessage.useMediaCache && preparedMessage.videoHash.length != 0)
                                    [TGImageDownloadActor addServerMediaSataForAssetUrl:preparedMessage.videoHash attachment:videoAttachment];
                                
                                [TGDatabaseInstance() updateLastUseDateForMediaType:1 mediaId:videoAttachment.videoId messageId:messageId];
                                
                                NSString *paintingImagePath = preparedMessage.adjustments[@"paintingImagePath"];
                                if (paintingImagePath != nil)
                                    [[NSFileManager defaultManager] removeItemAtPath:paintingImagePath error:NULL];
                                
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
                            else
                            {
                                TGDocumentMediaAttachment *documentAttachment = [initialAttachment value];
                                
                                NSMutableArray *dataFilePaths = [[NSMutableArray alloc] init];
                                if (preparedMessage.localThumbnailDataPath != nil)
                                    [dataFilePaths addObject:preparedMessage.localThumbnailDataPath];
                                if ([preparedMessage localDocumentDirectory] != nil)
                                    [dataFilePaths addObject:[preparedMessage localDocumentDirectory]];
                                
                                if (documentAttachment.thumbnailInfo != nil && preparedMessage.localThumbnailDataPath != nil)
                                {
                                    NSString *thumbnailUri = [[documentAttachment thumbnailInfo] imageUrlForLargestSize:NULL];
                                    if (thumbnailUri != nil)
                                    {
                                        [[TGRemoteImageView sharedCache] moveToCache:[self pathForLocalImagePath:preparedMessage.localThumbnailDataPath] cacheUrl:thumbnailUri];
                                        [dataFilePaths removeObject:preparedMessage.localThumbnailDataPath];
                                    }
                                }
                                
                                NSString *updatedDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:documentAttachment.documentId version:documentAttachment.version];
                                
                                [[NSFileManager defaultManager] removeItemAtPath:updatedDocumentDirectory error:nil];
                                [[NSFileManager defaultManager] moveItemAtPath:[preparedMessage localDocumentDirectory] toPath:updatedDocumentDirectory error:nil];
                                
                                [TGDatabaseInstance() updateLastUseDateForMediaType:3 mediaId:documentAttachment.documentId messageId:messageId];
                                
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

                            return [SSignal complete];
                        }]];
                    }];
                }
                
                return [SSignal never];
            }];
        }
        
        return [SSignal complete];
    }];
}

+ (NSString *)pathForLocalImagePath:(NSString *)path
{
    if ([path hasPrefix:@"upload/"])
    {
        NSString *localFileUrl = [path substringFromIndex:7];
        NSString *imagePath = [[[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"upload"] stringByAppendingPathComponent:localFileUrl];
        
        return imagePath;
    }
    else if ([path hasPrefix:@"file://"])
        return [path substringFromIndex:@"file://".length];
    
    return path;
}

+ (NSString *)filePathForLocalDocumentId:(int64_t)localDocumentId attributes:(NSArray *)attributes
{
    NSString *directory = nil;
    directory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:localDocumentId version:0];
    
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

@end
