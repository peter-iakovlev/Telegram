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
#import "TGPreparedRemoteDocumentMessage.h"
#import "TGPreparedCloudDocumentMessage.h"

#import "TGRemoteImageView.h"
#import "TGImageDownloadActor.h"

#import "TGDownloadManager.h"

#import "TGImageManager.h"

#import "TGMediaStoreContext.h"

#import "TGRequestEncryptedChatActor.h"

#import "TGImageInfo+Telegraph.h"

#import "TGAppDelegate.h"

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
    return 23;
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
        case 20:
            return [Secret20_DecryptedMessageMedia decryptedMessageMediaGeoPointWithLat:@(latitude) plong:@(longitude)];
        case 23:
            return [Secret23_DecryptedMessageMedia decryptedMessageMediaGeoPointWithLat:@(latitude) plong:@(longitude)];
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
            return [Secret1_DecryptedMessageMedia decryptedMessageMediaPhotoWithThumb:thumbnailData == nil ? [NSData data] : thumbnailData thumbW:@((int)thumbnailSize.width) thumbH:@((int)thumbnailSize.height) w:@((int)imageSize.width) h:@((int)imageSize.height) size:@(size) key:key iv:iv];
        case 17:
            return [Secret17_DecryptedMessageMedia decryptedMessageMediaPhotoWithThumb:thumbnailData == nil ? [NSData data] : thumbnailData thumbW:@((int)thumbnailSize.width) thumbH:@((int)thumbnailSize.height) w:@((int)imageSize.width) h:@((int)imageSize.height) size:@(size) key:key iv:iv];
        case 20:
            return [Secret20_DecryptedMessageMedia decryptedMessageMediaPhotoWithThumb:thumbnailData == nil ? [NSData data] : thumbnailData thumbW:@((int)thumbnailSize.width) thumbH:@((int)thumbnailSize.height) w:@((int)imageSize.width) h:@((int)imageSize.height) size:@(size) key:key iv:iv];
        case 23:
            return [Secret23_DecryptedMessageMedia decryptedMessageMediaPhotoWithThumb:thumbnailData == nil ? [NSData data] : thumbnailData thumbW:@((int)thumbnailSize.width) thumbH:@((int)thumbnailSize.height) w:@((int)imageSize.width) h:@((int)imageSize.height) size:@(size) key:key iv:iv];
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
            return [Secret1_DecryptedMessageMedia decryptedMessageMediaVideoWithThumb:thumbnailData == nil ? [NSData data] : thumbnailData thumbW:@((int)thumbnailSize.width) thumbH:@((int)thumbnailSize.height) duration:@(duration) w:@((int)dimensions.width) h:@((int)dimensions.height) size:@(size) key:key iv:iv];
        case 17:
            return [Secret17_DecryptedMessageMedia decryptedMessageMediaVideoWithThumb: thumbnailData == nil ? [NSData data] : thumbnailData thumbW:@((int)thumbnailSize.width) thumbH:@((int)thumbnailSize.height) duration:@(duration) mimeType:mimeType w:@((int)dimensions.width) h:@((int)dimensions.height) size:@(size) key:key iv:iv];
        case 20:
            return [Secret20_DecryptedMessageMedia decryptedMessageMediaVideoWithThumb: thumbnailData == nil ? [NSData data] : thumbnailData thumbW:@((int)thumbnailSize.width) thumbH:@((int)thumbnailSize.height) duration:@(duration) mimeType:mimeType w:@((int)dimensions.width) h:@((int)dimensions.height) size:@(size) key:key iv:iv];
        case 23:
            return [Secret23_DecryptedMessageMedia decryptedMessageMediaVideoWithThumb: thumbnailData == nil ? [NSData data] : thumbnailData thumbW:@((int)thumbnailSize.width) thumbH:@((int)thumbnailSize.height) duration:@(duration) mimeType:mimeType w:@((int)dimensions.width) h:@((int)dimensions.height) size:@(size) key:key iv:iv];
    }
    
    return nil;
}

- (id)decryptedDocumentWithLayer:(NSUInteger)layer thumbnailData:(NSData *)thumbnailData thumbnailSize:(CGSize)thumbnailSize fileName:(NSString *)fileName mimeType:(NSString *)mimeType size:(int)size key:(NSData *)key iv:(NSData *)iv
{
    switch (layer)
    {
        case 1:
            return [Secret1_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:thumbnailData == nil ? [NSData data] : thumbnailData thumbW:@((int)thumbnailSize.width) thumbH:@((int)thumbnailSize.height) fileName:fileName mimeType:mimeType size:@(size) key:key iv:iv];
        case 17:
            return [Secret17_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:thumbnailData == nil ? [NSData data] : thumbnailData thumbW:@((int)thumbnailSize.width) thumbH:@((int)thumbnailSize.height) fileName:fileName mimeType:mimeType size:@(size) key:key iv:iv];
        case 20:
            return [Secret20_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:thumbnailData == nil ? [NSData data] : thumbnailData thumbW:@((int)thumbnailSize.width) thumbH:@((int)thumbnailSize.height) fileName:fileName mimeType:mimeType size:@(size) key:key iv:iv];
        case 23:
            return [Secret23_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:thumbnailData == nil ? [NSData data] : thumbnailData thumbW:@((int)thumbnailSize.width) thumbH:@((int)thumbnailSize.height) fileName:fileName mimeType:mimeType size:@(size) key:key iv:iv];
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
            return [Secret17_DecryptedMessageMedia decryptedMessageMediaAudioWithDuration:@(duration) mimeType:mimeType size:@(size) key:key iv:iv];
        case 20:
            return [Secret20_DecryptedMessageMedia decryptedMessageMediaAudioWithDuration:@(duration) mimeType:mimeType size:@(size) key:key iv:iv];
        case 23:
            return [Secret23_DecryptedMessageMedia decryptedMessageMediaAudioWithDuration:@(duration) mimeType:mimeType size:@(size) key:key iv:iv];
        default:
            break;
    }
    return nil;
}

- (NSArray *)convertDocumentAttributes:(NSArray *)attributes toLayer:(NSUInteger)layer
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (id attribute in attributes)
    {
        if ([attribute isKindOfClass:[TGDocumentAttributeFilename class]])
        {
            id convertedAttribute = nil;
            switch (layer)
            {
                case 23:
                    convertedAttribute = [Secret23_DocumentAttribute documentAttributeFilenameWithFileName:((TGDocumentAttributeFilename *)attribute).filename];
                default:
                    break;
            }
            if (convertedAttribute != nil)
                [result addObject:convertedAttribute];
        }
        else if ([attribute isKindOfClass:[TGDocumentAttributeAnimated class]])
        {
            id convertedAttribute = nil;
            switch (layer)
            {
                case 23:
                    convertedAttribute = [Secret23_DocumentAttribute documentAttributeAnimated];
                default:
                    break;
            }
            if (convertedAttribute != nil)
                [result addObject:convertedAttribute];
        }
        else if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]])
        {
            id convertedAttribute = nil;
            switch (layer)
            {
                case 23:
                    convertedAttribute = [Secret23_DocumentAttribute documentAttributeImageSizeWithW:@((int32_t)((TGDocumentAttributeImageSize *)attribute).size.width) h:@((int32_t)((TGDocumentAttributeImageSize *)attribute).size.height)];
                default:
                    break;
            }
            if (convertedAttribute != nil)
                [result addObject:convertedAttribute];
        }
        else if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
        {
            id convertedAttribute = nil;
            switch (layer)
            {
                case 23:
                    convertedAttribute = [Secret23_DocumentAttribute documentAttributeSticker];
                default:
                    break;
            }
            if (convertedAttribute != nil)
                [result addObject:convertedAttribute];
        }
    }
    
    return result;
}

- (id)decryptedExternalDocumentWithLayer:(NSUInteger)layer id:(int64_t)n_id accessHash:(int64_t)accessHash date:(int32_t)date mimeType:(NSString *)mimeType size:(int32_t)size thumbnailUri:(NSString *)thumbnailUri thumbnailData:(NSData *)thumbnailData thumbnailSize:(CGSize)thumbnailSize dcId:(int32_t)dcId attributes:(NSArray *)attributes
{
    switch (layer)
    {
        case 23:
        {
            int32_t thumbDcId = 0;
            int64_t thumbVolumeId = 0;
            int32_t thumbLocalId = 0;
            int64_t thumbSecret = 0;
            extractFileUrlComponents(thumbnailUri, &thumbDcId, &thumbVolumeId, &thumbLocalId, &thumbSecret);
            Secret23_PhotoSize_photoCachedSize *cachedSize = [Secret23_PhotoSize photoCachedSizeWithType:@"s" location:[Secret23_FileLocation_fileLocation fileLocationWithDcId:@(thumbDcId) volumeId:@(thumbVolumeId) localId:@(thumbLocalId) secret:@(thumbSecret)] w:@(thumbnailSize.width) h:@(thumbnailSize.height) bytes:thumbnailData];
            return [Secret23_DecryptedMessageMedia decryptedMessageMediaExternalDocumentWithPid:@(n_id) accessHash:@(accessHash) date:@(date) mimeType:mimeType == nil ? @"" : mimeType size:@(size) thumb:cachedSize dcId:@(dcId) attributes:[self convertDocumentAttributes:attributes toLayer:layer]];
        }
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
        if ([self.preparedMessage isKindOfClass:[TGPreparedTextMessage class]])
        {
            [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
            
            TGPreparedTextMessage *textMessage = (TGPreparedTextMessage *)self.preparedMessage;
            
            int64_t randomId = self.preparedMessage.randomId;
            if (randomId == 0)
                arc4random_buf(&randomId, 8);
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:textMessage.text media:nil lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:nil watcher:self];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedMapMessage class]])
        {
            [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
            
            TGPreparedMapMessage *mapMessage = (TGPreparedMapMessage *)self.preparedMessage;
            
            id media = [self decryptedGeoPointWithLayer:[self currentPeerLayer] latitude:mapMessage.latitude longitude:mapMessage.longitude];
            
            int64_t randomId = self.preparedMessage.randomId;
            if (randomId == 0)
                arc4random_buf(&randomId, 8);
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:nil watcher:self];
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
        else if ([self.preparedMessage isKindOfClass:[TGPreparedRemoteDocumentMessage class]])
        {
            TGPreparedRemoteDocumentMessage *preparedDocument = (TGPreparedRemoteDocumentMessage *)self.preparedMessage;
            
            [self setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
            
            CGSize thumSize = CGSizeZero;
            NSString *thumbnailUri = [preparedDocument.thumbnailInfo imageUrlForLargestSize:&thumSize];
            NSData *thumbnailData = [NSData dataWithContentsOfFile:[[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:preparedDocument.documentId] stringByAppendingPathComponent:@"thumbnail"]];
            if (thumbnailData == nil)
            {
                thumbnailData = [NSData dataWithContentsOfFile:[[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:preparedDocument.documentId] stringByAppendingPathComponent:@"thumbnail-high"]];
            }
            
            if (thumbnailData != nil)
            {
                id media = [self decryptedExternalDocumentWithLayer:[self currentPeerLayer] id:preparedDocument.documentId accessHash:preparedDocument.accessHash date:preparedDocument.date mimeType:preparedDocument.mimeType size:preparedDocument.size thumbnailUri:thumbnailUri thumbnailData:thumbnailData thumbnailSize:thumSize dcId:preparedDocument.datacenterId attributes:preparedDocument.attributes];
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                
                _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:nil watcher:self];
            }
            else
                [self _fail];
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
                
                _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:preparedForwardedMessage.innerMessage.text media:nil lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:nil watcher:self];
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
            
            NSString *documentPath = [self filePathForLocalDocumentId:downloadDocumentMessage.localDocumentId attributes:downloadDocumentMessage.attributes];
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
            else
            {
                [self setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
                self.uploadProgressContainsPreDownloads = true;
                
                NSString *path = [[NSString alloc] initWithFormat:@"/iCloudDownload/(%@)", [TGStringUtils stringByEscapingForActorURL:cloudDocumentMessage.documentUrl.absoluteString]];
                [ActionStageInstance() requestActor:path options:@{@"url": cloudDocumentMessage.documentUrl, @"path": documentPath, @"queue": @"messagePreDownloads"} flags:0 watcher:self];
                
                [self beginUploadProgress];
            }
        }
        else
            [self _fail];
    }
}

- (void)_fail
{
    std::vector<TGDatabaseMessageFlagValue> flags;
    flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDeliveryState, .value = TGMessageDeliveryStateFailed});
    [TGDatabaseInstance() updateMessage:self.preparedMessage.mid peerId:0 flags:flags media:nil dispatch:true];
    
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
        NSString *documentsDirectory = [TGAppDelegate documentsPath];
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
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
            return true;
        }
        else
            return false;
    }
    else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
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
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
            return true;
        }
        else
            return false;
    }
    else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
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
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
            return true;
        }
        else
            return false;
    }
    else if ([attachment isKindOfClass:[TGAudioMediaAttachment class]])
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
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
            return true;
        }
        else
            return false;
    }
    else if ([attachment isKindOfClass:[TGLocationMediaAttachment class]])
    {
        [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
        
        TGLocationMediaAttachment *locationAttachment = attachment;
        
        id media = [self decryptedGeoPointWithLayer:[self currentPeerLayer] latitude:locationAttachment.latitude longitude:locationAttachment.longitude];
        
        int64_t randomId = self.preparedMessage.randomId;
        if (randomId == 0)
            arc4random_buf(&randomId, 8);
        
        _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:nil watcher:self];
        return true;
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
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
        }
        else
            [self _fail];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalVideoMessage class]])
    {
        TGPreparedLocalVideoMessage *localVideoMessage = (TGPreparedLocalVideoMessage *)self.preparedMessage;
        
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
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
        }
        else
            [self _fail];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalDocumentMessage class]])
    {
        TGPreparedLocalDocumentMessage *localDocumentMessage = (TGPreparedLocalDocumentMessage *)self.preparedMessage;
        
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
            
            NSString *filename = @"file";
            for (id attribute in localDocumentMessage.attributes)
            {
                if ([attribute isKindOfClass:[TGDocumentAttributeFilename class]])
                    filename = ((TGDocumentAttributeFilename *)attribute).filename;
            }
            
            id media = [self decryptedDocumentWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize fileName:filename mimeType:localDocumentMessage.mimeType size:localDocumentMessage.size key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
            
            
            _sentDecryptedDocumentSize = localDocumentMessage.size;
            _sendDecryptedDocumentKey = fileInfo[@"key"];
            _sendDecryptedDocumentIv = fileInfo[@"iv"];
            
            int64_t randomId = self.preparedMessage.randomId;
            if (randomId == 0)
                arc4random_buf(&randomId, 8);
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
        }
        else
            [self _fail];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalAudioMessage class]])
    {
        TGPreparedLocalAudioMessage *localAudioMessage = (TGPreparedLocalAudioMessage *)self.preparedMessage;
        
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
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
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
                
                _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
            }
            else
                [self _fail];
        }
        else
            [self _fail];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadDocumentMessage class]] || [self.preparedMessage isKindOfClass:[TGPreparedCloudDocumentMessage class]])
    {
        TGPreparedDownloadDocumentMessage *downloadDocumentMessage = (TGPreparedDownloadDocumentMessage *)self.preparedMessage;
        
        NSDictionary *fileInfo = filePathToUploadedFile[@"embedded-data://0"];
        if (fileInfo != nil)
        {
            NSData *thumbnailData = nil;
            CGSize thumbnailSize = CGSizeZero;
            
            if (downloadDocumentMessage.thumbnailInfo != nil)
            {
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:[self filePathForLocalDocumentId:downloadDocumentMessage.localDocumentId attributes:downloadDocumentMessage.attributes]];
                if (image != nil)
                {
                    CGSize thumbSize = TGFitSize(image.size, CGSizeMake(90, 90));
                    thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(image, thumbSize), 0.6f);
                    
                    if (thumbnailData != nil)
                        thumbnailSize = thumbSize;
                }
            }
            
            NSString *fileName = @"file";
            for (id attribute in downloadDocumentMessage.attributes)
            {
                if ([attribute isKindOfClass:[TGDocumentAttributeFilename class]])
                {
                    fileName = ((TGDocumentAttributeFilename *)attribute).filename;
                    break;
                }
            }
            
            id media = [self decryptedDocumentWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize fileName:fileName mimeType:downloadDocumentMessage.mimeType size:downloadDocumentMessage.size key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
            
            
            _sentDecryptedDocumentSize = downloadDocumentMessage.size;
            _sendDecryptedDocumentKey = fileInfo[@"key"];
            _sendDecryptedDocumentIv = fileInfo[@"iv"];
            
            int64_t randomId = self.preparedMessage.randomId;
            if (randomId == 0)
                arc4random_buf(&randomId, 8);
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media lifetime:self.preparedMessage.messageLifetime randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
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
            documentAttachment.attributes = localDocumentMessage.attributes;
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
            documentAttachment.attributes = downloadDocumentMessage.attributes;
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
    [TGDatabaseInstance() updateMessage:self.preparedMessage.mid peerId:0 flags:flags media:messageMedia dispatch:true];
    
    TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:self.preparedMessage.mid peerId:_conversationId];
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
            messageData = [Secret1__Environment serializeObject:[Secret1_DecryptedMessage decryptedMessageWithRandomId:@(randomId) randomBytes:randomBytesData message:text media:media != nil ? media : [Secret1_DecryptedMessageMedia decryptedMessageMediaEmpty]]];
            break;
        case 17:
            messageData = [Secret17__Environment serializeObject:[Secret17_DecryptedMessage decryptedMessageWithRandomId:@(randomId) ttl:@(lifetime) message:text media:media != nil ? media : [Secret17_DecryptedMessageMedia decryptedMessageMediaEmpty]]];
            break;
        case 20:
            messageData = [Secret20__Environment serializeObject:[Secret20_DecryptedMessage decryptedMessageWithRandomId:@(randomId) ttl:@(lifetime) message:text media:media != nil ? media : [Secret20_DecryptedMessageMedia decryptedMessageMediaEmpty]]];
            break;
        case 23:
            messageData = [Secret23__Environment serializeObject:[Secret23_DecryptedMessage decryptedMessageWithRandomId:@(randomId) ttl:@(lifetime) message:text media:media != nil ? media : [Secret23_DecryptedMessageMedia decryptedMessageMediaEmpty]]];
            break;
        default:
            break;
    }
    
    return messageData;
}

+ (int32_t)enqueueOutgoingMessageForPeerId:(int64_t)peerId layer:(NSUInteger)layer keyId:(int64_t)keyId randomId:(int64_t)randomId messageData:(NSData *)messageData storedFileInfo:(TGStoredOutgoingMessageFileInfo *)storedFileInfo watcher:(id)watcher
{
    if (keyId == 0)
        [TGDatabaseInstance() encryptionKeyForConversationId:peerId requestedKeyFingerprint:0 outKeyFingerprint:&keyId];
    
    TGLog(@"enqueueOutgoingMessageForPeerId:%lld layer:%d keyId:%lld randomId:%lld messageData:<%d bytes> storedFileInfo:%@", peerId, (int)layer, keyId, randomId, (int)messageData.length, storedFileInfo);
    
    int32_t actionId = 0;
    [TGDatabaseInstance() enqueuePeerOutgoingAction:peerId action:[[TGStoredOutgoingMessageSecretAction alloc] initWithRandomId:randomId layer:layer keyId:keyId data:messageData fileInfo:storedFileInfo] useSeq:layer >= 17 seqOut:NULL seqIn:NULL actionId:&actionId];
    
    NSString *path = [[NSString alloc] initWithFormat:@"/tg/secret/outgoing/(%" PRId64 ")", peerId];
    [ActionStageInstance() requestActor:path options:@{@"peerId": @(peerId)} watcher:TGTelegraphInstance];
    if (watcher != nil)
        [ActionStageInstance() requestActor:path options:nil watcher:watcher];
    
    return actionId;
}

+ (int32_t)enqueueOutgoingServiceMessageForPeerId:(int64_t)peerId layer:(NSUInteger)layer keyId:(int64_t)keyId randomId:(int64_t)randomId messageData:(NSData *)messageData
{
    if (keyId == 0)
        [TGDatabaseInstance() encryptionKeyForConversationId:peerId requestedKeyFingerprint:0 outKeyFingerprint:&keyId];
    int32_t seqOut = 0;
    [TGDatabaseInstance() enqueuePeerOutgoingAction:peerId action:[[TGStoredOutgoingServiceMessageSecretAction alloc] initWithRandomId:randomId layer:layer keyId:keyId data:messageData] useSeq:layer >= 17 seqOut:&seqOut seqIn:NULL actionId:NULL];
    
    TGLog(@"enqueueOutgoingServiceMessageForPeerId:%lld layer:%d keyId:%lld randomId:%lld messageData:<%d bytes> = seqOut: %d", peerId, (int)layer, keyId, randomId, (int)messageData.length, (int)seqOut);
    
    NSString *path = [[NSString alloc] initWithFormat:@"/tg/secret/outgoing/(%" PRId64 ")", peerId];
    [ActionStageInstance() requestActor:path options:@{@"peerId": @(peerId)} watcher:TGTelegraphInstance];
    
    return seqOut;
}

+ (void)enqueueOutgoingResendMessagesForPeerId:(int64_t)peerId fromSeq:(int32_t)fromSeq toSeq:(int32_t)toSeq
{
    TGLog(@"enqueueOutgoingResendMessagesForPeerId:%lld fromSeq:%d toSeq:%d", peerId, fromSeq, toSeq);
    
    [TGDatabaseInstance() enqueuePeerOutgoingResendActions:peerId fromSeq:fromSeq toSeq:toSeq completion:^(bool success)
    {
    TGLog(@"enqueueOutgoingResendMessagesForPeerId:%lld fromSeq:%d toSeq:%d == %d", peerId, fromSeq, toSeq, (int)success);
        
        if (!success)
        {
            int64_t encryptedChatId = [TGDatabaseInstance() encryptedConversationIdForPeerId:peerId];
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/encrypted/discardEncryptedChat/(%lld)", encryptedChatId] options:@{@"encryptedConversationId": @(encryptedChatId)} flags:0 watcher:TGTelegraphInstance];
        }
        
        NSString *path = [[NSString alloc] initWithFormat:@"/tg/secret/outgoing/(%" PRId64 ")", peerId];
        [ActionStageInstance() requestActor:path options:@{@"peerId": @(peerId)} watcher:TGTelegraphInstance];
    }];
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

+ (void)enqueueIncomingEncryptedMessagesByPeerId:(NSDictionary *)messageByPeerId
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [messageByPeerId enumerateKeysAndObjectsUsingBlock:^(NSNumber *nPeerId, NSArray *actions, __unused BOOL *stop)
        {
            int64_t peerId = (int64_t)[nPeerId longLongValue];
            
            [TGDatabaseInstance() enqueuePeerIncomingEncryptedActions:peerId actions:actions];
            
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

+ (void)maybeRekeyPeerId:(int64_t)peerId
{
    TGLog(@"maybeRekeyPeerId:%lld", peerId);
    
    [TGDatabaseInstance() dispatchOnDatabaseThread:^
    {
        TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:peerId];
         TLmessages_DhConfig$messages_dhConfig *config = [TGRequestEncryptedChatActor cachedEncryptionConfig];
        int64_t encryptedConversationId = [TGDatabaseInstance() encryptedConversationIdForPeerId:peerId];
        if (encryptedConversationId != 0 && conversation.encryptedData.keyFingerprint != 0 && conversation.encryptedData.currentRekeyExchangeId == 0 && config != nil)
        {
            uint8_t rawABytes[256];
            SecRandomCopyBytes(kSecRandomDefault, 256, rawABytes);
            
            for (int i = 0; i < 256 && i < (int)config.random.length; i++)
            {
                uint8_t currentByte = ((uint8_t *)config.random.bytes)[i];
                rawABytes[i] ^= currentByte;
            }
            
            NSData * aBytes = [[NSData alloc] initWithBytes:rawABytes length:256];
            
            int32_t tmpG = config.g;
            tmpG = NSSwapInt(tmpG);
            NSData *g = [[NSData alloc] initWithBytes:&tmpG length:4];
            
            NSData *g_a = MTExp(g, aBytes, config.p);
            
            if (!MTCheckIsSafeGAOrB(g_a, config.p))
            {
                TGLog(@"Surprisingly, we generated an unsafe g_a");
                return;
            }
            
            conversation = [conversation copy];
            TGEncryptedConversationData *encryptedData = [conversation.encryptedData copy];
            int64_t currentRekeyExchangeId = 0;
            arc4random_buf(&currentRekeyExchangeId, 8);
            encryptedData.currentRekeyExchangeId = currentRekeyExchangeId;
            encryptedData.currentRekeyIsInitiatedByLocalClient = true;
            encryptedData.currentRekeyNumber = aBytes;
            conversation.encryptedData = encryptedData;
            [TGDatabaseInstance() addMessagesToConversation:nil conversationId:peerId updateConversation:conversation dispatch:true countUnread:false];
            
            int64_t actionRandomId = 0;
            arc4random_buf(&actionRandomId, 8);
            
            NSUInteger peerLayer = [TGDatabaseInstance() peerLayer:peerId];
            
            NSData *messageData = [self decryptedServiceMessageActionWithLayer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) requestKey:currentRekeyExchangeId g_a:g_a randomId:actionRandomId];
            
            if (messageData != nil)
            {
                [TGModernSendSecretMessageActor enqueueOutgoingServiceMessageForPeerId:peerId layer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) keyId:0 randomId:actionRandomId messageData:messageData];
            }
        }
    } synchronous:false];
}

+ (NSData *)encryptMessage:(NSData *)serializedMessage key:(NSData *)key keyId:(int64_t)keyId
{
    if (serializedMessage == nil)
        return nil;
    NSMutableData *decryptedBytesOriginal = [serializedMessage mutableCopy];
    int32_t messageLength = (int32_t)decryptedBytesOriginal.length;
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
            messageData = [Secret1__Environment serializeObject:[Secret1_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) randomBytes:randomBytesData action:[Secret1_DecryptedMessageAction decryptedMessageActionSetMessageTTLWithTtlSeconds:@(ttl)]]];
            break;
        case 17:
            messageData = [Secret17__Environment serializeObject:[Secret17_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret17_DecryptedMessageAction decryptedMessageActionSetMessageTTLWithTtlSeconds:@(ttl)]]];
            break;
        case 20:
            messageData = [Secret20__Environment serializeObject:[Secret20_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret20_DecryptedMessageAction decryptedMessageActionSetMessageTTLWithTtlSeconds:@(ttl)]]];
            break;
        case 23:
            messageData = [Secret23__Environment serializeObject:[Secret23_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret23_DecryptedMessageAction decryptedMessageActionSetMessageTTLWithTtlSeconds:@(ttl)]]];
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
            messageData = [Secret1__Environment serializeObject:[Secret1_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) randomBytes:randomBytesData action:[Secret1_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandomIds:randomIds]]];
            break;
        case 17:
            messageData = [Secret17__Environment serializeObject:[Secret17_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret17_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandomIds:randomIds]]];
            break;
        case 20:
            messageData = [Secret20__Environment serializeObject:[Secret20_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret20_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandomIds:randomIds]]];
            break;
        case 23:
            messageData = [Secret23__Environment serializeObject:[Secret23_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret23_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandomIds:randomIds]]];
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
            messageData = [Secret1__Environment serializeObject:[Secret1_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) randomBytes:randomBytesData action:[Secret1_DecryptedMessageAction decryptedMessageActionFlushHistory]]];
            break;
        case 17:
            messageData = [Secret17__Environment serializeObject:[Secret17_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret17_DecryptedMessageAction decryptedMessageActionFlushHistory]]];
            break;
        case 20:
            messageData = [Secret20__Environment serializeObject:[Secret20_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret20_DecryptedMessageAction decryptedMessageActionFlushHistory]]];
            break;
        case 23:
            messageData = [Secret23__Environment serializeObject:[Secret23_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret23_DecryptedMessageAction decryptedMessageActionFlushHistory]]];
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
            messageData = [Secret17__Environment serializeObject:[Secret17_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret17_DecryptedMessageAction decryptedMessageActionReadMessagesWithRandomIds:randomIds]]];
            break;
        case 20:
            messageData = [Secret20__Environment serializeObject:[Secret20_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret20_DecryptedMessageAction decryptedMessageActionReadMessagesWithRandomIds:randomIds]]];
            break;
        case 23:
            messageData = [Secret23__Environment serializeObject:[Secret23_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret23_DecryptedMessageAction decryptedMessageActionReadMessagesWithRandomIds:randomIds]]];
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
            messageData = [Secret17__Environment serializeObject:[Secret17_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret17_DecryptedMessageAction decryptedMessageActionScreenshotMessagesWithRandomIds:randomIds]]];
            break;
        case 20:
            messageData = [Secret20__Environment serializeObject:[Secret20_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret20_DecryptedMessageAction decryptedMessageActionScreenshotMessagesWithRandomIds:randomIds]]];
            break;
        case 23:
            messageData = [Secret23__Environment serializeObject:[Secret23_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret23_DecryptedMessageAction decryptedMessageActionScreenshotMessagesWithRandomIds:randomIds]]];
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
            messageData = [Secret1__Environment serializeObject:[Secret1_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) randomBytes:randomBytesData action:[Secret1_DecryptedMessageAction decryptedMessageActionNotifyLayerWithLayer:@(notifyLayer)]]];
            break;
        case 17:
            messageData = [Secret17__Environment serializeObject:[Secret17_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret17_DecryptedMessageAction decryptedMessageActionNotifyLayerWithLayer:@(notifyLayer)]]];
            break;
        case 20:
            messageData = [Secret20__Environment serializeObject:[Secret20_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret20_DecryptedMessageAction decryptedMessageActionNotifyLayerWithLayer:@(notifyLayer)]]];
            break;
        case 23:
            messageData = [Secret23__Environment serializeObject:[Secret23_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret23_DecryptedMessageAction decryptedMessageActionNotifyLayerWithLayer:@(notifyLayer)]]];
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
            messageData = [Secret17__Environment serializeObject:[Secret17_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret17_DecryptedMessageAction decryptedMessageActionResendWithStartSeqNo:@(fromSeq) endSeqNo:@(toSeq)]]];
            break;
        case 20:
            messageData = [Secret20__Environment serializeObject:[Secret20_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret20_DecryptedMessageAction decryptedMessageActionResendWithStartSeqNo:@(fromSeq) endSeqNo:@(toSeq)]]];
            break;
        case 23:
            messageData = [Secret23__Environment serializeObject:[Secret23_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret23_DecryptedMessageAction decryptedMessageActionResendWithStartSeqNo:@(fromSeq) endSeqNo:@(toSeq)]]];
            break;
        default:
            break;
    }
    
    return messageData;
}

+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer requestKey:(int64_t)exchangeId g_a:(NSData *)g_a randomId:(int64_t)randomId
{
    NSData *messageData = nil;
    
    switch (layer)
    {
        case 1: // not supported
            return nil;
        case 17: // not supported
            return nil;
        case 20:
            messageData = [Secret20__Environment serializeObject:[Secret20_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret20_DecryptedMessageAction decryptedMessageActionRequestKeyWithExchangeId:@(exchangeId) gA:g_a]]];
            break;
        case 23:
            messageData = [Secret23__Environment serializeObject:[Secret23_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret23_DecryptedMessageAction decryptedMessageActionRequestKeyWithExchangeId:@(exchangeId) gA:g_a]]];
            break;
        default:
            break;
    }
    
    return messageData;
}

+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer acceptKey:(int64_t)exchangeId g_b:(NSData *)g_b keyFingerprint:(int64_t)keyFingerprint randomId:(int64_t)randomId
{
    NSData *messageData = nil;
    
    switch (layer)
    {
        case 1: // not supported
            return nil;
        case 17: // not supported
            return nil;
        case 20:
            messageData = [Secret20__Environment serializeObject:[Secret20_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret20_DecryptedMessageAction decryptedMessageActionAcceptKeyWithExchangeId:@(exchangeId) gB:g_b keyFingerprint:@(keyFingerprint)]]];
            break;
        case 23:
            messageData = [Secret23__Environment serializeObject:[Secret23_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret23_DecryptedMessageAction decryptedMessageActionAcceptKeyWithExchangeId:@(exchangeId) gB:g_b keyFingerprint:@(keyFingerprint)]]];
            break;
        default:
            break;
    }
    
    return messageData;
}

+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer commitKey:(int64_t)exchangeId keyFingerprint:(int64_t)keyFingerprint randomId:(int64_t)randomId
{
    NSData *messageData = nil;
    
    switch (layer)
    {
        case 1: // not supported
            return nil;
        case 17: // not supported
            return nil;
        case 20:
            messageData = [Secret20__Environment serializeObject:[Secret20_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret20_DecryptedMessageAction decryptedMessageActionCommitKeyWithExchangeId:@(exchangeId) keyFingerprint:@(keyFingerprint)]]];
            break;
        case 23:
            messageData = [Secret23__Environment serializeObject:[Secret23_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret23_DecryptedMessageAction decryptedMessageActionCommitKeyWithExchangeId:@(exchangeId) keyFingerprint:@(keyFingerprint)]]];
            break;
        default:
            break;
    }
    
    return messageData;
}

+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer abortKey:(int64_t)exchangeId randomId:(int64_t)randomId
{
    NSData *messageData = nil;
    
    switch (layer)
    {
        case 1: // not supported
            return nil;
        case 17: // not supported
            return nil;
        case 20:
            messageData = [Secret20__Environment serializeObject:[Secret20_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret20_DecryptedMessageAction decryptedMessageActionAbortKeyWithExchangeId:@(exchangeId)]]];
            break;
        case 23:
            messageData = [Secret23__Environment serializeObject:[Secret23_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret23_DecryptedMessageAction decryptedMessageActionAbortKeyWithExchangeId:@(exchangeId)]]];
            break;
        default:
            break;
    }
    
    return messageData;
}

+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer noopRandomId:(int64_t)randomId
{
    NSData *messageData = nil;
    
    switch (layer)
    {
        case 1: // not supported
            return nil;
        case 17: // not supported
            return nil;
        case 20:
            messageData = [Secret20__Environment serializeObject:[Secret20_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret20_DecryptedMessageAction decryptedMessageActionNoop]]];
            break;
        case 23:
            messageData = [Secret23__Environment serializeObject:[Secret23_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret23_DecryptedMessageAction decryptedMessageActionNoop]]];
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
    else if ([path hasPrefix:@"/temporaryDownload/"] || [path hasPrefix:@"/iCloudDownload/"])
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
        
        NSMutableArray *files = [[NSMutableArray alloc] init];
        [files addObject:@[data, @"bin", @(true)]];
        [self uploadFilesWithExtensions:files];
    }
    else
        [self _fail];
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

@end
