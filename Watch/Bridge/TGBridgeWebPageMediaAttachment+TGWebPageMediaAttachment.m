#import "TGBridgeWebPageMediaAttachment+TGWebPageMediaAttachment.h"
#import "TGBridgeImageMediaAttachment+TGImageMediaAttachment.h"

@implementation TGBridgeWebPageMediaAttachment (TGWebPageMediaAttachment)

+ (TGBridgeWebPageMediaAttachment *)attachmentWithTGWebPageMediaAttachment:(TGWebPageMediaAttachment *)attachment
{
    if (attachment == nil)
        return nil;
    
    TGBridgeWebPageMediaAttachment *bridgeAttachment = [[TGBridgeWebPageMediaAttachment alloc] init];
    
    bridgeAttachment.webPageId = attachment.webPageId;
    bridgeAttachment.url = attachment.url;
    bridgeAttachment.displayUrl = attachment.displayUrl;
    bridgeAttachment.pageType = attachment.pageType;
    bridgeAttachment.siteName = attachment.siteName;
    bridgeAttachment.title = attachment.title;
    bridgeAttachment.pageDescription = attachment.pageDescription;
    bridgeAttachment.photo = [TGBridgeImageMediaAttachment attachmentWithTGImageMediaAttachment:attachment.photo];
    bridgeAttachment.embedUrl = attachment.embedUrl;
    bridgeAttachment.embedType = attachment.embedType;
    bridgeAttachment.embedSize = attachment.embedSize;
    bridgeAttachment.duration = attachment.duration;
    bridgeAttachment.author = attachment.author;
    
    return bridgeAttachment;
}

@end
