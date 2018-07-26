#import "TGModernConversationViewContext.h"

#import "TGModernConversationCompanion.h"

@implementation TGModernConversationViewContext

- (bool)isFocusedOnMessage:(int32_t)messageId peerId:(int64_t)peerId
{
    TGModernConversationCompanion *companion = _companion;
    TGMessageIndex *messageIndex = [companion focusedOnMessageIndex];
    return messageIndex.peerId == peerId && messageIndex.messageId == messageId;
}

- (bool)isMediaVisibleInMessage:(int32_t)messageId peerId:(int64_t)peerId
{
    TGModernConversationCompanion *companion = _companion;
    TGMessageIndex *messageIndex = [companion mediaHiddenMessageIndex];
    return messageIndex.peerId != peerId || messageIndex.messageId != messageId;
}

- (bool)isMessageChecked:(int32_t)messageId peerId:(int64_t)peerId
{
    TGModernConversationCompanion *companion = _companion;
    return [companion _isMessageChecked:[TGMessageIndex indexWithPeerId:peerId messageId:messageId]];
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
