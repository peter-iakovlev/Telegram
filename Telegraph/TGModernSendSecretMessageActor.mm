#import "TGModernSendSecretMessageActor.h"

#import "ActionStage.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"
#import <MTProtoKit/MTEncryption.h>
#import "TLMetaClassStore.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGFileUtils.h"

#import "TGPreparedTextMessage.h"
#import "TGPreparedMapMessage.h"
#import "TGPreparedLocalImageMessage.h"
#import "TGPreparedLocalVideoMessage.h"
#import "TGPreparedLocalDocumentMessage.h"
#import "TGPreparedForwardedMessage.h"
#import "TGPreparedDownloadImageMessage.h"
#import "TGPreparedDownloadDocumentMessage.h"
#import "TGPreparedRemoteDocumentMessage.h"
#import "TGPreparedRemoteImageMessage.h"
#import "TGPreparedCloudDocumentMessage.h"
#import "TGPreparedDownloadExternalGifMessage.h"
#import "TGPreparedDownloadExternalImageMessage.h"
#import "TGPreparedDownloadExternalDocumentMessage.h"
#import "TGDocumentEncryptedFileReference.h"
#import "TGPreparedAssetImageMessage.h"
#import "TGPreparedAssetVideoMessage.h"
#import "TGPreparedRemoteVideoMessage.h"

#import "TGRemoteImageView.h"
#import "TGImageDownloadActor.h"

#import "TGMediaAssetsLibrary.h"
#import "TGMediaAssetImageSignals.h"
#import "TGVideoConverter.h"
#import "TGMediaVideoConverter.h"
#import "TGMediaLiveUploadWatcher.h"

#import "UIImage+TG.h"

#import "TGDownloadManager.h"

#import "TGImageManager.h"

#import "TGMediaStoreContext.h"

#import "TGRequestEncryptedChatActor.h"

#import "TGImageInfo+Telegraph.h"

#import "TGAppDelegate.h"

#import "TGRemoteFileSignal.h"
#import "TGSharedFileSignals.h"
#import "TGStickersSignals.h"

#import "TGRecentGifsSignal.h"
#import "TGRecentStickersSignal.h"

#import <AVFoundation/AVFoundation.h>

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
    return 66;
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

- (id)decryptedGeoPointWithLayer:(NSUInteger)layer latitude:(double)latitude longitude:(double)longitude venue:(TGVenueAttachment *)venue
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
        case 46:
            if (venue == nil) {
                return [Secret46_DecryptedMessageMedia decryptedMessageMediaGeoPointWithLat:@(latitude) plong:@(longitude)];
            } else {
                return [Secret46_DecryptedMessageMedia decryptedMessageMediaVenueWithLat:@(latitude) plong:@(longitude) title:venue.title == nil ? @"" : venue.title address:venue.address == nil ? @"" : venue.address provider:venue.provider == nil ? @"" : venue.provider venueId:venue.venueId == nil ? @"" : venue.venueId];
            }
        case 66:
            if (venue == nil) {
                return [Secret66_DecryptedMessageMedia decryptedMessageMediaGeoPointWithLat:@(latitude) plong:@(longitude)];
            } else {
                return [Secret66_DecryptedMessageMedia decryptedMessageMediaVenueWithLat:@(latitude) plong:@(longitude) title:venue.title == nil ? @"" : venue.title address:venue.address == nil ? @"" : venue.address provider:venue.provider == nil ? @"" : venue.provider venueId:venue.venueId == nil ? @"" : venue.venueId];
            }
        default:
            break;
    }
    
    return nil;
}

- (id)decryptedPhotoWithLayer:(NSUInteger)layer thumbnailData:(NSData *)thumbnailData thumbnailSize:(CGSize)thumbnailSize imageSize:(CGSize)imageSize caption:(NSString *)caption size:(int)size key:(NSData *)key iv:(NSData *)iv
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
        case 46:
            return [Secret46_DecryptedMessageMedia decryptedMessageMediaPhotoWithThumb:thumbnailData == nil ? [NSData data] : thumbnailData thumbW:@((int)thumbnailSize.width) thumbH:@((int)thumbnailSize.height) w:@((int)imageSize.width) h:@((int)imageSize.height) size:@(size) key:key iv:iv caption:caption == nil ? @"" : caption];
        case 66:
            return [Secret66_DecryptedMessageMedia decryptedMessageMediaPhotoWithThumb:thumbnailData == nil ? [NSData data] : thumbnailData thumbW:@((int)thumbnailSize.width) thumbH:@((int)thumbnailSize.height) w:@((int)imageSize.width) h:@((int)imageSize.height) size:@(size) key:key iv:iv caption:caption == nil ? @"" : caption];
        default:
            break;
    }
    
    return nil;
}

- (id)decryptedVideoWithLayer:(NSUInteger)layer thumbnailData:(NSData *)thumbnailData thumbnailSize:(CGSize)thumbnailSize duration:(int)duration dimensions:(CGSize)dimensions mimeType:(NSString *)mimeType caption:(NSString *)caption size:(int)size key:(NSData *)key iv:(NSData *)iv
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
        case 46:
            return [Secret46_DecryptedMessageMedia decryptedMessageMediaVideoWithThumb: thumbnailData == nil ? [NSData data] : thumbnailData thumbW:@((int)thumbnailSize.width) thumbH:@((int)thumbnailSize.height) duration:@(duration) mimeType:mimeType w:@((int)dimensions.width) h:@((int)dimensions.height) size:@(size) key:key iv:iv caption:caption == nil ? @"" : caption];
        case 66:
            return [Secret66_DecryptedMessageMedia decryptedMessageMediaVideoWithThumb: thumbnailData == nil ? [NSData data] : thumbnailData thumbW:@((int)thumbnailSize.width) thumbH:@((int)thumbnailSize.height) duration:@(duration) mimeType:mimeType w:@((int)dimensions.width) h:@((int)dimensions.height) size:@(size) key:key iv:iv caption:caption == nil ? @"" : caption];
    }
    
    return nil;
}

- (id)documentAttributeWithLayer:(NSUInteger)layer attribute:(id)attribute {
    switch (layer) {
        case 46:
            if ([attribute isKindOfClass:[TGDocumentAttributeAnimated class]]) {
                return [Secret46_DocumentAttribute documentAttributeAnimated];
            } else if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                TGDocumentAttributeAudio *concreteAttribute = attribute;
                int32_t flags = 0;
                if (concreteAttribute.isVoice) {
                    flags |= (1 << 10);
                }
                if (concreteAttribute.title != nil) {
                    flags |= (1 << 0);
                }
                if (concreteAttribute.performer != nil) {
                    flags |= (1 << 1);
                }
                if (concreteAttribute.waveform != nil) {
                    flags |= (1 << 2);
                }
                
                return [Secret46_DocumentAttribute documentAttributeAudioWithFlags:@(flags) duration:@(concreteAttribute.duration) title:concreteAttribute.title performer:concreteAttribute.performer waveform:[concreteAttribute.waveform bitstream]];
            } else if ([attribute isKindOfClass:[TGDocumentAttributeFilename class]]) {
                TGDocumentAttributeFilename *concreteAttribute = attribute;
                return [Secret46_DocumentAttribute documentAttributeFilenameWithFileName:concreteAttribute.filename == nil ? @"" : concreteAttribute.filename];
            } else if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]]) {
                TGDocumentAttributeImageSize *concreteAttribute = attribute;
                return [Secret46_DocumentAttribute documentAttributeImageSizeWithW:@((int)concreteAttribute.size.width) h:@((int)concreteAttribute.size.height)];
            } else if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]]) {
                TGDocumentAttributeSticker *concreteAttribute = attribute;
                id stickerset = [Secret46_InputStickerSet inputStickerSetEmpty];
                NSString *shortName = [TGStickersSignals stickerPackShortName:concreteAttribute.packReference];
                if (shortName.length != 0) {
                    stickerset = [Secret46_InputStickerSet inputStickerSetShortNameWithShortName:shortName];
                }
                return [Secret46_DocumentAttribute documentAttributeStickerWithAlt:concreteAttribute.alt == nil ? @"" : concreteAttribute.alt stickerset:stickerset];
            } else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                TGDocumentAttributeVideo *concreteAttribute = attribute;
                return [Secret46_DocumentAttribute documentAttributeVideoWithDuration:@(concreteAttribute.duration) w:@((int)concreteAttribute.size.width) h:@((int)concreteAttribute.size.height)];
            }
            break;
        case 66:
            if ([attribute isKindOfClass:[TGDocumentAttributeAnimated class]]) {
                return [Secret66_DocumentAttribute documentAttributeAnimated];
            } else if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                TGDocumentAttributeAudio *concreteAttribute = attribute;
                int32_t flags = 0;
                if (concreteAttribute.isVoice) {
                    flags |= (1 << 10);
                }
                if (concreteAttribute.title != nil) {
                    flags |= (1 << 0);
                }
                if (concreteAttribute.performer != nil) {
                    flags |= (1 << 1);
                }
                if (concreteAttribute.waveform != nil) {
                    flags |= (1 << 2);
                }
                
                return [Secret66_DocumentAttribute documentAttributeAudioWithFlags:@(flags) duration:@(concreteAttribute.duration) title:concreteAttribute.title performer:concreteAttribute.performer waveform:[concreteAttribute.waveform bitstream]];
            } else if ([attribute isKindOfClass:[TGDocumentAttributeFilename class]]) {
                TGDocumentAttributeFilename *concreteAttribute = attribute;
                return [Secret66_DocumentAttribute documentAttributeFilenameWithFileName:concreteAttribute.filename == nil ? @"" : concreteAttribute.filename];
            } else if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]]) {
                TGDocumentAttributeImageSize *concreteAttribute = attribute;
                return [Secret66_DocumentAttribute documentAttributeImageSizeWithW:@((int)concreteAttribute.size.width) h:@((int)concreteAttribute.size.height)];
            } else if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]]) {
                TGDocumentAttributeSticker *concreteAttribute = attribute;
                id stickerset = [Secret66_InputStickerSet inputStickerSetEmpty];
                NSString *shortName = [TGStickersSignals stickerPackShortName:concreteAttribute.packReference];
                if (shortName.length != 0) {
                    stickerset = [Secret66_InputStickerSet inputStickerSetShortNameWithShortName:shortName];
                }
                return [Secret66_DocumentAttribute documentAttributeStickerWithAlt:concreteAttribute.alt == nil ? @"" : concreteAttribute.alt stickerset:stickerset];
            } else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                TGDocumentAttributeVideo *concreteAttribute = attribute;
                int32_t flags = 0;
                if (concreteAttribute.isRoundMessage) {
                    flags |= (1 << 0);
                }
                return [Secret66_DocumentAttribute documentAttributeVideoWithFlags:@(flags) duration:@(concreteAttribute.duration) w:@((int)concreteAttribute.size.width) h:@((int)concreteAttribute.size.height)];
            }
            break;
    }
    return nil;
}

- (id)decryptedDocumentWithLayer:(NSUInteger)layer thumbnailData:(NSData *)thumbnailData thumbnailSize:(CGSize)thumbnailSize attributes:(NSArray *)attributes mimeType:(NSString *)mimeType caption:(NSString *)caption size:(int)size key:(NSData *)key iv:(NSData *)iv
{
    NSString *fileName = @"file";
    NSMutableArray *convertedAttributes = [[NSMutableArray alloc] init];
    bool isVoice = false;
    int32_t voiceDuration = 0;
    
    for (id attribute in attributes) {
        if ([attribute isKindOfClass:[TGDocumentAttributeFilename class]]) {
            fileName = ((TGDocumentAttributeFilename *)attribute).filename;
        } else if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
            isVoice = ((TGDocumentAttributeAudio *)attribute).isVoice;
            voiceDuration = ((TGDocumentAttributeAudio *)attribute).duration;
        }
        
        id convertedAttribute = [self documentAttributeWithLayer:layer attribute:attribute];
        if (convertedAttribute != nil) {
            [convertedAttributes addObject:convertedAttribute];
        }
    }
    
    switch (layer)
    {
        case 1:
            return [Secret1_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:thumbnailData == nil ? [NSData data] : thumbnailData thumbW:@((int)thumbnailSize.width) thumbH:@((int)thumbnailSize.height) fileName:fileName mimeType:mimeType size:@(size) key:key iv:iv];
        case 17:
            return [Secret17_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:thumbnailData == nil ? [NSData data] : thumbnailData thumbW:@((int)thumbnailSize.width) thumbH:@((int)thumbnailSize.height) fileName:fileName mimeType:mimeType size:@(size) key:key iv:iv];
        case 20:
            return [Secret20_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:thumbnailData == nil ? [NSData data] : thumbnailData thumbW:@((int)thumbnailSize.width) thumbH:@((int)thumbnailSize.height) fileName:fileName mimeType:mimeType size:@(size) key:key iv:iv];
        case 23:
            if (isVoice) {
                return [Secret23_DecryptedMessageMedia decryptedMessageMediaAudioWithDuration:@(voiceDuration) mimeType:@"audio/ogg" size:@(size) key:key iv:iv];
            } else {
                return [Secret23_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:thumbnailData == nil ? [NSData data] : thumbnailData thumbW:@((int)thumbnailSize.width) thumbH:@((int)thumbnailSize.height) fileName:fileName mimeType:mimeType size:@(size) key:key iv:iv];
            }
        case 46:
            return [Secret46_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:thumbnailData == nil ? [NSData data] : thumbnailData thumbW:@((int)thumbnailSize.width) thumbH:@((int)thumbnailSize.height) mimeType:mimeType size:@(size) key:key iv:iv attributes:convertedAttributes caption:caption == nil ? @"" : caption];
        case 66:
            return [Secret66_DecryptedMessageMedia decryptedMessageMediaDocumentWithThumb:thumbnailData == nil ? [NSData data] : thumbnailData thumbW:@((int)thumbnailSize.width) thumbH:@((int)thumbnailSize.height) mimeType:mimeType size:@(size) key:key iv:iv attributes:convertedAttributes caption:caption == nil ? @"" : caption];
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
        case 46:
            return [Secret46_DecryptedMessageMedia decryptedMessageMediaAudioWithDuration:@(duration) mimeType:mimeType size:@(size) key:key iv:iv];
        case 66:
            return [Secret66_DecryptedMessageMedia decryptedMessageMediaAudioWithDuration:@(duration) mimeType:mimeType size:@(size) key:key iv:iv];
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
                    break;
                case 46:
                    convertedAttribute = [Secret46_DocumentAttribute documentAttributeFilenameWithFileName:((TGDocumentAttributeFilename *)attribute).filename];
                    break;
                case 66:
                    convertedAttribute = [Secret66_DocumentAttribute documentAttributeFilenameWithFileName:((TGDocumentAttributeFilename *)attribute).filename];
                    break;
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
                    break;
                case 46:
                    convertedAttribute = [Secret46_DocumentAttribute documentAttributeAnimated];
                    break;
                case 66:
                    convertedAttribute = [Secret66_DocumentAttribute documentAttributeAnimated];
                    break;
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
                    break;
                case 46:
                    convertedAttribute = [Secret46_DocumentAttribute documentAttributeImageSizeWithW:@((int32_t)((TGDocumentAttributeImageSize *)attribute).size.width) h:@((int32_t)((TGDocumentAttributeImageSize *)attribute).size.height)];
                    break;
                case 66:
                    convertedAttribute = [Secret66_DocumentAttribute documentAttributeImageSizeWithW:@((int32_t)((TGDocumentAttributeImageSize *)attribute).size.width) h:@((int32_t)((TGDocumentAttributeImageSize *)attribute).size.height)];
                    break;
                default:
                    break;
            }
            if (convertedAttribute != nil)
                [result addObject:convertedAttribute];
        }
        else if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
        {
            TGDocumentAttributeSticker *concreteAttribute = attribute;
            id convertedAttribute = nil;
            switch (layer)
            {
                case 23:
                    convertedAttribute = [Secret23_DocumentAttribute documentAttributeSticker];
                    break;
                case 46:
                {
                    Secret46_InputStickerSet *stickerset = [Secret46_InputStickerSet inputStickerSetEmpty];
                    NSString *shortName = [TGStickersSignals stickerPackShortName:concreteAttribute.packReference];
                    if (shortName.length != 0) {
                        stickerset = [Secret46_InputStickerSet inputStickerSetShortNameWithShortName:shortName];
                    }
                    convertedAttribute = [Secret46_DocumentAttribute documentAttributeStickerWithAlt:concreteAttribute.alt == nil ? @"" : concreteAttribute.alt stickerset:stickerset];
                    break;
                }
                case 66:
                {
                    Secret66_InputStickerSet *stickerset = [Secret66_InputStickerSet inputStickerSetEmpty];
                    NSString *shortName = [TGStickersSignals stickerPackShortName:concreteAttribute.packReference];
                    if (shortName.length != 0) {
                        stickerset = [Secret66_InputStickerSet inputStickerSetShortNameWithShortName:shortName];
                    }
                    convertedAttribute = [Secret66_DocumentAttribute documentAttributeStickerWithAlt:concreteAttribute.alt == nil ? @"" : concreteAttribute.alt stickerset:stickerset];
                    break;
                }
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
        case 46:
        {
            int32_t thumbDcId = 0;
            int64_t thumbVolumeId = 0;
            int32_t thumbLocalId = 0;
            int64_t thumbSecret = 0;
            extractFileUrlComponents(thumbnailUri, &thumbDcId, &thumbVolumeId, &thumbLocalId, &thumbSecret);
            Secret46_PhotoSize_photoCachedSize *cachedSize = [Secret46_PhotoSize photoCachedSizeWithType:@"s" location:[Secret46_FileLocation_fileLocation fileLocationWithDcId:@(thumbDcId) volumeId:@(thumbVolumeId) localId:@(thumbLocalId) secret:@(thumbSecret)] w:@(thumbnailSize.width) h:@(thumbnailSize.height) bytes:thumbnailData];
            return [Secret46_DecryptedMessageMedia decryptedMessageMediaExternalDocumentWithPid:@(n_id) accessHash:@(accessHash) date:@(date) mimeType:mimeType == nil ? @"" : mimeType size:@(size) thumb:cachedSize dcId:@(dcId) attributes:[self convertDocumentAttributes:attributes toLayer:layer]];
        }
        case 66:
        {
            int32_t thumbDcId = 0;
            int64_t thumbVolumeId = 0;
            int32_t thumbLocalId = 0;
            int64_t thumbSecret = 0;
            extractFileUrlComponents(thumbnailUri, &thumbDcId, &thumbVolumeId, &thumbLocalId, &thumbSecret);
            Secret66_PhotoSize_photoCachedSize *cachedSize = [Secret66_PhotoSize photoCachedSizeWithType:@"s" location:[Secret66_FileLocation_fileLocation fileLocationWithDcId:@(thumbDcId) volumeId:@(thumbVolumeId) localId:@(thumbLocalId) secret:@(thumbSecret)] w:@(thumbnailSize.width) h:@(thumbnailSize.height) bytes:thumbnailData];
            return [Secret66_DecryptedMessageMedia decryptedMessageMediaExternalDocumentWithPid:@(n_id) accessHash:@(accessHash) date:@(date) mimeType:mimeType == nil ? @"" : mimeType size:@(size) thumb:cachedSize dcId:@(dcId) attributes:[self convertDocumentAttributes:attributes toLayer:layer]];
        }
        default:
            break;
    }
    return nil;
}

- (id)decryptedWebpageWithLayer:(NSUInteger)layer url:(NSString *)url {
    if (url == nil) {
        return nil;
    }
    
    switch (layer) {
        case 46:
            return [Secret46_DecryptedMessageMedia decryptedMessageMediaWebPageWithUrl:url];
            break;
        case 66:
            return [Secret66_DecryptedMessageMedia decryptedMessageMediaWebPageWithUrl:url];
            break;
        default:
            break;
    }
    return nil;
}

- (NSUInteger)currentPeerLayer
{
    return MIN([TGModernSendSecretMessageActor currentLayer], [TGDatabaseInstance() peerLayer:_conversationId]);
}

- (NSString *)viaBotName {
    if (self.preparedMessage.botContextResult != nil) {
        TGUser *user = [TGDatabaseInstance() loadUser:self.preparedMessage.botContextResult.userId];
        if (user != nil) {
            return user.userName;
        }
    }
    return nil;
}

- (int64_t)replyToRandomId {
    if (self.preparedMessage.replyMessage != nil) {
        return [TGDatabaseInstance() randomIdForMessageId:self.preparedMessage.replyMessage.mid];
    }
    return 0;
}

- (id)convertedMessageEntityWithLayer:(NSUInteger)layer entity:(TGMessageEntity *)entity {
    if ([entity isKindOfClass:[TGMessageEntityBold class]]) {
        switch (layer) {
            case 46:
                return [Secret46_MessageEntity messageEntityBoldWithOffset:@(entity.range.location) length:@(entity.range.length)];
                break;
            case 66:
                return [Secret66_MessageEntity messageEntityBoldWithOffset:@(entity.range.location) length:@(entity.range.length)];
                break;
            default:
                break;
        }
    } else if ([entity isKindOfClass:[TGMessageEntityBotCommand class]]) {
        switch (layer) {
            case 46:
                return [Secret46_MessageEntity messageEntityBotCommandWithOffset:@(entity.range.location) length:@(entity.range.length)];
                break;
            case 66:
                return [Secret66_MessageEntity messageEntityBotCommandWithOffset:@(entity.range.location) length:@(entity.range.length)];
                break;
            default:
                break;
        }
    } else if ([entity isKindOfClass:[TGMessageEntityCode class]]) {
        switch (layer) {
            case 46:
                return [Secret46_MessageEntity messageEntityCodeWithOffset:@(entity.range.location) length:@(entity.range.length)];
                break;
            case 66:
                return [Secret66_MessageEntity messageEntityCodeWithOffset:@(entity.range.location) length:@(entity.range.length)];
                break;
            default:
                break;
        }
    } else if ([entity isKindOfClass:[TGMessageEntityEmail class]]) {
        switch (layer) {
            case 46:
                return [Secret46_MessageEntity messageEntityEmailWithOffset:@(entity.range.location) length:@(entity.range.length)];
                break;
            case 66:
                return [Secret66_MessageEntity messageEntityEmailWithOffset:@(entity.range.location) length:@(entity.range.length)];
                break;
            default:
                break;
        }
    } else if ([entity isKindOfClass:[TGMessageEntityHashtag class]]) {
        switch (layer) {
            case 46:
                return [Secret46_MessageEntity messageEntityHashtagWithOffset:@(entity.range.location) length:@(entity.range.length)];
                break;
            case 66:
                return [Secret66_MessageEntity messageEntityHashtagWithOffset:@(entity.range.location) length:@(entity.range.length)];
                break;
            default:
                break;
        }
    } else if ([entity isKindOfClass:[TGMessageEntityItalic class]]) {
        switch (layer) {
            case 46:
                return [Secret46_MessageEntity messageEntityItalicWithOffset:@(entity.range.location) length:@(entity.range.length)];
                break;
            case 66:
                return [Secret66_MessageEntity messageEntityItalicWithOffset:@(entity.range.location) length:@(entity.range.length)];
                break;
            default:
                break;
        }
    } else if ([entity isKindOfClass:[TGMessageEntityMention class]]) {
        switch (layer) {
            case 46:
                return [Secret46_MessageEntity messageEntityMentionWithOffset:@(entity.range.location) length:@(entity.range.length)];
                break;
            case 66:
                return [Secret66_MessageEntity messageEntityMentionWithOffset:@(entity.range.location) length:@(entity.range.length)];
                break;
            default:
                break;
        }
    } else if ([entity isKindOfClass:[TGMessageEntityPre class]]) {
        TGMessageEntityPre *concreteEntity = (TGMessageEntityPre *)entity;
        switch (layer) {
            case 46:
                return [Secret46_MessageEntity messageEntityPreWithOffset:@(entity.range.location) length:@(entity.range.length) language:concreteEntity.language == nil ? @"" : concreteEntity.language];
                break;
            case 66:
                return [Secret46_MessageEntity messageEntityPreWithOffset:@(entity.range.location) length:@(entity.range.length) language:concreteEntity.language == nil ? @"" : concreteEntity.language];
                break;
            default:
                break;
        }
    } else if ([entity isKindOfClass:[TGMessageEntityTextUrl class]]) {
        TGMessageEntityTextUrl *concreteEntity = (TGMessageEntityTextUrl *)entity;
        switch (layer) {
            case 46:
                return [Secret46_MessageEntity messageEntityTextUrlWithOffset:@(entity.range.location) length:@(entity.range.length) url:concreteEntity.url == nil ? @"" : concreteEntity.url];
                break;
            case 66:
                return [Secret46_MessageEntity messageEntityTextUrlWithOffset:@(entity.range.location) length:@(entity.range.length) url:concreteEntity.url == nil ? @"" : concreteEntity.url];
                break;
            default:
                break;
        }
    } else if ([entity isKindOfClass:[TGMessageEntityUrl class]]) {
        switch (layer) {
            case 46:
                return [Secret46_MessageEntity messageEntityUrlWithOffset:@(entity.range.location) length:@(entity.range.length)];
                break;
            case 66:
                return [Secret66_MessageEntity messageEntityUrlWithOffset:@(entity.range.location) length:@(entity.range.length)];
                break;
            default:
                break;
        }
    }
    
    return nil;
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
            
            NSMutableArray *convertedEntities = nil;
            if (textMessage.entities.count != 0) {
                convertedEntities = [[NSMutableArray alloc] init];
                for (id entity in textMessage.entities) {
                    id convertedEntity = [self convertedMessageEntityWithLayer:[self currentPeerLayer] entity:entity];
                    if (convertedEntity != nil) {
                        [convertedEntities addObject:convertedEntity];
                    }
                }
            }
            
            id media = nil;
            if (textMessage.parsedWebpage.url.length != 0) {
                media = [self decryptedWebpageWithLayer:[self currentPeerLayer] url:textMessage.parsedWebpage.url];
            }
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:textMessage.text media:media entities:convertedEntities viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:nil watcher:self];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedMapMessage class]])
        {
            [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
            
            TGPreparedMapMessage *mapMessage = (TGPreparedMapMessage *)self.preparedMessage;
            
            id media = [self decryptedGeoPointWithLayer:[self currentPeerLayer] latitude:mapMessage.latitude longitude:mapMessage.longitude venue:mapMessage.venue];
            
            int64_t randomId = self.preparedMessage.randomId;
            if (randomId == 0)
                arc4random_buf(&randomId, 8);
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:nil watcher:self];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalImageMessage class]])
        {
            TGPreparedLocalImageMessage *localImageMessage = (TGPreparedLocalImageMessage *)self.preparedMessage;
            
            [self setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
            
            [self uploadFilesWithExtensions:@[@[localImageMessage.localImageDataPath, @"bin", @(true)]] mediaTypeTag:TGNetworkMediaTypeTagImage];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalVideoMessage class]])
        {
            TGPreparedLocalVideoMessage *localVideoMessage = (TGPreparedLocalVideoMessage *)self.preparedMessage;
            
            [self setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
            
            [self uploadFilesWithExtensions:@[@[[localVideoMessage localVideoPath], @"bin", @(true)]] mediaTypeTag:TGNetworkMediaTypeTagVideo];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedLocalDocumentMessage class]])
        {
            TGPreparedLocalDocumentMessage *preparedDocument = (TGPreparedLocalDocumentMessage *)self.preparedMessage;
            
            [self setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
            
            NSMutableArray *desc = [[NSMutableArray alloc] init];
            [desc addObjectsFromArray:@[[[preparedDocument localDocumentDirectory] stringByAppendingPathComponent:[preparedDocument localDocumentFileName]], @"bin", @(true)]];
            if (preparedDocument.liveUploadData != nil)
                [desc addObject:preparedDocument.liveUploadData];
            
            [self uploadFilesWithExtensions:@[desc] mediaTypeTag:TGNetworkMediaTypeTagDocument];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedRemoteImageMessage class]])
        {
            TGImageMediaAttachment *imageAttachment = nil;
            for (id attachment in [self.preparedMessage message].mediaAttachments) {
                if ([attachment isKindOfClass:[TGImageMediaAttachment class]]) {
                    imageAttachment = attachment;
                    break;
                }
            }
            
            if ([self isMediaLocallyAvailable:imageAttachment])
            {
                if ([self doesMediaRequireUpload:imageAttachment])
                {
                    if (![self uploadForwardedMedia:imageAttachment])
                        [self _fail];
                }
                else
                {
                    if (![self sendForwardedMedia:imageAttachment filePathToUploadedFile:@{}])
                        [self _fail];
                }
            }
            else
            {
                if (![self downloadMedia:imageAttachment messageId:self.preparedMessage.mid conversationId:_conversationId])
                    [self _fail];
            }
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedRemoteDocumentMessage class]])
        {
            TGPreparedRemoteDocumentMessage *preparedDocument = (TGPreparedRemoteDocumentMessage *)self.preparedMessage;
            
            bool isSticker = false;
            for (id attribute in preparedDocument.attributes) {
                if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]]) {
                    isSticker = true;
                    break;
                }
            }
            
            if (isSticker) {
                [self setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
                
                CGSize thumSize = CGSizeZero;
                NSString *thumbnailUri = [preparedDocument.thumbnailInfo imageUrlForLargestSize:&thumSize];
                NSData *thumbnailData = nil;
                
                if (thumbnailUri != nil) {
                    [NSData dataWithContentsOfFile:[[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:preparedDocument.documentId version:0] stringByAppendingPathComponent:@"thumbnail"]];
                    if (thumbnailData == nil)
                    {
                        thumbnailData = [NSData dataWithContentsOfFile:[[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:preparedDocument.documentId version:0] stringByAppendingPathComponent:@"thumbnail-high"]];
                    }
                }
                
                if (thumbnailData == nil && thumbnailUri != nil) {
                    int datacenterId = 0;
                    int64_t volumeId = 0;
                    int localId = 0;
                    int64_t secret = 0;
                    if (extractFileUrlComponents(thumbnailUri, &datacenterId, &volumeId, &localId, &secret)) {
                        TLInputFileLocation$inputFileLocation *location = [[TLInputFileLocation$inputFileLocation alloc] init];
                        location.volume_id = volumeId;
                        location.local_id = localId;
                        location.secret = secret;
                        __weak TGModernSendSecretMessageActor *weakSelf = self;
                        [self.disposables add:[[[TGRemoteFileSignal dataForLocation:location datacenterId:datacenterId size:0 reportProgress:false mediaTypeTag:TGNetworkMediaTypeTagDocument] deliverOn:[SQueue wrapConcurrentNativeQueue:[ActionStageInstance() globalStageDispatchQueue]]] startWithNext:^(NSData *data) {
                            __strong TGModernSendSecretMessageActor *strongSelf = weakSelf;
                            if (strongSelf != nil) {
                                id media = [strongSelf decryptedExternalDocumentWithLayer:[strongSelf currentPeerLayer] id:preparedDocument.documentId accessHash:preparedDocument.accessHash date:preparedDocument.date mimeType:preparedDocument.mimeType size:preparedDocument.size thumbnailUri:thumbnailUri thumbnailData:data thumbnailSize:thumSize dcId:preparedDocument.datacenterId attributes:preparedDocument.attributes];
                                
                                int64_t randomId = strongSelf.preparedMessage.randomId;
                                if (randomId == 0)
                                    arc4random_buf(&randomId, 8);
                                
                                strongSelf->_actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[strongSelf peerId] layer:[strongSelf currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[strongSelf currentPeerLayer] text:nil media:media entities:nil viaBotName:[strongSelf viaBotName] lifetime:strongSelf.preparedMessage.messageLifetime replyToRandomId:[strongSelf replyToRandomId] randomId:randomId] storedFileInfo:nil watcher:strongSelf];
                            }
                        } error:^(__unused id error) {
                            __strong TGModernSendSecretMessageActor *strongSelf = weakSelf;
                            if (strongSelf != nil) {
                                [strongSelf _fail];
                            }
                        } completed:nil]];
                    } else {
                        [self _fail];
                    }
                } else {
                    id media = [self decryptedExternalDocumentWithLayer:[self currentPeerLayer] id:preparedDocument.documentId accessHash:preparedDocument.accessHash date:preparedDocument.date mimeType:preparedDocument.mimeType size:preparedDocument.size thumbnailUri:thumbnailUri thumbnailData:thumbnailData thumbnailSize:thumSize dcId:preparedDocument.datacenterId attributes:preparedDocument.attributes];
                    
                    int64_t randomId = self.preparedMessage.randomId;
                    if (randomId == 0)
                        arc4random_buf(&randomId, 8);
                    
                    _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:nil watcher:self];
                }
            } else {
                NSString *thumbnailUri = [preparedDocument.thumbnailInfo imageUrlForLargestSize:NULL];
                
                SSignal *documentSignal = [[TGSharedFileSignals documentData:[preparedDocument document] priority:true] mapToSignal:^SSignal *(NSArray *signals) {
                    return [SSignal mergeSignals:signals];
                }];
                
                //self.uploadProgressContainsPreDownloads = true;
                __weak TGModernSendSecretMessageActor *weakSelf = self;
                [self.disposables add:[[documentSignal deliverOn:[SQueue wrapConcurrentNativeQueue:[ActionStageInstance() globalStageDispatchQueue]]] startWithNext:^(id next) {
                    __strong TGModernSendSecretMessageActor *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        if ([next respondsToSelector:@selector(floatValue)]) {
                            
                        } else {
                            NSData *documentData = next;
                            [strongSelf _uploadDownloadedData:documentData dispatchThumbnail:thumbnailUri.length != 0];
                        }
                    }
                } error:^(__unused id error) {
                    __strong TGModernSendSecretMessageActor *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [ActionStageInstance() actionFailed:self.path reason:-1];
                    }
                } completed:nil]];
            }
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedRemoteVideoMessage class]])
        {
            TGPreparedRemoteVideoMessage *preparedVideo = (TGPreparedRemoteVideoMessage *)self.preparedMessage;
            
            NSString *thumbnailUri = [preparedVideo.thumbnailInfo imageUrlForLargestSize:NULL];
            
            SSignal *documentSignal = [[TGSharedFileSignals videoData:[preparedVideo video] priority:true] mapToSignal:^SSignal *(NSArray *signals) {
                return [SSignal mergeSignals:signals];
            }];
            
            self.uploadProgressContainsPreDownloads = true;
            __weak TGModernSendSecretMessageActor *weakSelf = self;
            [self.disposables add:[[documentSignal deliverOn:[SQueue wrapConcurrentNativeQueue:[ActionStageInstance() globalStageDispatchQueue]]] startWithNext:^(id next) {
                __strong TGModernSendSecretMessageActor *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    if ([next respondsToSelector:@selector(floatValue)]) {
                        [strongSelf updatePreDownloadsProgress:[next floatValue]];
                    } else {
                        NSData *documentData = next;
                        [strongSelf _uploadDownloadedData:documentData dispatchThumbnail:thumbnailUri.length != 0];
                    }
                }
            } error:^(__unused id error) {
                __strong TGModernSendSecretMessageActor *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [ActionStageInstance() actionFailed:self.path reason:-1];
                }
            } completed:nil]];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedForwardedMessage class]])
        {
            TGPreparedForwardedMessage *preparedForwardedMessage = (TGPreparedForwardedMessage *)self.preparedMessage;
            id media = [self mediaToForward:preparedForwardedMessage.innerMessage];
            
            if (media != nil)
            {
                if ([media isKindOfClass:[TGDocumentMediaAttachment class]] && ((TGDocumentMediaAttachment *)media).isStickerWithPack) {
                    TGDocumentMediaAttachment *document = media;
                    
                    CGSize thumSize = CGSizeZero;
                    NSString *thumbnailUri = [document.thumbnailInfo imageUrlForLargestSize:&thumSize];
                    NSData *thumbnailData = nil;
                    
                    if (thumbnailUri != nil) {
                        [NSData dataWithContentsOfFile:[[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId version:0] stringByAppendingPathComponent:@"thumbnail"]];
                        if (thumbnailData == nil)
                        {
                            thumbnailData = [NSData dataWithContentsOfFile:[[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId version:0] stringByAppendingPathComponent:@"thumbnail-high"]];
                        }
                    }
                    
                    id media = [self decryptedExternalDocumentWithLayer:[self currentPeerLayer] id:document.documentId accessHash:document.accessHash date:document.date mimeType:document.mimeType size:document.size thumbnailUri:thumbnailUri thumbnailData:thumbnailData thumbnailSize:thumSize dcId:document.datacenterId attributes:document.attributes];
                    
                    int64_t randomId = self.preparedMessage.randomId;
                    if (randomId == 0)
                        arc4random_buf(&randomId, 8);
                    
                    _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:nil watcher:self];
                } else if ([self isMediaLocallyAvailable:media])
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
                
                _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:preparedForwardedMessage.innerMessage.text media:nil entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:nil watcher:self];
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
                [ActionStageInstance() requestActor:path options:@{@"url": url, @"file": imagePath, @"queue": @"messagePreDownloads", @"mediaTypeTag": @(TGNetworkMediaTypeTagImage)} flags:0 watcher:self];
                
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
                [ActionStageInstance() requestActor:path options:@{@"url": downloadDocumentMessage.documentUrl, @"size": @(downloadDocumentMessage.size), @"path": documentPath, @"queue": @"messagePreDownloads", @"mediaTypeTag": @(TGNetworkMediaTypeTagDocument)} flags:0 watcher:self];
                
                [self beginUploadProgress];
            }
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedAssetImageMessage class]])
        {
            TGPreparedAssetImageMessage *assetImageMessage = (TGPreparedAssetImageMessage *)self.preparedMessage;
            
            [self beginUploadProgress];
            
            __weak TGModernSendSecretMessageActor *weakSelf = self;
            [self.disposables add:[[[[[TGMediaAssetsLibrary sharedLibrary] assetWithIdentifier:assetImageMessage.assetIdentifier] mapToSignal:^SSignal *(TGMediaAsset *asset)
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
            }] deliverOn:[SQueue wrapConcurrentNativeQueue:[ActionStageInstance() globalStageDispatchQueue]]] startWithNext:^(id next)
            {
                __strong TGModernSendSecretMessageActor *strongSelf = weakSelf;
                if ([next isKindOfClass:[NSNumber class]])
                {
                    float value = [next floatValue];
                    [strongSelf updatePreDownloadsProgress:value];
                }
                else if ([next isKindOfClass:[UIImage class]] && !((UIImage *)next).degraded)
                {
                    [strongSelf updatePreDownloadsProgress:1.0f];
                    
                    [strongSelf setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
                    
                    assetImageMessage.imageSize = ((UIImage *)next).size;
                    
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
                    
                    [strongSelf uploadFilesWithExtensions:@[@[imageData, @"bin", @(true)]] mediaTypeTag:TGNetworkMediaTypeTagImage];
                }
                else if ([next isKindOfClass:[TGMediaAssetImageData class]])
                {
                    [strongSelf updatePreDownloadsProgress:1.0f];
                    
                    [strongSelf setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
                    
                    TGMediaAssetImageData *assetData = (TGMediaAssetImageData *)next;
                    NSData *documentData = assetData.imageData;
                    
                    assetImageMessage.fileSize = (uint32_t)assetData.imageData.length;
                    
                    TGMessage *updatedMessage = [TGDatabaseInstance() loadMessageWithMid:self.preparedMessage.mid peerId:_conversationId];
                    if (updatedMessage == nil) {
                        updatedMessage = self.preparedMessage.message;
                    }
                    updatedMessage.cid = _conversationId;
                    
                    TGDatabaseUpdateMessageWithMessage *messageUpdate = [[TGDatabaseUpdateMessageWithMessage alloc] initWithPeerId:0 messageId:self.preparedMessage.mid message:updatedMessage dispatchEdited:false];
                    [TGDatabaseInstance() transactionUpdateMessages:@[messageUpdate] updateConversationDatas:nil];
                    
                    updatedMessage = [TGDatabaseInstance() loadMessageWithMid:self.preparedMessage.mid peerId:_conversationId];
                    id resource = [[SGraphObjectNode alloc] initWithObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:self.preparedMessage.mid], updatedMessage, nil]];
                    [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesChanged", _conversationId] resource:resource];
                    
                    NSArray *attributes = assetImageMessage.attributes;
                    
                    NSString *documentPath = [self filePathForLocalDocumentId:assetImageMessage.localDocumentId attributes:attributes];
                    [[NSFileManager defaultManager] createDirectoryAtPath:[documentPath stringByDeletingLastPathComponent] withIntermediateDirectories:true attributes:nil error:nil];
                    [documentData writeToFile:documentPath atomically:false];
                    
                    NSMutableArray *files = [[NSMutableArray alloc] init];
                    [files addObject:@[documentPath, @"bin", @(true)]];
                    
                    NSString *thumbnailUrl = [assetImageMessage.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
                    if (thumbnailUrl != nil)
                        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/as/media/imageThumbnailUpdated"] resource:thumbnailUrl];
                    
                    [self uploadFilesWithExtensions:files mediaTypeTag:TGNetworkMediaTypeTagImage];
                }
            } error:^(__unused id error)
            {
                __strong TGModernSendSecretMessageActor *strongSelf = weakSelf;
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
            
            if (!assetVideoMessage.document || assetVideoMessage.isAnimation)
                self.uploadProgressContainsPreDownloads = true;
            
            NSString *tempFilePath = TGTemporaryFileName(nil);
            
            SSignal *signal = nil;
            if (assetVideoMessage.roundMessage && assetVideoMessage.adjustments == nil)
            {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                if ([[NSFileManager defaultManager] fileExistsAtPath:assetVideoMessage.assetURL.path])
                    dict[@"fileUrl"] = assetVideoMessage.assetURL;
                else
                    dict[@"fileUrl"] = [NSURL fileURLWithPath:assetVideoMessage.localVideoPath];
                dict[@"duration"] = @(assetVideoMessage.duration);
                dict[@"dimensions"] = [NSValue valueWithCGSize:assetVideoMessage.dimensions];
                dict[@"previewImage"] = [UIImage imageWithContentsOfFile:assetVideoMessage.localThumbnailDataPath];
                if (assetVideoMessage.liveData)
                    dict[@"liveUploadData"] = assetVideoMessage.liveData;
                
                signal = [SSignal single:@{ @"convertResult": dict }];
            }
            else
            {
                SSignal *sourceSignal = nil;
                if (assetVideoMessage.assetIdentifier != nil)
                {
                    sourceSignal = [[[TGMediaAssetsLibrary sharedLibrary] assetWithIdentifier:assetVideoMessage.assetIdentifier] mapToSignal:^SSignal *(TGMediaAsset *asset)
                    {
                        if (!assetVideoMessage.document || assetVideoMessage.isAnimation)
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
                    }];
                }
                else if (assetVideoMessage.assetURL != nil)
                {
                    sourceSignal = [SSignal single:[[AVURLAsset alloc] initWithURL:assetVideoMessage.assetURL options:nil]];
                }
                else
                {
                    sourceSignal = [SSignal fail:nil];
                }
            
                signal = [videoDownloadQueue() enqueue:[sourceSignal mapToSignal:^SSignal *(id value)
                {
                    if ([value isKindOfClass:[AVAsset class]])
                    {
                        AVAsset *avAsset = (AVAsset *)value;
                        
                        SSignal *innerConvertSignal = iosMajorVersion() < 8 ? [TGVideoConverter convertSignalForAVAsset:avAsset adjustments:adjustments liveUpload:liveUpload passthrough:false] : [TGMediaVideoConverter convertAVAsset:avAsset adjustments:adjustments watcher:liveUpload ? [[TGMediaLiveUploadWatcher alloc] init] : nil];
                        
                        return [innerConvertSignal map:^id(id value)
                        {
                            if ([value isKindOfClass:[TGMediaVideoConversionResult class]])
                            {
                                NSMutableDictionary *dict = [[(TGMediaVideoConversionResult *)value dictionary] mutableCopy];
                                return @{ @"convertResult": dict };
                            }
                            else if ([value isKindOfClass:[NSDictionary class]])
                            {
                                return @{ @"convertResult": value };
                            }
                            else if ([value isKindOfClass:[NSNumber class]])
                            {
                                return @{ @"convertProgress": value };
                            }
                            return nil;
                        }];
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
            }
            
            __weak TGModernSendSecretMessageActor *weakSelf = self;
            [self.disposables add:[[signal deliverOn:[SQueue wrapConcurrentNativeQueue:[ActionStageInstance() globalStageDispatchQueue]]] startWithNext:^(id next)
            {
                __strong TGModernSendSecretMessageActor *strongSelf = weakSelf;
                if (![next isKindOfClass:[NSDictionary class]])
                    return;
                
                NSDictionary *dict = (NSDictionary *)next;
                if (dict[@"downloadProgress"] != nil)
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
                    
                    [strongSelf setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
                    
                    assetVideoMessage.duration = [result[@"duration"] doubleValue];
                    assetVideoMessage.dimensions = [result[@"dimensions"] CGSizeValue];
                    assetVideoMessage.fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:[result[@"fileUrl"] path] error:NULL][NSFileSize] intValue];
                    
                    TGMessage *updatedMessage = [TGDatabaseInstance() loadMessageWithMid:self.preparedMessage.mid peerId:_conversationId];
                    if (updatedMessage == nil) {
                        updatedMessage = self.preparedMessage.message;
                    }
                    updatedMessage.cid = _conversationId;
                    
                    TGDatabaseUpdateMessageWithMessage *messageUpdate = [[TGDatabaseUpdateMessageWithMessage alloc] initWithPeerId:0 messageId:self.preparedMessage.mid message:updatedMessage dispatchEdited:false];
                    [TGDatabaseInstance() transactionUpdateMessages:@[messageUpdate] updateConversationDatas:nil];
                    
                    updatedMessage = [TGDatabaseInstance() loadMessageWithMid:self.preparedMessage.mid peerId:_conversationId];
                    
                    if (assetVideoMessage.isAnimation)
                    {
                        NSArray *attributes = assetVideoMessage.attributes;
                        
                        NSString *documentPath = [self filePathForLocalDocumentId:assetVideoMessage.localDocumentId attributes:attributes];
                        [[NSFileManager defaultManager] createDirectoryAtPath:[documentPath stringByDeletingLastPathComponent] withIntermediateDirectories:true attributes:nil error:nil];
                        [[NSFileManager defaultManager] moveItemAtPath:[result[@"fileUrl"] path] toPath:documentPath error:nil];
                        
                        NSString *thumbnailUrl = [assetVideoMessage.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
                        if (thumbnailUrl != nil)
                            [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/as/media/imageThumbnailUpdated"] resource:thumbnailUrl];
                        
                        [self uploadFilesWithExtensions:@[@[documentPath, @"bin", @(true)]] mediaTypeTag:TGNetworkMediaTypeTagVideo];
                    }
                    else
                    {
                        [[NSFileManager defaultManager] removeItemAtPath:[assetVideoMessage localVideoPath] error:nil];
                        [[NSFileManager defaultManager] moveItemAtPath:[result[@"fileUrl"] path] toPath:[assetVideoMessage localVideoPath] error:nil];
                        [[NSFileManager defaultManager] createSymbolicLinkAtPath:[result[@"fileUrl"] path] withDestinationPath:[assetVideoMessage localVideoPath] error:nil];
                        
                        NSString *thumbnailUrl = [assetVideoMessage.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
                        if (thumbnailUrl != nil)
                            [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/as/media/imageThumbnailUpdated"] resource:thumbnailUrl];
                        
                        [self uploadFilesWithExtensions:@[@[[assetVideoMessage localVideoPath], @"bin", @(true)]] mediaTypeTag:TGNetworkMediaTypeTagVideo];
                    }
                    
                    id resource = [[SGraphObjectNode alloc] initWithObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:self.preparedMessage.mid], updatedMessage, nil]];
                    [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesChanged", _conversationId] resource:resource];
                }
                else if (dict[@"fileResult"] != nil)
                {
                    [strongSelf updatePreDownloadsProgress:1.0f];
                    
                    [strongSelf setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
                    
                    NSDictionary *result = dict[@"fileResult"];
                    
                    assetVideoMessage.fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:result[@"filePath"] error:NULL][NSFileSize] intValue];
                    
                    TGMessage *updatedMessage = [TGDatabaseInstance() loadMessageWithMid:self.preparedMessage.mid peerId:_conversationId];
                    if (updatedMessage == nil) {
                        updatedMessage = self.preparedMessage.message;
                    }
                    updatedMessage.cid = _conversationId;
                    
                    TGDatabaseUpdateMessageWithMessage *messageUpdate = [[TGDatabaseUpdateMessageWithMessage alloc] initWithPeerId:0 messageId:self.preparedMessage.mid message:updatedMessage dispatchEdited:false];
                    [TGDatabaseInstance() transactionUpdateMessages:@[messageUpdate] updateConversationDatas:nil];
                    
                    updatedMessage = [TGDatabaseInstance() loadMessageWithMid:self.preparedMessage.mid peerId:_conversationId];
                    id resource = [[SGraphObjectNode alloc] initWithObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:self.preparedMessage.mid], updatedMessage, nil]];
                    [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesChanged", _conversationId] resource:resource];
                    
                    NSArray *attributes = assetVideoMessage.attributes;
                    
                    NSString *documentPath = [self filePathForLocalDocumentId:assetVideoMessage.localDocumentId attributes:attributes];
                    [[NSFileManager defaultManager] createDirectoryAtPath:[documentPath stringByDeletingLastPathComponent] withIntermediateDirectories:true attributes:nil error:nil];
                    [[NSFileManager defaultManager] moveItemAtPath:result[@"filePath"] toPath:documentPath error:nil];
                    
                    NSString *thumbnailUrl = [assetVideoMessage.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
                    if (thumbnailUrl != nil)
                        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/as/media/imageThumbnailUpdated"] resource:thumbnailUrl];
                    
                    [self uploadFilesWithExtensions:@[@[documentPath, @"bin", @(true)]] mediaTypeTag:TGNetworkMediaTypeTagVideo];
                }
            } error:^(__unused id error)
            {
                __strong TGModernSendSecretMessageActor *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    TGLog(@"Cloud photo load error");
                    [strongSelf _fail];
                }
            } completed:nil]];
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadExternalGifMessage class]]) {
            TGPreparedDownloadExternalGifMessage *downloadDocumentMessage = (TGPreparedDownloadExternalGifMessage *)self.preparedMessage;
            
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
                [ActionStageInstance() requestActor:path options:@{@"url": downloadDocumentMessage.documentUrl, @"size": @(downloadDocumentMessage.size), @"path": documentPath, @"queue": @"messagePreDownloads", @"mediaTypeTag": @(TGNetworkMediaTypeTagDocument)} flags:0 watcher:self];
                
                [self beginUploadProgress];
            }
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadExternalDocumentMessage class]]) {
            TGPreparedDownloadExternalDocumentMessage *downloadDocumentMessage = (TGPreparedDownloadExternalDocumentMessage *)self.preparedMessage;
            
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
                [ActionStageInstance() requestActor:path options:@{@"url": downloadDocumentMessage.documentUrl, @"size": @(downloadDocumentMessage.size), @"path": documentPath, @"queue": @"messagePreDownloads", @"mediaTypeTag": @(TGNetworkMediaTypeTagDocument)} flags:0 watcher:self];
                
                [self beginUploadProgress];
            }
        }
        else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadExternalImageMessage class]]) {
            TGPreparedDownloadExternalImageMessage *downloadImageMessage = (TGPreparedDownloadExternalImageMessage *)self.preparedMessage;
            
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
                [ActionStageInstance() requestActor:path options:@{@"url": url, @"file": imagePath, @"queue": @"messagePreDownloads", @"mediaTypeTag": @(TGNetworkMediaTypeTagImage)} flags:0 watcher:self];
                
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
    TGDatabaseUpdateMessageFailedDeliveryInBackground *messageUpdate = [[TGDatabaseUpdateMessageFailedDeliveryInBackground alloc] initWithPeerId:_conversationId messageId:self.preparedMessage.mid];
    [TGDatabaseInstance() transactionUpdateMessages:@[messageUpdate] updateConversationDatas:nil];
    
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
        directory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId version:document.version];
    else
        directory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:document.localDocumentId version:document.version];
    
    NSString *filePath = [directory stringByAppendingPathComponent:[TGDocumentMediaAttachment safeFileNameForFileName:document.fileName]];
    return filePath;
}

- (NSString *)filePathForAudio:(TGAudioMediaAttachment *)audio
{
    NSString *filePath = nil;
    if (audio.audioId != 0)
        filePath = [TGAudioMediaAttachment localAudioFilePathForRemoteAudioId:audio.audioId];
    else
        filePath = [TGAudioMediaAttachment localAudioFilePathForLocalAudioId:audio.localAudioId];
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
            
            id media = [self decryptedPhotoWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize imageSize:size caption:imageAttachment.caption size:(int32_t)[fileInfo[@"fileSize"] intValue] key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
            
            _sentDecryptedPhotoSize = (int32_t)[fileInfo[@"fileSize"] intValue];
            _sendDecryptedPhotoKey = fileInfo[@"key"];
            _sendDecryptedPhotoIv = fileInfo[@"iv"];
            
            int64_t randomId = self.preparedMessage.randomId;
            if (randomId == 0)
                arc4random_buf(&randomId, 8);
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
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
            
            id media = nil;
            if (videoAttachment.roundMessage) {
                NSArray *attributes = @[[[TGDocumentAttributeVideo alloc] initWithRoundMessage:true size:videoAttachment.dimensions duration:(int32_t)videoAttachment.duration], [[TGDocumentAttributeFilename alloc] initWithFilename:@"video.mp4"]];
                media = [self decryptedDocumentWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize attributes:attributes mimeType:@"video/mp4" caption:videoAttachment.caption size:videoSize key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
            } else {
                media = [self decryptedVideoWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize duration:(int32_t)videoAttachment.duration dimensions:videoAttachment.dimensions mimeType:@"video/mp4" caption:videoAttachment.caption size:videoSize key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
            }
            
            int64_t randomId = self.preparedMessage.randomId;
            if (randomId == 0)
                arc4random_buf(&randomId, 8);
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
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
        
        CGSize pictureSize = [documentAttachment pictureSize];
        
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
                CGSize thumbSize = TGFitSize(pictureSize.width < FLT_EPSILON ? thumbnailImage.size : pictureSize, CGSizeMake(90, 90));
                thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(thumbnailImage, thumbSize), 0.6f);
                
                if (thumbnailData != nil)
                    thumbnailSize = thumbSize;
            }
            
            id media = [self decryptedDocumentWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize attributes:documentAttachment.attributes mimeType:documentAttachment.mimeType caption:documentAttachment.caption size:documentAttachment.size key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
            
            _sentDecryptedDocumentSize = documentAttachment.size;
            _sendDecryptedDocumentKey = fileInfo[@"key"];
            _sendDecryptedDocumentIv = fileInfo[@"iv"];
            
            int64_t randomId = self.preparedMessage.randomId;
            if (randomId == 0)
                arc4random_buf(&randomId, 8);
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
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
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
            return true;
        }
        else
            return false;
    }
    else if ([attachment isKindOfClass:[TGLocationMediaAttachment class]])
    {
        [self setupFailTimeout:[TGModernSendMessageActor defaultTimeoutInterval]];
        
        TGLocationMediaAttachment *locationAttachment = attachment;
        
        id media = [self decryptedGeoPointWithLayer:[self currentPeerLayer] latitude:locationAttachment.latitude longitude:locationAttachment.longitude venue:locationAttachment.venue];
        
        int64_t randomId = self.preparedMessage.randomId;
        if (randomId == 0)
            arc4random_buf(&randomId, 8);
        
        _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:nil watcher:self];
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
        
        [self uploadFilesWithExtensions:@[@[imageCachePath, @"bin", @(true)]] mediaTypeTag:TGNetworkMediaTypeTagImage];
        
        return true;
    }
    else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
    {
        TGVideoMediaAttachment *videoAttachment = attachment;
        NSString *videoPath = [self filePathForVideoId:videoAttachment.videoId == 0 ? videoAttachment.localVideoId : videoAttachment.videoId local:videoAttachment.videoId == 0];
        
        [self setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
        
        [self uploadFilesWithExtensions:@[@[videoPath, @"bin", @(true)]] mediaTypeTag:TGNetworkMediaTypeTagVideo];
        
        return true;
    }
    else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
    {
        TGDocumentMediaAttachment *documentAttachment = attachment;
        NSString *documentPath = [self filePathForDocument:documentAttachment];
        
        [self setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
        
        TGNetworkMediaTypeTag mediaTypeTag = TGNetworkMediaTypeTagDocument;
        for (id attribute in documentAttachment.attributes) {
            if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                mediaTypeTag = TGNetworkMediaTypeTagAudio;
                break;
            }
        }
        [self uploadFilesWithExtensions:@[@[documentPath, @"bin", @(true)]] mediaTypeTag:mediaTypeTag];
        
        return true;
    }
    else if ([attachment isKindOfClass:[TGAudioMediaAttachment class]])
    {
        TGAudioMediaAttachment *audioAttachment = attachment;
        NSString *audioPath = [self filePathForAudio:audioAttachment];
        
        [self setupFailTimeout:[TGModernSendSecretMessageActor defaultTimeoutInterval]];
        
        [self uploadFilesWithExtensions:@[@[audioPath, @"bin", @(true)]] mediaTypeTag:TGNetworkMediaTypeTagAudio];
        
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
            
            id media = [self decryptedPhotoWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize imageSize:localImageMessage.imageSize caption:localImageMessage.caption size:(int32_t)[fileInfo[@"fileSize"] intValue] key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
            
            _sentDecryptedPhotoSize = (int32_t)[fileInfo[@"fileSize"] intValue];
            _sendDecryptedPhotoKey = fileInfo[@"key"];
            _sendDecryptedPhotoIv = fileInfo[@"iv"];
            
            int64_t randomId = self.preparedMessage.randomId;
            if (randomId == 0)
                arc4random_buf(&randomId, 8);
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
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
            
            id media = [self decryptedVideoWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize duration:(int)localVideoMessage.duration dimensions:localVideoMessage.videoSize mimeType:@"video/mp4" caption:localVideoMessage.caption size:localVideoMessage.size key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
            
            int64_t randomId = self.preparedMessage.randomId;
            if (randomId == 0)
                arc4random_buf(&randomId, 8);
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
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
            
            id media = [self decryptedDocumentWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize attributes:localDocumentMessage.attributes mimeType:localDocumentMessage.mimeType caption:@"" size:localDocumentMessage.size key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
            
            _sentDecryptedDocumentSize = localDocumentMessage.size;
            _sendDecryptedDocumentKey = fileInfo[@"key"];
            _sendDecryptedDocumentIv = fileInfo[@"iv"];
            
            int64_t randomId = self.preparedMessage.randomId;
            if (randomId == 0)
                arc4random_buf(&randomId, 8);
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
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
    else if ([self.preparedMessage isKindOfClass:[TGPreparedRemoteImageMessage class]]) {
        TGImageMediaAttachment *imageAttachment = nil;
        for (id attachment in [self.preparedMessage.message mediaAttachments]) {
            if ([attachment isKindOfClass:[TGImageMediaAttachment class]]) {
                imageAttachment = attachment;
            }
        }
        
        CGSize size = CGSizeZero;
        NSString *imageUrl = [imageAttachment.imageInfo closestImageUrlWithSize:CGSizeMake(1000, 1000) resultingSize:&size];
        NSString *imageCachePath = [[TGRemoteImageView sharedCache] pathForCachedData:imageUrl];
        
        NSDictionary *fileInfo = filePathToUploadedFile[imageCachePath];
        if (fileInfo != nil)
        {
            UIImage *thumbnailImage = [[UIImage alloc] initWithContentsOfFile:imageCachePath];
            CGSize thumbnailSize = TGFitSize(thumbnailImage.size, CGSizeMake(90, 90));
            NSData *thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(thumbnailImage, thumbnailSize), 0.6f);
            
            id media = [self decryptedPhotoWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize imageSize:size caption:imageAttachment.caption size:(int32_t)[fileInfo[@"fileSize"] intValue] key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
            
            _sentDecryptedPhotoSize = (int32_t)[fileInfo[@"fileSize"] intValue];
            _sendDecryptedPhotoKey = fileInfo[@"key"];
            _sendDecryptedPhotoIv = fileInfo[@"iv"];
            
            int64_t randomId = self.preparedMessage.randomId;
            if (randomId == 0)
                arc4random_buf(&randomId, 8);
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
        }
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
                
                id media = [self decryptedPhotoWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize imageSize:imageSize caption:downloadImageMessage.caption size:(int32_t)[fileInfo[@"fileSize"] intValue] key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
                
                _sentDecryptedPhotoSize = (int32_t)[fileInfo[@"fileSize"] intValue];
                _sendDecryptedPhotoKey = fileInfo[@"key"];
                _sendDecryptedPhotoIv = fileInfo[@"iv"];
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                
                _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
            }
            else
                [self _fail];
        }
        else
            [self _fail];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadExternalImageMessage class]]) {
        TGPreparedDownloadExternalImageMessage *downloadImageMessage = (TGPreparedDownloadExternalImageMessage *)self.preparedMessage;
        
        NSDictionary *fileInfo = filePathToUploadedFile[@"embedded-data://0"];
        if (fileInfo != nil)
        {
            CGSize imageSize = CGSizeZero;
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:[self filePathForLocalImageUrl:[downloadImageMessage.imageInfo imageUrlForLargestSize:&imageSize]]];
            if (image != nil)
            {
                CGSize thumbnailSize = TGFitSize(image.size, CGSizeMake(90, 90));
                NSData *thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(image, thumbnailSize), 0.6f);
                
                id media = [self decryptedPhotoWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize imageSize:imageSize caption:downloadImageMessage.caption size:(int32_t)[fileInfo[@"fileSize"] intValue] key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
                
                _sentDecryptedPhotoSize = (int32_t)[fileInfo[@"fileSize"] intValue];
                _sendDecryptedPhotoKey = fileInfo[@"key"];
                _sendDecryptedPhotoIv = fileInfo[@"iv"];
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                
                _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
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
            
            id media = [self decryptedDocumentWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize attributes:downloadDocumentMessage.attributes mimeType:downloadDocumentMessage.mimeType caption:@"" size:downloadDocumentMessage.size key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
            
            
            _sentDecryptedDocumentSize = downloadDocumentMessage.size;
            _sendDecryptedDocumentKey = fileInfo[@"key"];
            _sendDecryptedDocumentIv = fileInfo[@"iv"];
            
            int64_t randomId = self.preparedMessage.randomId;
            if (randomId == 0)
                arc4random_buf(&randomId, 8);
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
        }
        else
            [self _fail];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedRemoteDocumentMessage class]])
    {
        TGPreparedRemoteDocumentMessage *remoteDocumentMessage = (TGPreparedRemoteDocumentMessage *)self.preparedMessage;
        
        NSString *documentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:remoteDocumentMessage.documentId version:remoteDocumentMessage.document.version];
        NSString *filePath = [documentDirectory stringByAppendingPathComponent:[remoteDocumentMessage.document safeFileName]];
        
        NSDictionary *fileInfo = filePathToUploadedFile[@"embedded-data://0"];
        if (fileInfo != nil)
        {
            NSData *thumbnailData = nil;
            CGSize thumbnailSize = CGSizeZero;
            
            if ([remoteDocumentMessage.mimeType isEqualToString:@"video/mp4"]) {
                NSString *videoFilePath = filePath;
                if ([filePath pathExtension].length == 0) {
                    [[NSFileManager defaultManager] createSymbolicLinkAtPath:[filePath stringByAppendingPathExtension:@"mov"] withDestinationPath:[filePath pathComponents].lastObject error:nil];
                    videoFilePath = [filePath stringByAppendingPathExtension:@"mov"];
                }
                
                AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoFilePath]];
                
                AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                imageGenerator.maximumSize = CGSizeMake(320.0f, 320.0f);
                imageGenerator.appliesPreferredTrackTransform = true;
                NSError *imageError = nil;
                CGImageRef imageRef = [imageGenerator copyCGImageAtTime:CMTimeMake(0, asset.duration.timescale) actualTime:NULL error:&imageError];
                UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
                if (imageRef != NULL) {
                    CGImageRelease(imageRef);
                }
                
                if (image != nil) {
                    CGSize thumbSize = TGFitSize(image.size, CGSizeMake(90, 90));
                    thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(image, thumbSize), 0.6f);
                    
                    if (thumbnailData != nil)
                        thumbnailSize = thumbSize;
                }
            } else {
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:filePath];
                if (image != nil) {
                    CGSize thumbSize = TGFitSize(image.size, CGSizeMake(90, 90));
                    thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(image, thumbSize), 0.6f);
                    
                    if (thumbnailData != nil)
                        thumbnailSize = thumbSize;
                }
            }
            
            NSString *filename = @"file";
            for (id attribute in remoteDocumentMessage.attributes)
            {
                if ([attribute isKindOfClass:[TGDocumentAttributeFilename class]])
                    filename = ((TGDocumentAttributeFilename *)attribute).filename;
            }
            
            id media = [self decryptedDocumentWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize attributes:remoteDocumentMessage.attributes mimeType:remoteDocumentMessage.mimeType caption:remoteDocumentMessage.caption size:remoteDocumentMessage.size key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
            
            _sentDecryptedDocumentSize = remoteDocumentMessage.size;
            _sendDecryptedDocumentKey = fileInfo[@"key"];
            _sendDecryptedDocumentIv = fileInfo[@"iv"];
            
            int64_t randomId = self.preparedMessage.randomId;
            if (randomId == 0)
                arc4random_buf(&randomId, 8);
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
        } else {
            [self _fail];
        }
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedRemoteVideoMessage class]])
    {
        TGPreparedRemoteVideoMessage *remoteVideoMessage = (TGPreparedRemoteVideoMessage *)self.preparedMessage;
        
        NSString *filePath = [self filePathForRemoteVideoId:remoteVideoMessage.videoId];
        
        NSDictionary *fileInfo = filePathToUploadedFile[@"embedded-data://0"];
        if (fileInfo != nil)
        {
            NSData *thumbnailData = nil;
            CGSize thumbnailSize = CGSizeZero;
            
            NSString *videoFilePath = filePath;
            if ([filePath pathExtension].length == 0) {
                [[NSFileManager defaultManager] createSymbolicLinkAtPath:[filePath stringByAppendingPathExtension:@"mov"] withDestinationPath:[filePath pathComponents].lastObject error:nil];
                videoFilePath = [filePath stringByAppendingPathExtension:@"mov"];
            }
            
            AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoFilePath]];
            
            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            imageGenerator.maximumSize = CGSizeMake(320.0f, 320.0f);
            imageGenerator.appliesPreferredTrackTransform = true;
            NSError *imageError = nil;
            CGImageRef imageRef = [imageGenerator copyCGImageAtTime:CMTimeMake(0, asset.duration.timescale) actualTime:NULL error:&imageError];
            UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
            if (imageRef != NULL) {
                CGImageRelease(imageRef);
            }
            
            if (image != nil) {
                CGSize thumbSize = TGFitSize(image.size, CGSizeMake(90, 90));
                thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(image, thumbSize), 0.6f);
                
                if (thumbnailData != nil)
                    thumbnailSize = thumbSize;
            }
            
            id media = [self decryptedVideoWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize duration:(int32_t)remoteVideoMessage.duration dimensions:remoteVideoMessage.videoSize mimeType:@"video/mp4" caption:remoteVideoMessage.caption size:remoteVideoMessage.size key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
            
            _sentDecryptedDocumentSize = remoteVideoMessage.size;
            _sendDecryptedDocumentKey = fileInfo[@"key"];
            _sendDecryptedDocumentIv = fileInfo[@"iv"];
            
            int64_t randomId = self.preparedMessage.randomId;
            if (randomId == 0)
                arc4random_buf(&randomId, 8);
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
        } else {
            [self _fail];
        }
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadExternalGifMessage class]])
    {
        TGPreparedDownloadExternalGifMessage *downloadDocumentMessage = (TGPreparedDownloadExternalGifMessage *)self.preparedMessage;
        
        NSDictionary *fileInfo = filePathToUploadedFile[@"embedded-data://0"];
        if (fileInfo != nil)
        {
            NSData *thumbnailData = nil;
            CGSize thumbnailSize = CGSizeZero;
            
            if (downloadDocumentMessage.thumbnailInfo != nil)
            {
                UIImage *image = nil;
                if ([downloadDocumentMessage.mimeType isEqualToString:@"video/mp4"]) {
                    NSString *videoFilePath = [self filePathForLocalDocumentId:downloadDocumentMessage.localDocumentId attributes:downloadDocumentMessage.attributes];
                    if ([videoFilePath pathExtension].length == 0) {
                        [[NSFileManager defaultManager] createSymbolicLinkAtPath:[videoFilePath stringByAppendingPathExtension:@"mov"] withDestinationPath:[videoFilePath pathComponents].lastObject error:nil];
                        videoFilePath = [videoFilePath stringByAppendingPathExtension:@"mov"];
                    }
                    
                    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoFilePath]];
                    
                    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                    imageGenerator.maximumSize = CGSizeMake(800, 800);
                    imageGenerator.appliesPreferredTrackTransform = true;
                    NSError *imageError = nil;
                    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:CMTimeMake(0, asset.duration.timescale) actualTime:NULL error:&imageError];
                    image = [[UIImage alloc] initWithCGImage:imageRef];
                    if (imageRef != NULL) {
                        CGImageRelease(imageRef);
                    }
                } else {
                    image = [[UIImage alloc] initWithContentsOfFile:[self filePathForLocalDocumentId:downloadDocumentMessage.localDocumentId attributes:downloadDocumentMessage.attributes]];
                }
                
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
            
            id media = [self decryptedDocumentWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize attributes:downloadDocumentMessage.attributes mimeType:downloadDocumentMessage.mimeType caption:downloadDocumentMessage.caption size:downloadDocumentMessage.size key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
            
            
            _sentDecryptedDocumentSize = downloadDocumentMessage.size;
            _sendDecryptedDocumentKey = fileInfo[@"key"];
            _sendDecryptedDocumentIv = fileInfo[@"iv"];
            
            int64_t randomId = self.preparedMessage.randomId;
            if (randomId == 0)
                arc4random_buf(&randomId, 8);
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
        }
        else
            [self _fail];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadExternalDocumentMessage class]])
    {
        TGPreparedDownloadExternalDocumentMessage *downloadDocumentMessage = (TGPreparedDownloadExternalDocumentMessage *)self.preparedMessage;
        
        NSDictionary *fileInfo = filePathToUploadedFile[@"embedded-data://0"];
        if (fileInfo != nil)
        {
            NSData *thumbnailData = nil;
            CGSize thumbnailSize = CGSizeZero;
            
            if (downloadDocumentMessage.thumbnailInfo != nil)
            {
                UIImage *image = nil;
                if ([downloadDocumentMessage.mimeType isEqualToString:@"video/mp4"]) {
                    NSString *videoFilePath = [self filePathForLocalDocumentId:downloadDocumentMessage.localDocumentId attributes:downloadDocumentMessage.attributes];
                    if ([videoFilePath pathExtension].length == 0) {
                        [[NSFileManager defaultManager] createSymbolicLinkAtPath:[videoFilePath stringByAppendingPathExtension:@"mov"] withDestinationPath:[videoFilePath pathComponents].lastObject error:nil];
                        videoFilePath = [videoFilePath stringByAppendingPathExtension:@"mov"];
                    }
                    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoFilePath]];
                    
                    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                    imageGenerator.maximumSize = CGSizeMake(800, 800);
                    imageGenerator.appliesPreferredTrackTransform = true;
                    NSError *imageError = nil;
                    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:CMTimeMake(0, asset.duration.timescale) actualTime:NULL error:&imageError];
                    image = [[UIImage alloc] initWithCGImage:imageRef];
                    if (imageRef != NULL) {
                        CGImageRelease(imageRef);
                    }
                } else {
                    image = [[UIImage alloc] initWithContentsOfFile:[self filePathForLocalDocumentId:downloadDocumentMessage.localDocumentId attributes:downloadDocumentMessage.attributes]];
                }
                
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
            
            id media = [self decryptedDocumentWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize attributes:downloadDocumentMessage.attributes mimeType:downloadDocumentMessage.mimeType caption:downloadDocumentMessage.caption size:downloadDocumentMessage.size key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
            
            
            _sentDecryptedDocumentSize = downloadDocumentMessage.size;
            _sendDecryptedDocumentKey = fileInfo[@"key"];
            _sendDecryptedDocumentIv = fileInfo[@"iv"];
            
            int64_t randomId = self.preparedMessage.randomId;
            if (randomId == 0)
                arc4random_buf(&randomId, 8);
            
            _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
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
                UIImage *thumbnailImage = [[UIImage alloc] initWithContentsOfFile:[self pathForLocalImagePath:assetImageMessage.localThumbnailDataPath] ];
                CGSize thumbnailSize = TGFitSize(thumbnailImage.size, CGSizeMake(90, 90));
                NSData *thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(thumbnailImage, thumbnailSize), 0.6f);
                
                id media = [self decryptedPhotoWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize imageSize:assetImageMessage.imageSize caption:assetImageMessage.caption size:(int32_t)[fileInfo[@"fileSize"] intValue] key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
                
                _sentDecryptedPhotoSize = (int32_t)[fileInfo[@"fileSize"] intValue];
                _sendDecryptedPhotoKey = fileInfo[@"key"];
                _sendDecryptedPhotoIv = fileInfo[@"iv"];
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                
                _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
            }
            else
                [self _fail];
        }
        else
        {
            NSDictionary *fileInfo = filePathToUploadedFile[[[assetImageMessage localDocumentDirectory] stringByAppendingPathComponent:[assetImageMessage localDocumentFileName]]];
            if (fileInfo != nil)
            {
                NSData *thumbnailData = nil;
                CGSize thumbnailSize = CGSizeZero;
                
                if (assetImageMessage.localThumbnailDataPath != nil)
                {
                    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[self pathForLocalImagePath:assetImageMessage.localThumbnailDataPath]];
                    if (image != nil)
                    {
                        CGSize thumbSize = TGFitSize(image.size, CGSizeMake(90, 90));
                        thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(image, thumbSize), 0.6f);
                        
                        if (thumbnailData != nil)
                            thumbnailSize = thumbSize;
                    }
                }
                
                NSString *filename = @"file";
                for (id attribute in assetImageMessage.attributes)
                {
                    if ([attribute isKindOfClass:[TGDocumentAttributeFilename class]])
                        filename = ((TGDocumentAttributeFilename *)attribute).filename;
                }
                
                id media = [self decryptedDocumentWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize attributes:assetImageMessage.attributes mimeType:assetImageMessage.mimeType caption:assetImageMessage.caption size:(int32_t)[fileInfo[@"fileSize"] intValue] key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
                
                _sentDecryptedDocumentSize = (int32_t)[fileInfo[@"fileSize"] intValue];
                _sendDecryptedDocumentKey = fileInfo[@"key"];
                _sendDecryptedDocumentIv = fileInfo[@"iv"];
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                
                _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
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
            NSDictionary *fileInfo = filePathToUploadedFile[assetVideoMessage.localVideoPath];
            if (fileInfo != nil)
            {
                UIImage *thumbnailImage = [[UIImage alloc] initWithContentsOfFile:[self pathForLocalImagePath:assetVideoMessage.localThumbnailDataPath]];
                CGSize thumbnailSize = TGFitSize(thumbnailImage.size, CGSizeMake(90, 90));
                NSData *thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(thumbnailImage, thumbnailSize), 0.6f);
                
                id media = nil;
                if (assetVideoMessage.roundMessage) {
                    NSArray *attributes = @[[[TGDocumentAttributeVideo alloc] initWithRoundMessage:true size:assetVideoMessage.dimensions duration:(int32_t)assetVideoMessage.duration], [[TGDocumentAttributeFilename alloc] initWithFilename:@"video.mp4"]];
                    media = [self decryptedDocumentWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize attributes:attributes mimeType:@"video/mp4" caption:assetVideoMessage.caption size:(int32_t)[fileInfo[@"fileSize"] intValue] key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
                } else {
                    media = [self decryptedVideoWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize duration:(int)assetVideoMessage.duration dimensions:assetVideoMessage.dimensions mimeType:@"video/mp4" caption:assetVideoMessage.caption size:(int32_t)[fileInfo[@"fileSize"] intValue] key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
                }
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                
                _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
            }
            else
                [self _fail];
        }
        else
        {
            NSDictionary *fileInfo = filePathToUploadedFile[[[assetVideoMessage localDocumentDirectory] stringByAppendingPathComponent:[assetVideoMessage localDocumentFileName]]];
            if (fileInfo != nil)
            {
                NSData *thumbnailData = nil;
                CGSize thumbnailSize = CGSizeZero;
                
                if (assetVideoMessage.localThumbnailDataPath != nil)
                {
                    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[self pathForLocalImagePath:assetVideoMessage.localThumbnailDataPath]];
                    if (image != nil)
                    {
                        CGSize thumbSize = TGFitSize(image.size, CGSizeMake(90, 90));
                        thumbnailData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(image, thumbSize), 0.6f);
                        
                        if (thumbnailData != nil)
                            thumbnailSize = thumbSize;
                    }
                }
                
                NSString *filename = @"file";
                for (id attribute in assetVideoMessage.attributes)
                {
                    if ([attribute isKindOfClass:[TGDocumentAttributeFilename class]])
                        filename = ((TGDocumentAttributeFilename *)attribute).filename;
                }
                
                id media = [self decryptedDocumentWithLayer:[self currentPeerLayer] thumbnailData:thumbnailData thumbnailSize:thumbnailSize attributes:assetVideoMessage.attributes mimeType:(assetVideoMessage.isAnimation ? @"video/mp4" : assetVideoMessage.mimeType) caption:assetVideoMessage.caption size:(int32_t)[fileInfo[@"fileSize"] intValue] key:fileInfo[@"key"] iv:fileInfo[@"iv"]];
                
                _sentDecryptedDocumentSize = (int32_t)[fileInfo[@"fileSize"] intValue];
                _sendDecryptedDocumentKey = fileInfo[@"key"];
                _sendDecryptedDocumentIv = fileInfo[@"iv"];
                
                int64_t randomId = self.preparedMessage.randomId;
                if (randomId == 0)
                    arc4random_buf(&randomId, 8);
                
                _actionId = [TGModernSendSecretMessageActor enqueueOutgoingMessageForPeerId:[self peerId] layer:[self currentPeerLayer] keyId:0 randomId:randomId messageData:[TGModernSendSecretMessageActor prepareDecryptedMessageWithLayer:[self currentPeerLayer] text:nil media:media entities:nil viaBotName:[self viaBotName] lifetime:self.preparedMessage.messageLifetime replyToRandomId:[self replyToRandomId] randomId:randomId] storedFileInfo:[self storedFileInfoForSchemeFileInfo:fileInfo[@"file"]] watcher:self];
            }
            else
                [self _fail];
        }
    }
    else
        [self _fail];
    
    [super uploadsCompleted:filePathToUploadedFile];
}

#pragma mark -

- (void)afterMessageSent:(TGMessage *)message {
    for (id attachment in message.mediaAttachments) {
        if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]) {
            TGDocumentMediaAttachment *document = attachment;
            if ([document isAnimated] && ([document.mimeType isEqualToString:@"video/mp4"])) {
                if (document.documentId != 0) {
                    [TGRecentGifsSignal addRecentGifFromDocument:document];
                }
            }
            if ([document isStickerWithPack]) {
                if (document.documentId != 0) {
                    [TGRecentStickersSignal addRecentStickerFromDocument:document];
                }
            }
            break;
        }
    }
}

- (void)sendEncryptedMessageSuccess:(int32_t)date encryptedFile:(TLEncryptedFile *)encryptedFile
{
    NSMutableArray *messageMedia = [[NSMutableArray alloc] init];
    if (self.preparedMessage.botContextResult != nil) {
        [messageMedia addObject:[[TGViaUserAttachment alloc] initWithUserId:self.preparedMessage.botContextResult.userId username:nil]];
    }
    
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
            imageAttachment.caption = localImageMessage.caption;
            [messageMedia addObject:imageAttachment];
            
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
            
            [messageMedia addObject:documentAttachment];
            
            [TGDatabaseInstance() updateLastUseDateForMediaType:3 mediaId:documentAttachment.localDocumentId messageId:self.preparedMessage.mid];
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
            imageAttachment.caption = downloadImageMessage.caption;
            [messageMedia addObject:imageAttachment];
            
            NSString *localImageUrl = [downloadImageMessage.imageInfo imageUrlForLargestSize:NULL];
            
            NSString *localImageDirectory = [[self filePathForLocalImageUrl:localImageUrl] stringByDeletingLastPathComponent];
            NSString *updatedImageDirectory = [[self filePathForRemoteImageId:imageAttachment.imageId] stringByDeletingLastPathComponent];
            [[NSFileManager defaultManager] moveItemAtPath:localImageDirectory toPath:updatedImageDirectory error:nil];
            
            [TGDatabaseInstance() updateLastUseDateForMediaType:2 mediaId:imageAttachment.imageId messageId:self.preparedMessage.mid];
        }
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadExternalImageMessage class]])
    {
        TGPreparedDownloadExternalImageMessage *downloadImageMessage = (TGPreparedDownloadExternalImageMessage *)self.preparedMessage;
        
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
            imageAttachment.caption = downloadImageMessage.caption;
            [messageMedia addObject:imageAttachment];
            
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
            
            [messageMedia addObject:documentAttachment];
            
            [TGDatabaseInstance() updateLastUseDateForMediaType:3 mediaId:documentAttachment.localDocumentId messageId:self.preparedMessage.mid];
        }
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadExternalGifMessage class]])
    {
        TGPreparedDownloadExternalGifMessage *downloadDocumentMessage = (TGPreparedDownloadExternalGifMessage *)self.preparedMessage;
        
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
            
            [messageMedia addObject:documentAttachment];
            
            [TGDatabaseInstance() updateLastUseDateForMediaType:3 mediaId:documentAttachment.localDocumentId messageId:self.preparedMessage.mid];
        }
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadExternalDocumentMessage class]])
    {
        TGPreparedDownloadExternalDocumentMessage *downloadDocumentMessage = (TGPreparedDownloadExternalDocumentMessage *)self.preparedMessage;
        
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
            
            [messageMedia addObject:documentAttachment];
            
            [TGDatabaseInstance() updateLastUseDateForMediaType:3 mediaId:documentAttachment.localDocumentId messageId:self.preparedMessage.mid];
        }
    }
    
    std::vector<TGDatabaseMessageFlagValue> flags;
    flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDeliveryState, .value = TGMessageDeliveryStateDelivered});
    flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDate, .value = date});
    
    if (messageMedia.count == 0 || (messageMedia.count == 1 && [messageMedia[0] isKindOfClass:[TGViaUserAttachment class]])) {
        messageMedia = nil;
    }
    
    TGMessage *updatedMessage = [TGDatabaseInstance() loadMessageWithMid:self.preparedMessage.mid peerId:_conversationId];
    updatedMessage.deliveryState = TGMessageDeliveryStateDelivered;
    updatedMessage.date = date;
    if (messageMedia.count != 0) {
        updatedMessage.mediaAttachments = messageMedia;
    }
    
    TGDatabaseUpdateMessageWithMessage *messageUpdate = [[TGDatabaseUpdateMessageWithMessage alloc] initWithPeerId:_conversationId messageId:self.preparedMessage.mid message:updatedMessage dispatchEdited:false];
    [TGDatabaseInstance() transactionUpdateMessages:@[messageUpdate] updateConversationDatas:nil];
    
    TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:self.preparedMessage.mid peerId:_conversationId];
    if (message != nil)
    {
        [self afterMessageSent:message];
        
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

+ (NSData *)prepareDecryptedMessageWithLayer:(NSUInteger)layer text:(NSString *)text media:(id)media entities:(NSArray *)entities viaBotName:(NSString *)viaBotName lifetime:(int32_t)lifetime replyToRandomId:(int64_t)replyToRandomId randomId:(int64_t)randomId
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
        case 46:
        {
            int32_t flags = 0;
            if (media != nil) {
                flags |= (1 << 9);
            }
            if (entities != nil) {
                flags |= (1 << 7);
            }
            if (viaBotName.length != 0) {
                flags |= (1 << 11);
            }
            if (replyToRandomId != 0) {
                flags |= (1 << 3);
            }
            messageData = [Secret46__Environment serializeObject:[Secret46_DecryptedMessage decryptedMessageWithFlags:@(flags) randomId:@(randomId) ttl:@(lifetime) message:text media:media entities:entities viaBotName:viaBotName replyToRandomId:replyToRandomId == 0 ? nil : @(replyToRandomId)]];
            break;
        }
        case 66:
        {
            int32_t flags = 0;
            if (media != nil) {
                flags |= (1 << 9);
            }
            if (entities != nil) {
                flags |= (1 << 7);
            }
            if (viaBotName.length != 0) {
                flags |= (1 << 11);
            }
            if (replyToRandomId != 0) {
                flags |= (1 << 3);
            }
            messageData = [Secret66__Environment serializeObject:[Secret66_DecryptedMessage decryptedMessageWithFlags:@(flags) randomId:@(randomId) ttl:@(lifetime) message:text media:media entities:entities viaBotName:viaBotName replyToRandomId:replyToRandomId == 0 ? nil : @(replyToRandomId)]];
            break;
        }
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
    if ([TGDatabaseInstance() loadConversationWithId:peerId].encryptedData.handshakeState != 3) {
        NSString *path = [[NSString alloc] initWithFormat:@"/tg/secret/outgoing/(%" PRId64 ")", peerId];
        [ActionStageInstance() requestActor:path options:@{@"peerId": @(peerId)} watcher:TGTelegraphInstance];
    }
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
            __unused int result = SecRandomCopyBytes(kSecRandomDefault, 256, rawABytes);
            
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
            
            [TGDatabaseInstance() transactionAddMessages:nil updateConversationDatas:@{@(conversation.conversationId): conversation} notifyAdded:true];
            
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
        case 46:
            messageData = [Secret46__Environment serializeObject:[Secret46_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret46_DecryptedMessageAction decryptedMessageActionSetMessageTTLWithTtlSeconds:@(ttl)]]];
            break;
        case 66:
            messageData = [Secret66__Environment serializeObject:[Secret66_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret66_DecryptedMessageAction decryptedMessageActionSetMessageTTLWithTtlSeconds:@(ttl)]]];
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
        case 46:
            messageData = [Secret46__Environment serializeObject:[Secret46_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret46_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandomIds:randomIds]]];
            break;
        case 66:
            messageData = [Secret66__Environment serializeObject:[Secret66_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret66_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandomIds:randomIds]]];
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
        case 46:
            messageData = [Secret46__Environment serializeObject:[Secret46_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret46_DecryptedMessageAction decryptedMessageActionFlushHistory]]];
            break;
        case 66:
            messageData = [Secret66__Environment serializeObject:[Secret66_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret66_DecryptedMessageAction decryptedMessageActionFlushHistory]]];
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
        case 46:
            messageData = [Secret46__Environment serializeObject:[Secret46_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret46_DecryptedMessageAction decryptedMessageActionReadMessagesWithRandomIds:randomIds]]];
            break;
        case 66:
            messageData = [Secret66__Environment serializeObject:[Secret66_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret66_DecryptedMessageAction decryptedMessageActionReadMessagesWithRandomIds:randomIds]]];
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
        case 46:
            messageData = [Secret46__Environment serializeObject:[Secret46_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret46_DecryptedMessageAction decryptedMessageActionScreenshotMessagesWithRandomIds:randomIds]]];
            break;
        case 66:
            messageData = [Secret66__Environment serializeObject:[Secret66_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret66_DecryptedMessageAction decryptedMessageActionScreenshotMessagesWithRandomIds:randomIds]]];
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
        case 46:
            messageData = [Secret46__Environment serializeObject:[Secret46_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret46_DecryptedMessageAction decryptedMessageActionNotifyLayerWithLayer:@(notifyLayer)]]];
            break;
        case 66:
            messageData = [Secret66__Environment serializeObject:[Secret66_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret66_DecryptedMessageAction decryptedMessageActionNotifyLayerWithLayer:@(notifyLayer)]]];
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
        case 46:
            messageData = [Secret46__Environment serializeObject:[Secret46_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret46_DecryptedMessageAction decryptedMessageActionResendWithStartSeqNo:@(fromSeq) endSeqNo:@(toSeq)]]];
            break;
        case 66:
            messageData = [Secret66__Environment serializeObject:[Secret66_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret66_DecryptedMessageAction decryptedMessageActionResendWithStartSeqNo:@(fromSeq) endSeqNo:@(toSeq)]]];
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
        case 46:
            messageData = [Secret46__Environment serializeObject:[Secret46_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret46_DecryptedMessageAction decryptedMessageActionRequestKeyWithExchangeId:@(exchangeId) gA:g_a]]];
            break;
        case 66:
            messageData = [Secret66__Environment serializeObject:[Secret66_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret66_DecryptedMessageAction decryptedMessageActionRequestKeyWithExchangeId:@(exchangeId) gA:g_a]]];
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
        case 46:
            messageData = [Secret46__Environment serializeObject:[Secret46_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret46_DecryptedMessageAction decryptedMessageActionAcceptKeyWithExchangeId:@(exchangeId) gB:g_b keyFingerprint:@(keyFingerprint)]]];
            break;
        case 66:
            messageData = [Secret66__Environment serializeObject:[Secret66_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret66_DecryptedMessageAction decryptedMessageActionAcceptKeyWithExchangeId:@(exchangeId) gB:g_b keyFingerprint:@(keyFingerprint)]]];
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
        case 46:
            messageData = [Secret46__Environment serializeObject:[Secret46_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret46_DecryptedMessageAction decryptedMessageActionCommitKeyWithExchangeId:@(exchangeId) keyFingerprint:@(keyFingerprint)]]];
            break;
        case 66:
            messageData = [Secret66__Environment serializeObject:[Secret66_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret66_DecryptedMessageAction decryptedMessageActionCommitKeyWithExchangeId:@(exchangeId) keyFingerprint:@(keyFingerprint)]]];
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
        case 46:
            messageData = [Secret46__Environment serializeObject:[Secret46_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret46_DecryptedMessageAction decryptedMessageActionAbortKeyWithExchangeId:@(exchangeId)]]];
            break;
        case 66:
            messageData = [Secret66__Environment serializeObject:[Secret66_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret66_DecryptedMessageAction decryptedMessageActionAbortKeyWithExchangeId:@(exchangeId)]]];
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
        case 46:
            messageData = [Secret46__Environment serializeObject:[Secret46_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret46_DecryptedMessageAction decryptedMessageActionNoop]]];
            break;
        case 66:
            messageData = [Secret66__Environment serializeObject:[Secret66_DecryptedMessage decryptedMessageServiceWithRandomId:@(randomId) action:[Secret66_DecryptedMessageAction decryptedMessageActionNoop]]];
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
        if (arguments != nil && _downloadingItemId != nil)
        {
            id media = nil;
            if ([self.preparedMessage isKindOfClass:[TGPreparedForwardedMessage class]]) {
                TGPreparedForwardedMessage *preparedForwardedMessage = (TGPreparedForwardedMessage *)self.preparedMessage;
                media = [self mediaToForward:preparedForwardedMessage.innerMessage];
            } else {
                for (id attachment in self.preparedMessage.message.mediaAttachments) {
                    if ([attachment isKindOfClass:[TGImageMediaAttachment class]] || [attachment isKindOfClass:[TGVideoMediaAttachment class]] || [attachment isKindOfClass:[TGDocumentMediaAttachment class]]) {
                        media = attachment;
                        break;
                    }
                }
            }
            
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
                    else {
                        dispatch_async([TGCache diskCacheQueue], ^{
                            [ActionStageInstance() dispatchOnStageQueue:^{
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
                                } else {
                                    [self _fail];
                                }
                            }];
                        });
                    }
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
            else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadExternalGifMessage class]]) {
                NSData *documentData = result;
                TGPreparedDownloadExternalGifMessage *downloadDocumentMessage = (TGPreparedDownloadExternalGifMessage *)self.preparedMessage;
                NSString *documentPath = [self filePathForLocalDocumentId:downloadDocumentMessage.localDocumentId attributes:downloadDocumentMessage.attributes];
                [[NSFileManager defaultManager] createDirectoryAtPath:[documentPath stringByDeletingLastPathComponent] withIntermediateDirectories:true attributes:nil error:nil];
                [documentData writeToFile:documentPath atomically:false];
            }
            else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadExternalDocumentMessage class]]) {
                NSData *documentData = result;
                TGPreparedDownloadExternalDocumentMessage *downloadDocumentMessage = (TGPreparedDownloadExternalDocumentMessage *)self.preparedMessage;
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
            else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadExternalImageMessage class]])
            {
                NSData *imageData = result;
                TGPreparedDownloadExternalImageMessage *downloadImageMessage = (TGPreparedDownloadExternalImageMessage *)self.preparedMessage;
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
        
        [self uploadFilesWithExtensions:@[@[data, @"bin", @(true)]] mediaTypeTag:TGNetworkMediaTypeTagImage];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadExternalImageMessage class]])
    {
        TGPreparedDownloadExternalImageMessage *downloadImageMessage = (TGPreparedDownloadExternalImageMessage *)self.preparedMessage;
        if (dispatchThumbnail)
        {
            NSString *thumbnailUrl = [downloadImageMessage.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
            if (thumbnailUrl != nil)
            {
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/as/media/imageThumbnailUpdated"] resource:thumbnailUrl];
            }
        }
        
        [self uploadFilesWithExtensions:@[@[data, @"bin", @(true)]] mediaTypeTag:TGNetworkMediaTypeTagImage];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedRemoteDocumentMessage class]])
    {
        TGPreparedRemoteDocumentMessage *remoteDocumentMessage = (TGPreparedRemoteDocumentMessage *)self.preparedMessage;
        if (dispatchThumbnail)
        {
            NSString *thumbnailUrl = [remoteDocumentMessage.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
            if (thumbnailUrl != nil)
            {
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/as/media/imageThumbnailUpdated"] resource:thumbnailUrl];
            }
        }
        
        [self uploadFilesWithExtensions:@[@[data, @"bin", @(true)]] mediaTypeTag:TGNetworkMediaTypeTagDocument];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedRemoteVideoMessage class]])
    {
        TGPreparedRemoteVideoMessage *remoteVideoMessage = (TGPreparedRemoteVideoMessage *)self.preparedMessage;
        if (dispatchThumbnail)
        {
            NSString *thumbnailUrl = [remoteVideoMessage.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
            if (thumbnailUrl != nil)
            {
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/as/media/imageThumbnailUpdated"] resource:thumbnailUrl];
            }
        }
        
        [self uploadFilesWithExtensions:@[@[data, @"bin", @(true)]] mediaTypeTag:TGNetworkMediaTypeTagVideo];
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
        [self uploadFilesWithExtensions:files mediaTypeTag:TGNetworkMediaTypeTagDocument];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadExternalGifMessage class]])
    {
        TGPreparedDownloadExternalGifMessage *downloadDocumentMessage = (TGPreparedDownloadExternalGifMessage *)self.preparedMessage;
        if (dispatchThumbnail)
        {
            NSString *thumbnailUrl = [downloadDocumentMessage.thumbnailInfo imageUrlForLargestSize:NULL];
            if (thumbnailUrl != nil)
            {
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/as/media/imageThumbnailUpdated"] resource:thumbnailUrl];
            }
        }
        
        downloadDocumentMessage.size = (int32_t)data.length;
        
        NSMutableArray *files = [[NSMutableArray alloc] init];
        [files addObject:@[data, @"bin", @(true)]];
        [self uploadFilesWithExtensions:files mediaTypeTag:TGNetworkMediaTypeTagDocument];
    }
    else if ([self.preparedMessage isKindOfClass:[TGPreparedDownloadExternalDocumentMessage class]])
    {
        TGPreparedDownloadExternalDocumentMessage *downloadDocumentMessage = (TGPreparedDownloadExternalDocumentMessage *)self.preparedMessage;
        if (dispatchThumbnail)
        {
            NSString *thumbnailUrl = [downloadDocumentMessage.thumbnailInfo imageUrlForLargestSize:NULL];
            if (thumbnailUrl != nil)
            {
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/as/media/imageThumbnailUpdated"] resource:thumbnailUrl];
            }
        }
        
        downloadDocumentMessage.size = (int32_t)data.length;
        
        NSMutableArray *files = [[NSMutableArray alloc] init];
        [files addObject:@[data, @"bin", @(true)]];
        [self uploadFilesWithExtensions:files mediaTypeTag:TGNetworkMediaTypeTagDocument];
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
        [self uploadFilesWithExtensions:files mediaTypeTag:TGNetworkMediaTypeTagDocument];
    }
    else
        [self _fail];
}

- (NSString *)filePathForLocalDocumentId:(int64_t)localDocumentId attributes:(NSArray *)attributes
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
         
- (NSString *)filePathForRemoteVideoId:(int64_t)remoteVideoId {
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    NSString *videosDirectory = [documentsDirectory stringByAppendingPathComponent:@"video"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:videosDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:videosDirectory withIntermediateDirectories:true attributes:nil error:nil];
    
    return [videosDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"remote%llx.mov", remoteVideoId]];
}

@end
