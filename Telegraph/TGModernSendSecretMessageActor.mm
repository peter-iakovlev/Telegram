#import "TGModernSendSecretMessageActor.h"

#import "ActionStage.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"
#import <MTProtoKit/MTEncryption.h>
#import "TLMetaClassStore.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "TGPreparedTextMessage.h"
#import "TGPreparedMapMessage.h"
#import "TGPreparedLocalImageMessage.h"
#import "TGPreparedLocalVideoMessage.h"
#import "TGPreparedLocalDocumentMessage.h"
#import "TGPreparedLocalAudioMessage.h"
#import "TGPreparedForwardedMessage.h"

#import "TGRemoteImageView.h"
#import "TGImageDownloadActor.h"

#import "TGDownloadManager.h"

#import "TGImageManager.h"

@interface TGModernSendSecretMessageActor ()
{
    int64_t _conversationId;
    int64_t _encryptedConversationId;
    int64_t _accessHash;
    
    TLDecryptedMessageMedia$decryptedMessageMediaPhoto *_sentDecryptedPhoto;
    TLDecryptedMessageMedia$decryptedMessageMediaVideo *_sentDecryptedVideo;
    TLDecryptedMessageMedia$decryptedMessageMediaDocument *_sentDecryptedDocument;
    TLDecryptedMessageMedia$decryptedMessageMediaAudio *_sentDecryptedAudio;
    
    id _downloadingItemId;
}

@end

@implementation TGModernSendSecretMessageActor

+ (NSString *)genericPath
{
    return @"/tg/sendSecretMessage/@/@";
}

- (void)cancel
{
    if (_downloadingItemId != nil)
        [[TGDownloadManager instance] cancelItem:_downloadingItemId];
    
    [super cancel];
}

- (void)prepare:(NSDictionary *)options
{
    [super prepare:options];
    
    _conversationId = [options[@"conversationId"] longLongValue];
    _encryptedConversationId = [options[@"encryptedConversationId"] longLongValue];
    _accessHash = [options[@"accessHash"] longLongValue];
}

- (bool)_encryptUploads
{
    return true;
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
        int64_t keyId = 0;
        NSData *key = [TGDatabaseInstance() encryptionKeyForConversationId:_conversationId keyFingerprint:&keyId];
        
        if (key != nil)
        {
            if ([self.preparedMessage isKindOfClass:[TGPreparedTextMessage class]])
            {
                [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
                
                TGPreparedTextMessage *textMessage = (TGPreparedTextMessage *)self.preparedMessage;
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                NSData *encryptedMessage = [TGModernSendSecretMessageActor prepareEncryptedMessage:textMessage.text media:nil randomId:randomId key:key keyId:keyId];
                if (encryptedMessage != nil)
                {
                    self.cancelToken = [TGTelegraphInstance doSendEncryptedMessage:_encryptedConversationId accessHash:_accessHash randomId:randomId data:encryptedMessage encryptedFile:nil actor:self];
                }
                else
                {
                    TGLog(@"***** Couldn't encrypt message for conversation %lld", _encryptedConversationId);
                    [self _fail];
                }
            }
            else if ([self.preparedMessage isKindOfClass:[TGPreparedMapMessage class]])
            {
                [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
                
                TGPreparedMapMessage *mapMessage = (TGPreparedMapMessage *)self.preparedMessage;
                
                TLDecryptedMessageMedia$decryptedMessageMediaGeoPoint *decryptedGeoPoint = [[TLDecryptedMessageMedia$decryptedMessageMediaGeoPoint alloc] init];
                decryptedGeoPoint.lat = mapMessage.latitude;
                decryptedGeoPoint.n_long = mapMessage.longitude;
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                NSData *encryptedMessage = [TGModernSendSecretMessageActor prepareEncryptedMessage:nil media:decryptedGeoPoint randomId:randomId key:key keyId:keyId];
                if (encryptedMessage != nil)
                {
                    self.cancelToken = [TGTelegraphInstance doSendEncryptedMessage:_encryptedConversationId accessHash:_accessHash randomId:randomId data:encryptedMessage encryptedFile:nil actor:self];
                }
                else
                {
                    TGLog(@"***** Couldn't encrypt message for conversation %lld", _encryptedConversationId);
                    [self _fail];
                }
            }
            else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalImageMessage class]])
            {
                TGPreparedLocalImageMessage *localImageMessage = (TGPreparedLocalImageMessage *)self.preparedMessage;
                
                [self setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
                
                [self uploadFilesWithExtensions:@[@[localImageMessage.localImageDataPath, @"bin", @(true)]]];
            }
            else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalVideoMessage class]])
            {
                TGPreparedLocalVideoMessage *localVideoMessage = (TGPreparedLocalVideoMessage *)self.preparedMessage;
                
                [self setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
                
                [self uploadFilesWithExtensions:@[@[[localVideoMessage localVideoPath], @"bin", @(true)]]];
            }
            else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalDocumentMessage class]])
            {
                TGPreparedLocalDocumentMessage *preparedDocument = (TGPreparedLocalDocumentMessage *)self.preparedMessage;
                
                [self setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
                
                [self uploadFilesWithExtensions:@[@[[[preparedDocument localDocumentDirectory] stringByAppendingPathComponent:[preparedDocument localDocumentFileName]], @"bin", @(true)]]];
            }
            else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalAudioMessage class]])
            {
                TGPreparedLocalAudioMessage *preparedAudio = (TGPreparedLocalAudioMessage *)self.preparedMessage;
                
                [self setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
                
                NSMutableArray *desc = [[NSMutableArray alloc] initWithArray:@[[preparedAudio localAudioFilePath1], @"bin", @(true)]];
                if (preparedAudio.liveData != nil)
                    [desc addObject:preparedAudio.liveData];
                
                [self uploadFilesWithExtensions:@[desc]];
            }
            else if ([self.preparedMessage isKindOfClass:[TGPreparedForwardedMessage class]])
            {
                TGPreparedForwardedMessage *preparedForwardedMessage = (TGPreparedForwardedMessage *)self.preparedMessage;
                id media = [self mediaToForward:preparedForwardedMessage.innerMessage];
                
                if (media != nil)
                {
                    if ([self isMediaLocallyAvailable:media])
                    {
                        if ([self doesMediaRequireUpload:media])
                        {
                            if (![self uploadForwardedMedia:media])
                                [self _fail];
                        }
                        else
                        {
                            if (![self sendForwardedMedia:media filePathToUploadedFile:@{}])
                                [self _fail];
                        }
                    }
                    else
                    {
                        if (![self downloadMedia:media messageId:preparedForwardedMessage.innerMessage.mid conversationId:preparedForwardedMessage.innerMessage.cid])
                            [self _fail];
                    }
                }
                else
                {
                    int64_t randomId = self.preparedMessage.randomId;
                    if (randomId == 0)
                        arc4random_buf(&randomId, 8);
                    NSData *encryptedMessage = [TGModernSendSecretMessageActor prepareEncryptedMessage:preparedForwardedMessage.innerMessage.text media:nil randomId:randomId key:key keyId:keyId];
                    if (encryptedMessage != nil)
                    {
                        self.cancelToken = [TGTelegraphInstance doSendEncryptedMessage:_encryptedConversationId accessHash:_accessHash randomId:randomId data:encryptedMessage encryptedFile:nil actor:self];
                    }
                    else
                    {
                        TGLog(@"***** Couldn't encrypt message for conversation %lld", _encryptedConversationId);
                        [self _fail];
                    }
                }
            }
            else
                [self _fail];
        }
        else
        {
            TGLog(@"***** Couldn't find encryption key for conversation %lld", _encryptedConversationId);
            [self _fail];
        }
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

- (NSString *)filePathForVideoId:(int64_t)videoId local:(bool)local
{
    static NSString *videosDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) objectAtIndex:0];
        videosDirectory = [documentsDirectory stringByAppendingPathComponent:@"video"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:videosDirectory])
            [[NSFileManager defaultManager] createDirectoryAtPath:videosDirectory withIntermediateDirectories:true attributes:nil error:nil];
    });
    
    return [videosDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@%" PRIx64 ".mov", local ? @"local" : @"remote", videoId]];
}

- (NSString *)filePathForDocument:(TGDocumentMediaAttachment *)document
{
    NSString *directory = nil;
    if (document.documentId != 0)
        directory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId];
    else
        directory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:document.localDocumentId];
    
    NSString *filePath = [directory stringByAppendingPathComponent:[TGDocumentMediaAttachment safeFileNameForFileName:document.fileName]];
    return filePath;
}

- (NSString *)filePathForAudio:(TGAudioMediaAttachment *)audio
{
    NSString *filePath = nil;
    if (audio.audioId != 0)
        filePath = [TGPreparedLocalAudioMessage localAudioFilePathForRemoteAudioId1:audio.audioId];
    else
        filePath = [TGPreparedLocalAudioMessage localAudioFilePathForLocalAudioId1:audio.localAudioId];
    return filePath;
}

- (id)mediaToForward:(TGMessage *)message
{
    id media = nil;
    
    for (id attachment in message.mediaAttachments)
    {
        if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
            media = attachment;
        else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
            media = attachment;
        else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
            media = attachment;
        else if ([attachment isKindOfClass:[TGAudioMediaAttachment class]])
            media = attachment;
        else if ([attachment isKindOfClass:[TGLocationMediaAttachment class]])
            media = attachment;
    }
    
    return media;
}

- (bool)isMediaLocallyAvailable:(id)attachment
{
    if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
    {
        TGImageMediaAttachment *imageAttachment = attachment;
        
        NSString *imageUrl = [imageAttachment.imageInfo closestImageUrlWithSize:CGSizeMake(1000, 1000) resultingSize:NULL];
        NSString *imageCachePath = [[TGRemoteImageView sharedCache] pathForCachedData:imageUrl];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:imageCachePath])
            return true;
    }
    else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
    {
        TGVideoMediaAttachment *videoAttachment = attachment;
        NSString *videoPath = [self filePathForVideoId:videoAttachment.videoId == 0 ? videoAttachment.localVideoId : videoAttachment.videoId local:videoAttachment.videoId == 0];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath])
            return true;
    }
    else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
    {
        TGDocumentMediaAttachment *documentAttachment = attachment;
        NSString *documentPath = [self filePathForDocument:documentAttachment];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:documentPath])
            return true;
    }
    else if ([attachment isKindOfClass:[TGAudioMediaAttachment class]])
    {
        TGAudioMediaAttachment *audioAttachment = attachment;
        NSString *audioPath = [self filePathForAudio:audioAttachment];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:audioPath])
            return true;
    }
    else if ([attachment isKindOfClass:[TGLocationMediaAttachment class]])
        return true;
    
    return false;
}

- (bool)doesMediaRequireUpload:(id)attachment
{
    if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
        return true;
    else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
        return true;
    else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
        return true;
    else if ([attachment isKindOfClass:[TGAudioMediaAttachment class]])
        return true;
    else if ([attachment isKindOfClass:[TGLocationMediaAttachment class]])
        return false;
    
    return false;
}

- (bool)downloadMedia:(id)attachment messageId:(int32_t)messageId conversationId:(int64_t)conversationId
{
    if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
    {
        TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
        id mediaId = [[TGMediaId alloc] initWithType:2 itemId:imageAttachment.imageId];
        
        NSString *url = [[imageAttachment imageInfo] closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:NULL pickLargest:true];
        
        if (url != nil)
        {
            int contentHints = TGRemoteImageContentHintLargeFile;
            
            NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:0], @"cancelTimeout", [TGRemoteImageView sharedCache], @"cache", [NSNumber numberWithBool:false], @"useCache", [NSNumber numberWithBool:false], @"allowThumbnailCache", [[NSNumber alloc] initWithInt:contentHints], @"contentHints", nil];
            [options setObject:[[NSDictionary alloc] initWithObjectsAndKeys:
                                [[NSNumber alloc] initWithInt:messageId], @"messageId",
                                [[NSNumber alloc] initWithLongLong:conversationId], @"conversationId",
                                mediaId, @"mediaId", imageAttachment.imageInfo, @"imageInfo",
                                nil] forKey:@"userProperties"];
            
            [ActionStageInstance() watchForPath:@"downloadManagerStateChanged" watcher:self];
            _downloadingItemId = mediaId;
            
            [[TGDownloadManager instance] requestItem:[NSString stringWithFormat:@"/img/(download:{filter:%@}%@)", @"maybeScale", url] options:options changePriority:false messageId:messageId itemId:mediaId groupId:conversationId itemClass:TGDownloadItemClassImage];
            
            [self beginUploadProgress];
        }
        
        return true;
    }
    else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
    {
        TGVideoMediaAttachment *videoAttachment = attachment;
        id mediaId = [[TGMediaId alloc] initWithType:1 itemId:videoAttachment.videoId];
        
        NSString *url = [videoAttachment.videoInfo urlWithQuality:0 actualQuality:NULL actualSize:NULL];
        
        if (url != nil)
        {
            [ActionStageInstance() watchForPath:@"downloadManagerStateChanged" watcher:self];
            _downloadingItemId = mediaId;
            
            [self beginUploadProgress];
            
            [[TGDownloadManager instance] requestItem:[NSString stringWithFormat:@"/as/media/video/(%@)", url] options:[[NSDictionary alloc] initWithObjectsAndKeys:videoAttachment, @"videoAttachment", nil] changePriority:false messageId:messageId itemId:mediaId groupId:conversationId itemClass:TGDownloadItemClassVideo];
            
            return true;
        }
        else
            return false;
    }
    else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
    {
        TGDocumentMediaAttachment *documentAttachment = attachment;
        if (documentAttachment.documentId != 0 || documentAttachment.documentUri.length != 0)
        {
            id mediaId = [[TGMediaId alloc] initWithType:3 itemId:documentAttachment.documentId != 0 ? documentAttachment.documentId : documentAttachment.localDocumentId];
            
            [ActionStageInstance() watchForPath:@"downloadManagerStateChanged" watcher:self];
            _downloadingItemId = mediaId;
            
            [self beginUploadProgress];
            
            [[TGDownloadManager instance] requestItem:[NSString stringWithFormat:@"/tg/media/document/(%d:%" PRId64 ":%@)", documentAttachment.datacenterId, documentAttachment.documentId, documentAttachment.documentUri.length != 0 ? documentAttachment.documentUri : @""] options:[[NSDictionary alloc] initWithObjectsAndKeys:documentAttachment, @"documentAttachment", nil] changePriority:false messageId:messageId itemId:mediaId groupId:conversationId itemClass:TGDownloadItemClassDocument];
            
            return true;
        }
        else
            return false;
    }
    else if ([attachment isKindOfClass:[TGAudioMediaAttachment class]])
    {
        TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
        if (audioAttachment.audioId != 0 || audioAttachment.audioUri.length != 0)
        {
            id mediaId = [[TGMediaId alloc] initWithType:4 itemId:audioAttachment.audioId != 0 ? audioAttachment.audioId : audioAttachment.localAudioId];
            
            [ActionStageInstance() watchForPath:@"downloadManagerStateChanged" watcher:self];
            _downloadingItemId = mediaId;
            
            [self beginUploadProgress];
            
            [[TGDownloadManager instance] requestItem:[NSString stringWithFormat:@"/tg/media/audio/(%" PRId32 ":%" PRId64 ":%@)", audioAttachment.datacenterId, audioAttachment.audioId, audioAttachment.audioUri.length != 0 ? audioAttachment.audioUri : @""] options:[[NSDictionary alloc] initWithObjectsAndKeys:audioAttachment, @"audioAttachment", nil] changePriority:false messageId:messageId itemId:mediaId groupId:conversationId itemClass:TGDownloadItemClassAudio];
            
            return true;
        }
        else
            return false;
    }
    
    return false;
}

- (bool)sendForwardedMedia:(id)attachment filePathToUploadedFile:(NSDictionary *)filePathToUploadedFile
{
    if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
    {
        int64_t keyId = 0;
        NSData *key = [TGDatabaseInstance() encryptionKeyForConversationId:_conversationId keyFingerprint:&keyId];
        if (key != nil)
        {
            TGImageMediaAttachment *imageAttachment = attachment;
            
            CGSize size = CGSizeZero;
            NSString *imageUrl = [imageAttachment.imageInfo closestImageUrlWithSize:CGSizeMake(1000, 1000) resultingSize:&size];
            NSString *imageCachePath = [[TGRemoteImageView sharedCache] pathForCachedData:imageUrl];
            
            NSDictionary *fileInfo = filePathToUploadedFile[imageCachePath];
            if (fileInfo != nil)
            {
                UIImage *thumbnailImage = [[UIImage alloc] initWithContentsOfFile:imageCachePath];
                CGSize thumbnailSize = TGFitSize(thumbnailImage.size, CGSizeMake(90, 90));
                NSData *thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(thumbnailImage, thumbnailSize), 0.6f);
                
                TLDecryptedMessageMedia$decryptedMessageMediaPhoto *decryptedPhoto = [[TLDecryptedMessageMedia$decryptedMessageMediaPhoto alloc] init];
                decryptedPhoto.thumb = thumbnailData;
                decryptedPhoto.thumb_w = (int32_t)thumbnailSize.width;
                decryptedPhoto.thumb_h = (int32_t)thumbnailSize.height;
                decryptedPhoto.w = (int32_t)size.width;
                decryptedPhoto.h = (int32_t)size.height;
                decryptedPhoto.size = (int32_t)[fileInfo[@"fileSize"] intValue];
                decryptedPhoto.key = fileInfo[@"key"];
                decryptedPhoto.iv = fileInfo[@"iv"];
                
                _sentDecryptedPhoto = decryptedPhoto;
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                NSData *encryptedMessage = [TGModernSendSecretMessageActor prepareEncryptedMessage:nil media:decryptedPhoto randomId:randomId key:key keyId:keyId];
                if (encryptedMessage != nil)
                {
                    self.cancelToken = [TGTelegraphInstance doSendEncryptedMessage:_encryptedConversationId accessHash:_accessHash randomId:randomId data:encryptedMessage encryptedFile:fileInfo[@"file"] actor:self];
                    
                    return true;
                }
                else
                {
                    TGLog(@"***** Couldn't encrypt message for conversation %lld", _encryptedConversationId);
                    
                    return false;
                }
            }
            else
                return false;
        }
        else
            return false;
    }
    else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
    {
        int64_t keyId = 0;
        NSData *key = [TGDatabaseInstance() encryptionKeyForConversationId:_conversationId keyFingerprint:&keyId];
        if (key != nil)
        {
            TGVideoMediaAttachment *videoAttachment = attachment;
            NSString *videoPath = [self filePathForVideoId:videoAttachment.videoId == 0 ? videoAttachment.localVideoId : videoAttachment.videoId local:videoAttachment.videoId == 0];
            
            NSDictionary *fileInfo = filePathToUploadedFile[videoPath];
            if (fileInfo != nil)
            {
                NSMutableString *previewUri = nil;
                
                NSString *legacyVideoFilePath = [self filePathForVideoId:videoAttachment.videoId != 0 ? videoAttachment.videoId : videoAttachment.localVideoId local:videoAttachment.videoId == 0];
                NSString *legacyThumbnailCacheUri = [videoAttachment.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
                
                int videoSize = 0;
                [videoAttachment.videoInfo urlWithQuality:0 actualQuality:NULL actualSize:&videoSize];
                
                if (videoAttachment.videoId != 0 || videoAttachment.localVideoId != 0)
                {
                    previewUri = [[NSMutableString alloc] initWithString:@"media-gallery-video-preview://?"];
                    if (videoAttachment.videoId != 0)
                        [previewUri appendFormat:@"id=%" PRId64 "", videoAttachment.videoId];
                    else
                        [previewUri appendFormat:@"local-id=%" PRId64 "", videoAttachment.localVideoId];
                    
                    CGSize dimensions = videoAttachment.dimensions;
                    CGSize size = TGFitSize(dimensions, CGSizeMake(90, 90));
                    
                    [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)size.width, (int)size.height, (int)size.width, (int)size.height];
                    
                    [previewUri appendFormat:@"&legacy-video-file-path=%@", legacyVideoFilePath];
                    if (legacyThumbnailCacheUri != nil)
                        [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUri];
                    
                    //[previewUri appendFormat:@"&messageId=%" PRId32 "", (int32_t)messageId];
                    //[previewUri appendFormat:@"&conversationId=%" PRId64 "", (int64_t)peerId];
                }
                
                UIImage *thumbnailImage = [[[TGImageManager instance] loadDataSyncWithUri:previewUri canWait:true acceptPartialData:false asyncTaskId:NULL progress:nil partialCompletion:nil completion:nil] image];
                CGSize thumbnailSize = TGFitSize(thumbnailImage.size, CGSizeMake(90, 90));
                NSData *thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(thumbnailImage, thumbnailSize), 0.6f);
                
                TLDecryptedMessageMedia$decryptedMessageMediaVideo *decryptedVideo = [[TLDecryptedMessageMedia$decryptedMessageMediaVideo alloc] init];
                decryptedVideo.thumb = thumbnailData;
                decryptedVideo.thumb_w = (int32_t)thumbnailSize.width;
                decryptedVideo.thumb_h = (int32_t)thumbnailSize.height;
                decryptedVideo.duration = (int32_t)videoAttachment.duration;
                decryptedVideo.w = (int32_t)videoAttachment.dimensions.width;
                decryptedVideo.h = (int32_t)videoAttachment.dimensions.height;
                decryptedVideo.size = (int32_t)videoSize;
                decryptedVideo.key = fileInfo[@"key"];
                decryptedVideo.iv = fileInfo[@"iv"];
                
                _sentDecryptedVideo = decryptedVideo;
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                NSData *encryptedMessage = [TGModernSendSecretMessageActor prepareEncryptedMessage:nil media:decryptedVideo randomId:randomId key:key keyId:keyId];
                if (encryptedMessage != nil)
                {
                    self.cancelToken = [TGTelegraphInstance doSendEncryptedMessage:_encryptedConversationId accessHash:_accessHash randomId:randomId data:encryptedMessage encryptedFile:fileInfo[@"file"] actor:self];
                    
                    return true;
                }
                else
                {
                    TGLog(@"***** Couldn't encrypt message for conversation %lld", _encryptedConversationId);
                    
                    return false;
                }
            }
            else
                return false;
        }
        else
            return false;
    }
    else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
    {
        int64_t keyId = 0;
        NSData *key = [TGDatabaseInstance() encryptionKeyForConversationId:_conversationId keyFingerprint:&keyId];
        if (key != nil)
        {
            TGDocumentMediaAttachment *documentAttachment = attachment;
            NSString *documentPath = [self filePathForDocument:documentAttachment];
            
            NSDictionary *fileInfo = filePathToUploadedFile[documentPath];
            if (fileInfo != nil)
            {
                TLDecryptedMessageMedia$decryptedMessageMediaDocument *decryptedDocument = [[TLDecryptedMessageMedia$decryptedMessageMediaDocument alloc] init];
                decryptedDocument.file_name = documentAttachment.fileName;
                decryptedDocument.mime_type = documentAttachment.mimeType;
                decryptedDocument.size = documentAttachment.size;
                decryptedDocument.key = fileInfo[@"key"];
                decryptedDocument.iv = fileInfo[@"iv"];
                
                UIImage *thumbnailImage = nil;
                
                if (documentAttachment.thumbnailInfo != nil)
                {
                    CGSize dimensions = CGSizeZero;
                    NSString *legacyThumbnailCacheUri = [documentAttachment.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:&dimensions];
                    dimensions.width *= 10.0f;
                    dimensions.height *= 10.0f;
                    
                    NSString *filePreviewUri = nil;
                    
                    if ((documentAttachment.documentId != 0 || documentAttachment.localDocumentId != 0) && legacyThumbnailCacheUri.length != 0)
                    {
                        NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"file-thumbnail://?"];
                        if (documentAttachment.documentId != 0)
                            [previewUri appendFormat:@"id=%" PRId64 "", documentAttachment.documentId];
                        else
                            [previewUri appendFormat:@"local-id=%" PRId64 "", documentAttachment.localDocumentId];
                        
                        [previewUri appendFormat:@"&file-name=%@", [documentAttachment.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        
                        CGSize thumbnailSize = CGSizeMake(90.0f, 90.0f);
                        CGSize renderSize = CGSizeZero;
                        if (dimensions.width < dimensions.height)
                        {
                            renderSize.height = CGFloor((dimensions.height * thumbnailSize.width / dimensions.width));
                            renderSize.width = thumbnailSize.width;
                        }
                        else
                        {
                            renderSize.width = CGFloor((dimensions.width * thumbnailSize.height / dimensions.height));
                            renderSize.height = thumbnailSize.height;
                        }
                        
                        [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
                        
                        if (legacyThumbnailCacheUri != nil)
                            [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUri];
                        
                        filePreviewUri = previewUri;
                    }

                    thumbnailImage = [[[TGImageManager instance] loadDataSyncWithUri:filePreviewUri canWait:true acceptPartialData:false asyncTaskId:NULL progress:nil partialCompletion:nil completion:nil] image];
                }
                
                if (thumbnailImage != nil)
                {
                    CGSize thumbSize = TGFitSize(thumbnailImage.size, CGSizeMake(90, 90));
                    NSData *thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(thumbnailImage, thumbSize), 0.6f);
                    
                    if (thumbnailData != nil)
                    {
                        decryptedDocument.thumb = thumbnailData;
                        decryptedDocument.thumb_w = (int32_t)thumbSize.width;
                        decryptedDocument.thumb_h = (int32_t)thumbSize.height;
                    }
                }
                
                _sentDecryptedDocument = decryptedDocument;
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                NSData *encryptedMessage = [TGModernSendSecretMessageActor prepareEncryptedMessage:nil media:decryptedDocument randomId:randomId key:key keyId:keyId];
                if (encryptedMessage != nil)
                {
                    int64_t randomId = self.preparedMessage.randomId;
                    if (randomId == 0)
                        arc4random_buf(&randomId, 8);
                    self.cancelToken = [TGTelegraphInstance doSendEncryptedMessage:_encryptedConversationId accessHash:_accessHash randomId:randomId data:encryptedMessage encryptedFile:fileInfo[@"file"] actor:self];
                    
                    return true;
                }
                else
                {
                    TGLog(@"***** Couldn't encrypt message for conversation %lld", _encryptedConversationId);
                    
                    return false;
                }
            }
            else
                return false;
        }
        else
            return false;
    }
    else if ([attachment isKindOfClass:[TGAudioMediaAttachment class]])
    {
        int64_t keyId = 0;
        NSData *key = [TGDatabaseInstance() encryptionKeyForConversationId:_conversationId keyFingerprint:&keyId];
        if (key != nil)
        {
            TGAudioMediaAttachment *audioAttachment = attachment;
            NSString *audioPath = [self filePathForAudio:audioAttachment];
            
            NSDictionary *fileInfo = filePathToUploadedFile[audioPath];
            if (fileInfo != nil)
            {
                TLDecryptedMessageMedia$decryptedMessageMediaAudio *decryptedAudio = [[TLDecryptedMessageMedia$decryptedMessageMediaAudio alloc] init];
                decryptedAudio.duration = audioAttachment.duration;
                decryptedAudio.size = [fileInfo[@"fileSize"] intValue];
                decryptedAudio.key = fileInfo[@"key"];
                decryptedAudio.iv = fileInfo[@"iv"];
                
                _sentDecryptedAudio = decryptedAudio;
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                NSData *encryptedMessage = [TGModernSendSecretMessageActor prepareEncryptedMessage:nil media:decryptedAudio randomId:randomId key:key keyId:keyId];
                if (encryptedMessage != nil)
                {
                    int64_t randomId = self.preparedMessage.randomId;
                    if (randomId == 0)
                        arc4random_buf(&randomId, 8);
                    self.cancelToken = [TGTelegraphInstance doSendEncryptedMessage:_encryptedConversationId accessHash:_accessHash randomId:randomId data:encryptedMessage encryptedFile:fileInfo[@"file"] actor:self];
                    
                    return true;
                }
                else
                {
                    TGLog(@"***** Couldn't encrypt message for conversation %lld", _encryptedConversationId);
                    
                    return false;
                }
            }
            else
                return false;
        }
        else
            return false;
    }
    else if ([attachment isKindOfClass:[TGLocationMediaAttachment class]])
    {
        int64_t keyId = 0;
        NSData *key = [TGDatabaseInstance() encryptionKeyForConversationId:_conversationId keyFingerprint:&keyId];
        if (key != nil)
        {
            [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
            
            TGLocationMediaAttachment *locationAttachment = attachment;
            
            TLDecryptedMessageMedia$decryptedMessageMediaGeoPoint *decryptedGeoPoint = [[TLDecryptedMessageMedia$decryptedMessageMediaGeoPoint alloc] init];
            decryptedGeoPoint.lat = locationAttachment.latitude;
            decryptedGeoPoint.n_long = locationAttachment.longitude;
            
            int64_t randomId = self.preparedMessage.randomId;
            if (randomId == 0)
                arc4random_buf(&randomId, 8);
            NSData *encryptedMessage = [TGModernSendSecretMessageActor prepareEncryptedMessage:nil media:decryptedGeoPoint randomId:randomId key:key keyId:keyId];
            if (encryptedMessage != nil)
            {
                self.cancelToken = [TGTelegraphInstance doSendEncryptedMessage:_encryptedConversationId accessHash:_accessHash randomId:randomId data:encryptedMessage encryptedFile:nil actor:self];
                
                return true;
            }
            else
            {
                TGLog(@"***** Couldn't encrypt message for conversation %lld", _encryptedConversationId);
                
                return false;
            }
        }
        else
            return false;
    }
    
    return false;
}

- (bool)uploadForwardedMedia:(id)attachment
{
    if (![self isMediaLocallyAvailable:attachment])
        return false;
    
    if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
    {
        TGImageMediaAttachment *imageAttachment = attachment;
        
        NSString *imageUrl = [imageAttachment.imageInfo closestImageUrlWithSize:CGSizeMake(1000, 1000) resultingSize:NULL];
        NSString *imageCachePath = [[TGRemoteImageView sharedCache] pathForCachedData:imageUrl];
        
        [self setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
        
        [self uploadFilesWithExtensions:@[@[imageCachePath, @"bin", @(true)]]];
        
        return true;
    }
    else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
    {
        TGVideoMediaAttachment *videoAttachment = attachment;
        NSString *videoPath = [self filePathForVideoId:videoAttachment.videoId == 0 ? videoAttachment.localVideoId : videoAttachment.videoId local:videoAttachment.videoId == 0];
        
        [self setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
        
        [self uploadFilesWithExtensions:@[@[videoPath, @"bin", @(true)]]];
        
        return true;
    }
    else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
    {
        TGDocumentMediaAttachment *documentAttachment = attachment;
        NSString *documentPath = [self filePathForDocument:documentAttachment];
        
        [self setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
        
        [self uploadFilesWithExtensions:@[@[documentPath, @"bin", @(true)]]];
        
        return true;
    }
    else if ([attachment isKindOfClass:[TGAudioMediaAttachment class]])
    {
        TGAudioMediaAttachment *audioAttachment = attachment;
        NSString *audioPath = [self filePathForAudio:audioAttachment];
        
        [self setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
        
        [self uploadFilesWithExtensions:@[@[audioPath, @"bin", @(true)]]];
        
        return true;
    }
    
    return false;
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
    if ([self.preparedMessage isKindOfClass:[TGPreparedLocalImageMessage class]])
    {
        int64_t keyId = 0;
        NSData *key = [TGDatabaseInstance() encryptionKeyForConversationId:_conversationId keyFingerprint:&keyId];
        if (key != nil)
        {
            TGPreparedLocalImageMessage *localImageMessage = (TGPreparedLocalImageMessage *)self.preparedMessage;
            
            NSDictionary *fileInfo = filePathToUploadedFile[localImageMessage.localImageDataPath];
            if (fileInfo != nil)
            {
                UIImage *thumbnailImage = [[UIImage alloc] initWithContentsOfFile:[self pathForLocalImagePath:localImageMessage.localThumbnailDataPath] ];
                CGSize thumbnailSize = TGFitSize(thumbnailImage.size, CGSizeMake(90, 90));
                NSData *thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(thumbnailImage, thumbnailSize), 0.6f);
                
                TLDecryptedMessageMedia$decryptedMessageMediaPhoto *decryptedPhoto = [[TLDecryptedMessageMedia$decryptedMessageMediaPhoto alloc] init];
                decryptedPhoto.thumb = thumbnailData;
                decryptedPhoto.thumb_w = (int32_t)thumbnailSize.width;
                decryptedPhoto.thumb_h = (int32_t)thumbnailSize.height;
                decryptedPhoto.w = (int32_t)localImageMessage.imageSize.width;
                decryptedPhoto.h = (int32_t)localImageMessage.imageSize.height;
                decryptedPhoto.size = (int32_t)[fileInfo[@"fileSize"] intValue];
                decryptedPhoto.key = fileInfo[@"key"];
                decryptedPhoto.iv = fileInfo[@"iv"];
                
                _sentDecryptedPhoto = decryptedPhoto;
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                NSData *encryptedMessage = [TGModernSendSecretMessageActor prepareEncryptedMessage:nil media:decryptedPhoto randomId:randomId key:key keyId:keyId];
                if (encryptedMessage != nil)
                {
                    self.cancelToken = [TGTelegraphInstance doSendEncryptedMessage:_encryptedConversationId accessHash:_accessHash randomId:randomId data:encryptedMessage encryptedFile:fileInfo[@"file"] actor:self];
                }
                else
                {
                    TGLog(@"***** Couldn't encrypt message for conversation %lld", _encryptedConversationId);
                    [self _fail];
                }
            }
            else
                [self _fail];
        }
        else
            [self _fail];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalVideoMessage class]])
    {
        TGPreparedLocalVideoMessage *localVideoMessage = (TGPreparedLocalVideoMessage *)self.preparedMessage;
        
        int64_t keyId = 0;
        NSData *key = [TGDatabaseInstance() encryptionKeyForConversationId:_conversationId keyFingerprint:&keyId];
        if (key != nil)
        {
            NSDictionary *fileInfo = filePathToUploadedFile[localVideoMessage.localVideoPath];
            if (fileInfo != nil)
            {
                UIImage *thumbnailImage = [[UIImage alloc] initWithContentsOfFile:[self pathForLocalImagePath:localVideoMessage.localThumbnailDataPath]];
                CGSize thumbnailSize = TGFitSize(thumbnailImage.size, CGSizeMake(90, 90));
                NSData *thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(thumbnailImage, thumbnailSize), 0.6f);
                
                TLDecryptedMessageMedia$decryptedMessageMediaVideo *decryptedVideo = [[TLDecryptedMessageMedia$decryptedMessageMediaVideo alloc] init];
                decryptedVideo.thumb = thumbnailData;
                decryptedVideo.thumb_w = (int32_t)thumbnailSize.width;
                decryptedVideo.thumb_h = (int32_t)thumbnailSize.height;
                decryptedVideo.duration = (int32_t)localVideoMessage.duration;
                decryptedVideo.w = (int32_t)localVideoMessage.videoSize.width;
                decryptedVideo.h = (int32_t)localVideoMessage.videoSize.height;
                decryptedVideo.size = localVideoMessage.size;
                decryptedVideo.key = fileInfo[@"key"];
                decryptedVideo.iv = fileInfo[@"iv"];
                
                _sentDecryptedVideo = decryptedVideo;
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                NSData *encryptedMessage = [TGModernSendSecretMessageActor prepareEncryptedMessage:nil media:decryptedVideo randomId:randomId key:key keyId:keyId];
                if (encryptedMessage != nil)
                {
                    self.cancelToken = [TGTelegraphInstance doSendEncryptedMessage:_encryptedConversationId accessHash:_accessHash randomId:randomId data:encryptedMessage encryptedFile:fileInfo[@"file"] actor:self];
                }
                else
                {
                    TGLog(@"***** Couldn't encrypt message for conversation %lld", _encryptedConversationId);
                    [self _fail];
                }
            }
            else
                [self _fail];
        }
        else
            [self _fail];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalDocumentMessage class]])
    {
        TGPreparedLocalDocumentMessage *localDocumentMessage = (TGPreparedLocalDocumentMessage *)self.preparedMessage;
        
        int64_t keyId = 0;
        NSData *key = [TGDatabaseInstance() encryptionKeyForConversationId:_conversationId keyFingerprint:&keyId];
        if (key != nil)
        {
            NSDictionary *fileInfo = filePathToUploadedFile[[[localDocumentMessage localDocumentDirectory] stringByAppendingPathComponent:[localDocumentMessage localDocumentFileName]]];
            if (fileInfo != nil)
            {
                TLDecryptedMessageMedia$decryptedMessageMediaDocument *decryptedDocument = [[TLDecryptedMessageMedia$decryptedMessageMediaDocument alloc] init];
                decryptedDocument.file_name = localDocumentMessage.fileName;
                decryptedDocument.mime_type = localDocumentMessage.mimeType;
                decryptedDocument.size = localDocumentMessage.size;
                decryptedDocument.key = fileInfo[@"key"];
                decryptedDocument.iv = fileInfo[@"iv"];
                
                if (localDocumentMessage.localThumbnailDataPath != nil)
                {
                    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[self pathForLocalImagePath:localDocumentMessage.localThumbnailDataPath]];
                    if (image != nil)
                    {
                        CGSize thumbSize = TGFitSize(image.size, CGSizeMake(90, 90));
                        NSData *thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(image, thumbSize), 0.6f);
                        
                        if (thumbnailData != nil)
                        {
                            decryptedDocument.thumb = thumbnailData;
                            decryptedDocument.thumb_w = (int32_t)thumbSize.width;
                            decryptedDocument.thumb_h = (int32_t)thumbSize.height;
                        }
                    }
                }
                
                _sentDecryptedDocument = decryptedDocument;
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                NSData *encryptedMessage = [TGModernSendSecretMessageActor prepareEncryptedMessage:nil media:decryptedDocument randomId:randomId key:key keyId:keyId];
                if (encryptedMessage != nil)
                {
                    int64_t randomId = self.preparedMessage.randomId;
                    if (randomId == 0)
                        arc4random_buf(&randomId, 8);
                    self.cancelToken = [TGTelegraphInstance doSendEncryptedMessage:_encryptedConversationId accessHash:_accessHash randomId:randomId data:encryptedMessage encryptedFile:fileInfo[@"file"] actor:self];
                }
                else
                {
                    TGLog(@"***** Couldn't encrypt message for conversation %lld", _encryptedConversationId);
                    [self _fail];
                }
            }
            else
                [self _fail];
        }
        else
            [self _fail];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalAudioMessage class]])
    {
        TGPreparedLocalAudioMessage *localAudioMessage = (TGPreparedLocalAudioMessage *)self.preparedMessage;
        
        int64_t keyId = 0;
        NSData *key = [TGDatabaseInstance() encryptionKeyForConversationId:_conversationId keyFingerprint:&keyId];
        if (key != nil)
        {
            NSDictionary *fileInfo = filePathToUploadedFile[[localAudioMessage localAudioFilePath1]];
            if (fileInfo != nil)
            {
                TLDecryptedMessageMedia$decryptedMessageMediaAudio *decryptedAudio = [[TLDecryptedMessageMedia$decryptedMessageMediaAudio alloc] init];
                decryptedAudio.duration = localAudioMessage.duration;
                decryptedAudio.size = [fileInfo[@"fileSize"] intValue];
                decryptedAudio.key = fileInfo[@"key"];
                decryptedAudio.iv = fileInfo[@"iv"];
                
                _sentDecryptedAudio = decryptedAudio;
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                NSData *encryptedMessage = [TGModernSendSecretMessageActor prepareEncryptedMessage:nil media:decryptedAudio randomId:randomId key:key keyId:keyId];
                if (encryptedMessage != nil)
                {
                    int64_t randomId = self.preparedMessage.randomId;
                    if (randomId == 0)
                        arc4random_buf(&randomId, 8);
                    self.cancelToken = [TGTelegraphInstance doSendEncryptedMessage:_encryptedConversationId accessHash:_accessHash randomId:randomId data:encryptedMessage encryptedFile:fileInfo[@"file"] actor:self];
                }
                else
                {
                    TGLog(@"***** Couldn't encrypt message for conversation %lld", _encryptedConversationId);
                    [self _fail];
                }
            }
            else
                [self _fail];
        }
        else
            [self _fail];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedForwardedMessage class]])
    {
        TGPreparedForwardedMessage *preparedForwardedMessage = (TGPreparedForwardedMessage *)self.preparedMessage;
        id media = [self mediaToForward:preparedForwardedMessage.innerMessage];
        
        if (![self sendForwardedMedia:media filePathToUploadedFile:filePathToUploadedFile])
            [self _fail];
    }
    else
        [self _fail];
    
    [super uploadsCompleted:filePathToUploadedFile];
}

#pragma mark -

- (void)sendEncryptedMessageSuccess:(int32_t)date encryptedFile:(TLEncryptedFile *)encryptedFile
{
    NSArray *messageMedia = nil;
    
    if ([self.preparedMessage isKindOfClass:[TGPreparedLocalImageMessage class]])
    {
        TGPreparedLocalImageMessage *localImageMessage = (TGPreparedLocalImageMessage *)self.preparedMessage;
        
        if ([encryptedFile isKindOfClass:[TLEncryptedFile$encryptedFile class]])
        {
            TLEncryptedFile$encryptedFile *concreteFile = (TLEncryptedFile$encryptedFile *)encryptedFile;
            
            NSString *imageUrl = [[NSString alloc] initWithFormat:@"mt-encrypted-file://?dc=%d&id=%lld&accessHash=%lld&size=%d&decryptedSize=%d&fingerprint=%d&key=%@%@", concreteFile.dc_id, concreteFile.n_id, concreteFile.access_hash, concreteFile.size, _sentDecryptedPhoto.size, concreteFile.key_fingerprint, [_sentDecryptedPhoto.key stringByEncodingInHex], [_sentDecryptedPhoto.iv stringByEncodingInHex]];
            if (localImageMessage.localImageDataPath != nil)
            {
                [[TGRemoteImageView sharedCache] moveToCache:[self pathForLocalImagePath:localImageMessage.localImageDataPath] cacheUrl:imageUrl];
                [TGImageDownloadActor addUrlRewrite:localImageMessage.localImageDataPath newUrl:imageUrl];
            }
            
            NSString *thumbnailUrl = [[NSString alloc] initWithFormat:@"encryptedThumbnail:%lld", concreteFile.n_id];
            if (localImageMessage.localThumbnailDataPath != nil)
            {
                [[TGRemoteImageView sharedCache] moveToCache:[self pathForLocalImagePath:localImageMessage.localThumbnailDataPath] cacheUrl:thumbnailUrl];
                [TGImageDownloadActor addUrlRewrite:localImageMessage.localThumbnailDataPath newUrl:thumbnailUrl];
            }
            
            TGImageMediaAttachment *imageAttachment = [[TGImageMediaAttachment alloc] init];
            imageAttachment.imageId = concreteFile.n_id;
            TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
            [imageInfo addImageWithSize:localImageMessage.thumbnailSize url:thumbnailUrl];
            [imageInfo addImageWithSize:localImageMessage.imageSize url:imageUrl fileSize:_sentDecryptedPhoto.size];
            imageAttachment.imageInfo = imageInfo;
            messageMedia = @[imageAttachment];
            
            [TGDatabaseInstance() updateLastUseDateForMediaType:2 mediaId:imageAttachment.imageId messageId:self.preparedMessage.mid];
        }
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalDocumentMessage class]])
    {
        TGPreparedLocalDocumentMessage *localDocumentMessage = (TGPreparedLocalDocumentMessage *)self.preparedMessage;
        
        if ([encryptedFile isKindOfClass:[TLEncryptedFile$encryptedFile class]])
        {
            TLEncryptedFile$encryptedFile *concreteFile = (TLEncryptedFile$encryptedFile *)encryptedFile;
            
            TGDocumentMediaAttachment *documentAttachment = [[TGDocumentMediaAttachment alloc] init];
            
            documentAttachment.localDocumentId = localDocumentMessage.localDocumentId;
            documentAttachment.fileName = localDocumentMessage.fileName;
            documentAttachment.mimeType = localDocumentMessage.mimeType;
            documentAttachment.size = localDocumentMessage.size;
            
            if (localDocumentMessage.localThumbnailDataPath != nil)
            {
                NSString *thumbnailUrl = [[NSString alloc] initWithFormat:@"encryptedThumbnail:%lld", concreteFile.n_id];
                [[TGRemoteImageView sharedCache] moveToCache:[self pathForLocalImagePath:localDocumentMessage.localThumbnailDataPath] cacheUrl:thumbnailUrl];
                
                TGImageInfo *thumbnailInfo = [[TGImageInfo alloc] init];
                [thumbnailInfo addImageWithSize:localDocumentMessage.thumbnailSize url:thumbnailUrl];
                documentAttachment.thumbnailInfo = thumbnailInfo;
            }
            
            documentAttachment.documentUri = [[NSString alloc] initWithFormat:@"mt-encrypted-file://?dc=%d&id=%lld&accessHash=%lld&size=%d&decryptedSize=%d&fingerprint=%d&key=%@%@", concreteFile.dc_id, concreteFile.n_id, concreteFile.access_hash, concreteFile.size, _sentDecryptedDocument.size, concreteFile.key_fingerprint, [_sentDecryptedDocument.key stringByEncodingInHex], [_sentDecryptedDocument.iv stringByEncodingInHex]];
            
            messageMedia = @[documentAttachment];
            
            [TGDatabaseInstance() updateLastUseDateForMediaType:3 mediaId:documentAttachment.localDocumentId messageId:self.preparedMessage.mid];
        }
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalAudioMessage class]])
    {
        TGPreparedLocalAudioMessage *localAudioMessage = (TGPreparedLocalAudioMessage *)self.preparedMessage;
        
        if ([encryptedFile isKindOfClass:[TLEncryptedFile$encryptedFile class]])
        {
            TLEncryptedFile$encryptedFile *concreteFile = (TLEncryptedFile$encryptedFile *)encryptedFile;
            
            TGAudioMediaAttachment *audioAttachment = [[TGAudioMediaAttachment alloc] init];
            
            audioAttachment.localAudioId = localAudioMessage.localAudioId;
            audioAttachment.duration = localAudioMessage.duration;
            audioAttachment.fileSize = _sentDecryptedAudio.size;
            
            audioAttachment.audioUri = [[NSString alloc] initWithFormat:@"mt-encrypted-file://?dc=%d&id=%lld&accessHash=%lld&size=%d&decryptedSize=%d&fingerprint=%d&key=%@%@", concreteFile.dc_id, concreteFile.n_id, concreteFile.access_hash, concreteFile.size, _sentDecryptedAudio.size, concreteFile.key_fingerprint, [_sentDecryptedAudio.key stringByEncodingInHex], [_sentDecryptedAudio.iv stringByEncodingInHex]];
            
            messageMedia = @[audioAttachment];
            
            [TGDatabaseInstance() updateLastUseDateForMediaType:4 mediaId:audioAttachment.localAudioId messageId:self.preparedMessage.mid];
        }
    }
    
    std::vector<TGDatabaseMessageFlagValue> flags;
    flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDeliveryState, .value = TGMessageDeliveryStateDelivered});
    flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDate, .value = date});
    [TGDatabaseInstance() updateMessage:self.preparedMessage.mid flags:flags media:messageMedia dispatch:true];
        
    [self _success:@{
        @"previousMid": @(self.preparedMessage.mid),
        @"mid": @(self.preparedMessage.mid),
        @"date": @(date)
    }];
}

- (void)sendEncryptedMessageFailed
{
    [self _fail];
}

+ (MTMessageEncryptionKey *)generateMessageKeyData:(NSData *)messageKey incoming:(bool)incoming key:(NSData *)key
{
    NSData *authKey = key;
    if (authKey == nil || authKey.length == 0)
        return nil;
    
    int x = incoming ? 8 : 0;
    
    NSData *sha1_a = nil;
    {
        NSMutableData *data = [[NSMutableData alloc] init];
        [data appendData:messageKey];
        [data appendBytes:(((int8_t *)authKey.bytes) + x) length:32];
        sha1_a = MTSha1(data);
    }
    
    NSData *sha1_b = nil;
    {
        NSMutableData *data = [[NSMutableData alloc] init];
        [data appendBytes:(((int8_t *)authKey.bytes) + 32 + x) length:16];
        [data appendData:messageKey];
        [data appendBytes:(((int8_t *)authKey.bytes) + 48 + x) length:16];
        sha1_b = MTSha1(data);
    }
    
    NSData *sha1_c = nil;
    {
        NSMutableData *data = [[NSMutableData alloc] init];
        [data appendBytes:(((int8_t *)authKey.bytes) + 64 + x) length:32];
        [data appendData:messageKey];
        sha1_c = MTSha1(data);
    }
    
    NSData *sha1_d = nil;
    {
        NSMutableData *data = [[NSMutableData alloc] init];
        [data appendData:messageKey];
        [data appendBytes:(((int8_t *)authKey.bytes) + 96 + x) length:32];
        sha1_d = MTSha1(data);
    }
    
    NSMutableData *aesKey = [[NSMutableData alloc] init];
    [aesKey appendBytes:(((int8_t *)sha1_a.bytes)) length:8];
    [aesKey appendBytes:(((int8_t *)sha1_b.bytes) + 8) length:12];
    [aesKey appendBytes:(((int8_t *)sha1_c.bytes) + 4) length:12];
    
    NSMutableData *aesIv = [[NSMutableData alloc] init];
    [aesIv appendBytes:(((int8_t *)sha1_a.bytes) + 8) length:12];
    [aesIv appendBytes:(((int8_t *)sha1_b.bytes)) length:8];
    [aesIv appendBytes:(((int8_t *)sha1_c.bytes) + 16) length:4];
    [aesIv appendBytes:(((int8_t *)sha1_d.bytes)) length:8];
    
    return [[MTMessageEncryptionKey alloc] initWithKey:[[NSData alloc] initWithData:aesKey] iv:[[NSData alloc] initWithData:aesIv]];
}

+ (NSData *)prepareEncryptedMessage:(NSString *)text media:(TLDecryptedMessageMedia *)media randomId:(int64_t)randomId key:(NSData *)key keyId:(int64_t)keyId
{
    TLDecryptedMessage$decryptedMessage *decryptedMessage = [[TLDecryptedMessage$decryptedMessage alloc] init];
    
    decryptedMessage.random_id = randomId;
    
    decryptedMessage.random_bytes = nil;
    
    decryptedMessage.message = text;
    
    decryptedMessage.media = media == nil ? [TLDecryptedMessageMedia$decryptedMessageMediaEmpty new] : media;
    
    NSOutputStream *os = [[NSOutputStream alloc] initToMemory];
    [os open];
    TLMetaClassStore::serializeObject(os, decryptedMessage, true);
    NSData *result = [self encryptMessage:[os currentBytes] key:key keyId:keyId];
    [os close];
    
    return result;
}

+ (NSData *)encryptMessage:(NSData *)serializedMessage key:(NSData *)key keyId:(int64_t)keyId
{
    NSMutableData *decryptedBytesOriginal = [serializedMessage mutableCopy];
    int32_t messageLength = decryptedBytesOriginal.length;
    [decryptedBytesOriginal replaceBytesInRange:NSMakeRange(0, 0) withBytes:&messageLength length:4];
    
    NSData *messageKeyFull = MTSha1(decryptedBytesOriginal);
    NSData *messageKey = [[NSData alloc] initWithBytes:(((int8_t *)messageKeyFull.bytes) + messageKeyFull.length - 16) length:16];
    
    uint8_t randomBuf[16];
    arc4random_buf(randomBuf, 16);
    int index = 0;
    
    NSMutableData *decryptedBytes = [[NSMutableData alloc] initWithCapacity:decryptedBytesOriginal.length + 16];
    [decryptedBytes appendData:decryptedBytesOriginal];
    while (decryptedBytes.length % 16 != 0)
    {
        [decryptedBytes appendBytes:randomBuf + index length:1];
        index++;
    }
    
    MTMessageEncryptionKey *keyData = [self generateMessageKeyData:messageKey incoming:false key:key];
    
    if (keyData != nil)
    {
        MTAesEncryptInplace(decryptedBytes, keyData.key, keyData.iv);
        NSMutableData *data = [[NSMutableData alloc] init];
        [data appendBytes:&keyId length:8];
        [data appendData:messageKey];
        [data appendData:decryptedBytes];
        
        return data;
    }
    
    return nil;
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)arguments
{
    if ([path isEqualToString:@"downloadManagerStateChanged"])
    {
        if ([self.preparedMessage isKindOfClass:[TGPreparedForwardedMessage class]] && arguments != nil && _downloadingItemId != nil)
        {
            TGPreparedForwardedMessage *preparedForwardedMessage = (TGPreparedForwardedMessage *)self.preparedMessage;
            id media = [self mediaToForward:preparedForwardedMessage.innerMessage];
            
            if (media != nil)
            {
                if ([arguments[@"completedItemIds"] containsObject:_downloadingItemId])
                {
                    if ([self isMediaLocallyAvailable:media])
                    {
                        if ([self doesMediaRequireUpload:media])
                        {
                            if (![self uploadForwardedMedia:media])
                                [self _fail];
                        }
                        else
                        {
                            if (![self sendForwardedMedia:media filePathToUploadedFile:@{}])
                                [self _fail];
                        }
                    }
                    else
                        [self _fail];
                }
                else if ([arguments[@"failedItemIds"] containsObject:_downloadingItemId])
                    [self _fail];
            }
        }
    }
    
    if ([[self superclass] instancesRespondToSelector:@selector(actionStageResourceDispatched:resource:arguments:)])
        [super actionStageResourceDispatched:path resource:resource arguments:arguments];
}

@end
