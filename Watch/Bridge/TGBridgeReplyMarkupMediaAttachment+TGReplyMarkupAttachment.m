#import "TGBridgeReplyMarkupMediaAttachment+TGReplyMarkupAttachment.h"
#import "TGBridgeBotReplyMarkup+TGBotReplyMarkup.h"

@implementation TGBridgeReplyMarkupMediaAttachment (TGReplyMarkupAttachment)

+ (TGBridgeReplyMarkupMediaAttachment *)attachmentWithTGReplyMarkupAttachment:(TGReplyMarkupAttachment *)attachment
{
    if (attachment == nil)
        return nil;
    
    TGBridgeReplyMarkupMediaAttachment *bridgeAttachment = [[TGBridgeReplyMarkupMediaAttachment alloc] init];
    bridgeAttachment.replyMarkup = [TGBridgeBotReplyMarkup botReplyMarkupWithTGBotReplyMarkup:attachment.replyMarkup message:nil];
    return bridgeAttachment;
}

@end
