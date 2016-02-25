#import "TGBridgeAudioMediaAttachment.h"
#import "TGAudioMediaAttachment.h"

@interface TGBridgeAudioMediaAttachment (TGAudioMediaAttachment)

+ (TGBridgeAudioMediaAttachment *)attachmentWithTGAudioMediaAttachment:(TGAudioMediaAttachment *)attachment;

+ (TGAudioMediaAttachment *)tgAudioMediaAttachmentWithBridgeAudioMediaAttachment:(TGBridgeAudioMediaAttachment *)bridgeAttachment;

@end
