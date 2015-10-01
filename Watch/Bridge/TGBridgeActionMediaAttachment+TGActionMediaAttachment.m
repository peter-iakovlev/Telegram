#import "TGBridgeActionMediaAttachment+TGActionMediaAttachment.h"
#import "TGBridgeImageMediaAttachment+TGImageMediaAttachment.h"

@implementation TGBridgeActionMediaAttachment (TGActionMediaAttachment)

+ (TGBridgeActionMediaAttachment *)attachmentWithTGActionMediaAttachment:(TGActionMediaAttachment *)attachment
{
    if (attachment == nil)
        return nil;
    
    TGBridgeActionMediaAttachment *bridgeAttachment = [[TGBridgeActionMediaAttachment alloc] init];
    bridgeAttachment.actionType = (TGBridgeMessageAction)attachment.actionType;
    
    NSMutableDictionary *actionData = [[NSMutableDictionary alloc] init];
    
    for (id key in attachment.actionData.allKeys)
    {
        id value = attachment.actionData[key];
        if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
        {
            actionData[key] = value;
        }
        else if ([value isKindOfClass:[TGImageMediaAttachment class]])
        {
            actionData[key] = [TGBridgeImageMediaAttachment attachmentWithTGImageMediaAttachment:(TGImageMediaAttachment *)value];
        }
    }
    
    bridgeAttachment.actionData = actionData;
    
    return bridgeAttachment;
}

@end
