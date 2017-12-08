#import "TGModernConversationViewContext.h"

#import "TGModernConversationCompanion.h"

@implementation TGModernConversationViewContext

- (bool)isFocusedOnMessage:(int32_t)messageId
{
    TGModernConversationCompanion *companion = _companion;
    return [companion focusedOnMessageId] == messageId;
}

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

- (bool)isGroupChecked:(int64_t)groupedId
{
    TGModernConversationCompanion *companion = _companion;
    return [companion _isGroupChecked:groupedId];
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

@end
