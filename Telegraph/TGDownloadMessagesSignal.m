#import "TGDownloadMessagesSignal.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

#import "TGUserDataRequestBuilder.h"

#import "TGMessage+Telegraph.h"

#import "TGStickersSignals.h"
#import "TGRecentStickersSignal.h"
#import "TGRecentGifsSignal.h"
#import "TGWebpageSignals.h"
#import "TGRecentMaskStickersSignal.h"
#import "TGFavoriteStickersSignal.h"

#import "TGFileReferenceManager.h"

#import "TGTelegraph.h"
#import "TGDatabase.h"

#import "TLMetaScheme.h"
#import "TGConversation+Telegraph.h"

@implementation TGDownloadMessage

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash messageId:(int32_t)messageId {
    self = [super init];
    if (self != nil) {
        _peerId = peerId;
        _accessHash = accessHash;
        _messageId = messageId;
    }
    return self;
}

@end

@implementation TGDownloadMessagesSignal

+ (SSignal *)downloadMessages:(NSArray *)messages
{
    if (messages.count == 0) {
        return [SSignal single:messages];
    }
    
    SSignal *channelSignal = [SSignal single:@[]];
    SSignal *genericSignal = [SSignal single:@[]];
    
    NSMutableDictionary *channelMessageIdsByPeerId = [[NSMutableDictionary alloc] init];
    NSMutableArray *genericMessageIds = [[NSMutableArray alloc] init];
    for (TGDownloadMessage *message in messages) {
        if (TGPeerIdIsChannel(message.peerId)) {
            NSMutableArray *channelMessageIds = channelMessageIdsByPeerId[@(message.peerId)];
            if (channelMessageIds == nil) {
                channelMessageIds = [[NSMutableArray alloc] init];
                channelMessageIdsByPeerId[@(message.peerId)] = channelMessageIds;
            }
            [channelMessageIds addObject:message];
        } else {
            [genericMessageIds addObject:@(message.messageId)];
        }
    }
    
    if (channelMessageIdsByPeerId.count != 0) {
        NSMutableArray *signals = [[NSMutableArray alloc] init];
        
        [channelMessageIdsByPeerId enumerateKeysAndObjectsUsingBlock:^(__unused id key, NSArray *messages, __unused BOOL *stop) {
            if (messages.count != 0) {
                TLRPCchannels_getMessages$channels_getMessages *getChannelMessages = [[TLRPCchannels_getMessages$channels_getMessages alloc] init];
                TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
                inputChannel.channel_id = TGChannelIdFromPeerId(((TGDownloadMessage *)messages[0]).peerId);
                inputChannel.access_hash = ((TGDownloadMessage *)messages[0]).accessHash;
                getChannelMessages.channel = inputChannel;
                
                NSMutableArray *messageIds = [[NSMutableArray alloc] init];
                for (TGDownloadMessage *message in messages) {
                    [messageIds addObject:@(message.messageId)];
                }
                
                getChannelMessages.n_id = messageIds;
                
                SSignal *signal = [[[TGTelegramNetworking instance] requestSignal:getChannelMessages] map:^id(TLmessages_Messages *result) {
                    [TGUserDataRequestBuilder executeUserDataUpdate:result.users];
                    
                    NSMutableArray *messages = [[NSMutableArray alloc] init];
                    for (TLMessage *desc in result.messages)
                    {
                        TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:desc];
                        if (message.mid != 0)
                            [messages addObject:message];
                    }
                    
                    return messages;
                }];
                [signals addObject:signal];
            }
        }];
        
        channelSignal = [[SSignal combineSignals:signals] map:^id(NSArray *messageLists) {
            NSMutableArray *messages = [[NSMutableArray alloc] init];
            for (NSArray *array in messageLists) {
                [messages addObjectsFromArray:array];
            }
            return messages;
        }];
    }
    
    if (genericMessageIds.count != 0) {
        TLRPCmessages_getMessages$messages_getMessages *getMessages = [[TLRPCmessages_getMessages$messages_getMessages alloc] init];
        getMessages.n_id = genericMessageIds;
        genericSignal = [[[TGTelegramNetworking instance] requestSignal:getMessages] map:^id(TLmessages_Messages *result) {
            [TGUserDataRequestBuilder executeUserDataUpdate:result.users];
            
            NSMutableArray *messages = [[NSMutableArray alloc] init];
            for (TLMessage *desc in result.messages)
            {
                TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:desc];
                if (message.mid != 0)
                    [messages addObject:message];
            }
            
            return messages;
        }];
    }
    
    return [[[SSignal combineSignals:@[genericSignal, channelSignal]] map:^id(NSArray *messageLists) {
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        for (NSArray *array in messageLists) {
            [messages addObjectsFromArray:array];
        }
        return messages;
    }] catch:^SSignal *(__unused id error) {
        return [SSignal single:@[]];
    }];
}

+ (SSignal *)mediaStickerpacks:(TGMediaAttachment *)attachment {
    SSignal *request = nil;
    if ([attachment isKindOfClass:[TGImageMediaAttachment class]]) {
        TGImageMediaAttachment *image = (TGImageMediaAttachment *)attachment;
        TLRPCmessages_getAttachedStickers$messages_getAttachedStickers *getAttachedStickers = [[TLRPCmessages_getAttachedStickers$messages_getAttachedStickers alloc] init];
        TLInputStickeredMedia$inputStickeredMediaPhoto *inputStickeredPhoto = [[TLInputStickeredMedia$inputStickeredMediaPhoto alloc] init];
        TLInputPhoto$inputPhoto *inputPhoto = [[TLInputPhoto$inputPhoto alloc] init];
        inputPhoto.n_id = image.imageId;
        inputPhoto.access_hash = image.accessHash;
        inputPhoto.file_reference = image.originInfo.fileReference;
        inputStickeredPhoto.n_id = inputPhoto;
        getAttachedStickers.media = inputStickeredPhoto;
        request = [[TGTelegramNetworking instance] requestSignal:getAttachedStickers];
    } else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]]) {
        TGVideoMediaAttachment *video = (TGVideoMediaAttachment *)attachment;
        TLRPCmessages_getAttachedStickers$messages_getAttachedStickers *getAttachedStickers = [[TLRPCmessages_getAttachedStickers$messages_getAttachedStickers alloc] init];
        TLInputStickeredMedia$inputStickeredMediaDocument *inputStickeredDocument = [[TLInputStickeredMedia$inputStickeredMediaDocument alloc] init];
        TLInputDocument$inputDocument *inputDocument = [[TLInputDocument$inputDocument alloc] init];
        inputDocument.n_id = video.videoId;
        inputDocument.access_hash = video.accessHash;
        inputDocument.file_reference = video.originInfo.fileReference;
        inputStickeredDocument.n_id = inputDocument;
        getAttachedStickers.media = inputStickeredDocument;
        request = [[TGTelegramNetworking instance] requestSignal:getAttachedStickers];
    } else {
        return [SSignal single:@[]];
    }
    
    return [request mapToSignal:^SSignal *(NSArray<TLStickerSetCovered *> *result) {
        NSMutableArray *signals = [[NSMutableArray alloc] init];
        for (TLStickerSetCovered *coveredSet in result) {
            TGStickerPackIdReference *reference = [[TGStickerPackIdReference alloc] initWithPackId:coveredSet.set.n_id packAccessHash:coveredSet.set.access_hash shortName:coveredSet.set.short_name];
            [signals addObject:[TGStickersSignals stickerPackInfo:reference]];
        }
        return [SSignal combineSignals:signals];
    }];
}

+ (SSignal *)loadUnseenMentionMessageId:(int64_t)peerId accessHash:(int64_t)accessHash maxId:(int32_t)maxId {
    TLRPCmessages_getUnreadMentions$messages_getUnreadMentions *getUnreadMentions = [[TLRPCmessages_getUnreadMentions$messages_getUnreadMentions alloc] init];
    int32_t limit = 100;
    getUnreadMentions.peer = [TGTelegraphInstance createInputPeerForConversation:peerId accessHash:accessHash];
    getUnreadMentions.offset_id = maxId;
    getUnreadMentions.add_offset = -limit;
    getUnreadMentions.limit = limit;
    getUnreadMentions.max_id = INT32_MAX;
    getUnreadMentions.min_id = maxId - 1;
    
    return [[[TGTelegramNetworking instance] requestSignal:getUnreadMentions] mapToSignal:^SSignal *(TLmessages_Messages *result) {
        return [TGDatabaseInstance() modify:^id{
            NSMutableArray *messageIds = [[NSMutableArray alloc] init];
            NSMutableArray *messageUpdates = [[NSMutableArray alloc] init];
            for (TLMessage *message in result.messages) {
                [messageIds addObject:@(message.n_id)];
                [messageUpdates addObject:[[TGDatabaseUpdateMentionUnread alloc] initWithPeerId:peerId messageId:message.n_id]];
            }
            [TGDatabaseInstance() _addUnreadMensionMessageIds:peerId messageIds:messageIds replaceAfter:maxId <= 1 ? 1 : 0 afterFinal:(int32_t)messageIds.count < limit];
            [TGDatabaseInstance() transactionUpdateMessages:messageUpdates updateConversationDatas:nil];
            
            return messageIds.firstObject;
        }];
    }];
}

+ (SSignal *)earliestUnseenMentionMessageId:(int64_t)peerId accessHash:(int64_t)accessHash {
    return [[TGDatabaseInstance() modify:^id{
        int32_t loadRequiredAfterMessageId = 0;
        int32_t localId = [TGDatabaseInstance() _nextUnreadMentionMessageId:peerId loadRequiredAfterMessageId:&loadRequiredAfterMessageId];
        
        if (localId != 0) {
            [TGDatabaseInstance() transactionUpdateMessages:@[[[TGDatabaseUpdateMentionUnread alloc] initWithPeerId:peerId messageId:localId]] updateConversationDatas:nil];
            
            return [SSignal single:@(localId)];
        } else if (loadRequiredAfterMessageId != 0) {
            return [self loadUnseenMentionMessageId:peerId accessHash:accessHash maxId:loadRequiredAfterMessageId];
        } else {
            [TGDatabaseInstance() _addUnreadMensionMessageIds:peerId messageIds:@[] replaceAfter:1 afterFinal:true];
            return [SSignal single:nil];
        }
    }] switchToLatest];
}

static dispatch_block_t recursiveBlock(void (^block)(dispatch_block_t recurse))
{
    return ^
    {
        block(recursiveBlock(block));
    };
}

+ (SSignal *)clearUnseenMentions:(int64_t)peerId {
    SSignal *clear = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        SMetaDisposable *disposable = [[SMetaDisposable alloc] init];
        void (^start)() = recursiveBlock(^(dispatch_block_t recurse) {
            TLRPCmessages_readMentions$messages_readMentions *readMentions = [[TLRPCmessages_readMentions$messages_readMentions alloc] init];
            int64_t accessHash = 0;
            if (TGPeerIdIsChannel(peerId)) {
                accessHash = ((TGConversation *)[TGDatabaseInstance() loadChannels:@[@(peerId)]][@(peerId)]).accessHash;
            }
            readMentions.peer = [TGTelegraphInstance createInputPeerForConversation:peerId accessHash:accessHash];
            [disposable setDisposable:[[[TGTelegramNetworking instance] requestSignal:readMentions] startWithNext:^(TLmessages_AffectedHistory *result) {
                if (result != nil) {
                    if (!TGPeerIdIsChannel(peerId)) {
                        [[TGTelegramNetworking instance] updatePts:result.pts ptsCount:result.pts_count seq:0];
                    }
                }
                
                if (result.offset > 0) {
                    recurse();
                } else {
                    [subscriber putCompletion];
                }
            } error:^(__unused id error) {
                [subscriber putCompletion];
            } completed:nil]];
        });
        
        start();
        
        return [[SBlockDisposable alloc] initWithBlock:^{
            [disposable dispose];
        }];
    }];
    
    return [clear then:[[TGDatabaseInstance() modify:^id{
        NSMutableDictionary<NSNumber *, TGUnseenPeerMentionsState *> *resetPeerUnseenMentionsStates = [[NSMutableDictionary alloc] init];
        resetPeerUnseenMentionsStates[@(peerId)] = [[TGUnseenPeerMentionsState alloc] initWithVersion:0 count:0 maxIdWithPrecalculatedCount:0];
        [TGDatabaseInstance() transactionResetPeerUnseenMentionsStates:resetPeerUnseenMentionsStates];
        return [SSignal complete];
    }] switchToLatest]];
}

+ (TGFileReferenceManager *)fileReferenceManager
{
    static dispatch_once_t onceToken;
    static TGFileReferenceManager *manager;
    dispatch_once(&onceToken, ^
    {
        manager = [[TGFileReferenceManager alloc] init];
    });
    return manager;
}

+ (SSignal *)updatedOriginInfo:(TGMediaOriginInfo *)origin identifier:(int64_t)identifier
{
    return [[[self fileReferenceManager] updatedOriginInfo:origin] map:^id(NSDictionary *dictionary) {
        if (identifier == 0)
            return dictionary.allValues.firstObject;
        
        return dictionary[@(identifier)];
    }];
}

+ (SSignal *)remoteOriginInfo:(TGMediaOriginInfo *)origin
{
    switch (origin.type) {
        case TGMediaOriginTypeMessage:
        {
            SSignal *accessHashSignal = TGPeerIdIsChannel(origin.cid.int64Value) ? [SSignal defer:^SSignal *{
                return [SSignal single:@([TGDatabaseInstance() loadConversationWithId:origin.cid.int64Value].accessHash)];
            }] : [SSignal single:@0];
            
            return [[accessHashSignal mapToSignal:^SSignal *(NSNumber *accessHash) {
                TGDownloadMessage *downloadMessage = [[TGDownloadMessage alloc] initWithPeerId:origin.cid.int64Value accessHash:accessHash.int64Value messageId:origin.mid.int32Value];
                return [[self downloadMessages:@[downloadMessage]] take:1];
            }] map:^id(NSArray *messages)
            {
                TGMessage *message = messages.firstObject;
                
                TGMediaOriginInfo *originInfo = nil;
                int64_t identifier = 0;
                for (TGMediaAttachment *attachment in message.mediaAttachments)
                {
                    if (attachment.type == TGImageMediaAttachmentType)
                    {
                        originInfo = ((TGImageMediaAttachment *)attachment).originInfo;
                        identifier = ((TGImageMediaAttachment *)attachment).imageId;
                        break;
                    }
                    else if (attachment.type == TGVideoMediaAttachmentType)
                    {
                        originInfo = ((TGVideoMediaAttachment *)attachment).originInfo;
                        identifier = ((TGVideoMediaAttachment *)attachment).videoId;
                        break;
                    }
                    else if (attachment.type == TGDocumentMediaAttachmentType)
                    {
                        originInfo = ((TGDocumentMediaAttachment *)attachment).originInfo;
                        identifier = ((TGDocumentMediaAttachment *)attachment).documentId;
                        break;
                    }
                    else if (attachment.type == TGGameAttachmentType)
                    {
                        if (((TGGameMediaAttachment *)attachment).photo != nil)
                        {
                            originInfo = ((TGGameMediaAttachment *)attachment).photo.originInfo;
                            identifier = ((TGGameMediaAttachment *)attachment).photo.imageId;
                        }
                        else if (((TGGameMediaAttachment *)attachment).document != nil)
                        {
                            originInfo = ((TGGameMediaAttachment *)attachment).document.originInfo;
                            identifier = ((TGGameMediaAttachment *)attachment).document.documentId;
                        }
                    }
                }
                
                if (originInfo != nil)
                    return @{ @(identifier): originInfo };
                
                return nil;
            }];
        }
            break;
            
        case TGMediaOriginTypeSticker:
        {
            TGStickerPackIdReference *packReference = [[TGStickerPackIdReference alloc] initWithPackId:origin.stickerPackId.int64Value packAccessHash:origin.stickerPackAccessHash.int64Value shortName:nil];
            return [[[TGStickersSignals stickerPackInfo:packReference] onNext:^(TGStickerPack *next) {
                [TGStickersSignals updateStickerPack:next];
            }] map:^id(TGStickerPack *stickerPack)
            {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                for (TGDocumentMediaAttachment *attachment in stickerPack.documents)
                {
                    TGMediaOriginInfo *originInfo = ((TGDocumentMediaAttachment *)attachment).originInfo;
                    int64_t identifier = ((TGDocumentMediaAttachment *)attachment).documentId;
                    
                    if (originInfo != nil)
                        dict[@(identifier)] = originInfo;
                }
                return dict;
            }];
        }
            break;
            
        case TGMediaOriginTypeRecentSticker:
        {
            return [[TGRecentStickersSignal remoteRecentStickers] map:^id(NSDictionary *recentStickers) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                for (TGDocumentMediaAttachment *attachment in recentStickers[@"documents"])
                {
                    TGMediaOriginInfo *originInfo = attachment.originInfo;
                    int64_t identifier = attachment.documentId;
                    
                    if (originInfo != nil)
                        dict[@(identifier)] = originInfo;
                }
                return dict;
            }];
        }
            break;
            
        case TGMediaOriginTypeFavoriteSticker:
        {
            return [[TGFavoriteStickersSignal remoteFavedStickers] map:^id(NSArray *favoriteStickers) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                for (TGDocumentMediaAttachment *attachment in favoriteStickers)
                {
                    TGMediaOriginInfo *originInfo = attachment.originInfo;
                    int64_t identifier = attachment.documentId;
                    
                    if (originInfo != nil)
                        dict[@(identifier)] = originInfo;
                }
                return dict;
            }];
        }
            break;
            
        case TGMediaOriginTypeRecentMask:
        {
            return [[TGRecentMaskStickersSignal remoteRecentStickers] map:^id(NSArray *recentStickers) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                for (TGDocumentMediaAttachment *attachment in recentStickers)
                {
                    TGMediaOriginInfo *originInfo = attachment.originInfo;
                    int64_t identifier = attachment.documentId;
                    
                    if (originInfo != nil)
                        dict[@(identifier)] = originInfo;
                }
                return dict;
            }];
        }
            break;
            
        case TGMediaOriginTypeRecentGif:
        {
            return [[TGRecentGifsSignal remoteRecentGifs] map:^id(NSArray *recentGifs) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                for (TGDocumentMediaAttachment *attachment in recentGifs)
                {
                    TGMediaOriginInfo *originInfo = attachment.originInfo;
                    int64_t identifier = attachment.documentId;
                    
                    if (originInfo != nil)
                        dict[@(identifier)] = originInfo;
                }
                return dict;
            }];
        }
            break;
            
        case TGMediaOriginTypeProfilePhoto:
        {
            TLRPCphotos_getUserPhotos$photos_getUserPhotos *getPhotos = [[TLRPCphotos_getUserPhotos$photos_getUserPhotos alloc] init];
            getPhotos.user_id = [TGTelegraphInstance createInputUserForUid:origin.profilePhotoUserId.int32Value];
            getPhotos.offset = origin.profilePhotoOffset.int32Value;
            getPhotos.limit = 1;
            getPhotos.max_id = 0;
            
            return [[[TGTelegramNetworking instance] requestSignal:getPhotos] map:^id(TLphotos_Photos *result) {
                [TGUserDataRequestBuilder executeUserDataUpdate:result.users];
                
                if ([result.photos.firstObject isKindOfClass:[TLPhoto$photo class]])
                {
                    TLPhoto$photo *photo = (TLPhoto$photo *)result.photos.firstObject;
                    NSMutableDictionary *fileReferences = [[NSMutableDictionary alloc] init];
                    for (TLPhotoSize$photoSize *size in photo.sizes)
                    {
                        if (![size respondsToSelector:@selector(location)])
                            continue;
                        
                        TLFileLocation *location = [size performSelector:@selector(location)];
                        if ([location isKindOfClass:[TLFileLocation$fileLocation class]])
                        {
                            TLFileLocation$fileLocation *fileLocation = (TLFileLocation$fileLocation *)location;
                            fileReferences[[NSString stringWithFormat:@"%lld_%d", fileLocation.volume_id, fileLocation.local_id]] = fileLocation.file_reference;
                        }
                    }
                    TGMediaOriginInfo *originInfo = [TGMediaOriginInfo mediaOriginInfoWithFileReference:nil fileReferences:fileReferences userId:origin.profilePhotoUserId.int32Value offset:origin.profilePhotoOffset.int32Value];
                    return @{ @0: originInfo};
                }
                return nil;
            }];
        }
            break;
            
        case TGMediaOriginTypeChatPhoto:
        {
            int64_t peerId = origin.chatPhotoPeerId.int64Value;
            
            SSignal *getChatsSignal = nil;
            if (TGPeerIdIsChannel(peerId)) {
                TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:peerId];
                if (conversation.accessHash == 0)
                    return [SSignal fail:nil];
                
                TLInputPeer *peer = [TGTelegraphInstance createInputPeerForConversation:peerId accessHash:conversation.accessHash];
                if (peer == nil)
                    return [SSignal fail:nil];
                
                TLRPCchannels_getChannels$channels_getChannels *getChannels = [[TLRPCchannels_getChannels$channels_getChannels alloc] init];
                getChannels.n_id = @[peer];
                getChatsSignal = [[TGTelegramNetworking instance] requestSignal:getChannels];
            } else {
                TLRPCmessages_getChats$messages_getChats *getChats = [[TLRPCmessages_getChats$messages_getChats alloc] init];
                getChats.n_id = @[ @(TGGroupIdFromPeerId(peerId)) ];
                getChatsSignal = [[TGTelegramNetworking instance] requestSignal:getChats];
            }
            
            return [getChatsSignal map:^id(TLmessages_Chats *result) {
                TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:result.chats.firstObject];
                if (conversation == nil)
                    return nil;
                
                NSMutableDictionary *fileReferences = [[NSMutableDictionary alloc] init];
                if (conversation.chatPhotoSmall.length > 0 && conversation.chatPhotoFileReferenceSmall != nil)
                {
                    int64_t volumeId = 0;
                    int32_t localId = 0;
                    if (extractFileUrlComponents(conversation.chatPhotoSmall, NULL, &volumeId, &localId, NULL)) {
                        fileReferences[[NSString stringWithFormat:@"%lld_%d", volumeId, localId]] = conversation.chatPhotoFileReferenceSmall;
                    }
                }
                else
                {
                    return nil;
                }
                
                if (conversation.chatPhotoBig.length > 0 && conversation.chatPhotoFileReferenceBig)
                {
                    int64_t volumeId = 0;
                    int32_t localId = 0;
                    if (extractFileUrlComponents(conversation.chatPhotoBig, NULL, &volumeId, &localId, NULL)) {
                        fileReferences[[NSString stringWithFormat:@"%lld_%d", volumeId, localId]] = conversation.chatPhotoFileReferenceBig;
                    }
                }
                else
                {
                    return nil;
                }
                
                TGMediaOriginInfo *originInfo = [TGMediaOriginInfo mediaOriginInfoWithFileReference:nil fileReferences:fileReferences peerId:peerId];
                return @{ @0: originInfo};
            }];
        }
            break;
            
        case TGMediaOriginTypeWallpaper:
            return [SSignal single:origin];
            break;
            
        case TGMediaOriginTypeWebpage:
            return [[TGWebpageSignals updatedWebpageForUrl:origin.webpageUrl] map:^id(TGWebPageMediaAttachment *webpage) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                if (webpage.photo != nil)
                {
                    TGMediaOriginInfo *originInfo = webpage.photo.originInfo;
                    int64_t identifier = webpage.photo.imageId;
                    
                    if (originInfo != nil)
                        dict[@(identifier)] = originInfo;
                }
                if (webpage.document != nil)
                {
                    TGMediaOriginInfo *originInfo = webpage.document.originInfo;
                    int64_t identifier = webpage.document.documentId;
                    
                    if (originInfo != nil)
                        dict[@(identifier)] = originInfo;
                }
                if (webpage.instantPage != nil)
                {
                    for (TGImageMediaAttachment *image in webpage.instantPage.images.allValues)
                    {
                        TGMediaOriginInfo *originInfo = image.originInfo;
                        int64_t identifier = image.imageId;
                        
                        if (originInfo != nil)
                            dict[@(identifier)] = originInfo;
                    }
                    for (TGVideoMediaAttachment *video in webpage.instantPage.videos.allValues)
                    {
                        TGMediaOriginInfo *originInfo = video.originInfo;
                        int64_t identifier = video.videoId;
                        
                        if (originInfo != nil)
                            dict[@(identifier)] = originInfo;
                    }
                    for (TGDocumentMediaAttachment *document in webpage.instantPage.documents.allValues)
                    {
                        TGMediaOriginInfo *originInfo = document.originInfo;
                        int64_t identifier = document.documentId;
                        
                        if (originInfo != nil)
                            dict[@(identifier)] = originInfo;
                    }
                }
                return dict;
            }];
            break;
            
        default:
            return [SSignal fail:nil];
    }
}

@end
