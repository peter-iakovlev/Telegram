#import "TGModernSendBroadcastMessageActor.h"

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
#import "TGPreparedDownloadImageMessage.h"
#import "TGPreparedDownloadDocumentMessage.h"
#import "TGPreparedCloudDocumentMessage.h"
#import "TGPreparedRemoteDocumentMessage.h"

#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"
#import "TGDatabase.h"

#import "TGRemoteImageView.h"
#import "TGImageDownloadActor.h"
#import "TGVideoDownloadActor.h"
#import "TGMediaStoreContext.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "TGMessage+Telegraph.h"
#import "TGConversation+Telegraph.h"

#import "TGConversationAddMessagesActor.h"
#import "TGUserDataRequestBuilder.h"

#import "TLMessage$modernMessage.h"
#import "TLMessage$modernMessageService.h"

#import "TLUpdates+TG.h"

#import <WebP/decode.h>

#import "TGAppDelegate.h"

@interface TGModernSendBroadcastMessageActor ()
{
    int64_t _conversationId;
    NSArray *_userIds;
    NSArray *_secretChatConversationIds;
    NSArray *_chatConversationIds;
    
    bool _shouldPostAlmostDeliveredMessage;
    
    NSArray *_childSendMessageActionPaths;
    NSMutableArray *_remainingChildSendMessageActionPaths;
}

@end

@implementation TGModernSendBroadcastMessageActor

+ (void)load
{
    @autoreleasepool
    {
        [ASActor registerActorClass:self];
    }
}

+ (NSString *)genericPath
{
    return @"/tg/sendBroadcastMessage/@/@";
}

- (void)prepare:(NSDictionary *)options
{
    [super prepare:options];
    
    _conversationId = [options[@"conversationId"] longLongValue];
    _userIds = options[@"userIds"];
    _secretChatConversationIds = options[@"secretChatConversationIds"];
    _chatConversationIds = options[@"chatConversationIds"];
}

- (int64_t)peerId
{
    return _conversationId;
}

- (TGPreparedMessage *)copyPreparedMessage:(TGPreparedMessage *)preparedMessage
{
    if ([preparedMessage isKindOfClass:[TGPreparedTextMessage class]])
    {
        TGPreparedTextMessage *preparedTextMessage = (TGPreparedTextMessage *)preparedMessage;
        
        TGPreparedTextMessage *copyMessage = [[TGPreparedTextMessage alloc] initWithText:preparedTextMessage.text replyMessage:preparedTextMessage.replyMessage disableLinkPreviews:preparedTextMessage.disableLinkPreviews parsedWebpage:nil];
        return copyMessage;
    }
    else if ([preparedMessage isKindOfClass:[TGPreparedLocalImageMessage class]])
    {
        TGPreparedLocalImageMessage *preparedLocalImageMessage = (TGPreparedLocalImageMessage *)preparedMessage;
        
        return [TGPreparedLocalImageMessage messageByCopyingMessageData:preparedLocalImageMessage];
    }
    else if ([preparedMessage isKindOfClass:[TGPreparedLocalVideoMessage class]])
    {
        TGPreparedLocalVideoMessage *preparedLocalVideoMessage = (TGPreparedLocalVideoMessage *)preparedMessage;
        
        return [TGPreparedLocalVideoMessage messageByCopyingDataFromMessage:preparedLocalVideoMessage];
    }
    else if ([preparedMessage isKindOfClass:[TGPreparedLocalAudioMessage class]])
    {
        TGPreparedLocalAudioMessage *preparedLocalAudioMessage = (TGPreparedLocalAudioMessage *)preparedMessage;
        
        return [TGPreparedLocalAudioMessage messageByCopyingDataFromMessage:preparedLocalAudioMessage];
    }
    else if ([preparedMessage isKindOfClass:[TGPreparedLocalDocumentMessage class]])
    {
        TGPreparedLocalDocumentMessage *preparedLocalDocumentMessage = (TGPreparedLocalDocumentMessage *)preparedMessage;
        
        return [TGPreparedLocalDocumentMessage messageByCopyingDataFromMessage:preparedLocalDocumentMessage];
    }
    else if ([preparedMessage isKindOfClass:[TGPreparedMapMessage class]])
    {
        TGPreparedMapMessage *preparedMapMessage = (TGPreparedMapMessage *)preparedMessage;
        
        return [[TGPreparedMapMessage alloc] initWithLatitude:preparedMapMessage.latitude longitude:preparedMapMessage.longitude venue:preparedMapMessage.venue replyMessage:nil];
    }
    
    return nil;
}

- (void)_commitSend
{
    if (_conversationId == 0)
        [self _fail];
    else
    {
        if (_secretChatConversationIds.count != 0 || _chatConversationIds.count != 0)
        {
            [self beginUploadProgress];
            
            NSMutableArray *actionsWithOptions = [[NSMutableArray alloc] init];
            
            NSMutableArray *childSendMessageActionPaths = [[NSMutableArray alloc] init];
            
            for (NSNumber *nPeerId in _secretChatConversationIds)
            {
                TGPreparedMessage *preparedMessage = [self copyPreparedMessage:self.preparedMessage];
                
                int64_t encryptedConversationId = [TGDatabaseInstance() encryptedConversationIdForPeerId:[nPeerId longLongValue]];
                int64_t accessHash = [TGDatabaseInstance() encryptedConversationAccessHash:[nPeerId longLongValue]];
                
                if (preparedMessage.randomId == 0)
                {
                    int64_t randomId = 0;
                    arc4random_buf(&randomId, sizeof(randomId));
                    preparedMessage.randomId = randomId;
                }
                
                int32_t messageId = [[TGDatabaseInstance() generateLocalMids:1][0] intValue];
                preparedMessage.mid = messageId;
                
                preparedMessage.date = (int)[[TGTelegramNetworking instance] approximateRemoteTime];
                
                TGMessage *message = [preparedMessage message];
                if (message == nil)
                {
                    TGLog(@"***** Failed to generate message from prepared message");
                    continue;
                }
                
                message.outgoing = true;
                message.unread = true;
                message.fromUid = TGTelegraphInstance.clientUserId;
                message.toUid = [nPeerId longLongValue];
                message.deliveryState = TGMessageDeliveryStatePending;
                message.randomId = preparedMessage.randomId;
                message.isBroadcast = true;
                
                NSString *path = [[NSString alloc] initWithFormat:@"/tg/sendSecretMessage/(%" PRId64 ")/(%" PRId32 ")", (int64_t)[nPeerId longLongValue], messageId];
                NSDictionary *options = @{@"conversationId": nPeerId, @"encryptedConversationId": @(encryptedConversationId), @"accessHash": @(accessHash), @"preparedMessage": preparedMessage};
                
                [TGDatabaseInstance() addMessagesToConversation:@[message] conversationId:[nPeerId longLongValue] updateConversation:nil dispatch:true countUnread:false updateDates:false];
                
                [childSendMessageActionPaths addObject:path];
                [actionsWithOptions addObject:@[path, options]];
            }
            
            for (NSNumber *nPeerId in _chatConversationIds)
            {
                TGPreparedMessage *preparedMessage = [self copyPreparedMessage:self.preparedMessage];
                
                if (preparedMessage.randomId == 0)
                {
                    int64_t randomId = 0;
                    arc4random_buf(&randomId, sizeof(randomId));
                    preparedMessage.randomId = randomId;
                }
                
                int32_t messageId = [[TGDatabaseInstance() generateLocalMids:1][0] intValue];
                preparedMessage.mid = messageId;
                
                preparedMessage.date = (int)[[TGTelegramNetworking instance] approximateRemoteTime];
                
                TGMessage *message = [preparedMessage message];
                if (message == nil)
                {
                    TGLog(@"***** Failed to generate message from prepared message");
                    continue;
                }
                
                message.outgoing = true;
                message.unread = true;
                message.fromUid = TGTelegraphInstance.clientUserId;
                message.toUid = [nPeerId longLongValue];
                message.deliveryState = TGMessageDeliveryStatePending;
                message.randomId = preparedMessage.randomId;
                message.isBroadcast = true;
                
                NSString *path = [[NSString alloc] initWithFormat:@"/tg/sendCommonMessage/(%" PRId64 ")/(%" PRId32 ")", (int64_t)[nPeerId longLongValue], messageId];
                NSDictionary *options = @{@"conversationId": nPeerId, @"preparedMessage": preparedMessage};
                
                [TGDatabaseInstance() addMessagesToConversation:@[message] conversationId:[nPeerId longLongValue] updateConversation:nil dispatch:true countUnread:false updateDates:false];
                
                [childSendMessageActionPaths addObject:path];
                [actionsWithOptions addObject:@[path, options]];
            }
            
            _childSendMessageActionPaths = childSendMessageActionPaths;
            _remainingChildSendMessageActionPaths = [[NSMutableArray alloc] initWithArray:_childSendMessageActionPaths];
            
            for (NSArray *actionAndOption in actionsWithOptions)
            {
                [ActionStageInstance() requestActor:actionAndOption[0] options:actionAndOption[1] watcher:self];
            }
            
            if (actionsWithOptions.count == 0)
                [self _commitSendBroadcast];
        }
        else
            [self _commitSendBroadcast];
    }
}

- (void)_commitSendBroadcast
{
    if ([self.preparedMessage isKindOfClass:[TGPreparedTextMessage class]])
    {
        TGPreparedTextMessage *textMessage = (TGPreparedTextMessage *)self.preparedMessage;
        
        if (self.preparedMessage.randomId != 0 && self.preparedMessage.mid != 0)
            [TGDatabaseInstance() setTempIdForMessageId:textMessage.mid peerId:0 tempId:textMessage.randomId];
        
        [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
        
        self.cancelToken = [TGTelegraphInstance doBroadcastSendMessage:_userIds messageText:textMessage.text geo:nil tmpId:textMessage.randomId actor:self];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedMapMessage class]])
    {
        TGPreparedMapMessage *mapMessage = (TGPreparedMapMessage *)self.preparedMessage;
        
        TLInputGeoPoint$inputGeoPoint *geoPoint = [[TLInputGeoPoint$inputGeoPoint alloc] init];
        geoPoint.lat = mapMessage.latitude;
        geoPoint.n_long = mapMessage.longitude;
        
        TLInputMedia *media = nil;
        if (mapMessage.venue != nil)
        {
            TGVenueAttachment *venue = mapMessage.venue;
            
            TLInputMedia$inputMediaVenue *venueMedia = [[TLInputMedia$inputMediaVenue alloc] init];
            venueMedia.geo_point = geoPoint;
            venueMedia.title = venue.title;
            venueMedia.address = venue.address;
            venueMedia.provider = venue.provider;
            venueMedia.venue_id = venue.venueId;
            media = venueMedia;
        }
        else
        {
            TLInputMedia$inputMediaGeoPoint *geoMedia = [[TLInputMedia$inputMediaGeoPoint alloc] init];
            geoMedia.geo_point = geoPoint;
            media = geoMedia;
        }
        
        [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
        
        self.cancelToken = [TGTelegraphInstance doBroadcastSendMedia:_userIds media:media tmpId:mapMessage.randomId actor:self];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalImageMessage class]])
    {
        TGPreparedLocalImageMessage *localImageMessage = (TGPreparedLocalImageMessage *)self.preparedMessage;
        
        [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
        
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
        
        self.cancelToken = [TGTelegraphInstance doBroadcastSendMedia:_userIds media:remotePhoto tmpId:remoteImageMessage.randomId actor:self];
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
        
        self.cancelToken = [TGTelegraphInstance doBroadcastSendMedia:_userIds media:remoteDocument tmpId:remoteDocumentMessage.randomId actor:self];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalVideoMessage class]])
    {
        TGPreparedLocalVideoMessage *localVideoMessage = (TGPreparedLocalVideoMessage *)self.preparedMessage;
        
        UIImage *thumbnailImage = [[UIImage alloc] initWithContentsOfFile:[self pathForLocalImagePath:localVideoMessage.localThumbnailDataPath]];
        CGSize thumbnailSize = TGFitSize(thumbnailImage.size, CGSizeMake(90, 90));
        NSData *thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(thumbnailImage, thumbnailSize), 0.6f);
        
        [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
        
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
        self.cancelToken = [TGTelegraphInstance doBroadcastSendMedia:_userIds media:remoteVideo tmpId:remoteVideoMessage.randomId actor:self];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalDocumentMessage class]])
    {
        TGPreparedLocalDocumentMessage *localDocumentMessage = (TGPreparedLocalDocumentMessage *)self.preparedMessage;
        
        [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
        
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
    else if ([self.preparedMessage isKindOfClass:[TGPreparedContactMessage class]])
    {
        TGPreparedContactMessage *contactMessage = (TGPreparedContactMessage *)self.preparedMessage;
        
        [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
        
        TLInputMedia$inputMediaContact *inputContact = [[TLInputMedia$inputMediaContact alloc] init];
        inputContact.first_name = contactMessage.firstName;
        inputContact.last_name = contactMessage.lastName;
        inputContact.phone_number = contactMessage.phoneNumber;
        
        self.cancelToken = [TGTelegraphInstance doBroadcastSendMedia:_userIds media:inputContact tmpId:contactMessage.randomId actor:self];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalAudioMessage class]])
    {
        TGPreparedLocalAudioMessage *localAudioMessage = (TGPreparedLocalAudioMessage *)self.preparedMessage;
        
        [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
        
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
        
        [self setupFailTimeout:[TGModernSendBroadcastMessageActor defaultTimeoutInterval]];
        
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
            [self setupFailTimeout:[TGModernSendBroadcastMessageActor defaultTimeoutInterval]];
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
            [self setupFailTimeout:[TGModernSendBroadcastMessageActor defaultTimeoutInterval]];
            self.uploadProgressContainsPreDownloads = true;
            
            NSString *path = [[NSString alloc] initWithFormat:@"/iCloudDownload/(%@)", [TGStringUtils stringByEscapingForActorURL:cloudDocumentMessage.documentUrl.absoluteString]];
            [ActionStageInstance() requestActor:path options:@{@"url": cloudDocumentMessage.documentUrl, @"path": documentPath, @"queue": @"messagePreDownloads"} flags:0 watcher:self];
            
            [self beginUploadProgress];
        }
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
            uploadedPhoto.caption = localImageMessage.caption;
            
            self.cancelToken = [TGTelegraphInstance doBroadcastSendMedia:_userIds media:uploadedPhoto tmpId:localImageMessage.randomId actor:self];
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
            
            self.cancelToken = [TGTelegraphInstance doBroadcastSendMedia:_userIds media:uploadedVideo tmpId:localVideoMessage.randomId actor:self];
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
            
            self.cancelToken = [TGTelegraphInstance doBroadcastSendMedia:_userIds media:uploadedDocument tmpId:localDocumentMessage.randomId actor:self];
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
            
            self.cancelToken = [TGTelegraphInstance doBroadcastSendMedia:_userIds media:uploadedAudio tmpId:localAudioMessage.randomId actor:self];
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
            
            self.cancelToken = [TGTelegraphInstance doBroadcastSendMedia:_userIds media:uploadedPhoto tmpId:downloadImageMessage.randomId actor:self];
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
            
            self.cancelToken = [TGTelegraphInstance doBroadcastSendMedia:_userIds media:uploadedDocument tmpId:downloadDocumentMessage.randomId actor:self];
        }
        else
            [self _fail];
    }
    else
        [self _fail];
    
    [super uploadsCompleted:filePathToUploadedFile];
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

#pragma mark -

- (void)sendBroadcastSuccess:(TLUpdates *)updates
{
    if (updates.messages.count != 0)
    {
        int date = 0;
        TLMessage *message = updates.messages[0];
        if ([message isKindOfClass:[TLMessage$modernMessage class]])
            date = ((TLMessage$modernMessage *)message).date;
        else if ([message isKindOfClass:[TLMessage$modernMessageService class]])
            date = ((TLMessage$modernMessageService *)message).date;
        
        if (date != 0)
        {
            NSMutableArray *parsedMessages = [[NSMutableArray alloc] init];
            
            for (TLMessage *message in updates.messages)
            {
                TGMessage *parsedMessage = [[TGMessage alloc] initWithTelegraphMessageDesc:message];
                if (parsedMessage.mid != 0 && parsedMessage.cid != 0)
                {
                    parsedMessage.isBroadcast = true;
                    [parsedMessages addObject:parsedMessage];
                }
            }
            
            NSMutableDictionary *chats = [[NSMutableDictionary alloc] init];
            
            for (TLChat *chatDesc in updates.chats)
            {
                TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chatDesc];
                if (conversation != nil)
                {
                    [chats setObject:conversation forKey:[[NSNumber alloc] initWithLongLong:conversation.conversationId]];
                }
            }
            
            [TGUserDataRequestBuilder executeUserDataUpdate:updates.users];
            
            static int actionId = 0;
            [[[TGConversationAddMessagesActor alloc] initWithPath:[[NSString alloc] initWithFormat:@"/tg/addmessage/(sendBroadcast%d)", actionId++]] execute:[[NSDictionary alloc] initWithObjectsAndKeys:chats, @"chats", parsedMessages, @"messages", @true, @"doNotModifyDates", nil]];
            
            if (self.preparedMessage.randomId != 0)
                [TGDatabaseInstance() removeTempIds:@[@(self.preparedMessage.randomId)]];
            
            TGMessage *message = [parsedMessages[0] copy];
            message.mid = self.preparedMessage.mid;
            message.cid = _conversationId;
            
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
            if (date != 0)
                flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDate, .value = date});
            [TGDatabaseInstance() updateMessage:self.preparedMessage.mid peerId:0 flags:flags media:message.mediaAttachments dispatch:true];
            
            if (self.preparedMessage.randomId != 0)
                [TGDatabaseInstance() removeTempIds:@[@(self.preparedMessage.randomId)]];
            
            int64_t conversationId = _conversationId;
            id resource = [[SGraphObjectNode alloc] initWithObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:self.preparedMessage.mid], message, nil]];
            
            [self _success:@{
                @"previousMid": @(self.preparedMessage.mid),
                @"mid": @(self.preparedMessage.mid),
                @"date": @(date),
                @"message": message
            }];
            
            [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesChanged", conversationId] resource:resource];
        }
        else
            [self _fail];
    }
    
    [[TGTelegramNetworking instance] addUpdates:updates];
}

- (void)sendBroadcastFailed
{
    [self _fail];
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([_childSendMessageActionPaths containsObject:path])
    {
        if (status == ASStatusSuccess)
        {
            [_remainingChildSendMessageActionPaths removeObject:path];
            
            if (_remainingChildSendMessageActionPaths.count == 0)
                [self _commitSendBroadcast];
        }
        else
            [self _fail];
    }
    else if ([path hasPrefix:@"/temporaryDownload/"])
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

@end
