#import "TGBridgeDocumentMediaAttachment.h"

#import <LegacyComponents/LegacyComponents.h>

@interface TGBridgeDocumentMediaAttachment (TGDocumentMediaAttachment)

+ (TGBridgeDocumentMediaAttachment *)attachmentWithTGDocumentMediaAttachment:(TGDocumentMediaAttachment *)attachment;

+ (TGDocumentMediaAttachment *)tgDocumentMediaAttachmentWithBridgeDocumentMediaAttachment:(TGBridgeDocumentMediaAttachment *)bridgeAttachment;

@end
