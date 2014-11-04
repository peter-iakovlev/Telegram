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
#import "TGPreparedDownloadImageMessage.h"
#import "TGPreparedDownloadDocumentMessage.h"

#import "TGRemoteImageView.h"
#import "TGImageDownloadActor.h"

#import "TGDownloadManager.h"

#import "TGImageManager.h"

#import "TGMediaStoreContext.h"

@interface TGModernSendSecretMessageActor ()
{
    int64_t _conversationId;
    int64_t _encryptedConversationId;
    int64_t _accessHash;
    
    int32_t _sentDecryptedPhotoSize;
    NSData *_sendDecryptedPhotoKey;
    NSData *_sendDecryptedPhotoIv;
    
    int32_t _sentDecryptedDocumentSize;
    NSData *_sendDecryptedDocumentKey;
    NSData *_sendDecryptedDocumentIv;
    
    int32_t _sentDecryptedAudioSize;
    NSData *_sendDecryptedAudioKey;
    NSData *_sendDecryptedAudioIv;
    
    id _downloadingItemId;
    
    int32_t _actionId;
}

@end

@implementation TGModernSendSecretMessageActor

+ (NSUInteger)currentLayer
{
    return 17;
}

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

- (id)decryptedGeoPointWithLayer:(NSUInteger)layer latitude:(double)latitude longitude:(double)longitude
{
    switch (layer)
    {
        case 1:
            return [Secret1_DecryptedMessageMedia decryptedMessageMediaGeoPointWithLat:@(latitude) plong:@(longitude)];
        case 17:
            return [Secret17_DecryptedMessageMedia decryptedMessageMediaGeoPointWithLat:@(latitude) plong:@(longitude)];
        default:
            break;
    }
    
    return nil;
}

- (id)decryptedPhotoWithLayer:(NSUInteger)layer thumbnailData:(NSData *)thumbnailData thumbnailSize:(CGSize)thumbnailSize imageSize:(CGSize)imageSize size:(int)size key:(NSData *)key iv:(NSData *)iv
{
    switch (layer)
    {
        case 1:
            return [Secret1_DecryptedMessageMedia decryptedMessageMediaPhotoWithThumb:thumbnailData == nil ? [NSData data] : thumbnailData thumb_w:@((int)thumbnailSize.width) thumb_h:@((int)thumbnailSize.height) w:@((int)imageSize.width) h:@((int)imageSize.height) size:@(size) key:key iv:iv];
        case 17:
            return [Secret17_DecryptedMessageMedia decryptedMessageMediaPhotoWithThumb:thumbnailData == nil ? [NSData data] : thumbnailData thumb_w:@((int)thumbnailSize.width) thumb_h:@((int)thumbnailSize.height) w:@((int)imageSize.width) h:@((int)imageSize.height) size:@(size) key:key iv:iv];
        default:
            break;
    }
    
    return nil;
}

- (id)decryptedVideoWithLayer:(NSUInteger)layer thumbnailData:(NSData *)thumbnailData thumbnailSize:(CGSize)thumbnailSize duration:(int)duration dimensions:(CGSize)dimensions mimeType:(NSString *)mimeType size:(int)size key:(NSData *)key iv:(NSData *)iv
{
    switch (layer)
    {
        case 1:
            return [Secret1_DecryptedMessageMedia decryptedMessageMediaVideoWithThumb:thumbnailData == nil ? [NSData data] : thumbnailData thumb_w:@((int)thumbnailSize.width) thumb_h:@((int)thumbnailSize.height) duration:@(duration) w:@((int)dimensions.width) h:@((int)dimensions.height) size:@(size) key:key iv:iv];
        case 17:
            return [Secret17_DecryptedMessageMedia decryptedMessageMediaVideoWithThumb: thumbnailData == nil ? [NSData data] : thumbnailData thumb_w:@((int)thumbnailSize.width) thumb_h:@((int)thumbnailSize.height) duration:@(duration) mime_type:mimeType w:@((int)dimensions.width) h:@((int)dimensions.height) size:@(size) key:key iv:iv];
    }
    
    return nil;
}

- (id)decryptedDocumentWithLayer:(NSUInteger)layer thumbnailData:(NSData *)thumbnailData thumbnailSize:(CGSize)thumbnailSize fileName:(NSString *)fileName mimeType:(NSString *)mimeType size:(int)size key:(NSData *)key iv:(NSData *)iv
{
    switch (layer)
    {
        case 1:
            return [Secret1_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:thumbnailData == nil ? [NSData data] : thumbnailData thumb_w:@((int)thumbnailSize.width) thumb_h:@((int)thumbnailSize.height) file_name:fileName mime_type:mimeType size:@(size) key:key iv:iv];
        case 17:
            return [Secret17_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:thumbnailData == nil ? [NSData data] : thumbnailData thumb_w:@((int)thumbnailSize.width) thumb_h:@((int)thumbnailSize.height) file_name:fileName mime_type:mimeType size:@(size) key:key iv:iv];
        default:
            break;
    }
    
    return nil;
}

- (id)decryptedAudioWithLayer:(NSUInteger)layer duration:(int)duration mimeType:(NSString *)mimeType size:(int)size key:(NSData *)key iv:(NSData *)iv
{
    switch (layer)
    {
        case 1:
            return [Secret1_DecryptedMessageMedia decryptedMessageMediaAudioWithDuration:@(duration) size:@(size) key:key iv:iv];
        case 17:
            return [Secret17_DecryptedMessageMedia decryptedMessageMediaAudioWithDuration:@(duration) mime_type:mimeType size:@(size) key:key iv:iv];
            
        default:
            break;
    }
    return nil;
}

- (NSUInteger)currentPeerLayer
{
    return MIN([TGModernSendSecretMessageActor currentLayer], [TGDatabaseInstance() peerLayer:_conversationId]);
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
                
                _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:textMessage.text media:nil lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:nil watcher:self];
            }
            else if ([self.preparedMessage isKindOfClass:[TGPreparedMapMessage class]])
            {
                [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
                
                TGPreparedMapMessage *mapMessage = (TGPreparedMapMessage *)self.preparedMessage;
                
                id media = [self decryptedGeoPointWithLayer:[self currentPeerLayer] latitude:mapMessage.latitude longitude:mapMessage.longitude];
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                
                _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:nil watcher:self];
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
                    
                    _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:preparedForwardedMessage.innerMessage.text media:nil lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:nil watcher:self];
                }
            }
            else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadImageMessage class]])
            {
                TGPreparedDownloadImageMessage *downloadImageMessage = (TGPreparedDownloadImageMessage *)self.preparedMessage;
                
                [self setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
                
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
                    [self setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
                    self.uploadProgressContainsPreDownloads = true;
                    
                    NSString *path = [[NSString alloc] initWithFormat:@"/temporaryDownload/(%@)", downloadDocumentMessage.documentUrl];
                    [ActionStageInstance() requestActor:path options:@{@"url": downloadDocumentMessage.documentUrl, @"path": documentPath, @"queue": @"messagePreDownloads"} flags:0 watcher:self];
                    
                    [self beginUploadProgress];
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

- (id)storedFileInfoForSchemeFileInfo:(id)schemeFileInfo
{
    id storedFileInfo = nil;
    if ([schemeFileInfo isKindOfClass:[TLInputEncryptedFile$inputEncryptedFileUploaded class]])
    {
        TLInputEncryptedFile$inputEncryptedFileUploaded *concreteFileInfo = schemeFileInfo;
        storedFileInfo = [[TGStoredOutgoingMessageFileInfoUploaded alloc] initWithN_id:concreteFileInfo.n_id parts:concreteFileInfo.parts md5_checksum:concreteFileInfo.md5_checksum key_fingerprint:concreteFileInfo.key_fingerprint];
    }
    else if ([schemeFileInfo isKindOfClass:[TLInputEncryptedFile$inputEncryptedFile class]])
    {
        TLInputEncryptedFile$inputEncryptedFile *concreteFileInfo = schemeFileInfo;
        storedFileInfo = [[TGStoredOutgoingMessageFileInfoExisting alloc] initWithN_id:concreteFileInfo.n_id accessHash:concreteFileInfo.access_hash];
    }
    else if ([schemeFileInfo isKindOfClass:[TLInputEncryptedFile$inputEncryptedFileBigUploaded class]])
    {
        TLInputEncryptedFile$inputEncryptedFileBigUploaded *concreteFileInfo = schemeFileInfo;
        storedFileInfo = [[TGStoredOutgoingMessageFileInfoBigUploaded alloc] initWithN_id:concreteFileInfo.n_id parts:concreteFileInfo.parts key_fingerprint:concreteFileInfo.key_fingerprint];
    }
    
    return storedFileInfo;
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
                
                id media = [self decryptedPhotoWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize imageSize:size size:(int32_t)[fileInfo[@"fileSize"] intValue] key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
                
                _sentDecryptedPhotoSize = (int32_t)[fileInfo[@"fileSize"] intValue];
                _sendDecryptedPhotoKey = fileInfo[@"key"];
                _sendDecryptedPhotoIv = fileInfo[@"iv"];
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                
                _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
                return true;
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
                
                id media = [self decryptedVideoWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize duration:(int32_t)videoAttachment.duration dimensions:videoAttachment.dimensions mimeType:@"video/mp4" size:videoSize key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                
                _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
                return true;
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
            
            NSData *thumbnailData = nil;
            CGSize thumbnailSize = CGSizeZero;
            
            NSDictionary *fileInfo = filePathToUploadedFile[documentPath];
            if (fileInfo != nil)
            {
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
                    thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(thumbnailImage, thumbSize), 0.6f);
                    
                    if (thumbnailData != nil)
                        thumbnailSize = thumbSize;
                }
                
                id media = [self decryptedDocumentWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize fileName:documentAttachment.fileName mimeType:documentAttachment.mimeType size:documentAttachment.size key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
                
                _sentDecryptedDocumentSize = documentAttachment.size;
                _sendDecryptedDocumentKey = fileInfo[@"key"];
                _sendDecryptedDocumentIv = fileInfo[@"iv"];
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                
                _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
                return true;
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
                id media = [self decryptedAudioWithLayer:[self currentPeerLayer] duration:audioAttachment.duration mimeType:@"audio/ogg" size:[fileInfo[@"fileSize"] intValue] key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
                
                _sentDecryptedAudioSize = [fileInfo[@"fileSize"] intValue];
                _sendDecryptedAudioKey = fileInfo[@"key"];
                _sendDecryptedAudioIv = fileInfo[@"iv"];
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                
                _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
                return true;
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
            
            id media = [self decryptedGeoPointWithLayer:[self currentPeerLayer] latitude:locationAttachment.latitude longitude:locationAttachment.longitude];
            
            int64_t randomId = self.preparedMessage.randomId;
            if (randomId == 0)
                arc4random_buf(&randomId, 8);
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:nil watcher:self];
            return true;
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
                
                id media = [self decryptedPhotoWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize imageSize:localImageMessage.imageSize size:(int32_t)[fileInfo[@"fileSize"] intValue] key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
                
                _sentDecryptedPhotoSize = (int32_t)[fileInfo[@"fileSize"] intValue];
                _sendDecryptedPhotoKey = fileInfo[@"key"];
                _sendDecryptedPhotoIv = fileInfo[@"iv"];
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                
                _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
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
                
                id media = [self decryptedVideoWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize duration:(int)localVideoMessage.duration dimensions:localVideoMessage.videoSize mimeType:@"video/mp4" size:localVideoMessage.size key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                
                _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
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
                NSData *thumbnailData = nil;
                CGSize thumbnailSize = CGSizeZero;
                
                if (localDocumentMessage.localThumbnailDataPath != nil)
                {
                    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[self pathForLocalImagePath:localDocumentMessage.localThumbnailDataPath]];
                    if (image != nil)
                    {
                        CGSize thumbSize = TGFitSize(image.size, CGSizeMake(90, 90));
                        thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(image, thumbSize), 0.6f);
                        
                        if (thumbnailData != nil)
                            thumbnailSize = thumbSize;
                    }
                }
                
                id media = [self decryptedDocumentWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize fileName:localDocumentMessage.fileName mimeType:localDocumentMessage.mimeType size:localDocumentMessage.size key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
                
                
                _sentDecryptedDocumentSize = localDocumentMessage.size;
                _sendDecryptedDocumentKey = fileInfo[@"key"];
                _sendDecryptedDocumentIv = fileInfo[@"iv"];
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                
                _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
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
                id media = [self decryptedAudioWithLayer:[self currentPeerLayer] duration:localAudioMessage.duration mimeType:@"audio/ogg" size:[fileInfo[@"fileSize"] intValue] key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
                
                _sentDecryptedAudioSize = [fileInfo[@"fileSize"] intValue];
                _sendDecryptedAudioKey = fileInfo[@"key"];
                _sendDecryptedAudioIv = fileInfo[@"iv"];
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                
                _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
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
    else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadImageMessage class]])
    {
        int64_t keyId = 0;
        NSData *key = [TGDatabaseInstance() encryptionKeyForConversationId:_conversationId keyFingerprint:&keyId];
        if (key != nil)
        {
            TGPreparedDownloadImageMessage *downloadImageMessage = (TGPreparedDownloadImageMessage *)self.preparedMessage;
            
            NSDictionary *fileInfo = filePathToUploadedFile[@"embedded-data://0"];
            if (fileInfo != nil)
            {
                CGSize imageSize = CGSizeZero;
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:[self filePathForLocalImageUrl:[downloadImageMessage.imageInfo imageUrlForLargestSize:&imageSize]]];
                if (image != nil)
                {
                    CGSize thumbnailSize = TGFitSize(image.size, CGSizeMake(90, 90));
                    NSData *thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(image, thumbnailSize), 0.6f);
                    
                    id media = [self decryptedPhotoWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize imageSize:imageSize size:(int32_t)[fileInfo[@"fileSize"] intValue] key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
                    
                    _sentDecryptedPhotoSize = (int32_t)[fileInfo[@"fileSize"] intValue];
                    _sendDecryptedPhotoKey = fileInfo[@"key"];
                    _sendDecryptedPhotoIv = fileInfo[@"iv"];
                    
                    int64_t randomId = self.preparedMessage.randomId;
                    if (randomId == 0)
                        arc4random_buf(&randomId, 8);
                    
                    _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
                }
                else
                    [self _fail];
            }
            else
                [self _fail];
        }
        else
            [self _fail];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadDocumentMessage class]])
    {
        TGPreparedDownloadDocumentMessage *downloadDocumentMessage = (TGPreparedDownloadDocumentMessage *)self.preparedMessage;
        
        int64_t keyId = 0;
        NSData *key = [TGDatabaseInstance() encryptionKeyForConversationId:_conversationId keyFingerprint:&keyId];
        if (key != nil)
        {
            NSDictionary *fileInfo = filePathToUploadedFile[@"embedded-data://0"];
            if (fileInfo != nil)
            {
                NSData *thumbnailData = nil;
                CGSize thumbnailSize = CGSizeZero;
                
                if (downloadDocumentMessage.thumbnailInfo != nil)
                {
                    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[self filePathForLocalDocumentId:downloadDocumentMessage.localDocumentId fileName:downloadDocumentMessage.fileName]];
                    if (image != nil)
                    {
                        CGSize thumbSize = TGFitSize(image.size, CGSizeMake(90, 90));
                        thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(image, thumbSize), 0.6f);
                        
                        if (thumbnailData != nil)
                            thumbnailSize = thumbSize;
                    }
                }
                
                id media = [self decryptedDocumentWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize fileName:downloadDocumentMessage.fileName mimeType:downloadDocumentMessage.mimeType size:downloadDocumentMessage.size key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
                
                
                _sentDecryptedDocumentSize = downloadDocumentMessage.size;
                _sendDecryptedDocumentKey = fileInfo[@"key"];
                _sendDecryptedDocumentIv = fileInfo[@"iv"];
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                
                _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
            }
            else
                [self _fail];
        }
        else
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
            
            NSString *imageUrl = [[NSString alloc] initWithFormat:@"mt-encrypted-file://?dc=%d&id=%lld&accessHash=%lld&size=%d&decryptedSize=%d&fingerprint=%d&key=%@%@", concreteFile.dc_id, concreteFile.n_id, concreteFile.access_hash, concreteFile.size, _sentDecryptedPhotoSize, concreteFile.key_fingerprint, [_sendDecryptedPhotoKey stringByEncodingInHex], [_sendDecryptedPhotoIv stringByEncodingInHex]];
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
            [imageInfo addImageWithSize:localImageMessage.imageSize url:imageUrl fileSize:_sentDecryptedPhotoSize];
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
            
            documentAttachment.documentUri = [[NSString alloc] initWithFormat:@"mt-encrypted-file://?dc=%d&id=%lld&accessHash=%lld&size=%d&decryptedSize=%d&fingerprint=%d&key=%@%@", concreteFile.dc_id, concreteFile.n_id, concreteFile.access_hash, concreteFile.size, _sentDecryptedDocumentSize, concreteFile.key_fingerprint, [_sendDecryptedDocumentKey stringByEncodingInHex], [_sendDecryptedDocumentIv stringByEncodingInHex]];
            
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
            audioAttachment.fileSize = _sentDecryptedAudioSize;
            
            audioAttachment.audioUri = [[NSString alloc] initWithFormat:@"mt-encrypted-file://?dc=%d&id=%lld&accessHash=%lld&size=%d&decryptedSize=%d&fingerprint=%d&key=%@%@", concreteFile.dc_id, concreteFile.n_id, concreteFile.access_hash, concreteFile.size, _sentDecryptedAudioSize, concreteFile.key_fingerprint, [_sendDecryptedAudioKey stringByEncodingInHex], [_sendDecryptedAudioIv stringByEncodingInHex]];
            
            messageMedia = @[audioAttachment];
            
            [TGDatabaseInstance() updateLastUseDateForMediaType:4 mediaId:audioAttachment.localAudioId messageId:self.preparedMessage.mid];
        }
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadImageMessage class]])
    {
        TGPreparedDownloadImageMessage *downloadImageMessage = (TGPreparedDownloadImageMessage *)self.preparedMessage;
        
        if ([encryptedFile isKindOfClass:[TLEncryptedFile$encryptedFile class]])
        {
            TLEncryptedFile$encryptedFile *concreteFile = (TLEncryptedFile$encryptedFile *)encryptedFile;
            
            NSString *imageUrl = [[NSString alloc] initWithFormat:@"mt-encrypted-file://?dc=%d&id=%lld&accessHash=%lld&size=%d&decryptedSize=%d&fingerprint=%d&key=%@%@", concreteFile.dc_id, concreteFile.n_id, concreteFile.access_hash, concreteFile.size, _sentDecryptedPhotoSize, concreteFile.key_fingerprint, [_sendDecryptedPhotoKey stringByEncodingInHex], [_sendDecryptedPhotoIv stringByEncodingInHex]];
            
            CGSize imageSize = CGSizeZero;
            [[downloadImageMessage imageInfo] imageUrlForLargestSize:&imageSize];
            
            TGImageMediaAttachment *imageAttachment = [[TGImageMediaAttachment alloc] init];
            imageAttachment.imageId = concreteFile.n_id;
            TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
            //[imageInfo addImageWithSize:localImageMessage.thumbnailSize url:thumbnailUrl];
            [imageInfo addImageWithSize:imageSize url:imageUrl fileSize:_sentDecryptedPhotoSize];
            imageAttachment.imageInfo = imageInfo;
            messageMedia = @[imageAttachment];
            
            NSString *localImageUrl = [downloadImageMessage.imageInfo imageUrlForLargestSize:NULL];
            
            NSString *localImageDirectory = [[self filePathForLocalImageUrl:localImageUrl] stringByDeletingLastPathComponent];
            NSString *updatedImageDirectory = [[self filePathForRemoteImageId:imageAttachment.imageId] stringByDeletingLastPathComponent];
            [[NSFileManager defaultManager] moveItemAtPath:localImageDirectory toPath:updatedImageDirectory error:nil];
            
            [TGDatabaseInstance() updateLastUseDateForMediaType:2 mediaId:imageAttachment.imageId messageId:self.preparedMessage.mid];
        }
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadDocumentMessage class]])
    {
        TGPreparedDownloadDocumentMessage *downloadDocumentMessage = (TGPreparedDownloadDocumentMessage *)self.preparedMessage;
        
        if ([encryptedFile isKindOfClass:[TLEncryptedFile$encryptedFile class]])
        {
            TLEncryptedFile$encryptedFile *concreteFile = (TLEncryptedFile$encryptedFile *)encryptedFile;
            
            TGDocumentMediaAttachment *documentAttachment = [[TGDocumentMediaAttachment alloc] init];
            
            documentAttachment.localDocumentId = downloadDocumentMessage.localDocumentId;
            documentAttachment.fileName = downloadDocumentMessage.fileName;
            documentAttachment.mimeType = downloadDocumentMessage.mimeType;
            documentAttachment.size = downloadDocumentMessage.size;
            
            if (downloadDocumentMessage.thumbnailInfo != nil)
            {
                NSString *thumbnailUrl = [[NSString alloc] initWithFormat:@"encryptedThumbnail:%lld", concreteFile.n_id];
                
                CGSize thumbnailSize = CGSizeZero;
                [downloadDocumentMessage.thumbnailInfo imageUrlForLargestSize:&thumbnailSize];
                
                TGImageInfo *thumbnailInfo = [[TGImageInfo alloc] init];
                [thumbnailInfo addImageWithSize:thumbnailSize url:thumbnailUrl];
                documentAttachment.thumbnailInfo = thumbnailInfo;
            }
            
            documentAttachment.documentUri = [[NSString alloc] initWithFormat:@"mt-encrypted-file://?dc=%d&id=%lld&accessHash=%lld&size=%d&decryptedSize=%d&fingerprint=%d&key=%@%@", concreteFile.dc_id, concreteFile.n_id, concreteFile.access_hash, concreteFile.size, _sentDecryptedDocumentSize, concreteFile.key_fingerprint, [_sendDecryptedDocumentKey stringByEncodingInHex], [_sendDecryptedDocumentIv stringByEncodingInHex]];
            
            //NSString *updatedDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:documentAttachment.documentId];
            
            //NSString *localDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:downloadDocumentMessage.localDocumentId];
            //[[NSFileManager defaultManager] moveItemAtPath:localDirectory toPath:updatedDocumentDirectory error:nil];
            
            messageMedia = @[documentAttachment];
            
            [TGDatabaseInstance() updateLastUseDateForMediaType:3 mediaId:documentAttachment.localDocumentId messageId:self.preparedMessage.mid];
        }
    }
    
    std::vector<TGDatabaseMessageFlagValue> flags;
    flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDeliveryState, .value = TGMessageDeliveryStateDelivered});
    flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDate, .value = date});
    [TGDatabaseInstance() updateMessage:self.preparedMessage.mid flags:flags media:messageMedia dispatch:true];
    
    TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:self.preparedMessage.mid];
    if (message != nil)
    {
        [self _success:@{
            @"previousMid": @(self.preparedMessage.mid),
            @"mid": @(self.preparedMessage.mid),
            @"date": @(date),
            @"message": message
        }];
    }
    else
        [self _fail];
}

- (void)sendEncryptedMessageFailed
{
    [self _fail];
}

- (bool)waitsForActionWithId:(int32_t)actionId
{
    return _actionId == actionId;
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

+ (NSData *)prepareDecryptedMessageWithLayer:(NSUInteger)layer text:(NSString *)text media:(id)media lifetime:(int32_t)lifetime randomId:(int64_t)randomId
{
    NSData *messageData = nil;
    
    uint8_t randomBytes[15];
    arc4random_buf(randomBytes, 15);
    NSData *randomBytesData = [[NSData alloc] initWithBytes:randomBytes length:15];
    
    if (text == nil)
        text = @"";
    switch (layer)
    {
        case 1:
            messageData = [Secret1__Environment serializeObject:[Secret1_DecryptedMessage decryptedMessageWithRandom_id:@(randomId) random_bytes:randomBytesData message:text media:media != nil ? media : [Secret1_DecryptedMessageMedia decryptedMessageMediaEmpty]]];
            break;
        case 17:
            messageData = [Secret17__Environment serializeObject:[Secret17_DecryptedMessage decryptedMessageWithRandom_id:@(randomId) ttl:@(lifetime) message:text media:media != nil ? media : [Secret17_DecryptedMessageMedia decryptedMessageMediaEmpty]]];
            break;
        default:
            break;
    }
    
    return messageData;
}

+ (int32_t)enqueueOutgoingMessageForPeerId:(int64_t)peerId layer:(NSUInteger)layer randomId:(int64_t)randomId messageData:(NSData *)messageData storedFileInfo:(TGStoredOutgoingMessageFileInfo *)storedFileInfo watcher:(id)watcher
{
    int32_t actionId = 0;
    [TGDatabaseInstance() enqueuePeerOutgoingAction:peerId action:[[TGStoredOutgoingMessageSecretAction alloc] initWithRandomId:randomId layer:layer data:messageData fileInfo:storedFileInfo] useSeq:layer >= 17 seqOut:NULL seqIn:NULL actionId:&actionId];
    
    NSString *path = [[NSString alloc] initWithFormat:@"/tg/secret/outgoing/(%" PRId64 ")", peerId];
    [ActionStageInstance() requestActor:path options:@{@"peerId": @(peerId)} watcher:TGTelegraphInstance];
    if (watcher != nil)
        [ActionStageInstance() requestActor:path options:nil watcher:watcher];
    
    return actionId;
}

+ (void)enqueueOutgoingServiceMessageForPeerId:(int64_t)peerId layer:(NSUInteger)layer randomId:(int64_t)randomId messageData:(NSData *)messageData
{
    [TGDatabaseInstance() enqueuePeerOutgoingAction:peerId action:[[TGStoredOutgoingServiceMessageSecretAction alloc] initWithRandomId:randomId layer:layer data:messageData] useSeq:layer >= 17 seqOut:NULL seqIn:NULL actionId:NULL];
    
    NSString *path = [[NSString alloc] initWithFormat:@"/tg/secret/outgoing/(%" PRId64 ")", peerId];
    [ActionStageInstance() requestActor:path options:@{@"peerId": @(peerId)} watcher:TGTelegraphInstance];
}

+ (void)enqueueOutgoingResendMessagesForPeerId:(int64_t)peerId fromSeq:(int32_t)fromSeq toSeq:(int32_t)toSeq
{
    [TGDatabaseInstance() enqueuePeerOutgoingResendActions:peerId fromSeq:fromSeq toSeq:toSeq completion:^(bool success)
    {
        if (!success)
        {
            int64_t encryptedChatId = [TGDatabaseInstance() encryptedConversationIdForPeerId:peerId];
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/encrypted/discardEncryptedChat/(%lld)", encryptedChatId] options:@{@"encryptedConversationId": @(encryptedChatId)} flags:0 watcher:TGTelegraphInstance];
        }
    }];
    
    NSString *path = [[NSString alloc] initWithFormat:@"/tg/secret/outgoing/(%" PRId64 ")", peerId];
    [ActionStageInstance() requestActor:path options:@{@"peerId": @(peerId)} watcher:TGTelegraphInstance];
}

+ (void)enqueueIncomingMessagesByPeerId:(NSDictionary *)messageByPeerId
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [messageByPeerId enumerateKeysAndObjectsUsingBlock:^(NSNumber *nPeerId, NSArray *actions, __unused BOOL *stop)
        {
            int64_t peerId = (int64_t)[nPeerId longLongValue];
            
            [TGDatabaseInstance() enqueuePeerIncomingActions:peerId actions:actions];
            
            NSString *path = [[NSString alloc] initWithFormat:@"/tg/secret/incoming/(%" PRId64 ")", peerId];
            [ActionStageInstance() requestActor:path options:@{@"peerId": @(peerId)} watcher:TGTelegraphInstance];
        }];
    }];
}

+ (void)beginIncomingQueueProcessingIfNeeded:(int64_t)peerId
{
    NSString *path = [[NSString alloc] initWithFormat:@"/tg/secret/incoming/(%" PRId64 ")", peerId];
    [ActionStageInstance() requestActor:path options:@{@"peerId": @(peerId)} watcher:TGTelegraphInstance];
}

+ (void)beginOutgoingQueueProcessingIfNeeded:(int64_t)peerId
{
    NSString *path = [[NSString alloc] initWithFormat:@"/tg/secret/outgoing/(%" PRId64 ")", peerId];
    [ActionStageInstance() requestActor:path options:@{@"peerId": @(peerId)} watcher:TGTelegraphInstance];
}

+ (NSData *)encryptMessage:(NSData *)serializedMessage key:(NSData *)key keyId:(int64_t)keyId
{
    if (serializedMessage == nil)
        return nil;
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

+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer setTTL:(int32_t)ttl randomId:(int64_t)randomId
{
    NSData *messageData = nil;
    
    uint8_t randomBytes[15];
    arc4random_buf(randomBytes, 15);
    NSData *randomBytesData = [[NSData alloc] initWithBytes:randomBytes length:15];
    
    switch (layer)
    {
        case 1:
            messageData = [Secret1__Environment serializeObject:[Secret1_DecryptedMessage decryptedMessageServiceWithRandom_id:@(randomId) random_bytes:randomBytesData action:[Secret1_DecryptedMessageAction decryptedMessageActionSetMessageTTLWithTtl_seconds:@(ttl)]]];
            break;
        case 17:
            messageData = [Secret17__Environment serializeObject:[Secret17_DecryptedMessage decryptedMessageServiceWithRandom_id:@(randomId) action:[Secret17_DecryptedMessageAction decryptedMessageActionSetMessageTTLWithTtl_seconds:@(ttl)]]];
            break;
        default:
            break;
    }
    
    return messageData;
}

+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer deleteMessagesWithRandomIds:(NSArray *)randomIds randomId:(int64_t)randomId
{
    NSData *messageData = nil;
    
    uint8_t randomBytes[15];
    arc4random_buf(randomBytes, 15);
    NSData *randomBytesData = [[NSData alloc] initWithBytes:randomBytes length:15];
    
    switch (layer)
    {
        case 1:
            messageData = [Secret1__Environment serializeObject:[Secret1_DecryptedMessage decryptedMessageServiceWithRandom_id:@(randomId) random_bytes:randomBytesData action:[Secret1_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandom_ids:randomIds]]];
            break;
        case 17:
            messageData = [Secret17__Environment serializeObject:[Secret17_DecryptedMessage decryptedMessageServiceWithRandom_id:@(randomId) action:[Secret17_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandom_ids:randomIds]]];
            break;
        default:
            break;
    }
    
    return messageData;
}

+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer flushHistoryWithRandomId:(int64_t)randomId
{
    NSData *messageData = nil;
    
    uint8_t randomBytes[15];
    arc4random_buf(randomBytes, 15);
    NSData *randomBytesData = [[NSData alloc] initWithBytes:randomBytes length:15];
    
    switch (layer)
    {
        case 1:
            messageData = [Secret1__Environment serializeObject:[Secret1_DecryptedMessage decryptedMessageServiceWithRandom_id:@(randomId) random_bytes:randomBytesData action:[Secret1_DecryptedMessageAction decryptedMessageActionFlushHistory]]];
            break;
        case 17:
            messageData = [Secret17__Environment serializeObject:[Secret17_DecryptedMessage decryptedMessageServiceWithRandom_id:@(randomId) action:[Secret17_DecryptedMessageAction decryptedMessageActionFlushHistory]]];
            break;
        default:
            break;
    }
    
    return messageData;
}

+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer readMessagesWithRandomIds:(NSArray *)randomIds randomId:(int64_t)randomId
{
    NSData *messageData = nil;
    
    switch (layer)
    {
        case 1: // not supported
            break;
        case 17:
            messageData = [Secret17__Environment serializeObject:[Secret17_DecryptedMessage decryptedMessageServiceWithRandom_id:@(randomId) action:[Secret17_DecryptedMessageAction decryptedMessageActionReadMessagesWithRandom_ids:randomIds]]];
            break;
        default:
            break;
    }
    
    return messageData;
}

+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer screenshotMessagesWithRandomIds:(NSArray *)randomIds randomId:(int64_t)randomId
{
    NSData *messageData = nil;
    
    switch (layer)
    {
        case 1: // not supported
            break;
        case 17:
            messageData = [Secret17__Environment serializeObject:[Secret17_DecryptedMessage decryptedMessageServiceWithRandom_id:@(randomId) action:[Secret17_DecryptedMessageAction decryptedMessageActionScreenshotMessagesWithRandom_ids:randomIds]]];
            break;
        default:
            break;
    }
    
    return messageData;
}

+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer notifyLayer:(NSUInteger)notifyLayer randomId:(int64_t)randomId
{
    NSData *messageData = nil;
    
    uint8_t randomBytes[15];
    arc4random_buf(randomBytes, 15);
    NSData *randomBytesData = [[NSData alloc] initWithBytes:randomBytes length:15];
    
    switch (layer)
    {
        case 1:
            messageData = [Secret1__Environment serializeObject:[Secret1_DecryptedMessage decryptedMessageServiceWithRandom_id:@(randomId) random_bytes:randomBytesData action:[Secret1_DecryptedMessageAction decryptedMessageActionNotifyLayerWithLayer:@(notifyLayer)]]];
            break;
        case 17:
            messageData = [Secret17__Environment serializeObject:[Secret17_DecryptedMessage decryptedMessageServiceWithRandom_id:@(randomId) action:[Secret17_DecryptedMessageAction decryptedMessageActionNotifyLayerWithLayer:@(notifyLayer)]]];
            break;
        default:
            break;
    }
    
    return messageData;
}

+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer resendMessagesFromSeq:(int32_t)fromSeq toSeq:(int32_t)toSeq randomId:(int64_t)randomId
{
    NSData *messageData = nil;
    
    switch (layer)
    {
        case 1: // not supported
            return nil;
        case 17:
            messageData = [Secret17__Environment serializeObject:[Secret17_DecryptedMessage decryptedMessageServiceWithRandom_id:@(randomId) action:[Secret17_DecryptedMessageAction decryptedMessageActionResendWithStart_seq_no:@(fromSeq) end_seq_no:@(toSeq)]]];
            break;
        default:
            break;
    }
    
    return messageData;
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
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/secret/outgoing/(%" PRId64 ")", [self peerId]]])
    {
        if ([messageType isEqualToString:@"actionCompletedWithSeq"])
        {
            if ([message[@"actionId"] intValue] == _actionId)
            {
                TLmessages_SentEncryptedMessage *result = message[@"result"];
                
                [self sendEncryptedMessageSuccess:result.date encryptedFile:[result isKindOfClass:[TLmessages_SentEncryptedMessage$messages_sentEncryptedFile class]] ? [(TLmessages_SentEncryptedMessage$messages_sentEncryptedFile *)result file] : nil];
            }
        }
        else if ([messageType isEqualToString:@"actionQuickAck"])
        {
            if ([message[@"actionId"] intValue] == _actionId)
            {
            }
        }
    }
    else if ([path hasPrefix:@"/temporaryDownload/"])
    {
        [self restartFailTimeoutIfRunning];
        
        [self updatePreDownloadsProgress:[message floatValue]];
    }
    
    if ([[self superclass] instancesRespondToSelector:@selector(actorMessageReceived:messageType:message:)])
        [super actorMessageReceived:path messageType:messageType message:messageType];
}

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
        
        [self uploadFilesWithExtensions:@[@[data, @"bin", @(true)]]];
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
        [files addObject:@[data, @"bin", @(true)]];
        [self uploadFilesWithExtensions:files];
    }
    else
        [self _fail];
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

@end
