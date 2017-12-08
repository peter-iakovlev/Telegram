#import "TGModernViewContext.h"

#import <LegacyComponents/LegacyComponents.h>

@implementation TGModernViewContext

- (bool)isFocusedOnMessage:(int32_t)__unused messageId
{
    return false;
}

- (bool)isMediaVisibleInMessage:(int32_t)__unused messageId
{
    return true;
}

- (bool)isMessageChecked:(int32_t)__unused messageId
{
    return false;
}

- (bool)isGroupChecked:(int64_t)__unused groupedId
{
    return false;
}

- (bool)isSecretMessageViewed:(int32_t)__unused messageId
{
    return false;
}

- (bool)isSecretMessageScreenshotted:(int32_t)__unused messageId
{
    return false;
}

- (NSTimeInterval)secretMessageViewDate:(int32_t)__unused messageId
{
    return 0.0;
}

- (bool)isMessageUnread:(TGMessage *)message {
    if (message.outgoing && !_outgoingMessagesAreAlwaysRead) {
        return [_conversationForUnreadCalculations isMessageUnread:message];
    } else {
        return false;
    }
}

- (bool)isByAdmin:(TGMessage *)message {
    return [_adminIds containsObject:@(message.fromUid)];
}

@end
