#import "TGBridgeDocumentMediaAttachment+TGDocumentMediaAttachment.h"

@implementation TGBridgeDocumentMediaAttachment (TGDocumentMediaAttachment)

+ (TGBridgeDocumentMediaAttachment *)attachmentWithTGDocumentMediaAttachment:(TGDocumentMediaAttachment *)attachment
{
    if (attachment == nil)
        return nil;
    
    TGBridgeDocumentMediaAttachment *bridgeAttachment = [[TGBridgeDocumentMediaAttachment alloc] init];
    bridgeAttachment.documentId = attachment.documentId;
    bridgeAttachment.localDocumentId = attachment.localDocumentId;
    bridgeAttachment.accessHash = attachment.accessHash;
    bridgeAttachment.datacenterId = attachment.datacenterId;
    bridgeAttachment.legacyThumbnailUri = [attachment.thumbnailInfo imageUrlForLargestSize:NULL];
    
    bridgeAttachment.fileSize = attachment.size;
    bridgeAttachment.fileName = attachment.safeFileName;
    
    for (id attribute in attachment.attributes)
    {
        if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]])
        {
            bridgeAttachment.imageSize = [NSValue valueWithCGSize:((TGDocumentAttributeImageSize *)attribute).size];
        }
        if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
            bridgeAttachment.imageSize = [NSValue valueWithCGSize:((TGDocumentAttributeVideo *)attribute).size];
        }
        if ([attribute isKindOfClass:[TGDocumentAttributeAnimated class]])
        {
            bridgeAttachment.isAnimated = true;
        }
        if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
        {
            TGDocumentAttributeSticker *stickerAttribute = (TGDocumentAttributeSticker *)attribute;
            bridgeAttachment.isSticker = true;
            if (stickerAttribute.alt.length > 0)
                bridgeAttachment.stickerAlt = stickerAttribute.alt;
        }
        if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]])
        {
            TGDocumentAttributeAudio *audioAttribute = (TGDocumentAttributeAudio *)attribute;
            bridgeAttachment.isAudio = true;
            bridgeAttachment.title = audioAttribute.title;
            bridgeAttachment.performer = audioAttribute.performer;
            bridgeAttachment.isVoice = audioAttribute.isVoice;
            bridgeAttachment.duration = audioAttribute.duration;
        }
    }
    
    return bridgeAttachment;
}

+ (TGDocumentMediaAttachment *)tgDocumentMediaAttachmentWithBridgeDocumentMediaAttachment:(TGBridgeDocumentMediaAttachment *)bridgeAttachment
{
    if (bridgeAttachment == nil)
        return nil;
    
    TGDocumentMediaAttachment *attachment = [[TGDocumentMediaAttachment alloc] init];
    attachment.documentId = bridgeAttachment.documentId;
    attachment.localDocumentId = bridgeAttachment.localDocumentId;
    attachment.accessHash = bridgeAttachment.accessHash;
    attachment.datacenterId = bridgeAttachment.datacenterId;
    
    NSMutableArray *attributes = [[NSMutableArray alloc] init];
    
    if (bridgeAttachment.isSticker)
        [attributes addObject:[[TGDocumentAttributeSticker alloc] initWithAlt:bridgeAttachment.stickerAlt packReference:nil mask:nil]];

    if (bridgeAttachment.imageSize != nil)
        [attributes addObject:[[TGDocumentAttributeImageSize alloc] initWithSize:bridgeAttachment.imageSize.CGSizeValue]];
    
    if (bridgeAttachment.isAudio)
    {
        [attributes addObject:[[TGDocumentAttributeAudio alloc] initWithIsVoice:bridgeAttachment.isVoice title:bridgeAttachment.title performer:bridgeAttachment.performer duration:bridgeAttachment.duration waveform:nil]];
    }
    
    attachment.attributes = attributes;
    
    return attachment;
}

@end
