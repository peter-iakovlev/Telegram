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
#import "TGPreparedDownloadImageMessage.h"
#import "TGPreparedDownloadDocumentMessage.h"
#import "TGPreparedCloudDocumentMessage.h"
#import "TGPreparedDownloadExternalGifMessage.h"
#import "TGPreparedDownloadExternalImageMessage.h"
#import "TGPreparedAssetImageMessage.h"
#import "TGPreparedAssetVideoMessage.h"

#import "TGLinkPreviewsContentProperty.h"

#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"
#import "TGDatabase.h"

#import "TGRemoteImageView.h"
#import "TGImageDownloadActor.h"
#import "TGVideoDownloadActor.h"

#import "TGMediaAssetsLibrary.h"
#import "TGMediaAssetImageSignals.h"
#import "TGVideoConverter.h"
#import "TGVideoEditAdjustments.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGFileUtils.h"

#import "TGMessage+Telegraph.h"

#import "TGMediaStoreContext.h"

#import "PSLMDBKeyValueStore.h"

#import "TLMessage$modernMessage.h"
#import "TLMessage$modernMessageService.h"
#import "TLUpdates$updateShortSentMessage.h"

#import "TLUpdates+TG.h"

#import "UIImage+TG.h"

#import <WebP/decode.h>

#import "TGAppDelegate.h"

#import "TGChannelManagementSignals.h"

#import "TGAlertView.h"

#import "TGWebpageSignals.h"

#import "TGBotContextResultAttachment.h"

#import "TGRecentGifsSignal.h"

#import <CommonCrypto/CommonDigest.h>

#import "TGDocumentMediaAttachment+Telegraph.h"

#import "TLDocumentAttribute$documentAttributeAudio.h"

@interface TGModernSendCommonMessageActor ()
{
    int64_t _conversationId;
    int64_t _accessHash;
    bool _postAsChannel;
    bool _notifyMembers;
    
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
    _notifyMembers = [options[@"notifyMembers"] boolValue];
    if (options[@"sendActivity"] != nil) {
        self.sendActivity = [options[@"sendActivity"] boolValue];
    } else {
        self.sendActivity = true;
    }
}

- (int64_t)peerId
{
    return _conversationId;
}

- (int64_t)conversationIdForActivity
{
    return _conversationId;
}

- (int64_t)accessHashForActivity {
    return _accessHash;
}

- (NSArray *)convertEntities:(NSArray *)entities {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (TGMessageEntity *entity in entities) {
        if ([entity isKindOfClass:[TGMessageEntityBold class]]) {
            TLMessageEntity$messageEntityBold *boldEntity = [[TLMessageEntity$messageEntityBold alloc] init];
            boldEntity.offset = (int32_t)entity.range.location;
            boldEntity.length = (int32_t)entity.range.length;
            [result addObject:boldEntity];
        } else if ([entity isKindOfClass:[TGMessageEntityBotCommand class]]) {
            TLMessageEntity$messageEntityBotCommand *botCommandEntity = [[TLMessageEntity$messageEntityBotCommand alloc] init];
            botCommandEntity.offset = (int32_t)entity.range.location;
            botCommandEntity.length = (int32_t)entity.range.length;
            [result addObject:botCommandEntity];
        } else if ([entity isKindOfClass:[TGMessageEntityCode class]]) {
            TLMessageEntity$messageEntityCode *codeEntity = [[TLMessageEntity$messageEntityCode alloc] init];
            codeEntity.offset = (int32_t)entity.range.location;
            codeEntity.length = (int32_t)entity.range.length;
            [result addObject:codeEntity];
        } else if ([entity isKindOfClass:[TGMessageEntityEmail class]]) {
            TLMessageEntity$messageEntityEmail *emailEntity = [[TLMessageEntity$messageEntityEmail alloc] init];
            emailEntity.offset = (int32_t)entity.range.location;
            emailEntity.length = (int32_t)entity.range.length;
            [result addObject:emailEntity];
        } else if ([entity isKindOfClass:[TGMessageEntityHashtag class]]) {
            TLMessageEntity$messageEntityHashtag *hashtagEntity = [[TLMessageEntity$messageEntityHashtag alloc] init];
            hashtagEntity.offset = (int32_t)entity.range.location;
            hashtagEntity.length = (int32_t)entity.range.length;
            [result addObject:hashtagEntity];
        } else if ([entity isKindOfClass:[TGMessageEntityItalic class]]) {
            TLMessageEntity$messageEntityItalic *italicEntity = [[TLMessageEntity$messageEntityItalic alloc] init];
            italicEntity.offset = (int32_t)entity.range.location;
            italicEntity.length = (int32_t)entity.range.length;
            [result addObject:italicEntity];
        } else if ([entity isKindOfClass:[TGMessageEntityMention class]]) {
            TLMessageEntity$messageEntityMention *mentionEntity = [[TLMessageEntity$messageEntityMention alloc] init];
            mentionEntity.offset = (int32_t)entity.range.location;
            mentionEntity.length = (int32_t)entity.range.length;
            [result addObject:mentionEntity];
        } else if ([entity isKindOfClass:[TGMessageEntityPre class]]) {
            TLMessageEntity$messageEntityPre *preEntity = [[TLMessageEntity$messageEntityPre alloc] init];
            preEntity.offset = (int32_t)entity.range.location;
            preEntity.length = (int32_t)entity.range.length;
            [result addObject:preEntity];
        } else if ([entity isKindOfClass:[TGMessageEntityTextUrl class]]) {
            TLMessageEntity$messageEntityTextUrl *textUrlEntity = [[TLMessageEntity$messageEntityTextUrl alloc] init];
            textUrlEntity.url = ((TGMessageEntityTextUrl *)entity).url;
            textUrlEntity.offset = (int32_t)entity.range.location;
            textUrlEntity.length = (int32_t)entity.range.length;
            [result addObject:textUrlEntity];
        } else if ([entity isKindOfClass:[TGMessageEntityUrl class]]) {
            TLMessageEntity$messageEntityUrl *urlEntity = [[TLMessageEntity$messageEntityUrl alloc] init];
            urlEntity.offset = (int32_t)entity.range.location;
            urlEntity.length = (int32_t)entity.range.length;
            [result addObject:urlEntity];
        }
    }
    return result;
}

- (void)_commitSend
{
    if (_conversationId == 0)
        [self _fail];
    else
    {
        if (self.preparedMessage.botContextResult != nil) {
            self.cancelToken = [TGTelegraphInstance doConversationBotContextResult:_conversationId accessHash:_accessHash botContextResult:self.preparedMessage.botContextResult tmpId:self.preparedMessage.randomId replyMessageId:self.preparedMessage.replyMessage.mid postAsChannel:_postAsChannel notifyMembers:_notifyMembers actor:self];
        } else if ([self.preparedMessage isKindOfClass:[TGPreparedTextMessage class]]) {
            TGPreparedTextMessage *textMessage = (TGPreparedTextMessage *)self.preparedMessage;
            
            if (self.preparedMessage.randomId != 0 && self.preparedMessage.mid != 0) {
                [TGDatabaseInstance() setTempIdForMessageId:textMessage.mid peerId:_conversationId tempId:textMessage.randomId];
            }
            
            [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
            
            _shouldPostAlmostDeliveredMessage = true;
            
            self.cancelToken = [TGTelegraphInstance doConversationSendMessage:_conversationId accessHash:_accessHash messageText:textMessage.text messageGuid:nil tmpId:textMessage.randomId replyMessageId:textMessage.replyMessage.mid disableLinkPreviews:textMessage.disableLinkPreviews postAsChannel:_postAsChannel notifyMembers:_notifyMembers entities:[self convertEntities:textMessage.entities] actor:self];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedMapMessage class]])
        {
            TGPreparedMapMessage *mapMessage = (TGPreparedMapMessage *)self.preparedMessage;

            [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
            self.cancelToken = [TGTelegraphInstance doConversationSendLocation:_conversationId accessHash:_accessHash latitude:mapMessage.latitude longitude:mapMessage.longitude venue:mapMessage.venue messageGuid:nil tmpId:mapMessage.randomId replyMessageId:mapMessage.replyMessage.mid postAsChannel:_postAsChannel notifyMembers:_notifyMembers actor:self];
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
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:remotePhoto messageGuid:nil tmpId:remoteImageMessage.randomId replyMessageId:remoteImageMessage.replyMessage.mid postAsChannel:_postAsChannel notifyMembers:_notifyMembers actor:self];
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
            
            TLInputMedia$inputMediaDocument *remoteDocument = [[TLInputMedia$inputMediaDocument alloc] init];
            TLInputDocument$inputDocument *inputDocument = [[TLInputDocument$inputDocument alloc] init];
            inputDocument.n_id = remoteVideoMessage.videoId;
            inputDocument.access_hash = remoteVideoMessage.accessHash;
            remoteDocument.n_id = inputDocument;
            remoteDocument.caption = remoteVideoMessage.caption;
            
            [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:remoteDocument messageGuid:nil tmpId:remoteVideoMessage.randomId replyMessageId:remoteVideoMessage.replyMessage.mid postAsChannel:_postAsChannel notifyMembers:_notifyMembers actor:self];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalDocumentMessage class]])
        {
            TGPreparedLocalDocumentMessage *localDocumentMessage = (TGPreparedLocalDocumentMessage *)self.preparedMessage;
            
            bool locateByHash = true;
            for (id attribute in localDocumentMessage.attributes) {
                if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                    if (((TGDocumentAttributeAudio *)attribute).isVoice) {
                        locateByHash = false;
                    }
                }
            }
            
            SSignal *locateSignal = [SSignal single:nil];
            
            if (locateByHash) {
                NSData *documentData = [NSData dataWithContentsOfFile:[[localDocumentMessage localDocumentDirectory] stringByAppendingPathComponent:[localDocumentMessage localDocumentFileName]] options:NSDataReadingMappedIfSafe error:nil];
                
                TLRPCmessages_getDocumentByHash$messages_getDocumentByHash *getDocumentByHash = [[TLRPCmessages_getDocumentByHash$messages_getDocumentByHash alloc] init];
                
                CC_SHA256_CTX ctx;
                CC_SHA256_Init(&ctx);
                
                int32_t length = (int32_t)documentData.length;
                for (int32_t offset = 0; offset < length; offset += 128 * 1024) {
                    CC_SHA256_Update(&ctx, ((uint8_t *)documentData.bytes) + offset, MIN(length - offset, 128 * 1024));
                }
                
                uint8_t digest[CC_SHA256_DIGEST_LENGTH];
                CC_SHA256_Final(digest, &ctx);
                
                getDocumentByHash.sha256 = [[NSData alloc] initWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
                getDocumentByHash.mime_type = localDocumentMessage.mimeType;
                getDocumentByHash.size = (int32_t)documentData.length;
                
                TGLog(@"getDocumentByHash hash: %@", getDocumentByHash.sha256);
                
                locateSignal = [[TGTelegramNetworking instance] requestSignal:getDocumentByHash];
            }
            
            __weak TGModernSendCommonMessageActor *weakSelf = self;
            [self.disposables add:[[locateSignal deliverOn:[SQueue wrapConcurrentNativeQueue:[ActionStageInstance() globalStageDispatchQueue]]] startWithNext:^(TLDocument *result) {
                __strong TGModernSendCommonMessageActor *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    if ([result isKindOfClass:[TLDocument$document class]]) {
                        TGDocumentMediaAttachment *documentAttachment = [[TGDocumentMediaAttachment alloc] initWithTelegraphDocumentDesc:result];
                        
                        TLInputMedia$inputMediaDocument *remoteDocument = [[TLInputMedia$inputMediaDocument alloc] init];
                        TLInputDocument$inputDocument *inputDocument = [[TLInputDocument$inputDocument alloc] init];
                        inputDocument.n_id = documentAttachment.documentId;
                        inputDocument.access_hash = documentAttachment.accessHash;
                        remoteDocument.caption = documentAttachment.caption;
                        remoteDocument.n_id = inputDocument;
                        
                        [strongSelf setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
                        strongSelf.cancelToken = [TGTelegraphInstance doConversationSendMedia:strongSelf->_conversationId accessHash:strongSelf->_accessHash media:remoteDocument messageGuid:nil tmpId:strongSelf.preparedMessage.randomId replyMessageId:strongSelf.preparedMessage.replyMessage.mid postAsChannel:strongSelf->_postAsChannel notifyMembers:strongSelf->_notifyMembers actor:strongSelf];
                    } else {
                        [strongSelf setupFailTimeout:[TGModernSendCommonMessageActor defaultTimeoutInterval]];
                        
                        NSMutableArray *uploadFiles = [[NSMutableArray alloc] init];
                        
                        NSMutableArray *desc = [[NSMutableArray alloc] init];
                        [desc addObjectsFromArray:@[
                                                    [[localDocumentMessage localDocumentDirectory] stringByAppendingPathComponent:[localDocumentMessage localDocumentFileName]], @"bin", @(true)
                                                    ]];
                        if (localDocumentMessage.liveUploadData != nil)
                            [desc addObject:localDocumentMessage.liveUploadData];
                        
                        [uploadFiles addObject:desc];
                        
                        if (localDocumentMessage.localThumbnailDataPath != nil)
                        {
                            UIImage *image = [[UIImage alloc] initWithContentsOfFile:[strongSelf pathForLocalImagePath:localDocumentMessage.localThumbnailDataPath]];
                            if (image != nil)
                            {
                                NSData *thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(image, TGFitSize(image.size, CGSizeMake(90, 90))), 0.6f);
                                if (thumbnailData != nil)
                                    [uploadFiles addObject:@[thumbnailData, @"jpg", @(false)]];
                            }
                        }
                        
                        [strongSelf uploadFilesWithExtensions:uploadFiles];
                    }
                }
            } error:^(__unused id error) {
                __strong TGModernSendCommonMessageActor *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf _fail];
                }
            } completed:nil]];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedRemoteDocumentMessage class]])
        {
            TGPreparedRemoteDocumentMessage *remoteDocumentMessage = (TGPreparedRemoteDocumentMessage *)self.preparedMessage;
            
            TLInputMedia$inputMediaDocument *remoteDocument = [[TLInputMedia$inputMediaDocument alloc] init];
            TLInputDocument$inputDocument *inputDocument = [[TLInputDocument$inputDocument alloc] init];
            inputDocument.n_id = remoteDocumentMessage.documentId;
            inputDocument.access_hash = remoteDocumentMessage.accessHash;
            remoteDocument.caption = remoteDocumentMessage.caption;
            remoteDocument.n_id = inputDocument;
            
            [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:remoteDocument messageGuid:nil tmpId:remoteDocumentMessage.randomId replyMessageId:remoteDocumentMessage.replyMessage.mid postAsChannel:_postAsChannel notifyMembers:_notifyMembers actor:self];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedForwardedMessage class]])
        {
            TGPreparedForwardedMessage *forwardedMessage = (TGPreparedForwardedMessage *)self.preparedMessage;
            
            int64_t fromPeerAccessHash = 0;
            if (TGPeerIdIsChannel(forwardedMessage.forwardSourcePeerId)) {
                fromPeerAccessHash = ((TGConversation *)[TGDatabaseInstance() loadChannels:@[@(forwardedMessage.forwardSourcePeerId)]][@(forwardedMessage.forwardSourcePeerId)]).accessHash;
            }
            
            [self setupFailTimeout:[TGModernSendCommonMessageActor defaultTimeoutInterval]];
            self.cancelToken = [TGTelegraphInstance doConversationForwardMessage:_conversationId accessHash:_accessHash messageId:forwardedMessage.forwardMid fromPeer:forwardedMessage.forwardSourcePeerId fromPeerAccessHash:fromPeerAccessHash postAsChannel:_postAsChannel notifyMembers:_notifyMembers tmpId:forwardedMessage.randomId actor:self];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedContactMessage class]])
        {
            TGPreparedContactMessage *contactMessage = (TGPreparedContactMessage *)self.preparedMessage;
            
            [self setupFailTimeout:[TGModernSendCommonMessageActor defaultTimeoutInterval]];
            
            TLInputMedia$inputMediaContact *inputContact = [[TLInputMedia$inputMediaContact alloc] init];
            inputContact.first_name = contactMessage.firstName;
            inputContact.last_name = contactMessage.lastName;
            inputContact.phone_number = contactMessage.phoneNumber;
            
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:inputContact messageGuid:nil tmpId:contactMessage.randomId replyMessageId:contactMessage.replyMessage.mid postAsChannel:_postAsChannel notifyMembers:_notifyMembers actor:self];
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
        else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadExternalGifMessage class]]) {
            TGPreparedDownloadExternalGifMessage *externalGifMessage = (TGPreparedDownloadExternalGifMessage *)self.preparedMessage;
            
            __weak TGModernSendCommonMessageActor *weakSelf = self;
            [self.disposables add:[[[TGWebpageSignals webpagePreview:externalGifMessage.searchResult.url] deliverOn:[SQueue wrapConcurrentNativeQueue:[ActionStageInstance() globalStageDispatchQueue]]] startWithNext:^(TGWebPageMediaAttachment *webPage) {
                __strong TGModernSendCommonMessageActor *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    if (webPage.document != nil) {
                        TLInputMedia$inputMediaDocument *remoteDocument = [[TLInputMedia$inputMediaDocument alloc] init];
                        TLInputDocument$inputDocument *inputDocument = [[TLInputDocument$inputDocument alloc] init];
                        inputDocument.n_id = webPage.document.documentId;
                        inputDocument.access_hash = webPage.document.accessHash;
                        remoteDocument.caption = externalGifMessage.caption;
                        remoteDocument.n_id = inputDocument;
                        
                        [strongSelf setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
                        strongSelf.cancelToken = [TGTelegraphInstance doConversationSendMedia:strongSelf->_conversationId accessHash:strongSelf->_accessHash media:remoteDocument messageGuid:nil tmpId:externalGifMessage.randomId replyMessageId:externalGifMessage.replyMessage.mid postAsChannel:strongSelf->_postAsChannel notifyMembers:strongSelf->_notifyMembers actor:strongSelf];
                    } else {
                        TGLog(@"Webpage doesn't contain document");
                        [strongSelf _fail];
                    }
                }
            } error:^(__unused id error) {
                __strong TGModernSendCommonMessageActor *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    TGLog(@"Webpage fetch error");
                    [strongSelf _fail];
                }
            } completed:nil]];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadExternalImageMessage class]]) {
            TGPreparedDownloadExternalImageMessage *externalImageMessage = (TGPreparedDownloadExternalImageMessage *)self.preparedMessage;
            
            __weak TGModernSendCommonMessageActor *weakSelf = self;
            [self.disposables add:[[[TGWebpageSignals webpagePreview:externalImageMessage.searchResult.url] deliverOn:[SQueue wrapConcurrentNativeQueue:[ActionStageInstance() globalStageDispatchQueue]]] startWithNext:^(TGWebPageMediaAttachment *webPage) {
                __strong TGModernSendCommonMessageActor *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    if (webPage.photo != nil) {
                        TLInputMedia$inputMediaPhoto *inputMedia = [[TLInputMedia$inputMediaPhoto alloc] init];
                        TLInputPhoto$inputPhoto *inputPhoto = [[TLInputPhoto$inputPhoto alloc] init];
                        inputPhoto.n_id = webPage.photo.imageId;
                        inputPhoto.access_hash = webPage.photo.accessHash;
                        inputMedia.n_id = inputPhoto;
                        
                        [strongSelf setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
                        strongSelf.cancelToken = [TGTelegraphInstance doConversationSendMedia:strongSelf->_conversationId accessHash:strongSelf->_accessHash media:inputMedia messageGuid:nil tmpId:externalImageMessage.randomId replyMessageId:externalImageMessage.replyMessage.mid postAsChannel:strongSelf->_postAsChannel notifyMembers:strongSelf->_notifyMembers actor:strongSelf];
                    } else {
                        TGLog(@"Webpage doesn't contain photo");
                        [strongSelf _fail];
                    }
                }
            } error:^(__unused id error) {
                __strong TGModernSendCommonMessageActor *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    TGLog(@"Webpage fetch error");
                    [strongSelf _fail];
                }
            } completed:nil]];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedAssetImageMessage class]])
        {
            TGPreparedAssetImageMessage *assetImageMessage = (TGPreparedAssetImageMessage *)self.preparedMessage;
            [self beginUploadProgress];
            
            __weak TGModernSendCommonMessageActor *weakSelf = self;
            [self.disposables add:[[[[[[TGMediaAssetsLibrary sharedLibrary] assetWithIdentifier:assetImageMessage.assetIdentifier] mapToSignal:^SSignal *(TGMediaAsset *asset)
            {
                if (!assetImageMessage.document)
                {
                    return [[TGMediaAssetImageSignals imageForAsset:asset imageType:TGMediaAssetImageTypeScreen size:CGSizeMake(1280, 1280) allowNetworkAccess:false] catch:^SSignal *(id error)
                    {
                        if (![error isKindOfClass:[NSNumber class]] && !assetImageMessage.isCloud)
                            return [SSignal fail:error];
                        
                        self.uploadProgressContainsPreDownloads = true;
                        return [TGMediaAssetImageSignals imageForAsset:asset imageType:TGMediaAssetImageTypeScreen size:CGSizeMake(1280, 1280) allowNetworkAccess:true];
                    }];
                }
                else
                {
                    return [[TGMediaAssetImageSignals imageDataForAsset:asset allowNetworkAccess:false] catch:^SSignal *(id error)
                    {
                        if (![error isKindOfClass:[NSNumber class]] && !assetImageMessage.isCloud)
                            return [SSignal fail:error];
                        
                        self.uploadProgressContainsPreDownloads = true;
                        return [TGMediaAssetImageSignals imageDataForAsset:asset allowNetworkAccess:true];
                    }];
                }
            }] filter:^bool(id value)
            {
                if ([value isKindOfClass:[UIImage class]])
                    return !((UIImage *)value).degraded;
                    
                return true;
            }] deliverOn:[SQueue wrapConcurrentNativeQueue:[ActionStageInstance() globalStageDispatchQueue]]] startWithNext:^(id next)
            {
                __strong TGModernSendCommonMessageActor *strongSelf = weakSelf;
                if ([next isKindOfClass:[NSNumber class]])
                {
                    float value = [next floatValue];
                    [strongSelf updatePreDownloadsProgress:value];
                }
                else if ([next isKindOfClass:[UIImage class]])
                {
                    [strongSelf updatePreDownloadsProgress:1.0f];
                    
                    [strongSelf setupFailTimeout:[TGModernSendCommonMessageActor defaultTimeoutInterval]];
                    
                    NSData *imageData = UIImageJPEGRepresentation((UIImage *)next, 0.54f);
                    
                    NSString *imagePath = [self filePathForLocalImageUrl:[assetImageMessage.imageInfo imageUrlForLargestSize:NULL]];
                    [[NSFileManager defaultManager] createDirectoryAtPath:[imagePath stringByDeletingLastPathComponent] withIntermediateDirectories:true attributes:nil error:nil];
                    [imageData writeToFile:imagePath atomically:false];
                    
                    NSString *localImageDirectory = [imagePath stringByDeletingLastPathComponent];
                    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:localImageDirectory error:nil];
                    for (NSString *file in files)
                    {
                        if ([file hasPrefix:@"thumbnail-"])
                            [[NSFileManager defaultManager] removeItemAtPath:[localImageDirectory stringByAppendingPathComponent:file] error:nil];
                    }
                    
                    NSString *thumbnailUrl = [assetImageMessage.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
                    if (thumbnailUrl != nil)
                        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/as/media/imageThumbnailUpdated"] resource:thumbnailUrl];
                    
                    NSString *hash = nil;
                    if (assetImageMessage.useMediaCache)
                    {
                        hash = TGImageHash(imageData);
                        assetImageMessage.imageHash = hash;
                    }
                    
                    TGImageMediaAttachment *attachment = [TGImageDownloadActor serverMediaDataForAssetUrl:hash][@"imageAttachment"];
                    if (hash != nil && attachment != nil)
                    {
                        TLInputMedia$inputMediaPhoto *remotePhoto = [[TLInputMedia$inputMediaPhoto alloc] init];
                        TLInputPhoto$inputPhoto *inputId = [[TLInputPhoto$inputPhoto alloc] init];
                        inputId.n_id = attachment.imageId;
                        inputId.access_hash = attachment.accessHash;
                        remotePhoto.n_id = inputId;
                        remotePhoto.caption = assetImageMessage.caption;
                        
                        self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:remotePhoto messageGuid:nil tmpId:assetImageMessage.randomId replyMessageId:assetImageMessage.replyMessage.mid postAsChannel:_postAsChannel notifyMembers:_notifyMembers actor:self];
                    }
                    else
                    {
                        [strongSelf uploadFilesWithExtensions:@[@[imageData, @"jpg", @(true)]]];
                    }
                }
                else if ([next isKindOfClass:[TGMediaAssetImageData class]])
                {
                    [strongSelf updatePreDownloadsProgress:1.0f];
                    
                    [strongSelf setupFailTimeout:[TGModernSendCommonMessageActor defaultTimeoutInterval]];
                    
                    TGMediaAssetImageData *assetData = (TGMediaAssetImageData *)next;
                    NSData *documentData = assetData.imageData;
                    
                    assetImageMessage.fileSize = (uint32_t)assetData.imageData.length;
                    
                    TGMessage *updatedMessage = self.preparedMessage.message;
                    [TGDatabaseInstance() updateMessage:self.preparedMessage.mid peerId:_conversationId flags:std::vector<TGDatabaseMessageFlagValue>() media:updatedMessage.mediaAttachments dispatch:false];
                    
                    updatedMessage = [TGDatabaseInstance() loadMessageWithMid:self.preparedMessage.mid peerId:_conversationId];
                    id resource = [[SGraphObjectNode alloc] initWithObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:self.preparedMessage.mid], updatedMessage, nil]];
                    [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesChanged", _conversationId] resource:resource];
                    
                    NSString *fileExtension = [assetData.fileName pathExtension];
                    if (fileExtension == nil)
                        fileExtension = @"";
                    
                    NSArray *attributes = assetImageMessage.attributes;
                    
                    NSString *documentPath = [self filePathForLocalDocumentId:assetImageMessage.localDocumentId attributes:attributes];
                    [[NSFileManager defaultManager] createDirectoryAtPath:[documentPath stringByDeletingLastPathComponent] withIntermediateDirectories:true attributes:nil error:nil];
                    [documentData writeToFile:documentPath atomically:false];
                    
                    NSMutableArray *files = [[NSMutableArray alloc] init];
                    [files addObject:@[documentPath, fileExtension, @(true)]];
                    
                    UIImage *thumbnailImage = [[UIImage alloc] initWithContentsOfFile:[self pathForLocalImagePath:assetImageMessage.localThumbnailDataPath]];
                    CGSize thumbnailSize = TGFitSize(thumbnailImage.size, CGSizeMake(90, 90));
                    NSData *thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(thumbnailImage, thumbnailSize), 0.6f);
                    if (thumbnailData != nil)
                        [files addObject:@[thumbnailData, @"jpg", @(false)]];
                    
                    NSString *thumbnailUrl = [assetImageMessage.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
                    if (thumbnailUrl != nil)
                        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/as/media/imageThumbnailUpdated"] resource:thumbnailUrl];
                    
                    [self uploadFilesWithExtensions:files];
                }
            } error:^(__unused id error)
            {
                __strong TGModernSendCommonMessageActor *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    TGLog(@"Cloud photo load error");
                    [strongSelf _fail];
                }
            } completed:nil]];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedAssetVideoMessage class]])
        {
            TGPreparedAssetVideoMessage *assetVideoMessage = (TGPreparedAssetVideoMessage *)self.preparedMessage;
            
            [self beginUploadProgress];

            TGVideoEditAdjustments *adjustments = [TGVideoEditAdjustments editAdjustmentsWithDictionary:assetVideoMessage.adjustments];
            bool liveUpload = assetVideoMessage.liveUpload;
            bool passthrough = assetVideoMessage.passthrough;
            bool useMediaCache = assetVideoMessage.useMediaCache;
            
            SSignal *(^hashSignal)(AVAsset *) = ^(AVAsset *avAsset)
            {
                if ([adjustments cropAppliedForAvatar:false] || [adjustments rotationApplied] || [adjustments trimApplied])
                    return [SSignal single:nil];
                
                return [TGVideoConverter hashSignalForAVAsset:avAsset];
            };
            
            if (!assetVideoMessage.document)
                self.uploadProgressContainsPreDownloads = true;
            
            NSString *tempFilePath = TGTemporaryFileName(nil);
            SSignal *signal = [videoDownloadQueue() enqueue:[[[[TGMediaAssetsLibrary sharedLibrary] assetWithIdentifier:assetVideoMessage.assetIdentifier] mapToSignal:^SSignal *(TGMediaAsset *asset)
            {
                if (!assetVideoMessage.document)
                {
                    return [[TGMediaAssetImageSignals avAssetForVideoAsset:asset allowNetworkAccess:false] catch:^SSignal *(id error)
                    {
                        if (![error isKindOfClass:[NSNumber class]] && !assetVideoMessage.isCloud)
                            return [SSignal fail:error];
                        
                        return [TGMediaAssetImageSignals avAssetForVideoAsset:asset allowNetworkAccess:true];
                    }];
                }
                else
                {
                    if (asset.subtypes & TGMediaAssetSubtypeVideoHighFrameRate)
                        self.uploadProgressContainsPreDownloads = true;
                    
                    return [[TGMediaAssetImageSignals saveUncompressedVideoForAsset:asset toPath:tempFilePath allowNetworkAccess:false] catch:^SSignal *(id error)
                    {
                        if (![error isKindOfClass:[NSNumber class]] && !assetVideoMessage.isCloud)
                            return [SSignal fail:error];
                        
                        self.uploadProgressContainsPreDownloads = true;
                        return [TGMediaAssetImageSignals saveUncompressedVideoForAsset:asset toPath:tempFilePath allowNetworkAccess:true];
                    }];
                }
            }] mapToSignal:^SSignal *(id value)
            {
                if ([value isKindOfClass:[AVAsset class]])
                {
                    AVAsset *avAsset = (AVAsset *)value;
                    SSignal *(^convertSignal)(NSString *) = ^SSignal *(NSString *hash)
                    {
                        assetVideoMessage.videoHash = hash;
                        return [[TGVideoConverter convertSignalForAVAsset:avAsset adjustments:adjustments liveUpload:liveUpload passthrough:passthrough] map:^id(id value)
                        {
                            if ([value isKindOfClass:[NSDictionary class]])
                            {
                                NSMutableDictionary *dict = [value mutableCopy];
                                if (hash != nil)
                                    dict[@"hash"] = hash;
                                
                                return @{ @"convertResult": dict };
                            }
                            else if ([value isKindOfClass:[NSNumber class]])
                            {
                                return @{ @"convertProgress": value };
                            }
                            return value;
                        }];
                    };
                    
                    if (useMediaCache)
                    {
                        return [hashSignal(avAsset) mapToSignal:^SSignal *(NSString *hash)
                        {
                            if (hash != nil && [TGImageDownloadActor serverMediaDataForAssetUrl:hash])
                            {
                                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                                dict[@"hash"] = hash;
                                return [SSignal single:@{ @"remote": dict }];
                            }

                            return convertSignal(hash);
                        }];
                    }
                    else
                    {
                        return convertSignal(nil);
                    }
                }
                else if ([value isKindOfClass:[NSString class]])
                {
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    dict[@"filePath"] = tempFilePath;
                    dict[@"fileName"] = value;
                    return [SSignal single:@{ @"fileResult": dict }];
                }
                else if ([value isKindOfClass:[NSNumber class]])
                {
                    return [SSignal single:@{ @"downloadProgress": value }];
                }
                
                return [SSignal single:value];
            }]];
            
            __weak TGModernSendCommonMessageActor *weakSelf = self;
            [self.disposables add:[[signal deliverOn:[SQueue wrapConcurrentNativeQueue:[ActionStageInstance() globalStageDispatchQueue]]] startWithNext:^(id next)
            {
                __strong TGModernSendCommonMessageActor *strongSelf = weakSelf;
                if (![next isKindOfClass:[NSDictionary class]])
                    return;
                
                NSDictionary *dict = (NSDictionary *)next;
                if (dict[@"remote"] != nil)
                {
                    NSString *hash = dict[@"remote"][@"hash"];
                    TGVideoMediaAttachment *attachment = [TGImageDownloadActor serverMediaDataForAssetUrl:hash][@"videoAttachment"];
                    if (attachment != nil)
                    {
                        TLInputMedia$inputMediaDocument *inputMediaDocument = [[TLInputMedia$inputMediaDocument alloc] init];
                        TLInputDocument$inputDocument *inputDocument = [[TLInputDocument$inputDocument alloc] init];
                        inputDocument.n_id = attachment.videoId;
                        inputDocument.access_hash = attachment.accessHash;
                        inputMediaDocument.n_id = inputDocument;
                        inputMediaDocument.caption = assetVideoMessage.caption;
                        
                        [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
                        self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:inputMediaDocument messageGuid:nil tmpId:assetVideoMessage.randomId replyMessageId:assetVideoMessage.replyMessage.mid postAsChannel:_postAsChannel notifyMembers:_notifyMembers actor:self];
                    }
                    else
                    {
                        [strongSelf _fail];
                    }
                }
                else if (dict[@"downloadProgress"] != nil)
                {
                    float value = [dict[@"downloadProgress"] floatValue];
                    if (!assetVideoMessage.document)
                        value /= 2.0f;
                    [strongSelf updatePreDownloadsProgress:value];
                }
                else if (dict[@"convertProgress"] != nil)
                {
                    float value = [dict[@"convertProgress"] floatValue];
                    [strongSelf updatePreDownloadsProgress:0.5f + value / 2.0f];
                }
                else if (dict[@"convertResult"] != nil)
                {
                    NSDictionary *result = dict[@"convertResult"];
                    
                    [strongSelf updatePreDownloadsProgress:1.0f];
                    
                    [strongSelf setupFailTimeout:[TGModernSendCommonMessageActor defaultTimeoutInterval]];
                    
                    assetVideoMessage.duration = [result[@"duration"] doubleValue];
                    assetVideoMessage.dimensions = [result[@"dimensions"] CGSizeValue];
                    assetVideoMessage.fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:[result[@"fileUrl"] path] error:NULL][NSFileSize] intValue];
                    
                    TGMessage *updatedMessage = self.preparedMessage.message;
                    [TGDatabaseInstance() updateMessage:self.preparedMessage.mid peerId:_conversationId flags:std::vector<TGDatabaseMessageFlagValue>() media:updatedMessage.mediaAttachments dispatch:false];
                    
                    updatedMessage = [TGDatabaseInstance() loadMessageWithMid:self.preparedMessage.mid peerId:_conversationId];
                    id resource = [[SGraphObjectNode alloc] initWithObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:self.preparedMessage.mid], updatedMessage, nil]];
                    [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesChanged", _conversationId] resource:resource];
                    
                    [[NSFileManager defaultManager] removeItemAtPath:[assetVideoMessage localVideoPath] error:nil];
                    [[NSFileManager defaultManager] moveItemAtPath:[result[@"fileUrl"] path] toPath:[assetVideoMessage localVideoPath] error:nil];
                    [[NSFileManager defaultManager] createSymbolicLinkAtPath:[result[@"fileUrl"] path] withDestinationPath:[assetVideoMessage localVideoPath] error:nil];
                    
                    NSString *thumbnailUrl = [assetVideoMessage.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
                    if (thumbnailUrl != nil)
                        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/as/media/imageThumbnailUpdated"] resource:thumbnailUrl];
                    
                    UIImage *thumbnailImage = result[@"previewImage"];
                    if (thumbnailImage == nil)
                    {
                        thumbnailImage = [[UIImage alloc] initWithContentsOfFile:[self pathForLocalImagePath:assetVideoMessage.localThumbnailDataPath]];
                    }
                    CGSize thumbnailSize = TGFitSize(thumbnailImage.size, CGSizeMake(90, 90));
                    NSData *thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(thumbnailImage, thumbnailSize), 0.6f);
                    
                    NSMutableArray *desc = [[NSMutableArray alloc] initWithArray:@[[assetVideoMessage localVideoPath], @"mp4", @(true)]];
                    if (result[@"liveUploadData"] != nil)
                        [desc addObject:result[@"liveUploadData"]];
                    
                    [self uploadFilesWithExtensions:@[desc, @[thumbnailData, @"jpg", @(false)]]];
                }
                else if (dict[@"fileResult"] != nil)
                {
                    [strongSelf updatePreDownloadsProgress:1.0f];
                    
                    [strongSelf setupFailTimeout:[TGModernSendCommonMessageActor defaultTimeoutInterval]];
                    
                    NSDictionary *result = dict[@"fileResult"];
                    
                    assetVideoMessage.fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:result[@"filePath"] error:NULL][NSFileSize] intValue];
                    
                    TGMessage *updatedMessage = self.preparedMessage.message;
                    [TGDatabaseInstance() updateMessage:self.preparedMessage.mid peerId:_conversationId flags:std::vector<TGDatabaseMessageFlagValue>() media:updatedMessage.mediaAttachments dispatch:false];
                    
                    updatedMessage = [TGDatabaseInstance() loadMessageWithMid:self.preparedMessage.mid peerId:_conversationId];
                    id resource = [[SGraphObjectNode alloc] initWithObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:self.preparedMessage.mid], updatedMessage, nil]];
                    [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesChanged", _conversationId] resource:resource];
                    
                    NSString *fileExtension = [assetVideoMessage.fileName pathExtension];
                    if (fileExtension == nil)
                        fileExtension = @"";
                    
                    NSArray *attributes = assetVideoMessage.attributes;
                    
                    NSString *documentPath = [self filePathForLocalDocumentId:assetVideoMessage.localDocumentId attributes:attributes];
                    [[NSFileManager defaultManager] createDirectoryAtPath:[documentPath stringByDeletingLastPathComponent] withIntermediateDirectories:true attributes:nil error:nil];
                    [[NSFileManager defaultManager] moveItemAtPath:result[@"filePath"] toPath:documentPath error:nil];
                    
                    NSMutableArray *files = [[NSMutableArray alloc] init];
                    [files addObject:@[documentPath, fileExtension, @(true)]];
                    
                    UIImage *thumbnailImage = [[UIImage alloc] initWithContentsOfFile:[self pathForLocalImagePath:assetVideoMessage.localThumbnailDataPath]];
                    CGSize thumbnailSize = TGFitSize(thumbnailImage.size, CGSizeMake(90, 90));
                    NSData *thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(thumbnailImage, thumbnailSize), 0.6f);
                    if (thumbnailData != nil)
                        [files addObject:@[thumbnailData, @"jpg", @(false)]];
                    
                    NSString *thumbnailUrl = [assetVideoMessage.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
                    if (thumbnailUrl != nil)
                        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/as/media/imageThumbnailUpdated"] resource:thumbnailUrl];
                    
                    [self uploadFilesWithExtensions:files];
                }
            } error:^(__unused id error)
            {
                __strong TGModernSendCommonMessageActor *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    TGLog(@"Cloud photo load error");
                    [strongSelf _fail];
                }
            } completed:nil]];
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
            if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                hasImageSizeAttribute = true;
            }
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
            if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                hasImageSizeAttribute = true;
            }
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
        else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
            TLDocumentAttribute$documentAttributeVideo *concreteAttribute = [[TLDocumentAttribute$documentAttributeVideo alloc] init];
            concreteAttribute.w = (int32_t)((TGDocumentAttributeVideo *)attribute).size.width;
            concreteAttribute.h = (int32_t)((TGDocumentAttributeVideo *)attribute).size.height;
            concreteAttribute.duration = (int32_t)((TGDocumentAttributeVideo *)attribute).duration;
            [attributes addObject:concreteAttribute];
        }
        else if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
        {
            [attributes addObject:[[TLDocumentAttribute$documentAttributeSticker alloc] init]];
        }
        else if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
            TGDocumentAttributeAudio *audio = attribute;
            int32_t flags = 0;
            if (audio.isVoice) {
                flags |= (1 << 10);
            }
            if (audio.title != nil) {
                flags |= (1 << 0);
            }
            if (audio.performer != nil) {
                flags |= (1 << 1);
            }
            if (audio.waveform != nil) {
                flags |= (1 << 2);
            }
            
            TLDocumentAttribute$documentAttributeAudio *nativeAttribute = [[TLDocumentAttribute$documentAttributeAudio alloc] init];
            nativeAttribute.flags = flags;
            nativeAttribute.duration = audio.duration;
            nativeAttribute.title = audio.title;
            nativeAttribute.performer = audio.performer;
            nativeAttribute.waveform = [audio.waveform bitstream];
            [attributes addObject:nativeAttribute];
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
            
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:uploadedPhoto messageGuid:nil tmpId:localImageMessage.randomId replyMessageId:localImageMessage.replyMessage.mid postAsChannel:_postAsChannel notifyMembers:_notifyMembers actor:self];
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
            TLInputMedia$inputMediaUploadedThumbDocument *uploadedDocument = [[TLInputMedia$inputMediaUploadedThumbDocument alloc] init];
            uploadedDocument.file = videoFileInfo[@"file"];
            uploadedDocument.thumb = thumbnailFileInfo[@"file"];
            
            TLDocumentAttribute$documentAttributeVideo *video = [[TLDocumentAttribute$documentAttributeVideo alloc] init];
            video.duration = (int32_t)localVideoMessage.duration;
            video.w = (int32_t)localVideoMessage.videoSize.width;
            video.h = (int32_t)localVideoMessage.videoSize.height;
            
            TLDocumentAttribute$documentAttributeFilename *filename = [[TLDocumentAttribute$documentAttributeFilename alloc] init];
            filename.file_name = @"video.mp4";
            
            uploadedDocument.attributes = @[video, filename];
            
            uploadedDocument.caption = localVideoMessage.caption;
            
            uploadedDocument.mime_type = @"video/mp4";
            
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:uploadedDocument messageGuid:nil tmpId:localVideoMessage.randomId replyMessageId:localVideoMessage.replyMessage.mid postAsChannel:_postAsChannel notifyMembers:_notifyMembers actor:self];
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
            
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:uploadedDocument messageGuid:nil tmpId:localDocumentMessage.randomId replyMessageId:localDocumentMessage.replyMessage.mid postAsChannel:_postAsChannel notifyMembers:_notifyMembers actor:self];
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
            
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:uploadedPhoto messageGuid:nil tmpId:downloadImageMessage.randomId replyMessageId:downloadImageMessage.replyMessage.mid postAsChannel:_postAsChannel notifyMembers:_notifyMembers actor:self];
        }
        else
            [self _fail];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedAssetImageMessage class]])
    {
        TGPreparedAssetImageMessage *assetImageMessage = (TGPreparedAssetImageMessage *)self.preparedMessage;
        
        if (!assetImageMessage.document)
        {
            NSDictionary *fileInfo = filePathToUploadedFile[@"embedded-data://0"];
            if (fileInfo != nil)
            {
                TLInputMedia$inputMediaUploadedPhoto *uploadedPhoto = [[TLInputMedia$inputMediaUploadedPhoto alloc] init];
                uploadedPhoto.file = fileInfo[@"file"];
                uploadedPhoto.caption = assetImageMessage.caption;
                
                self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:uploadedPhoto messageGuid:nil tmpId:assetImageMessage.randomId replyMessageId:assetImageMessage.replyMessage.mid postAsChannel:_postAsChannel notifyMembers:_notifyMembers actor:self];
            }
            else
                [self _fail];
        }
        else
        {
            NSDictionary *documentFileInfo = filePathToUploadedFile[[[assetImageMessage localDocumentDirectory] stringByAppendingPathComponent:[assetImageMessage localDocumentFileName]]];
            NSDictionary *thumbnailFileInfo = filePathToUploadedFile[@"embedded-data://0"];
            
            if (documentFileInfo != nil)
            {
                id uploadedDocument = nil;
                
                if (assetImageMessage.localThumbnailDataPath != nil && thumbnailFileInfo != nil)
                {
                    TLInputMedia$inputMediaUploadedThumbDocument *thumbUploadedDocument = [[TLInputMedia$inputMediaUploadedThumbDocument alloc] init];
                    thumbUploadedDocument.file = documentFileInfo[@"file"];
                    thumbUploadedDocument.attributes = [self attributesForNativeAttributes:assetImageMessage.attributes];
                    thumbUploadedDocument.mime_type = assetImageMessage.mimeType.length == 0 ? @"application/octet-stream" : assetImageMessage.mimeType;
                    thumbUploadedDocument.thumb = thumbnailFileInfo[@"file"];
                    
                    uploadedDocument = thumbUploadedDocument;
                }
                else
                {
                    TLInputMedia$inputMediaUploadedDocument *plainUploadedDocument = [[TLInputMedia$inputMediaUploadedDocument alloc] init];
                    plainUploadedDocument.file = documentFileInfo[@"file"];
                    plainUploadedDocument.attributes = [self attributesForNativeAttributes:assetImageMessage.attributes];
                    plainUploadedDocument.mime_type = assetImageMessage.mimeType.length == 0 ? @"application/octet-stream" : assetImageMessage.mimeType;
                    
                    uploadedDocument = plainUploadedDocument;
                }
                
                self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:uploadedDocument messageGuid:nil tmpId:assetImageMessage.randomId replyMessageId:assetImageMessage.replyMessage.mid postAsChannel:_postAsChannel notifyMembers:_notifyMembers actor:self];
            }
            else
                [self _fail];
        }
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedAssetVideoMessage class]])
    {
        TGPreparedAssetVideoMessage *assetVideoMessage = (TGPreparedAssetVideoMessage *)self.preparedMessage;
        
        if (!assetVideoMessage.document)
        {
            NSDictionary *videoFileInfo = filePathToUploadedFile[[assetVideoMessage localVideoPath]];
            NSDictionary *thumbnailFileInfo = filePathToUploadedFile[@"embedded-data://0"];
            if (videoFileInfo != nil && thumbnailFileInfo != nil)
            {
                TLInputMedia$inputMediaUploadedThumbDocument *uploadedDocument = [[TLInputMedia$inputMediaUploadedThumbDocument alloc] init];
                uploadedDocument.file = videoFileInfo[@"file"];
                uploadedDocument.thumb = thumbnailFileInfo[@"file"];
                
                TLDocumentAttribute$documentAttributeVideo *video = [[TLDocumentAttribute$documentAttributeVideo alloc] init];
                video.duration = (int32_t)assetVideoMessage.duration;
                video.w = (int32_t)assetVideoMessage.dimensions.width;
                video.h = (int32_t)assetVideoMessage.dimensions.height;
                
                TLDocumentAttribute$documentAttributeFilename *filename = [[TLDocumentAttribute$documentAttributeFilename alloc] init];
                filename.file_name = @"video.mp4";
                
                uploadedDocument.attributes = @[video, filename];
                
                uploadedDocument.caption = assetVideoMessage.caption;
                
                uploadedDocument.mime_type = @"video/mp4";
                
                self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:uploadedDocument messageGuid:nil tmpId:assetVideoMessage.randomId replyMessageId:assetVideoMessage.replyMessage.mid postAsChannel:_postAsChannel notifyMembers:_notifyMembers actor:self];
            }
            else
                [self _fail];
        }
        else
        {
            NSDictionary *documentFileInfo = filePathToUploadedFile[[[assetVideoMessage localDocumentDirectory] stringByAppendingPathComponent:[assetVideoMessage localDocumentFileName]]];
            NSDictionary *thumbnailFileInfo = filePathToUploadedFile[@"embedded-data://0"];
            
            if (documentFileInfo != nil)
            {
                id uploadedDocument = nil;
                
                if (assetVideoMessage.localThumbnailDataPath != nil && thumbnailFileInfo != nil)
                {
                    TLInputMedia$inputMediaUploadedThumbDocument *thumbUploadedDocument = [[TLInputMedia$inputMediaUploadedThumbDocument alloc] init];
                    thumbUploadedDocument.file = documentFileInfo[@"file"];
                    thumbUploadedDocument.attributes = [self attributesForNativeAttributes:assetVideoMessage.attributes];
                    thumbUploadedDocument.mime_type = assetVideoMessage.mimeType.length == 0 ? @"application/octet-stream" : assetVideoMessage.mimeType;
                    thumbUploadedDocument.thumb = thumbnailFileInfo[@"file"];
                    
                    uploadedDocument = thumbUploadedDocument;
                }
                else
                {
                    TLInputMedia$inputMediaUploadedDocument *plainUploadedDocument = [[TLInputMedia$inputMediaUploadedDocument alloc] init];
                    plainUploadedDocument.file = documentFileInfo[@"file"];
                    plainUploadedDocument.attributes = [self attributesForNativeAttributes:assetVideoMessage.attributes];
                    plainUploadedDocument.mime_type = assetVideoMessage.mimeType.length == 0 ? @"application/octet-stream" : assetVideoMessage.mimeType;
                    
                    uploadedDocument = plainUploadedDocument;
                }
                
                self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:uploadedDocument messageGuid:nil tmpId:assetVideoMessage.randomId replyMessageId:assetVideoMessage.replyMessage.mid postAsChannel:_postAsChannel notifyMembers:_notifyMembers actor:self];
            }
            else
                [self _fail];
        }
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
            
            self.cancelToken = [TGTelegraphInstance doConversationSendMedia:_conversationId accessHash:_accessHash media:uploadedDocument messageGuid:nil tmpId:downloadDocumentMessage.randomId replyMessageId:downloadDocumentMessage.replyMessage.mid postAsChannel:_postAsChannel notifyMembers:_notifyMembers actor:self];
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
        
        NSArray *entities = [TGMessage parseTelegraphEntities:sentMessage.entities];
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
        resultDict[@"pts"] = @(sentMessage.pts);
        
        if (updatedMessage == nil)
        {
            updatedMessage = [[self.preparedMessage message] copy];
            updatedMessage.mid = sentMessage.n_id;
            updatedMessage.date = sentMessage.date;
            updatedMessage.outgoing = true;
            updatedMessage.fromUid = TGTelegraphInstance.clientUserId;
            updatedMessage.unread = unread;
            updatedMessage.pts = sentMessage.pts;
        }
        
        [self afterMessageSent:updatedMessage];
        
        int64_t conversationId = _conversationId;
        id resource = [[SGraphObjectNode alloc] initWithObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:self.preparedMessage.mid], updatedMessage, nil]];
        
        [self _success:resultDict];
        
        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesChanged", conversationId] resource:resource];
    }
    else if ([result isKindOfClass:[TLUpdates class]])
    {
        TLUpdates *updates = result;
        
        TLMessage *updateMessage = updates.messages.firstObject;
        int32_t pts = 1;
        for (id update in updates.updatesList) {
            if ([update isKindOfClass:[TLUpdate$updateNewChannelMessage class]]) {
                pts = ((TLUpdate$updateNewChannelMessage *)update).pts;
            }
        }
        
        int32_t date = 0;
        if ([updateMessage isKindOfClass:[TLMessage$modernMessage class]])
            date = ((TLMessage$message *)updateMessage).date;
        else if ([updateMessage isKindOfClass:[TLMessage$modernMessageService class]])
            date = ((TLMessage$modernMessageService *)updateMessage).date;
        
        bool waitForFileQueue = false;
        
        TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:updateMessage];
        message.pts = pts;
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
            else if ([self.preparedMessage isKindOfClass:[TGPreparedAssetImageMessage class]])
            {
                TGPreparedAssetImageMessage *assetImageMessage = (TGPreparedAssetImageMessage *)self.preparedMessage;
                
                if (!assetImageMessage.document)
                {
                    for (TGMediaAttachment *attachment in message.mediaAttachments)
                    {
                        if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
                        {
                            TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
                            
                            NSString *localImageUrl = [assetImageMessage.imageInfo imageUrlForLargestSize:NULL];
                            
                            NSString *localImageDirectory = [[self filePathForLocalImageUrl:localImageUrl] stringByDeletingLastPathComponent];
                            NSString *updatedImageDirectory = [[self filePathForRemoteImageId:imageAttachment.imageId] stringByDeletingLastPathComponent];
                            
                            [[NSFileManager defaultManager] removeItemAtPath:updatedImageDirectory error:nil];
                            [[NSFileManager defaultManager] moveItemAtPath:localImageDirectory toPath:updatedImageDirectory error:nil];
                            
                            [TGModernSendCommonMessageActor setRemoteImageForRemoteUrl:localImageUrl image:imageAttachment];
                            
                            if (assetImageMessage.useMediaCache && assetImageMessage.imageHash.length != 0)
                                [TGImageDownloadActor addServerMediaSataForAssetUrl:assetImageMessage.imageHash attachment:imageAttachment];
                            
                            [TGDatabaseInstance() updateLastUseDateForMediaType:2 mediaId:imageAttachment.imageId messageId:message.mid];
                        }
                    }
                }
                else
                {
                    NSMutableArray *dataFilePaths = [[NSMutableArray alloc] init];
                    if (assetImageMessage.localThumbnailDataPath != nil)
                        [dataFilePaths addObject:assetImageMessage.localThumbnailDataPath];
                    if ([assetImageMessage localDocumentDirectory] != nil)
                        [dataFilePaths addObject:[assetImageMessage localDocumentDirectory]];
                    
                    for (TGMediaAttachment *attachment in message.mediaAttachments)
                    {
                        if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
                        {
                            TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                            
                            if (documentAttachment.thumbnailInfo != nil && assetImageMessage.localThumbnailDataPath != nil)
                            {
                                NSString *thumbnailUri = [[documentAttachment thumbnailInfo] imageUrlForLargestSize:NULL];
                                if (thumbnailUri != nil)
                                {
                                    [[TGRemoteImageView sharedCache] moveToCache:[self pathForLocalImagePath:assetImageMessage.localThumbnailDataPath] cacheUrl:thumbnailUri];
                                    [dataFilePaths removeObject:assetImageMessage.localThumbnailDataPath];
                                }
                            }
                            
                            NSString *updatedDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:documentAttachment.documentId];
                            
                            [[NSFileManager defaultManager] removeItemAtPath:updatedDocumentDirectory error:nil];
                            [[NSFileManager defaultManager] moveItemAtPath:[assetImageMessage localDocumentDirectory] toPath:updatedDocumentDirectory error:nil];
                            
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
            }
            else if ([self.preparedMessage isKindOfClass:[TGPreparedAssetVideoMessage class]])
            {
                TGPreparedAssetVideoMessage *assetVideoMessage = (TGPreparedAssetVideoMessage *)self.preparedMessage;
                
                if (!assetVideoMessage.document)
                {
                    NSMutableArray *dataFilePaths = [[NSMutableArray alloc] init];
                    if (assetVideoMessage.localThumbnailDataPath != nil)
                        [dataFilePaths addObject:assetVideoMessage.localThumbnailDataPath];
                    if ([assetVideoMessage localVideoPath] != nil)
                        [dataFilePaths addObject:[assetVideoMessage localVideoPath]];
                    
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
                            [[NSFileManager defaultManager] moveItemAtPath:[assetVideoMessage localVideoPath] toPath:updatedVideoPath error:nil];
                            [dataFilePaths removeObject:[assetVideoMessage localVideoPath]];
                            
                            NSString *remoteUrl = [videoAttachment.videoInfo urlWithQuality:1 actualQuality:NULL actualSize:NULL];
                            if (remoteUrl != nil)
                            {
                                [TGVideoDownloadActor rewriteLocalFilePath:[[NSString alloc] initWithFormat:@"local-video:local%llx.mov", assetVideoMessage.localVideoId] remoteUrl:remoteUrl];
                            }
                            
                            [[TGRemoteImageView sharedCache] changeCacheItemUrl:[[NSString alloc] initWithFormat:[assetVideoMessage localThumbnailDataPath], assetVideoMessage.localVideoId] newUrl:[[NSString alloc] initWithFormat:@"video-thumbnail-remote%llx.jpg", videoAttachment.videoId]];
                            
                            NSString *thumbnailUrl = [videoAttachment.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
                            if (thumbnailUrl != nil && assetVideoMessage.localThumbnailDataPath != nil)
                            {
                                [[TGRemoteImageView sharedCache] moveToCache:[self pathForLocalImagePath:assetVideoMessage.localThumbnailDataPath] cacheUrl:thumbnailUrl];
                                [dataFilePaths removeObject:assetVideoMessage.localThumbnailDataPath];
                                [TGImageDownloadActor addUrlRewrite:assetVideoMessage.localThumbnailDataPath newUrl:thumbnailUrl];
                            }
                            
                            if (assetVideoMessage.useMediaCache && assetVideoMessage.videoHash.length != 0)
                                [TGImageDownloadActor addServerMediaSataForAssetUrl:assetVideoMessage.videoHash attachment:videoAttachment];
                            
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
                else
                {
                    NSMutableArray *dataFilePaths = [[NSMutableArray alloc] init];
                    if (assetVideoMessage.localThumbnailDataPath != nil)
                        [dataFilePaths addObject:assetVideoMessage.localThumbnailDataPath];
                    if ([assetVideoMessage localDocumentDirectory] != nil)
                        [dataFilePaths addObject:[assetVideoMessage localDocumentDirectory]];
                    
                    for (TGMediaAttachment *attachment in message.mediaAttachments)
                    {
                        if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
                        {
                            TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                            
                            if (documentAttachment.thumbnailInfo != nil && assetVideoMessage.localThumbnailDataPath != nil)
                            {
                                NSString *thumbnailUri = [[documentAttachment thumbnailInfo] imageUrlForLargestSize:NULL];
                                if (thumbnailUri != nil)
                                {
                                    [[TGRemoteImageView sharedCache] moveToCache:[self pathForLocalImagePath:assetVideoMessage.localThumbnailDataPath] cacheUrl:thumbnailUri];
                                    [dataFilePaths removeObject:assetVideoMessage.localThumbnailDataPath];
                                }
                            }
                            
                            NSString *updatedDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:documentAttachment.documentId];
                            
                            [[NSFileManager defaultManager] removeItemAtPath:updatedDocumentDirectory error:nil];
                            [[NSFileManager defaultManager] moveItemAtPath:[assetVideoMessage localDocumentDirectory] toPath:updatedDocumentDirectory error:nil];
                            
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
            else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadExternalGifMessage class]])
            {
                TGPreparedDownloadExternalGifMessage *externalGifMessage = (TGPreparedDownloadExternalGifMessage *)self.preparedMessage;
                NSString *previousFileName = nil;
                for (id attribute in externalGifMessage.attributes) {
                    if ([attribute isKindOfClass:[TGDocumentAttributeFilename class]]) {
                        previousFileName = ((TGDocumentAttributeFilename *)attribute).filename;
                        break;
                    }
                }
                
                for (TGMediaAttachment *attachment in message.mediaAttachments)
                {
                    if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
                    {
                        TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                        
                        NSString *updatedDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:documentAttachment.documentId];
                        
                        NSString *previousDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:externalGifMessage.localDocumentId];
                        
                        [[NSFileManager defaultManager] createDirectoryAtPath:updatedDocumentDirectory withIntermediateDirectories:true attributes:nil error:NULL];
                        
                        for (NSString *fileName in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:previousDocumentDirectory error:nil]) {
                            NSString *updatedFileName = fileName;
                            if (previousFileName != nil && [previousFileName isEqualToString:fileName]) {
                                updatedFileName = documentAttachment.safeFileName;
                            }
                            [[NSFileManager defaultManager] copyItemAtPath:[previousDocumentDirectory stringByAppendingPathComponent:fileName] toPath:[updatedDocumentDirectory stringByAppendingPathComponent:updatedFileName] error:nil];
                        }
                        
                        [[NSFileManager defaultManager] removeItemAtPath:previousDocumentDirectory error:nil];
                        
                        [TGDatabaseInstance() updateLastUseDateForMediaType:3 mediaId:documentAttachment.documentId messageId:message.mid];
                    }
                }
            }
            else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadExternalImageMessage class]])
            {
                TGPreparedDownloadExternalImageMessage *externalImageMessage = (TGPreparedDownloadExternalImageMessage *)self.preparedMessage;
                
                for (TGMediaAttachment *attachment in message.mediaAttachments)
                {
                    if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
                    {
                        TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
                        
                        NSString *localImageUrl = [externalImageMessage.imageInfo imageUrlForLargestSize:NULL];
                        
                        NSString *localImageDirectory = [[self filePathForLocalImageUrl:localImageUrl] stringByDeletingLastPathComponent];
                        NSString *updatedImageDirectory = [[self filePathForRemoteImageId:imageAttachment.imageId] stringByDeletingLastPathComponent];
                        
                        [[NSFileManager defaultManager] createDirectoryAtPath:updatedImageDirectory withIntermediateDirectories:true attributes:nil error:NULL];
                        
                        for (NSString *fileName in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:localImageDirectory error:nil]) {
                            NSString *updatedFileName = fileName;
                            [[NSFileManager defaultManager] copyItemAtPath:[localImageDirectory stringByAppendingPathComponent:fileName] toPath:[updatedImageDirectory stringByAppendingPathComponent:updatedFileName] error:nil];
                        }
                        
                        [[NSFileManager defaultManager] removeItemAtPath:localImageDirectory error:nil];
                        
                        [TGModernSendCommonMessageActor setRemoteImageForRemoteUrl:localImageUrl image:imageAttachment];
                        
                        [TGDatabaseInstance() updateLastUseDateForMediaType:2 mediaId:imageAttachment.imageId messageId:message.mid];
                        
                        break;
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
                    @"unread": @(unread),
                    @"pts": @(message.pts)
                }];
                
                [self afterMessageSent:message];
                
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

- (void)afterMessageSent:(TGMessage *)message {
    for (id attachment in message.mediaAttachments) {
        if ([attachment isKindOfClass:[TGForwardedMessageMediaAttachment class]]) {
            return;
        }
    }
    
    for (id attachment in message.mediaAttachments) {
        if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]) {
            TGDocumentMediaAttachment *document = attachment;
            if ([document isAnimated] && ([document.mimeType isEqualToString:@"video/mp4"])) {
                if (document.documentId != 0) {
                    [TGRecentGifsSignal addRemoteRecentGifFromDocuments:@[document]];
                }
            }
            break;
        }
    }
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

- (void)conversationSendMessageRequestFailed:(NSString *)errorText
{
    if ([errorText isEqualToString:@"PEER_FLOOD"]) {
        TGDispatchOnMainThread(^{
            static CFAbsoluteTime lastErrorTime = 0.0;
            if (CFAbsoluteTimeGetCurrent() - lastErrorTime >= 1.0) {
                lastErrorTime = CFAbsoluteTimeGetCurrent();
                [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Conversation.SendMessageErrorFlood") cancelButtonTitle:TGLocalized(@"Generic.ErrorMoreInfo") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed) {
                    if (!okButtonPressed) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://telegram.org/faq#can-39t-send-messages-to-non-contacts"]];
                    }
                }] show];
            }
        });
    }
    
    [self _fail];
}

@end
