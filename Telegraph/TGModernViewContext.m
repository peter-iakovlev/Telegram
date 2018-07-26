#import "TGModernViewContext.h"
#import <libkern/OSAtomic.h>
#import <LegacyComponents/LegacyComponents.h>

@interface TGModernViewContext ()
{
    OSSpinLock _lock;
}
@end

@implementation TGModernViewContext

- (bool)isFocusedOnMessage:(int32_t)__unused messageId peerId:(int64_t)__unused peerId
{
    return false;
}

- (bool)isMediaVisibleInMessage:(int32_t)__unused messageId peerId:(int64_t)__unused peerId
{
    return true;
}

- (bool)isMessageChecked:(int32_t)__unused messageId peerId:(int64_t)__unused peerId
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
    bool isByAdmin = false;
    OSSpinLockLock(&_lock);
    isByAdmin = [_adminIds containsObject:@(message.fromUid)];
    OSSpinLockUnlock(&_lock);
    return isByAdmin;
}

- (void)setAdminIds:(NSSet *)adminIds
{
    OSSpinLockLock(&_lock);
    _adminIds = adminIds;
    OSSpinLockUnlock(&_lock);
}

@end
