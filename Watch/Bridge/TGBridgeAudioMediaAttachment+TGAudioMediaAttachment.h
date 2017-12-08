#import "TGBridgeAudioMediaAttachment.h"

#import <LegacyComponents/LegacyComponents.h>

@interface TGBridgeAudioMediaAttachment (TGAudioMediaAttachment)

+ (TGBridgeAudioMediaAttachment *)attachmentWithTGAudioMediaAttachment:(TGAudioMediaAttachment *)attachment;

+ (TGAudioMediaAttachment *)tgAudioMediaAttachmentWithBridgeAudioMediaAttachment:(TGBridgeAudioMediaAttachment *)bridgeAttachment;

@end
