#import "TGBridgeMediaAttachment+TGMediaAttachment.h"

#import "TGBridgeImageMediaAttachment+TGImageMediaAttachment.h"
#import "TGBridgeVideoMediaAttachment+TGVideoMediaAttachment.h"
#import "TGBridgeAudioMediaAttachment+TGAudioMediaAttachment.h"
#import "TGBridgeDocumentMediaAttachment+TGDocumentMediaAttachment.h"
#import "TGBridgeLocationMediaAttachment+TGLocationMediaAttachment.h"
#import "TGBridgeContactMediaAttachment+TGContactMediaAttachment.h"
#import "TGBridgeActionMediaAttachment+TGActionMediaAttachment.h"
#import "TGBridgeReplyMessageMediaAttachment+TGReplyMessageMediaAttachment.h"
#import "TGBridgeForwardedMessageMediaAttachment+TGForwardedMessageMediaAttachment.h"
#import "TGBridgeWebPageMediaAttachment+TGWebPageMediaAttachment.h"
#import "TGBridgeUnsupportedMediaAttachment+TGUnsupportedMediaAttachment.h"

@implementation TGBridgeMediaAttachment (TGMediaAttachment)

+ (TGBridgeMediaAttachment *)attachmentWithTGMediaAttachment:(TGMediaAttachment *)attachment
{
    if (attachment == nil)
        return nil;
    
    TGBridgeMediaAttachment *bridgeAttachment = nil;
    
    if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
        bridgeAttachment = [TGBridgeImageMediaAttachment attachmentWithTGImageMediaAttachment:(TGImageMediaAttachment *)attachment];
    else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
        bridgeAttachment = [TGBridgeVideoMediaAttachment attachmentWithTGVideoMediaAttachment:(TGVideoMediaAttachment *)attachment];
    else if ([attachment isKindOfClass:[TGAudioMediaAttachment class]])
        bridgeAttachment = [TGBridgeAudioMediaAttachment attachmentWithTGAudioMediaAttachment:(TGAudioMediaAttachment *)attachment];
    else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
        bridgeAttachment = [TGBridgeDocumentMediaAttachment attachmentWithTGDocumentMediaAttachment:(TGDocumentMediaAttachment *)attachment];
    else if ([attachment isKindOfClass:[TGLocationMediaAttachment class]])
        bridgeAttachment = [TGBridgeLocationMediaAttachment attachmentWithTGLocationMediaAttachment:(TGLocationMediaAttachment *)attachment];
    else if ([attachment isKindOfClass:[TGContactMediaAttachment class]])
        bridgeAttachment = [TGBridgeContactMediaAttachment attachmentWithTGContactMediaAttachment:(TGContactMediaAttachment *)attachment];
    else if ([attachment isKindOfClass:[TGActionMediaAttachment class]])
        bridgeAttachment = [TGBridgeActionMediaAttachment attachmentWithTGActionMediaAttachment:(TGActionMediaAttachment *)attachment];
    else if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]])
        bridgeAttachment = [TGBridgeReplyMessageMediaAttachment attachmentWithTGReplyMessageMediaAttachment:(TGReplyMessageMediaAttachment *)attachment];
    else if ([attachment isKindOfClass:[TGForwardedMessageMediaAttachment class]])
        bridgeAttachment = [TGBridgeForwardedMessageMediaAttachment attachmentWithTGForwardedMessageMediaAttachment:(TGForwardedMessageMediaAttachment *)attachment];
    else if ([attachment isKindOfClass:[TGWebPageMediaAttachment class]])
        bridgeAttachment = [TGBridgeWebPageMediaAttachment attachmentWithTGWebPageMediaAttachment:(TGWebPageMediaAttachment *)attachment];
    else if ([attachment isKindOfClass:[TGUnsupportedMediaAttachment class]])
        bridgeAttachment = [TGBridgeUnsupportedMediaAttachment attachmentWithTGUnsupportedMediaAttachment:(TGUnsupportedMediaAttachment *)attachment];
    
    return bridgeAttachment;
}

@end
