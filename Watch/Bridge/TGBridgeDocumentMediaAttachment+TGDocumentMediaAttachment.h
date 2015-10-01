#import "TGBridgeDocumentMediaAttachment.h"
#import "TGDocumentMediaAttachment.h"

@interface TGBridgeDocumentMediaAttachment (TGDocumentMediaAttachment)

+ (TGBridgeDocumentMediaAttachment *)attachmentWithTGDocumentMediaAttachment:(TGDocumentMediaAttachment *)attachment;

+ (TGDocumentMediaAttachment *)tgDocumentMediaAttachmentWithBridgeDocumentMediaAttachment:(TGBridgeDocumentMediaAttachment *)bridgeAttachment;

@end
