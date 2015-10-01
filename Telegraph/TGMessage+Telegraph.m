#import "TGMessage+Telegraph.h"

#import "TGSchema.h"

#import "TGPeerIdAdapter.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "TGTelegraph.h"

#import "TGImageMediaAttachment+Telegraph.h"
#import "TGVideoMediaAttachment+Telegraph.h"
#import "TGActionMediaAttachment+Telegraph.h"
#import "TGContactMediaAttachment+Telegraph.h"
#import "TGDocumentMediaAttachment+Telegraph.h"
#import "TGAudioMediaAttachment+Telegraph.h"
#import "TGWebPageMediaAttachment+Telegraph.h"
#import "TGImageInfo+Telegraph.h"

#import "TGRemoteImageView.h"

#import "TLMessage$modernMessage.h"
#import "TLMessage$modernMessageService.h"

#import "TGDatabase.h"

#import "TGMessageViewedContentProperty.h"

#import "TGBotSignals.h"

@implementation TGMessage (Telegraph)

+ (NSArray *)parseTelegraphMedia:(id)media
{
    NSMutableArray *mediaAttachments = [[NSMutableArray alloc] init];
    
    if ([media isKindOfClass:[TLMessageMedia$messageMediaPhoto class]])
    {
        TLMessageMedia$messageMediaPhoto *mediaPhoto = (TLMessageMedia$messageMediaPhoto *)media;
        
        TGImageMediaAttachment *imageMediaAttachment = [[TGImageMediaAttachment alloc] initWithTelegraphDesc:mediaPhoto.photo];
        imageMediaAttachment.caption = mediaPhoto.caption;
        
        [mediaAttachments addObject:imageMediaAttachment];
    }
    else if ([media isKindOfClass:[TLMessageMedia$messageMediaVideo class]])
    {
        TLMessageMedia$messageMediaVideo *mediaVideo = (TLMessageMedia$messageMediaVideo *)media;
        
        TGVideoMediaAttachment *videoAttachment = [[TGVideoMediaAttachment alloc] initWithTelegraphVideoDesc:mediaVideo.video];
        videoAttachment.caption = mediaVideo.caption;
        
        [mediaAttachments addObject:videoAttachment];
    }
    else if ([media isKindOfClass:[TLMessageMedia$messageMediaContact class]])
    {
        TLMessageMedia$messageMediaContact *mediaContact = (TLMessageMedia$messageMediaContact *)media;
        
        TGContactMediaAttachment *contactAttachment = [[TGContactMediaAttachment alloc] initWithTelegraphContactDesc:mediaContact];
        
        [mediaAttachments addObject:contactAttachment];
    }
    else if ([media isKindOfClass:[TLMessageMedia$messageMediaGeo class]])
    {
        TLMessageMedia$messageMediaGeo *mediaGeo = (TLMessageMedia$messageMediaGeo *)media;
        
        if ([mediaGeo.geo isKindOfClass:[TLGeoPoint$geoPoint class]])
        {
            TLGeoPoint$geoPoint *concreteGeo = (TLGeoPoint$geoPoint *)mediaGeo.geo;
            
            TGLocationMediaAttachment *locationMediaAttachment = [[TGLocationMediaAttachment alloc] init];
            locationMediaAttachment.latitude = concreteGeo.lat;
            locationMediaAttachment.longitude = concreteGeo.n_long;
            
            [mediaAttachments addObject:locationMediaAttachment];
        }
        else if ([mediaGeo.geo isKindOfClass:[TLGeoPoint$geoPlace class]])
        {
            TLGeoPoint$geoPlace *concreteGeo = (TLGeoPoint$geoPlace *)mediaGeo.geo;
            
            TGLocationMediaAttachment *locationMediaAttachment = [[TGLocationMediaAttachment alloc] init];
            locationMediaAttachment.latitude = concreteGeo.lat;
            locationMediaAttachment.longitude = concreteGeo.n_long;
            
            [mediaAttachments addObject:locationMediaAttachment];
        }
    }
    else if ([media isKindOfClass:[TLMessageMedia$messageMediaVenue class]])
    {
        TLMessageMedia$messageMediaVenue *mediaVenue = (TLMessageMedia$messageMediaVenue *)media;
        TGLocationMediaAttachment *locationMediaAttachment = [[TGLocationMediaAttachment alloc] init];
        [mediaAttachments addObject:locationMediaAttachment];
        
        if ([mediaVenue.geo isKindOfClass:[TLGeoPoint$geoPoint class]])
        {
            TLGeoPoint$geoPoint *concreteGeo = (TLGeoPoint$geoPoint *)mediaVenue.geo;
            
            locationMediaAttachment.latitude = concreteGeo.lat;
            locationMediaAttachment.longitude = concreteGeo.n_long;
        }
        else if ([mediaVenue.geo isKindOfClass:[TLGeoPoint$geoPlace class]])
        {
            TLGeoPoint$geoPlace *concreteGeo = (TLGeoPoint$geoPlace *)mediaVenue.geo;
            
            locationMediaAttachment.latitude = concreteGeo.lat;
            locationMediaAttachment.longitude = concreteGeo.n_long;
        }
        
        locationMediaAttachment.venue = [[TGVenueAttachment alloc] initWithTitle:mediaVenue.title address:mediaVenue.address provider:mediaVenue.provider venueId:mediaVenue.venue_id];
    }
    else if ([media isKindOfClass:[TLMessageMedia$messageMediaUnsupported class]])
    {
        TGUnsupportedMediaAttachment *unsupportedAttachment = [[TGUnsupportedMediaAttachment alloc] init];
        [mediaAttachments addObject:unsupportedAttachment];
    }
    else if ([media isKindOfClass:[TLMessageMedia$messageMediaDocument class]])
    {
        TLMessageMedia$messageMediaDocument *documentMedia = (TLMessageMedia$messageMediaDocument *)media;
        TGDocumentMediaAttachment *documentAttachment = [[TGDocumentMediaAttachment alloc] initWithTelegraphDocumentDesc:documentMedia.document];
        
        [mediaAttachments addObject:documentAttachment];
    }
    else if ([media isKindOfClass:[TLMessageMedia$messageMediaAudio class]])
    {
        TLMessageMedia$messageMediaAudio *audioMedia = (TLMessageMedia$messageMediaAudio *)media;
        TGAudioMediaAttachment *audioAttachment = [[TGAudioMediaAttachment alloc] initWithTelegraphAudioDesc:audioMedia.audio];

        [mediaAttachments addObject:audioAttachment];
    }
    else if ([media isKindOfClass:[TLMessageMedia$messageMediaWebPage class]])
    {
        TGWebPageMediaAttachment *webPage = [[TGWebPageMediaAttachment alloc] initWithTelegraphWebPageDesc:((TLMessageMedia$messageMediaWebPage *)media).webpage];
        
        [mediaAttachments addObject:webPage];
    }
    
    return mediaAttachments;
}

- (id)initWithTelegraphMessageDesc:(TLMessage *)desc
{
    self = [super init];
    if (self != nil)
    {
        NSArray *mediaAttachments = nil;
        TGReplyMarkupAttachment *replyMarkupAttachment = nil;
        TGMessageEntitiesAttachment *entitiesAttachment = nil;
        
        if ([desc isKindOfClass:[TLMessage$message class]] || [desc isKindOfClass:[TLMessage$modernMessage class]])
        {
            TLMessage$message *concreteMessage = (TLMessage$message *)desc;
            
            self.containsMention = concreteMessage.flags & (1 << 4);
            
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
            else if ([concreteMessage.to_id isKindOfClass:[TLPeer$peerChannel class]])
            {
                TLPeer$peerChannel *toChannel = (TLPeer$peerChannel *)concreteMessage.to_id;
                self.toUid = TGPeerIdFromChannelId(toChannel.channel_id);
                self.cid = self.toUid;
                
                if ((concreteMessage.flags & 16) != 0 || (concreteMessage.flags & 2) != 0 || (concreteMessage.flags & 256) == 0) {
                    self.sortKey = TGMessageSortKeyMake(self.cid, TGMessageSpaceImportant, concreteMessage.date, self.mid);
                } else {
                    self.sortKey = TGMessageSortKeyMake(self.cid, TGMessageSpaceUnimportant, concreteMessage.date, self.mid);
                }
                
                if ((concreteMessage.flags & 256) == 0) {
                    self.fromUid = self.cid;
                }
            }

            if ([desc isKindOfClass:[TLMessage$modernMessage class]])
            {
                TLMessage$modernMessage *modernMessage = (TLMessage$modernMessage *)desc;
                if (modernMessage.fwd_from_id != 0 && modernMessage.fwd_date != 0)
                {
                    TGForwardedMessageMediaAttachment *forwardedMessageAttachment = [[TGForwardedMessageMediaAttachment alloc] init];
                    if ([modernMessage.fwd_from_id isKindOfClass:[TLPeer$peerUser class]]) {
                        forwardedMessageAttachment.forwardPeerId = ((TLPeer$peerUser *)modernMessage.fwd_from_id).user_id;
                    } else if ([modernMessage.fwd_from_id isKindOfClass:[TLPeer$peerChannel class]]) {
                        forwardedMessageAttachment.forwardPeerId = TGPeerIdFromChannelId(((TLPeer$peerChannel *)modernMessage.fwd_from_id).channel_id);
                    }
                    forwardedMessageAttachment.forwardDate = modernMessage.fwd_date;
                    
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
                
                if (modernMessage.reply_to_msg_id != 0)
                {
                    TGMessage *replyMessage = [TGDatabaseInstance() loadMessageWithMid:modernMessage.reply_to_msg_id peerId:self.cid];

                    TGReplyMessageMediaAttachment *replyAttachment = [[TGReplyMessageMediaAttachment alloc] init];

                    replyAttachment.replyMessage = replyMessage;
                    replyAttachment.replyMessageId = modernMessage.reply_to_msg_id;
                    
                    if (mediaAttachments == nil)
                        mediaAttachments = [NSArray arrayWithObject:replyAttachment];
                    else
                    {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        [array addObjectsFromArray:mediaAttachments];
                        [array addObject:replyAttachment];
                        mediaAttachments = array;
                    }
                }
                
                if (modernMessage.flags & (1 << 10)) {
                    self.viewCount = [[TGMessageViewCountContentProperty alloc] initWithViewCount:modernMessage.views];
                }
            }
            
            if (concreteMessage.media != nil)
            {
                NSArray *parsedMedia = [TGMessage parseTelegraphMedia:concreteMessage.media];
                if (mediaAttachments == nil)
                    mediaAttachments = parsedMedia;
                else
                {
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    [array addObjectsFromArray:mediaAttachments];
                    [array addObjectsFromArray:parsedMedia];
                    mediaAttachments = array;
                }
                
                bool hasContentToRead = false;
                for (id media in mediaAttachments)
                {
                    if ([media isKindOfClass:[TGAudioMediaAttachment class]])
                    {
                        hasContentToRead |= (concreteMessage.flags & (1 << 5)) == 0;
                        break;
                    }
                }
                
                if (hasContentToRead || TGPeerIdIsChannel(self.cid))
                {
                    NSMutableDictionary *contentProperties = [[NSMutableDictionary alloc] initWithDictionary:self.contentProperties];
                    contentProperties[@"contentsRead"] = [[TGMessageViewedContentProperty alloc] init];
                    self.contentProperties = contentProperties;
                }
            }
            
            if ([desc isKindOfClass:[TLMessage$modernMessage class]] && ((TLMessage$modernMessage *)desc).replyMarkup != nil)
            {
                bool hidePreviousMarkup = false;
                bool forceReply = false;
                bool onlyIfRelevantToUser = false;
                TGBotReplyMarkup *replyMarkup = [TGBotSignals botReplyMarkupForMarkup:((TLMessage$modernMessage *)desc).replyMarkup userId:(int32_t)self.fromUid messageId:self.mid hidePreviousMarkup:&hidePreviousMarkup forceReply:&forceReply onlyIfRelevantToUser:&onlyIfRelevantToUser];
                
                if (!onlyIfRelevantToUser || ((TLMessage$modernMessage *)desc).flags & (1 << 4))
                {
                    self.hideReplyMarkup = hidePreviousMarkup;
                    self.forceReply = forceReply;
                    
                    if (replyMarkup != nil)
                    {
                        replyMarkupAttachment = [[TGReplyMarkupAttachment alloc] init];
                        replyMarkupAttachment.replyMarkup = replyMarkup;
                    }
                }
            }
            
            if ([desc isKindOfClass:[TLMessage$modernMessage class]] && ((TLMessage$modernMessage *)desc).entities != nil)
            {
                NSMutableArray *entities = [[NSMutableArray alloc] init];
                for (id entity in ((TLMessage$modernMessage *)desc).entities)
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
                    entitiesAttachment = [[TGMessageEntitiesAttachment alloc] init];
                    entitiesAttachment.entities = entities;
                }
            }
        }
        else if ([desc isKindOfClass:[TLMessage$modernMessageService class]])
        {
            TLMessage$modernMessageService *concreteMessage = (TLMessage$modernMessageService *)desc;
            
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
            else if ([concreteMessage.to_id isKindOfClass:[TLPeer$peerChannel class]])
            {
                TLPeer$peerChannel *toChannel = (TLPeer$peerChannel *)concreteMessage.to_id;
                self.toUid = TGPeerIdFromChannelId(toChannel.channel_id);
                self.cid = self.toUid;
                
                if ((concreteMessage.flags & 16) != 0 || (concreteMessage.flags & 2) != 0 || (concreteMessage.flags & 256) == 0) {
                    self.sortKey = TGMessageSortKeyMake(self.cid, TGMessageSpaceImportant, concreteMessage.date, self.mid);
                } else {
                    self.sortKey = TGMessageSortKeyMake(self.cid, TGMessageSpaceUnimportant, concreteMessage.date, self.mid);
                }
                
                if ((concreteMessage.flags & 256) == 0) {
                    self.fromUid = self.cid;
                }
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
        
        if (replyMarkupAttachment != nil)
        {
            if (mediaAttachments == nil)
            {
                mediaAttachments = [NSArray arrayWithObject:replyMarkupAttachment];
            }
            else
            {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                [array addObjectsFromArray:mediaAttachments];
                [array addObject:replyMarkupAttachment];
                mediaAttachments = array;
            }
        }
        
        if (entitiesAttachment != nil)
        {
            if (mediaAttachments == nil)
            {
                mediaAttachments = [NSArray arrayWithObject:entitiesAttachment];
            }
            else
            {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                [array addObjectsFromArray:mediaAttachments];
                [array addObject:entitiesAttachment];
                mediaAttachments = array;
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
        self.randomId = (int64_t)[desc.randomId longLongValue];
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
                        [imageInfo addImageWithSize:CGSizeMake([decryptedPhoto.thumbW intValue], [decryptedPhoto.thumbH intValue]) url:thumbnailUrl];
                        
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
                        [imageInfo addImageWithSize:CGSizeMake([decryptedVideo.thumbW intValue], [decryptedVideo.thumbH intValue]) url:thumbnailUrl];
                        
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
                    
                    NSMutableArray *attributes = [[NSMutableArray alloc] init];
                    [attributes addObject:[[TGDocumentAttributeFilename alloc] initWithFilename:decryptedDocument.fileName]];
                    
                    documentAttachment.localDocumentId = localId;
                    documentAttachment.mimeType = decryptedDocument.mimeType;
                    documentAttachment.size = [decryptedDocument.size intValue];
                    documentAttachment.attributes = attributes;
                    
                    documentAttachment.documentUri = [[NSString alloc] initWithFormat:@"mt-encrypted-file://?dc=%d&id=%lld&accessHash=%lld&size=%d&decryptedSize=%d&fingerprint=%d&key=%@%@", encryptedFile.datacenterId, encryptedFile.n_id, encryptedFile.accessHash, encryptedFile.size, [decryptedDocument.size intValue], encryptedFile.keyFingerprint, [decryptedDocument.key stringByEncodingInHex], [decryptedDocument.iv stringByEncodingInHex]];
                    
                    if (decryptedDocument.thumb != nil && [decryptedDocument.thumbW intValue] > 0 && [decryptedDocument.thumbH intValue] > 0)
                    {
                        NSString *thumbnailUrl = [[NSString alloc] initWithFormat:@"encryptedThumbnail:%lld", encryptedFile.n_id];
                        
                        TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
                        [imageInfo addImageWithSize:CGSizeMake([decryptedDocument.thumbW intValue], [decryptedDocument.thumbH intValue]) url:thumbnailUrl];
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
                    convertedContact.phone_number = mediaContact.phoneNumber;
                    convertedContact.first_name = mediaContact.firstName;
                    convertedContact.last_name = mediaContact.lastName;
                    convertedContact.user_id = [mediaContact.userId intValue];
                    
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
                actionAttachment.actionData = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:[concreteAction.ttlSeconds intValue]], @"messageLifetime", nil];
                
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
        self.randomId = (int64_t)[desc.randomId longLongValue];
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
                        [imageInfo addImageWithSize:CGSizeMake([decryptedPhoto.thumbW intValue], [decryptedPhoto.thumbH intValue]) url:thumbnailUrl];
                        
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
                        [imageInfo addImageWithSize:CGSizeMake([decryptedVideo.thumbW intValue], [decryptedVideo.thumbH intValue]) url:thumbnailUrl];
                        
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
                    
                    NSMutableArray *attributes = [[NSMutableArray alloc] init];
                    [attributes addObject:[[TGDocumentAttributeFilename alloc] initWithFilename:decryptedDocument.fileName]];
                    
                    documentAttachment.localDocumentId = localId;
                    documentAttachment.attributes = attributes;
                    documentAttachment.mimeType = decryptedDocument.mimeType;
                    documentAttachment.size = [decryptedDocument.size intValue];
                    
                    documentAttachment.documentUri = [[NSString alloc] initWithFormat:@"mt-encrypted-file://?dc=%d&id=%lld&accessHash=%lld&size=%d&decryptedSize=%d&fingerprint=%d&key=%@%@", encryptedFile.datacenterId, encryptedFile.n_id, encryptedFile.accessHash, encryptedFile.size, [decryptedDocument.size intValue], encryptedFile.keyFingerprint, [decryptedDocument.key stringByEncodingInHex], [decryptedDocument.iv stringByEncodingInHex]];
                    
                    if (decryptedDocument.thumb != nil && [decryptedDocument.thumbW intValue] > 0 && [decryptedDocument.thumbH intValue] > 0)
                    {
                        NSString *thumbnailUrl = [[NSString alloc] initWithFormat:@"encryptedThumbnail:%lld", encryptedFile.n_id];
                        
                        TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
                        [imageInfo addImageWithSize:CGSizeMake([decryptedDocument.thumbW intValue], [decryptedDocument.thumbH intValue]) url:thumbnailUrl];
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
                    convertedContact.phone_number = mediaContact.phoneNumber;
                    convertedContact.first_name = mediaContact.firstName;
                    convertedContact.last_name = mediaContact.lastName;
                    convertedContact.user_id = [mediaContact.userId intValue];
                    
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
                actionAttachment.actionData = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:[concreteAction.ttlSeconds intValue]], @"messageLifetime", nil];
                
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
                actionAttachment.actionData = @{@"randomIds": concreteAction.randomIds};
                
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

- (instancetype)initWithDecryptedMessageDesc20:(Secret20_DecryptedMessage *)desc encryptedFile:(TGStoredIncomingMessageFileInfo *)encryptedFile conversationId:(int64_t)conversationId fromUid:(int)fromUid date:(int)date
{
    self = [super init];
    if (self != nil)
    {
        self.randomId = (int64_t)[desc.randomId longLongValue];
        self.fromUid = fromUid;
        self.toUid = TGTelegraphInstance.clientUserId;
        self.date = date;
        self.unread = true;
        self.outgoing = false;
        self.cid = conversationId;
        
        NSArray *mediaAttachments = nil;
        
        if ([desc isKindOfClass:[Secret20_DecryptedMessage_decryptedMessage class]])
        {
            Secret20_DecryptedMessage_decryptedMessage *concreteMessage = (Secret20_DecryptedMessage_decryptedMessage *)desc;
            
            self.text = concreteMessage.message;
            self.messageLifetime = [concreteMessage.ttl intValue];
            
            if (![concreteMessage.media isKindOfClass:[Secret20_DecryptedMessageMedia_decryptedMessageMediaEmpty class]])
            {
                if ([concreteMessage.media isKindOfClass:[Secret20_DecryptedMessageMedia_decryptedMessageMediaPhoto class]])
                {
                    if (encryptedFile != nil)
                    {
                        Secret20_DecryptedMessageMedia_decryptedMessageMediaPhoto *decryptedPhoto = (Secret20_DecryptedMessageMedia_decryptedMessageMediaPhoto *)concreteMessage.media;
                        
                        TGImageMediaAttachment *imageAttachment = [[TGImageMediaAttachment alloc] init];
                        
                        imageAttachment.imageId = encryptedFile.n_id;
                        imageAttachment.accessHash = encryptedFile.accessHash;
                        
                        NSString *thumbnailUrl = [[NSString alloc] initWithFormat:@"encryptedThumbnail:%lld", encryptedFile.n_id];
                        
                        TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
                        [imageInfo addImageWithSize:CGSizeMake([decryptedPhoto.thumbW intValue], [decryptedPhoto.thumbH intValue]) url:thumbnailUrl];
                        
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
                else if ([concreteMessage.media isKindOfClass:[Secret20_DecryptedMessageMedia_decryptedMessageMediaVideo class]])
                {
                    if (encryptedFile != nil)
                    {
                        Secret20_DecryptedMessageMedia_decryptedMessageMediaVideo *decryptedVideo = (Secret20_DecryptedMessageMedia_decryptedMessageMediaVideo *)concreteMessage.media;
                        
                        TGVideoMediaAttachment *videoAttachment = [[TGVideoMediaAttachment alloc] init];
                        
                        videoAttachment.videoId = encryptedFile.n_id;
                        videoAttachment.accessHash = encryptedFile.accessHash;
                        
                        NSString *thumbnailUrl = [[NSString alloc] initWithFormat:@"encryptedThumbnail:%lld", encryptedFile.n_id];
                        
                        TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
                        [imageInfo addImageWithSize:CGSizeMake([decryptedVideo.thumbW intValue], [decryptedVideo.thumbH intValue]) url:thumbnailUrl];
                        
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
                else if ([concreteMessage.media isKindOfClass:[Secret20_DecryptedMessageMedia_decryptedMessageMediaDocument class]])
                {
                    Secret20_DecryptedMessageMedia_decryptedMessageMediaDocument *decryptedDocument = (Secret20_DecryptedMessageMedia_decryptedMessageMediaDocument *)concreteMessage.media;
                    
                    TGDocumentMediaAttachment *documentAttachment = [[TGDocumentMediaAttachment alloc] init];
                    
                    int64_t localId = 0;
                    arc4random_buf(&localId, sizeof(localId));
                    
                    NSMutableArray *attributes = [[NSMutableArray alloc] init];
                    [attributes addObject:[[TGDocumentAttributeFilename alloc] initWithFilename:decryptedDocument.fileName]];
                    
                    documentAttachment.localDocumentId = localId;
                    documentAttachment.attributes = attributes;
                    documentAttachment.mimeType = decryptedDocument.mimeType;
                    documentAttachment.size = [decryptedDocument.size intValue];
                    
                    documentAttachment.documentUri = [[NSString alloc] initWithFormat:@"mt-encrypted-file://?dc=%d&id=%lld&accessHash=%lld&size=%d&decryptedSize=%d&fingerprint=%d&key=%@%@", encryptedFile.datacenterId, encryptedFile.n_id, encryptedFile.accessHash, encryptedFile.size, [decryptedDocument.size intValue], encryptedFile.keyFingerprint, [decryptedDocument.key stringByEncodingInHex], [decryptedDocument.iv stringByEncodingInHex]];
                    
                    if (decryptedDocument.thumb != nil && [decryptedDocument.thumbW intValue] > 0 && [decryptedDocument.thumbH intValue] > 0)
                    {
                        NSString *thumbnailUrl = [[NSString alloc] initWithFormat:@"encryptedThumbnail:%lld", encryptedFile.n_id];
                        
                        TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
                        [imageInfo addImageWithSize:CGSizeMake([decryptedDocument.thumbW intValue], [decryptedDocument.thumbH intValue]) url:thumbnailUrl];
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
                else if ([concreteMessage.media isKindOfClass:[Secret20_DecryptedMessageMedia_decryptedMessageMediaAudio class]])
                {
                    Secret20_DecryptedMessageMedia_decryptedMessageMediaAudio *decryptedAudio = (Secret20_DecryptedMessageMedia_decryptedMessageMediaAudio *)concreteMessage.media;
                    
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
                else if ([concreteMessage.media isKindOfClass:[Secret20_DecryptedMessageMedia_decryptedMessageMediaGeoPoint class]])
                {
                    Secret20_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *concreteGeo = (Secret20_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)concreteMessage.media;
                    
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
                else if ([concreteMessage.media isKindOfClass:[Secret20_DecryptedMessageMedia_decryptedMessageMediaContact class]])
                {
                    Secret20_DecryptedMessageMedia_decryptedMessageMediaContact *mediaContact = (Secret20_DecryptedMessageMedia_decryptedMessageMediaContact *)concreteMessage.media;
                    
                    TLMessageMedia$messageMediaContact *convertedContact = [[TLMessageMedia$messageMediaContact alloc] init];
                    convertedContact.phone_number = mediaContact.phoneNumber;
                    convertedContact.first_name = mediaContact.firstName;
                    convertedContact.last_name = mediaContact.lastName;
                    convertedContact.user_id = [mediaContact.userId intValue];
                    
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
        else if ([desc isKindOfClass:[Secret20_DecryptedMessage_decryptedMessageService class]])
        {
            Secret20_DecryptedMessage_decryptedMessageService *concreteMessage = (Secret20_DecryptedMessage_decryptedMessageService *)desc;
            self.unread = false;
            
            if ([concreteMessage.action isKindOfClass:[Secret20_DecryptedMessageAction_decryptedMessageActionSetMessageTTL class]])
            {
                Secret20_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *concreteAction = (Secret20_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)concreteMessage.action;
                
                TGActionMediaAttachment *actionAttachment = [[TGActionMediaAttachment alloc] init];
                actionAttachment.actionType = TGMessageActionEncryptedChatMessageLifetime;
                actionAttachment.actionData = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:[concreteAction.ttlSeconds intValue]], @"messageLifetime", nil];
                
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
            else if ([concreteMessage.action isKindOfClass:[Secret20_DecryptedMessageAction_decryptedMessageActionScreenshotMessages class]])
            {
                Secret20_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *concreteAction = (Secret20_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)concreteMessage.action;
                TGActionMediaAttachment *actionAttachment = [[TGActionMediaAttachment alloc] init];
                actionAttachment.actionType = TGMessageActionEncryptedChatMessageScreenshot;
                actionAttachment.actionData = @{@"randomIds": concreteAction.randomIds};
                
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

- (instancetype)initWithDecryptedMessageDesc23:(Secret23_DecryptedMessage *)desc encryptedFile:(TGStoredIncomingMessageFileInfo *)encryptedFile conversationId:(int64_t)conversationId fromUid:(int)fromUid date:(int)date
{
    self = [super init];
    if (self != nil)
    {
        self.randomId = (int64_t)[desc.randomId longLongValue];
        self.fromUid = fromUid;
        self.toUid = TGTelegraphInstance.clientUserId;
        self.date = date;
        self.unread = true;
        self.outgoing = false;
        self.cid = conversationId;
        
        NSArray *mediaAttachments = nil;
        
        if ([desc isKindOfClass:[Secret23_DecryptedMessage_decryptedMessage class]])
        {
            Secret23_DecryptedMessage_decryptedMessage *concreteMessage = (Secret23_DecryptedMessage_decryptedMessage *)desc;
            
            self.text = concreteMessage.message;
            self.messageLifetime = [concreteMessage.ttl intValue];
            
            if (![concreteMessage.media isKindOfClass:[Secret23_DecryptedMessageMedia_decryptedMessageMediaEmpty class]])
            {
                if ([concreteMessage.media isKindOfClass:[Secret23_DecryptedMessageMedia_decryptedMessageMediaPhoto class]])
                {
                    if (encryptedFile != nil)
                    {
                        Secret23_DecryptedMessageMedia_decryptedMessageMediaPhoto *decryptedPhoto = (Secret23_DecryptedMessageMedia_decryptedMessageMediaPhoto *)concreteMessage.media;
                        
                        TGImageMediaAttachment *imageAttachment = [[TGImageMediaAttachment alloc] init];
                        
                        imageAttachment.imageId = encryptedFile.n_id;
                        imageAttachment.accessHash = encryptedFile.accessHash;
                        
                        NSString *thumbnailUrl = [[NSString alloc] initWithFormat:@"encryptedThumbnail:%lld", encryptedFile.n_id];
                        
                        TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
                        [imageInfo addImageWithSize:CGSizeMake([decryptedPhoto.thumbW intValue], [decryptedPhoto.thumbH intValue]) url:thumbnailUrl];
                        
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
                else if ([concreteMessage.media isKindOfClass:[Secret23_DecryptedMessageMedia_decryptedMessageMediaVideo class]])
                {
                    if (encryptedFile != nil)
                    {
                        Secret23_DecryptedMessageMedia_decryptedMessageMediaVideo *decryptedVideo = (Secret23_DecryptedMessageMedia_decryptedMessageMediaVideo *)concreteMessage.media;
                        
                        TGVideoMediaAttachment *videoAttachment = [[TGVideoMediaAttachment alloc] init];
                        
                        videoAttachment.videoId = encryptedFile.n_id;
                        videoAttachment.accessHash = encryptedFile.accessHash;
                        
                        NSString *thumbnailUrl = [[NSString alloc] initWithFormat:@"encryptedThumbnail:%lld", encryptedFile.n_id];
                        
                        TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
                        [imageInfo addImageWithSize:CGSizeMake([decryptedVideo.thumbW intValue], [decryptedVideo.thumbH intValue]) url:thumbnailUrl];
                        
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
                else if ([concreteMessage.media isKindOfClass:[Secret23_DecryptedMessageMedia_decryptedMessageMediaDocument class]])
                {
                    Secret23_DecryptedMessageMedia_decryptedMessageMediaDocument *decryptedDocument = (Secret23_DecryptedMessageMedia_decryptedMessageMediaDocument *)concreteMessage.media;
                    
                    TGDocumentMediaAttachment *documentAttachment = [[TGDocumentMediaAttachment alloc] init];
                    
                    int64_t localId = 0;
                    arc4random_buf(&localId, sizeof(localId));
                    
                    NSMutableArray *attributes = [[NSMutableArray alloc] init];
                    [attributes addObject:[[TGDocumentAttributeFilename alloc] initWithFilename:decryptedDocument.fileName]];
                    
                    documentAttachment.localDocumentId = localId;
                    documentAttachment.attributes = attributes;
                    documentAttachment.mimeType = decryptedDocument.mimeType;
                    documentAttachment.size = [decryptedDocument.size intValue];
                    
                    documentAttachment.documentUri = [[NSString alloc] initWithFormat:@"mt-encrypted-file://?dc=%d&id=%lld&accessHash=%lld&size=%d&decryptedSize=%d&fingerprint=%d&key=%@%@", encryptedFile.datacenterId, encryptedFile.n_id, encryptedFile.accessHash, encryptedFile.size, [decryptedDocument.size intValue], encryptedFile.keyFingerprint, [decryptedDocument.key stringByEncodingInHex], [decryptedDocument.iv stringByEncodingInHex]];
                    
                    if (decryptedDocument.thumb != nil && [decryptedDocument.thumbW intValue] > 0 && [decryptedDocument.thumbH intValue] > 0)
                    {
                        NSString *thumbnailUrl = [[NSString alloc] initWithFormat:@"encryptedThumbnail:%lld", encryptedFile.n_id];
                        
                        TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
                        [imageInfo addImageWithSize:CGSizeMake([decryptedDocument.thumbW intValue], [decryptedDocument.thumbH intValue]) url:thumbnailUrl];
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
                else if ([concreteMessage.media isKindOfClass:[Secret23_DecryptedMessageMedia_decryptedMessageMediaAudio class]])
                {
                    Secret23_DecryptedMessageMedia_decryptedMessageMediaAudio *decryptedAudio = (Secret23_DecryptedMessageMedia_decryptedMessageMediaAudio *)concreteMessage.media;
                    
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
                else if ([concreteMessage.media isKindOfClass:[Secret23_DecryptedMessageMedia_decryptedMessageMediaGeoPoint class]])
                {
                    Secret23_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *concreteGeo = (Secret23_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)concreteMessage.media;
                    
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
                else if ([concreteMessage.media isKindOfClass:[Secret23_DecryptedMessageMedia_decryptedMessageMediaContact class]])
                {
                    Secret23_DecryptedMessageMedia_decryptedMessageMediaContact *mediaContact = (Secret23_DecryptedMessageMedia_decryptedMessageMediaContact *)concreteMessage.media;
                    
                    TLMessageMedia$messageMediaContact *convertedContact = [[TLMessageMedia$messageMediaContact alloc] init];
                    convertedContact.phone_number = mediaContact.phoneNumber;
                    convertedContact.first_name = mediaContact.firstName;
                    convertedContact.last_name = mediaContact.lastName;
                    convertedContact.user_id = [mediaContact.userId intValue];
                    
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
                else if ([concreteMessage.media isKindOfClass:[Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument class]])
                {
                    Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *mediaDocument = (Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *)concreteMessage.media;
                    
                    TGDocumentMediaAttachment *documentAttachment = [[TGDocumentMediaAttachment alloc] initWithSecret23Desc:mediaDocument];
                    if (documentAttachment != nil)
                    {
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
                }
            }
        }
        else if ([desc isKindOfClass:[Secret23_DecryptedMessage_decryptedMessageService class]])
        {
            Secret23_DecryptedMessage_decryptedMessageService *concreteMessage = (Secret23_DecryptedMessage_decryptedMessageService *)desc;
            self.unread = false;
            
            if ([concreteMessage.action isKindOfClass:[Secret23_DecryptedMessageAction_decryptedMessageActionSetMessageTTL class]])
            {
                Secret23_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *concreteAction = (Secret23_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)concreteMessage.action;
                
                TGActionMediaAttachment *actionAttachment = [[TGActionMediaAttachment alloc] init];
                actionAttachment.actionType = TGMessageActionEncryptedChatMessageLifetime;
                actionAttachment.actionData = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:[concreteAction.ttlSeconds intValue]], @"messageLifetime", nil];
                
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
            else if ([concreteMessage.action isKindOfClass:[Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages class]])
            {
                Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *concreteAction = (Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)concreteMessage.action;
                TGActionMediaAttachment *actionAttachment = [[TGActionMediaAttachment alloc] init];
                actionAttachment.actionType = TGMessageActionEncryptedChatMessageScreenshot;
                actionAttachment.actionData = @{@"randomIds": concreteAction.randomIds};
                
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
