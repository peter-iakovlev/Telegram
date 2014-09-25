#import "TGModernConversationViewContext.h"

#import "TGModernConversationCompanion.h"

@implementation TGModernConversationViewContext

- (bool)isMediaVisibleInMessage:(int32_t)messageId
{
    TGModernConversationCompanion *companion = _companion;
    return [companion mediaHiddenMessageId] != messageId;
}

- (bool)isMessageChecked:(int32_t)messageId
{
    TGModernConversationCompanion *companion = _companion;
    return [companion _isMessageChecked:messageId];
}

- (bool)isSecretMessageViewed:(int32_t)messageId
{
    TGModernConversationCompanion *companion = _companion;
    return [companion _isSecretMessageViewed:messageId];
}

- (bool)isSecretMessageScreenshotted:(int32_t)messageId
{
    TGModernConversationCompanion *companion = _companion;
    return [companion _isSecretMessageScreenshotted:messageId];
}

- (NSTimeInterval)secretMessageViewDate:(int32_t)messageId
{
    TGModernConversationCompanion *companion = _companion;
    return [companion _secretMessageViewDate:messageId];
}

- (TGModernViewInlineMediaContext *)inlineMediaContext:(int32_t)messageId
{
    TGModernConversationCompanion *companion = _companion;
    return [companion _inlineMediaContext:messageId];
}

@end
