#import "TGMessage+Telegraph.h"

#import "TGSchema.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "TGTelegraph.h"

#import "TGImageMediaAttachment+Telegraph.h"
#import "TGVideoMediaAttachment+Telegraph.h"
#import "TGActionMediaAttachment+Telegraph.h"
#import "TGContactMediaAttachment+Telegraph.h"
#import "TGDocumentMediaAttachment+Telegraph.h"
#import "TGAudioMediaAttachment+Telegraph.h"
#import "TGImageInfo+Telegraph.h"

#import "TGRemoteImageView.h"

@implementation TGMessage (Telegraph)

- (id)initWithTelegraphMessageDesc:(TLMessage *)desc
{
    self = [super init];
    if (self != nil)
    {
        NSArray *mediaAttachments = nil;
        
        bool isForwarded = false;
        
        if ([desc isKindOfClass:[TLMessage$message class]] || (isForwarded = [desc isKindOfClass:[TLMessage$messageForwarded class]]))
        {
            TLMessage$message *concreteMessage = (TLMessage$message *)desc;
            
            self.mid = concreteMessage.n_id;
            self.unread = concreteMessage.flags & 1;
            self.outgoing = concreteMessage.flags & 2;
            self.fromUid = concreteMessage.from_id;
            
            self.text = concreteMessage.message;
            self.date = concreteMessage.date;
            
            if ([concreteMessage.to_id isKindOfClass:[TLPeer$peerUser class]])
            {
                TLPeer$peerUser *toUser = (TLPeer$peerUser *)concreteMessage.to_id;
                self.toUid = toUser.user_id;
                if (self.toUid == self.fromUid && !self.outgoing)
                    self.outgoing = true;
                self.cid = self.outgoing ? self.toUid : self.fromUid;
            }
            else if ([concreteMessage.to_id isKindOfClass:[TLPeer$peerChat class]])
            {
                TLPeer$peerChat *toChat = (TLPeer$peerChat *)concreteMessage.to_id;
                self.toUid = -toChat.chat_id;
                self.cid = self.toUid;
            }
            
            if (isForwarded)
            {
                TLMessage$messageForwarded *forwardedMessage = (TLMessage$messageForwarded *)desc;
                
                TGForwardedMessageMediaAttachment *forwardedMessageAttachment = [[TGForwardedMessageMediaAttachment alloc] init];
                forwardedMessageAttachment.forwardUid = forwardedMessage.fwd_from_id;
                forwardedMessageAttachment.forwardDate = forwardedMessage.fwd_date;
                
                if (mediaAttachments == nil)
                    mediaAttachments = [NSArray arrayWithObject:forwardedMessageAttachment];
                else
                {
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    [array addObjectsFromArray:mediaAttachments];
                    [array addObject:forwardedMessageAttachment];
                    mediaAttachments = array;
                }
            }
            
            if (concreteMessage.media != nil)
            {
                if ([concreteMessage.media isKindOfClass:[TLMessageMedia$messageMediaPhoto class]])
                {
                    TLMessageMedia$messageMediaPhoto *mediaPhoto = (TLMessageMedia$messageMediaPhoto *)concreteMessage.media;
                    
                    TGImageMediaAttachment *imageMediaAttachment = [[TGImageMediaAttachment alloc] initWithTelegraphDesc:mediaPhoto.photo];
                    
                    if (mediaAttachments == nil)
                        mediaAttachments = [NSArray arrayWithObject:imageMediaAttachment];
                    else
                    {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        [array addObjectsFromArray:mediaAttachments];
                        [array addObject:imageMediaAttachment];
                        mediaAttachments = array;
                    }
                }
                else if ([concreteMessage.media isKindOfClass:[TLMessageMedia$messageMediaVideo class]])
                {
                    TLMessageMedia$messageMediaVideo *mediaVideo = (TLMessageMedia$messageMediaVideo *)concreteMessage.media;
                    
                    TGVideoMediaAttachment *videoAttachment = [[TGVideoMediaAttachment alloc] initWithTelegraphVideoDesc:mediaVideo.video];
                    
                    if (mediaAttachments == nil)
                        mediaAttachments = [NSArray arrayWithObject:videoAttachment];
                    else
                    {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        [array addObjectsFromArray:mediaAttachments];
                        [array addObject:videoAttachment];
                        mediaAttachments = array;
                    }
                }
                else if ([concreteMessage.media isKindOfClass:[TLMessageMedia$messageMediaContact class]])
                {
                    TLMessageMedia$messageMediaContact *mediaContact = (TLMessageMedia$messageMediaContact *)concreteMessage.media;
                    
                    TGContactMediaAttachment *contactAttachment = [[TGContactMediaAttachment alloc] initWithTelegraphContactDesc:mediaContact];
                    
                    if (mediaAttachments == nil)
                        mediaAttachments = [NSArray arrayWithObject:contactAttachment];
                    else
                    {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        [array addObjectsFromArray:mediaAttachments];
                        [array addObject:contactAttachment];
                        mediaAttachments = array;
                    }
                }
                else if ([concreteMessage.media isKindOfClass:[TLMessageMedia$messageMediaGeo class]])
                {
                    TLMessageMedia$messageMediaGeo *mediaGeo = (TLMessageMedia$messageMediaGeo *)concreteMessage.media;
                    
                    if ([mediaGeo.geo isKindOfClass:[TLGeoPoint$geoPoint class]])
                    {
                        TLGeoPoint$geoPoint *concreteGeo = (TLGeoPoint$geoPoint *)mediaGeo.geo;
                        
                        TGLocationMediaAttachment *locationMediaAttachment = [[TGLocationMediaAttachment alloc] init];
                        locationMediaAttachment.latitude = concreteGeo.lat;
                        locationMediaAttachment.longitude = concreteGeo.n_long;
                        
                        if (mediaAttachments == nil)
                        {
                            mediaAttachments = [NSArray arrayWithObject:locationMediaAttachment];
                        }
                        else
                        {
                            NSMutableArray *array = [[NSMutableArray alloc] init];
                            [array addObjectsFromArray:mediaAttachments];
                            [array addObject:locationMediaAttachment];
                            mediaAttachments = array;
                        }
                    }
                    else if ([mediaGeo.geo isKindOfClass:[TLGeoPoint$geoPlace class]])
                    {
                        TLGeoPoint$geoPlace *concreteGeo = (TLGeoPoint$geoPlace *)mediaGeo.geo;
                        
                        TGLocationMediaAttachment *locationMediaAttachment = [[TGLocationMediaAttachment alloc] init];
                        locationMediaAttachment.latitude = concreteGeo.lat;
                        locationMediaAttachment.longitude = concreteGeo.n_long;
                        
                        if (mediaAttachments == nil)
                        {
                            mediaAttachments = [NSArray arrayWithObject:locationMediaAttachment];
                        }
                        else
                        {
                            NSMutableArray *array = [[NSMutableArray alloc] init];
                            [array addObjectsFromArray:mediaAttachments];
                            [array addObject:locationMediaAttachment];
                            mediaAttachments = array;
                        }
                    }
                }
                else if ([concreteMessage.media isKindOfClass:[TLMessageMedia$messageMediaUnsupported class]])
                {
                    TGUnsupportedMediaAttachment *unsupportedAttachment = [[TGUnsupportedMediaAttachment alloc] init];
                    unsupportedAttachment.data = ((TLMessageMedia$messageMediaUnsupported *)concreteMessage.media).bytes;
                    
                    if (mediaAttachments == nil)
                    {
                        mediaAttachments = [NSArray arrayWithObject:unsupportedAttachment];
                    }
                    else
                    {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        [array addObjectsFromArray:mediaAttachments];
                        [array addObject:unsupportedAttachment];
                        mediaAttachments = array;
                    }
                }
                else if ([concreteMessage.media isKindOfClass:[TLMessageMedia$messageMediaDocument class]])
                {
                    TLMessageMedia$messageMediaDocument *documentMedia = (TLMessageMedia$messageMediaDocument *)concreteMessage.media;
                    TGDocumentMediaAttachment *documentAttachment = [[TGDocumentMediaAttachment alloc] initWithTelegraphDocumentDesc:documentMedia.document];
                    
                    if (mediaAttachments == nil)
                        mediaAttachments = [NSArray arrayWithObject:documentAttachment];
                    else
                    {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        [array addObjectsFromArray:mediaAttachments];
                        [array addObject:documentAttachment];
                        mediaAttachments = array;
                    }
                }
                else if ([concreteMessage.media isKindOfClass:[TLMessageMedia$messageMediaAudio class]])
                {
                    TLMessageMedia$messageMediaAudio *audioMedia = (TLMessageMedia$messageMediaAudio *)concreteMessage.media;
                    TGAudioMediaAttachment *audioAttachment = [[TGAudioMediaAttachment alloc] initWithTelegraphAudioDesc:audioMedia.audio];
                    
                    if (mediaAttachments == nil)
                        mediaAttachments = [NSArray arrayWithObject:audioAttachment];
                    else
                    {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        [array addObjectsFromArray:mediaAttachments];
                        [array addObject:audioAttachment];
                        mediaAttachments = array;
                    }
                }
            }
        }
        else if ([desc isKindOfClass:[TLMessage$messageService class]])
        {
            TLMessage$messageService *concreteMessage = (TLMessage$messageService *)desc;
            
            self.mid = concreteMessage.n_id;
            self.unread = concreteMessage.flags & 1;
            self.outgoing = concreteMessage.flags & 2;
            self.fromUid = concreteMessage.from_id;
            
            self.text = @"";
            self.date = concreteMessage.date;
            
            if ([concreteMessage.to_id isKindOfClass:[TLPeer$peerUser class]])
            {
                TLPeer$peerUser *toUser = (TLPeer$peerUser *)concreteMessage.to_id;
                self.toUid = toUser.user_id;
                if (self.toUid == self.fromUid && !self.outgoing)
                    self.outgoing = true;
                self.cid = self.outgoing ? self.toUid : self.fromUid;
            }
            else if ([concreteMessage.to_id isKindOfClass:[TLPeer$peerChat class]])
            {
                TLPeer$peerChat *toChat = (TLPeer$peerChat *)concreteMessage.to_id;
                self.toUid = -toChat.chat_id;
                self.cid = self.toUid;
            }
            
            TLMessageAction *action = concreteMessage.action;
            if (action != nil && ![action isKindOfClass:[TLMessageAction$messageActionEmpty class]])
            {
                TGActionMediaAttachment *actionMediaAttachment = [[TGActionMediaAttachment alloc] initWithTelegraphActionDesc:action];
                if (actionMediaAttachment != nil && actionMediaAttachment.actionType != TGMessageActionNone)
                {
                    if (mediaAttachments == nil)
                    {
                        mediaAttachments = [NSArray arrayWithObject:actionMediaAttachment];
                    }
                    else
                    {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        [array addObjectsFromArray:mediaAttachments];
                        [array addObject:actionMediaAttachment];
                        mediaAttachments = array;
                    }
                }
            }
        }
        
        self.mediaAttachments = mediaAttachments;
    }
    return self;
}

- (instancetype)initWithDecryptedMessageDesc1:(Secret1_DecryptedMessage *)desc encryptedFile:(TGStoredIncomingMessageFileInfo *)encryptedFile conversationId:(int64_t)conversationId fromUid:(int)fromUid date:(int)date
{
    self = [super init];
    if (self != nil)
    {
        self.randomId = (int64_t)[desc.random_id longLongValue];
        self.fromUid = fromUid;
        self.toUid = TGTelegraphInstance.clientUserId;
        self.date = date;
        self.unread = true;
        self.outgoing = false;
        self.cid = conversationId;
        
        NSArray *mediaAttachments = nil;
        
        if ([desc isKindOfClass:[Secret1_DecryptedMessage_decryptedMessage class]])
        {
            Secret1_DecryptedMessage_decryptedMessage *concreteMessage = (Secret1_DecryptedMessage_decryptedMessage *)desc;
            
            self.text = concreteMessage.message;
            
            if (![concreteMessage.media isKindOfClass:[Secret1_DecryptedMessageMedia_decryptedMessageMediaEmpty class]])
            {
                if ([concreteMessage.media isKindOfClass:[Secret1_DecryptedMessageMedia_decryptedMessageMediaPhoto class]])
                {
                    if (encryptedFile != nil)
                    {
                        Secret1_DecryptedMessageMedia_decryptedMessageMediaPhoto *decryptedPhoto = (Secret1_DecryptedMessageMedia_decryptedMessageMediaPhoto *)concreteMessage.media;
                        
                        TGImageMediaAttachment *imageAttachment = [[TGImageMediaAttachment alloc] init];
                        
                        imageAttachment.imageId = encryptedFile.n_id;
                        imageAttachment.accessHash = encryptedFile.accessHash;
                        
                        NSString *thumbnailUrl = [[NSString alloc] initWithFormat:@"encryptedThumbnail:%lld", encryptedFile.n_id];
                        
                        TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
                        [imageInfo addImageWithSize:CGSizeMake([decryptedPhoto.thumb_w intValue], [decryptedPhoto.thumb_h intValue]) url:thumbnailUrl];
                        
                        [[TGRemoteImageView sharedCache] diskCacheContains:thumbnailUrl orUrl:nil completion:^(bool containsFirst, __unused bool containsSecond)
                        {
                            if (!containsFirst)
                            {
                                if (decryptedPhoto.thumb.length < 128 * 1024)
                                {
                                    if (TGEnableBlur() && cpuCoreCount() > 1)
                                    {
                                        NSData *data = nil;
                                        TGScaleAndBlurImage(decryptedPhoto.thumb, CGSizeZero, &data);
                                        if (data != nil)
                                            [[TGRemoteImageView sharedCache] cacheImage:nil withData:data url:thumbnailUrl availability:TGCacheDisk];
                                        else
                                            [[TGRemoteImageView sharedCache] cacheImage:nil withData:decryptedPhoto.thumb url:thumbnailUrl availability:TGCacheDisk];
                                    }
                                    else
                                        [[TGRemoteImageView sharedCache] cacheImage:nil withData:decryptedPhoto.thumb url:thumbnailUrl availability:TGCacheDisk];
                                }
                            }
                        }];
                        
                        NSString *fileUrl = [[NSString alloc] initWithFormat:@"mt-encrypted-file://?dc=%d&id=%lld&accessHash=%lld&size=%d&decryptedSize=%d&fingerprint=%d&key=%@%@", encryptedFile.datacenterId, encryptedFile.n_id, encryptedFile.accessHash, encryptedFile.size, [decryptedPhoto.size intValue], encryptedFile.keyFingerprint, [decryptedPhoto.key stringByEncodingInHex], [decryptedPhoto.iv stringByEncodingInHex]];
                        
                        [imageInfo addImageWithSize:CGSizeMake([decryptedPhoto.w intValue], [decryptedPhoto.h intValue]) url:fileUrl fileSize:encryptedFile.size];
                        
                        imageAttachment.imageInfo = imageInfo;
                        
                        if (mediaAttachments == nil)
                            mediaAttachments = [NSArray arrayWithObject:imageAttachment];
                        else
                        {
                            NSMutableArray *array = [[NSMutableArray alloc] init];
                            [array addObjectsFromArray:mediaAttachments];
                            [array addObject:imageAttachment];
                            mediaAttachments = array;
                        }
                    }
                }
                else if ([concreteMessage.media isKindOfClass:[Secret1_DecryptedMessageMedia_decryptedMessageMediaVideo class]])
                {
                    if (encryptedFile != nil)
                    {
                        Secret1_DecryptedMessageMedia_decryptedMessageMediaVideo *decryptedVideo = (Secret1_DecryptedMessageMedia_decryptedMessageMediaVideo *)concreteMessage.media;
                        
                        TGVideoMediaAttachment *videoAttachment = [[TGVideoMediaAttachment alloc] init];
                        
                        videoAttachment.videoId = encryptedFile.n_id;
                        videoAttachment.accessHash = encryptedFile.accessHash;
                        
                        NSString *thumbnailUrl = [[NSString alloc] initWithFormat:@"encryptedThumbnail:%lld", encryptedFile.n_id];
                        
                        TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
                        [imageInfo addImageWithSize:CGSizeMake([decryptedVideo.thumb_w intValue], [decryptedVideo.thumb_h intValue]) url:thumbnailUrl];
                        
                        [[TGRemoteImageView sharedCache] diskCacheContains:thumbnailUrl orUrl:nil completion:^(bool containsFirst, __unused bool containsSecond)
                        {
                            if (!containsFirst)
                            {
                                if (decryptedVideo.thumb.length < 128 * 1024)
                                {
                                    if (TGEnableBlur() && cpuCoreCount() > 1)
                                    {
                                        NSData *data = nil;
                                        TGScaleAndBlurImage(decryptedVideo.thumb, CGSizeZero, &data);
                                        if (data != nil)
                                            [[TGRemoteImageView sharedCache] cacheImage:nil withData:data url:thumbnailUrl availability:TGCacheDisk];
                                        else
                                            [[TGRemoteImageView sharedCache] cacheImage:nil withData:decryptedVideo.thumb url:thumbnailUrl availability:TGCacheDisk];
                                    }
                                    else
                                        [[TGRemoteImageView sharedCache] cacheImage:nil withData:decryptedVideo.thumb url:thumbnailUrl availability:TGCacheDisk];
                                }
                            }
                        }];
                        
                        videoAttachment.thumbnailInfo = imageInfo;
                        
                        videoAttachment.duration = [decryptedVideo.duration intValue];
                        videoAttachment.dimensions = CGSizeMake([decryptedVideo.w intValue], [decryptedVideo.h intValue]);
                        
                        TGVideoInfo *videoInfo = [[TGVideoInfo alloc] init];
                        
                        NSString *fileUrl = [[NSString alloc] initWithFormat:@"mt-encrypted-file://?dc=%d&id=%lld&accessHash=%lld&size=%d&decryptedSize=%d&fingerprint=%d&key=%@%@", encryptedFile.datacenterId, encryptedFile.n_id, encryptedFile.accessHash, encryptedFile.size, [decryptedVideo.size intValue], encryptedFile.keyFingerprint, [decryptedVideo.key stringByEncodingInHex], [decryptedVideo.iv stringByEncodingInHex]];
                        
                        [videoInfo addVideoWithQuality:1 url:fileUrl size:[decryptedVideo.size intValue]];
                        videoAttachment.videoInfo = videoInfo;
                        
                        if (mediaAttachments == nil)
                            mediaAttachments = [NSArray arrayWithObject:videoAttachment];
                        else
                        {
                            NSMutableArray *array = [[NSMutableArray alloc] init];
                            [array addObjectsFromArray:mediaAttachments];
                            [array addObject:videoAttachment];
                            mediaAttachments = array;
                        }
                    }
                }
                else if ([concreteMessage.media isKindOfClass:[Secret1_DecryptedMessageMedia_decryptedMessageMediaDocument class]])
                {
                    Secret1_DecryptedMessageMedia_decryptedMessageMediaDocument *decryptedDocument = (Secret1_DecryptedMessageMedia_decryptedMessageMediaDocument *)concreteMessage.media;
                    
                    TGDocumentMediaAttachment *documentAttachment = [[TGDocumentMediaAttachment alloc] init];
                    
                    int64_t localId = 0;
                    arc4random_buf(&localId, sizeof(localId));
                    
                    documentAttachment.localDocumentId = localId;
                    documentAttachment.fileName = decryptedDocument.file_name;
                    documentAttachment.mimeType = decryptedDocument.mime_type;
                    documentAttachment.size = [decryptedDocument.size intValue];
                    
                    documentAttachment.documentUri = [[NSString alloc] initWithFormat:@"mt-encrypted-file://?dc=%d&id=%lld&accessHash=%lld&size=%d&decryptedSize=%d&fingerprint=%d&key=%@%@", encryptedFile.datacenterId, encryptedFile.n_id, encryptedFile.accessHash, encryptedFile.size, [decryptedDocument.size intValue], encryptedFile.keyFingerprint, [decryptedDocument.key stringByEncodingInHex], [decryptedDocument.iv stringByEncodingInHex]];
                    
                    if (decryptedDocument.thumb != nil && [decryptedDocument.thumb_w intValue] > 0 && [decryptedDocument.thumb_h intValue] > 0)
                    {
                        NSString *thumbnailUrl = [[NSString alloc] initWithFormat:@"encryptedThumbnail:%lld", encryptedFile.n_id];
                        
                        TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
                        [imageInfo addImageWithSize:CGSizeMake([decryptedDocument.thumb_w intValue], [decryptedDocument.thumb_h intValue]) url:thumbnailUrl];
                        documentAttachment.thumbnailInfo = imageInfo;
                        
                        [[TGRemoteImageView sharedCache] diskCacheContains:thumbnailUrl orUrl:nil completion:^(bool containsFirst, __unused bool containsSecond)
                        {
                            if (!containsFirst)
                            {
                                if (decryptedDocument.thumb.length < 128 * 1024)
                                {
                                    if (TGEnableBlur() && cpuCoreCount() > 1)
                                    {
                                        NSData *data = nil;
                                        TGScaleAndBlurImage(decryptedDocument.thumb, CGSizeZero, &data);
                                        if (data != nil)
                                            [[TGRemoteImageView sharedCache] cacheImage:nil withData:data url:thumbnailUrl availability:TGCacheDisk];
                                        else
                                            [[TGRemoteImageView sharedCache] cacheImage:nil withData:decryptedDocument.thumb url:thumbnailUrl availability:TGCacheDisk];
                                    }
                                    else
                                        [[TGRemoteImageView sharedCache] cacheImage:nil withData:decryptedDocument.thumb url:thumbnailUrl availability:TGCacheDisk];
                                }
                            }
                        }];
                    }
                    
                    if (mediaAttachments == nil)
                        mediaAttachments = [NSArray arrayWithObject:documentAttachment];
                    else
                    {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        [array addObjectsFromArray:mediaAttachments];
                        [array addObject:documentAttachment];
                        mediaAttachments = array;
                    }
                }
                else if ([concreteMessage.media isKindOfClass:[Secret1_DecryptedMessageMedia_decryptedMessageMediaAudio class]])
                {
                    Secret1_DecryptedMessageMedia_decryptedMessageMediaAudio *decryptedAudio = (Secret1_DecryptedMessageMedia_decryptedMessageMediaAudio *)concreteMessage.media;
                    
                    TGAudioMediaAttachment *audioAttachment = [[TGAudioMediaAttachment alloc] init];
                    
                    int64_t localId = 0;
                    arc4random_buf(&localId, sizeof(localId));
                    
                    audioAttachment.localAudioId = localId;
                    audioAttachment.duration = [decryptedAudio.duration intValue];
                    audioAttachment.fileSize = [decryptedAudio.size intValue];
                    
                    audioAttachment.audioUri = [[NSString alloc] initWithFormat:@"mt-encrypted-file://?dc=%d&id=%lld&accessHash=%lld&size=%d&decryptedSize=%d&fingerprint=%d&key=%@%@", encryptedFile.datacenterId, encryptedFile.n_id, encryptedFile.accessHash, encryptedFile.size, [decryptedAudio.size intValue], encryptedFile.keyFingerprint, [decryptedAudio.key stringByEncodingInHex], [decryptedAudio.iv stringByEncodingInHex]];
                    
                    if (mediaAttachments == nil)
                        mediaAttachments = [NSArray arrayWithObject:audioAttachment];
                    else
                    {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        [array addObjectsFromArray:mediaAttachments];
                        [array addObject:audioAttachment];
                        mediaAttachments = array;
                    }
                }
                else if ([concreteMessage.media isKindOfClass:[Secret1_DecryptedMessageMedia_decryptedMessageMediaGeoPoint class]])
                {
                    Secret1_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *concreteGeo = (Secret1_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)concreteMessage.media;
                    
                    TGLocationMediaAttachment *locationMediaAttachment = [[TGLocationMediaAttachment alloc] init];
                    locationMediaAttachment.latitude = [concreteGeo.lat doubleValue];
                    locationMediaAttachment.longitude = [concreteGeo.plong doubleValue];
                    
                    if (mediaAttachments == nil)
                        mediaAttachments = [NSArray arrayWithObject:locationMediaAttachment];
                    else
                    {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        [array addObjectsFromArray:mediaAttachments];
                        [array addObject:locationMediaAttachment];
                        mediaAttachments = array;
                    }
                }
                else if ([concreteMessage.media isKindOfClass:[Secret1_DecryptedMessageMedia_decryptedMessageMediaContact class]])
                {
                    Secret1_DecryptedMessageMedia_decryptedMessageMediaContact *mediaContact = (Secret1_DecryptedMessageMedia_decryptedMessageMediaContact *)concreteMessage.media;
                    
                    TLMessageMedia$messageMediaContact *convertedContact = [[TLMessageMedia$messageMediaContact alloc] init];
                    convertedContact.phone_number = mediaContact.phone_number;
                    convertedContact.first_name = mediaContact.first_name;
                    convertedContact.last_name = mediaContact.last_name;
                    convertedContact.user_id = [mediaContact.user_id intValue];
                    
                    TGContactMediaAttachment *contactAttachment = [[TGContactMediaAttachment alloc] initWithTelegraphContactDesc:convertedContact];
                    
                    if (mediaAttachments == nil)
                        mediaAttachments = [NSArray arrayWithObject:contactAttachment];
                    else
                    {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        [array addObjectsFromArray:mediaAttachments];
                        [array addObject:contactAttachment];
                        mediaAttachments = array;
                    }
                }
            }
        }
        else if ([desc isKindOfClass:[Secret1_DecryptedMessage_decryptedMessageService class]])
        {
            Secret1_DecryptedMessage_decryptedMessageService *concreteMessage = (Secret1_DecryptedMessage_decryptedMessageService *)desc;
            self.unread = false;
            
            if ([concreteMessage.action isKindOfClass:[Secret1_DecryptedMessageAction_decryptedMessageActionSetMessageTTL class]])
            {
                Secret1_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *concreteAction = (Secret1_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)concreteMessage.action;
                
                TGActionMediaAttachment *actionAttachment = [[TGActionMediaAttachment alloc] init];
                actionAttachment.actionType = TGMessageActionEncryptedChatMessageLifetime;
                actionAttachment.actionData = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:[concreteAction.ttl_seconds intValue]], @"messageLifetime", nil];
                
                if (mediaAttachments == nil)
                    mediaAttachments = [NSArray arrayWithObject:actionAttachment];
                else
                {
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    [array addObjectsFromArray:mediaAttachments];
                    [array addObject:actionAttachment];
                    mediaAttachments = array;
                }
            }
        }
        
        if (mediaAttachments != nil)
            self.mediaAttachments = mediaAttachments;
    }
    return self;
}

- (instancetype)initWithDecryptedMessageDesc17:(Secret17_DecryptedMessage *)desc encryptedFile:(TGStoredIncomingMessageFileInfo *)encryptedFile conversationId:(int64_t)conversationId fromUid:(int)fromUid date:(int)date
{
    self = [super init];
    if (self != nil)
    {
        self.randomId = (int64_t)[desc.random_id longLongValue];
        self.fromUid = fromUid;
        self.toUid = TGTelegraphInstance.clientUserId;
        self.date = date;
        self.unread = true;
        self.outgoing = false;
        self.cid = conversationId;
        
        NSArray *mediaAttachments = nil;
        
        if ([desc isKindOfClass:[Secret17_DecryptedMessage_decryptedMessage class]])
        {
            Secret17_DecryptedMessage_decryptedMessage *concreteMessage = (Secret17_DecryptedMessage_decryptedMessage *)desc;
            
            self.text = concreteMessage.message;
            self.messageLifetime = [concreteMessage.ttl intValue];
            
            if (![concreteMessage.media isKindOfClass:[Secret17_DecryptedMessageMedia_decryptedMessageMediaEmpty class]])
            {
                if ([concreteMessage.media isKindOfClass:[Secret17_DecryptedMessageMedia_decryptedMessageMediaPhoto class]])
                {
                    if (encryptedFile != nil)
                    {
                        Secret17_DecryptedMessageMedia_decryptedMessageMediaPhoto *decryptedPhoto = (Secret17_DecryptedMessageMedia_decryptedMessageMediaPhoto *)concreteMessage.media;
                        
                        TGImageMediaAttachment *imageAttachment = [[TGImageMediaAttachment alloc] init];
                        
                        imageAttachment.imageId = encryptedFile.n_id;
                        imageAttachment.accessHash = encryptedFile.accessHash;
                        
                        NSString *thumbnailUrl = [[NSString alloc] initWithFormat:@"encryptedThumbnail:%lld", encryptedFile.n_id];
                        
                        TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
                        [imageInfo addImageWithSize:CGSizeMake([decryptedPhoto.thumb_w intValue], [decryptedPhoto.thumb_h intValue]) url:thumbnailUrl];
                        
                        [[TGRemoteImageView sharedCache] diskCacheContains:thumbnailUrl orUrl:nil completion:^(bool containsFirst, __unused bool containsSecond)
                        {
                            if (!containsFirst)
                            {
                                if (decryptedPhoto.thumb.length < 128 * 1024)
                                {
                                    if (TGEnableBlur() && cpuCoreCount() > 1)
                                    {
                                        NSData *data = nil;
                                        TGScaleAndBlurImage(decryptedPhoto.thumb, CGSizeZero, &data);
                                        if (data != nil)
                                            [[TGRemoteImageView sharedCache] cacheImage:nil withData:data url:thumbnailUrl availability:TGCacheDisk];
                                        else
                                            [[TGRemoteImageView sharedCache] cacheImage:nil withData:decryptedPhoto.thumb url:thumbnailUrl availability:TGCacheDisk];
                                    }
                                    else
                                        [[TGRemoteImageView sharedCache] cacheImage:nil withData:decryptedPhoto.thumb url:thumbnailUrl availability:TGCacheDisk];
                                }
                            }
                        }];
                        
                        NSString *fileUrl = [[NSString alloc] initWithFormat:@"mt-encrypted-file://?dc=%d&id=%lld&accessHash=%lld&size=%d&decryptedSize=%d&fingerprint=%d&key=%@%@", encryptedFile.datacenterId, encryptedFile.n_id, encryptedFile.accessHash, encryptedFile.size, [decryptedPhoto.size intValue], encryptedFile.keyFingerprint, [decryptedPhoto.key stringByEncodingInHex], [decryptedPhoto.iv stringByEncodingInHex]];
                        
                        [imageInfo addImageWithSize:CGSizeMake([decryptedPhoto.w intValue], [decryptedPhoto.h intValue]) url:fileUrl fileSize:encryptedFile.size];
                        
                        imageAttachment.imageInfo = imageInfo;
                        
                        if (mediaAttachments == nil)
                            mediaAttachments = [NSArray arrayWithObject:imageAttachment];
                        else
                        {
                            NSMutableArray *array = [[NSMutableArray alloc] init];
                            [array addObjectsFromArray:mediaAttachments];
                            [array addObject:imageAttachment];
                            mediaAttachments = array;
                        }
                    }
                }
                else if ([concreteMessage.media isKindOfClass:[Secret17_DecryptedMessageMedia_decryptedMessageMediaVideo class]])
                {
                    if (encryptedFile != nil)
                    {
                        Secret17_DecryptedMessageMedia_decryptedMessageMediaVideo *decryptedVideo = (Secret17_DecryptedMessageMedia_decryptedMessageMediaVideo *)concreteMessage.media;
                        
                        TGVideoMediaAttachment *videoAttachment = [[TGVideoMediaAttachment alloc] init];
                        
                        videoAttachment.videoId = encryptedFile.n_id;
                        videoAttachment.accessHash = encryptedFile.accessHash;
                        
                        NSString *thumbnailUrl = [[NSString alloc] initWithFormat:@"encryptedThumbnail:%lld", encryptedFile.n_id];
                        
                        TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
                        [imageInfo addImageWithSize:CGSizeMake([decryptedVideo.thumb_w intValue], [decryptedVideo.thumb_h intValue]) url:thumbnailUrl];
                        
                        [[TGRemoteImageView sharedCache] diskCacheContains:thumbnailUrl orUrl:nil completion:^(bool containsFirst, __unused bool containsSecond)
                        {
                            if (!containsFirst)
                            {
                                if (decryptedVideo.thumb.length < 128 * 1024)
                                {
                                    if (TGEnableBlur() && cpuCoreCount() > 1)
                                    {
                                        NSData *data = nil;
                                        TGScaleAndBlurImage(decryptedVideo.thumb, CGSizeZero, &data);
                                        if (data != nil)
                                            [[TGRemoteImageView sharedCache] cacheImage:nil withData:data url:thumbnailUrl availability:TGCacheDisk];
                                        else
                                            [[TGRemoteImageView sharedCache] cacheImage:nil withData:decryptedVideo.thumb url:thumbnailUrl availability:TGCacheDisk];
                                    }
                                    else
                                        [[TGRemoteImageView sharedCache] cacheImage:nil withData:decryptedVideo.thumb url:thumbnailUrl availability:TGCacheDisk];
                                }
                            }
                        }];
                        
                        videoAttachment.thumbnailInfo = imageInfo;
                        
                        videoAttachment.duration = [decryptedVideo.duration intValue];
                        videoAttachment.dimensions = CGSizeMake([decryptedVideo.w intValue], [decryptedVideo.h intValue]);
                        
                        TGVideoInfo *videoInfo = [[TGVideoInfo alloc] init];
                        
                        NSString *fileUrl = [[NSString alloc] initWithFormat:@"mt-encrypted-file://?dc=%d&id=%lld&accessHash=%lld&size=%d&decryptedSize=%d&fingerprint=%d&key=%@%@", encryptedFile.datacenterId, encryptedFile.n_id, encryptedFile.accessHash, encryptedFile.size, [decryptedVideo.size intValue], encryptedFile.keyFingerprint, [decryptedVideo.key stringByEncodingInHex], [decryptedVideo.iv stringByEncodingInHex]];
                        
                        [videoInfo addVideoWithQuality:1 url:fileUrl size:[decryptedVideo.size intValue]];
                        videoAttachment.videoInfo = videoInfo;
                        
                        if (mediaAttachments == nil)
                            mediaAttachments = [NSArray arrayWithObject:videoAttachment];
                        else
                        {
                            NSMutableArray *array = [[NSMutableArray alloc] init];
                            [array addObjectsFromArray:mediaAttachments];
                            [array addObject:videoAttachment];
                            mediaAttachments = array;
                        }
                    }
                }
                else if ([concreteMessage.media isKindOfClass:[Secret17_DecryptedMessageMedia_decryptedMessageMediaDocument class]])
                {
                    Secret17_DecryptedMessageMedia_decryptedMessageMediaDocument *decryptedDocument = (Secret17_DecryptedMessageMedia_decryptedMessageMediaDocument *)concreteMessage.media;
                    
                    TGDocumentMediaAttachment *documentAttachment = [[TGDocumentMediaAttachment alloc] init];
                    
                    int64_t localId = 0;
                    arc4random_buf(&localId, sizeof(localId));
                    
                    documentAttachment.localDocumentId = localId;
                    documentAttachment.fileName = decryptedDocument.file_name;
                    documentAttachment.mimeType = decryptedDocument.mime_type;
                    documentAttachment.size = [decryptedDocument.size intValue];
                    
                    documentAttachment.documentUri = [[NSString alloc] initWithFormat:@"mt-encrypted-file://?dc=%d&id=%lld&accessHash=%lld&size=%d&decryptedSize=%d&fingerprint=%d&key=%@%@", encryptedFile.datacenterId, encryptedFile.n_id, encryptedFile.accessHash, encryptedFile.size, [decryptedDocument.size intValue], encryptedFile.keyFingerprint, [decryptedDocument.key stringByEncodingInHex], [decryptedDocument.iv stringByEncodingInHex]];
                    
                    if (decryptedDocument.thumb != nil && [decryptedDocument.thumb_w intValue] > 0 && [decryptedDocument.thumb_h intValue] > 0)
                    {
                        NSString *thumbnailUrl = [[NSString alloc] initWithFormat:@"encryptedThumbnail:%lld", encryptedFile.n_id];
                        
                        TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
                        [imageInfo addImageWithSize:CGSizeMake([decryptedDocument.thumb_w intValue], [decryptedDocument.thumb_h intValue]) url:thumbnailUrl];
                        documentAttachment.thumbnailInfo = imageInfo;
                        
                        [[TGRemoteImageView sharedCache] diskCacheContains:thumbnailUrl orUrl:nil completion:^(bool containsFirst, __unused bool containsSecond)
                        {
                            if (!containsFirst)
                            {
                                if (decryptedDocument.thumb.length < 128 * 1024)
                                {
                                    if (TGEnableBlur() && cpuCoreCount() > 1)
                                    {
                                        NSData *data = nil;
                                        TGScaleAndBlurImage(decryptedDocument.thumb, CGSizeZero, &data);
                                        if (data != nil)
                                            [[TGRemoteImageView sharedCache] cacheImage:nil withData:data url:thumbnailUrl availability:TGCacheDisk];
                                        else
                                            [[TGRemoteImageView sharedCache] cacheImage:nil withData:decryptedDocument.thumb url:thumbnailUrl availability:TGCacheDisk];
                                    }
                                    else
                                        [[TGRemoteImageView sharedCache] cacheImage:nil withData:decryptedDocument.thumb url:thumbnailUrl availability:TGCacheDisk];
                                }
                            }
                        }];
                    }
                    
                    if (mediaAttachments == nil)
                        mediaAttachments = [NSArray arrayWithObject:documentAttachment];
                    else
                    {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        [array addObjectsFromArray:mediaAttachments];
                        [array addObject:documentAttachment];
                        mediaAttachments = array;
                    }
                }
                else if ([concreteMessage.media isKindOfClass:[Secret17_DecryptedMessageMedia_decryptedMessageMediaAudio class]])
                {
                    Secret17_DecryptedMessageMedia_decryptedMessageMediaAudio *decryptedAudio = (Secret17_DecryptedMessageMedia_decryptedMessageMediaAudio *)concreteMessage.media;
                    
                    TGAudioMediaAttachment *audioAttachment = [[TGAudioMediaAttachment alloc] init];
                    
                    int64_t localId = 0;
                    arc4random_buf(&localId, sizeof(localId));
                    
                    audioAttachment.localAudioId = localId;
                    audioAttachment.duration = [decryptedAudio.duration intValue];
                    audioAttachment.fileSize = [decryptedAudio.size intValue];
                    
                    audioAttachment.audioUri = [[NSString alloc] initWithFormat:@"mt-encrypted-file://?dc=%d&id=%lld&accessHash=%lld&size=%d&decryptedSize=%d&fingerprint=%d&key=%@%@", encryptedFile.datacenterId, encryptedFile.n_id, encryptedFile.accessHash, encryptedFile.size, [decryptedAudio.size intValue], encryptedFile.keyFingerprint, [decryptedAudio.key stringByEncodingInHex], [decryptedAudio.iv stringByEncodingInHex]];
                    
                    if (mediaAttachments == nil)
                        mediaAttachments = [NSArray arrayWithObject:audioAttachment];
                    else
                    {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        [array addObjectsFromArray:mediaAttachments];
                        [array addObject:audioAttachment];
                        mediaAttachments = array;
                    }
                }
                else if ([concreteMessage.media isKindOfClass:[Secret17_DecryptedMessageMedia_decryptedMessageMediaGeoPoint class]])
                {
                    Secret17_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *concreteGeo = (Secret17_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)concreteMessage.media;
                    
                    TGLocationMediaAttachment *locationMediaAttachment = [[TGLocationMediaAttachment alloc] init];
                    locationMediaAttachment.latitude = [concreteGeo.lat doubleValue];
                    locationMediaAttachment.longitude = [concreteGeo.plong doubleValue];
                    
                    if (mediaAttachments == nil)
                        mediaAttachments = [NSArray arrayWithObject:locationMediaAttachment];
                    else
                    {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        [array addObjectsFromArray:mediaAttachments];
                        [array addObject:locationMediaAttachment];
                        mediaAttachments = array;
                    }
                }
                else if ([concreteMessage.media isKindOfClass:[Secret17_DecryptedMessageMedia_decryptedMessageMediaContact class]])
                {
                    Secret17_DecryptedMessageMedia_decryptedMessageMediaContact *mediaContact = (Secret17_DecryptedMessageMedia_decryptedMessageMediaContact *)concreteMessage.media;
                    
                    TLMessageMedia$messageMediaContact *convertedContact = [[TLMessageMedia$messageMediaContact alloc] init];
                    convertedContact.phone_number = mediaContact.phone_number;
                    convertedContact.first_name = mediaContact.first_name;
                    convertedContact.last_name = mediaContact.last_name;
                    convertedContact.user_id = [mediaContact.user_id intValue];
                    
                    TGContactMediaAttachment *contactAttachment = [[TGContactMediaAttachment alloc] initWithTelegraphContactDesc:convertedContact];
                    
                    if (mediaAttachments == nil)
                        mediaAttachments = [NSArray arrayWithObject:contactAttachment];
                    else
                    {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        [array addObjectsFromArray:mediaAttachments];
                        [array addObject:contactAttachment];
                        mediaAttachments = array;
                    }
                }
            }
        }
        else if ([desc isKindOfClass:[Secret17_DecryptedMessage_decryptedMessageService class]])
        {
            Secret17_DecryptedMessage_decryptedMessageService *concreteMessage = (Secret17_DecryptedMessage_decryptedMessageService *)desc;
            self.unread = false;
            
            if ([concreteMessage.action isKindOfClass:[Secret17_DecryptedMessageAction_decryptedMessageActionSetMessageTTL class]])
            {
                Secret17_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *concreteAction = (Secret17_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)concreteMessage.action;
                
                TGActionMediaAttachment *actionAttachment = [[TGActionMediaAttachment alloc] init];
                actionAttachment.actionType = TGMessageActionEncryptedChatMessageLifetime;
                actionAttachment.actionData = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:[concreteAction.ttl_seconds intValue]], @"messageLifetime", nil];
                
                if (mediaAttachments == nil)
                    mediaAttachments = [NSArray arrayWithObject:actionAttachment];
                else
                {
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    [array addObjectsFromArray:mediaAttachments];
                    [array addObject:actionAttachment];
                    mediaAttachments = array;
                }
            }
            else if ([concreteMessage.action isKindOfClass:[Secret17_DecryptedMessageAction_decryptedMessageActionScreenshotMessages class]])
            {
                Secret17_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *concreteAction = (Secret17_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)concreteMessage.action;
                TGActionMediaAttachment *actionAttachment = [[TGActionMediaAttachment alloc] init];
                actionAttachment.actionType = TGMessageActionEncryptedChatMessageScreenshot;
                actionAttachment.actionData = @{@"randomIds": concreteAction.random_ids};
                
                if (mediaAttachments == nil)
                    mediaAttachments = [NSArray arrayWithObject:actionAttachment];
                else
                {
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    [array addObjectsFromArray:mediaAttachments];
                    [array addObject:actionAttachment];
                    mediaAttachments = array;
                }
            }
        }
        else
            return nil;
        
        if (mediaAttachments != nil)
            self.mediaAttachments = mediaAttachments;
    }
    return self;
}

@end
