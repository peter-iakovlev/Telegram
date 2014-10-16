/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedForwardedMessage.h"

#import "TGMessage.h"

@implementation TGPreparedForwardedMessage

- (instancetype)initWithInnerMessage:(TGMessage *)message
{
    self = [super init];
    if (self != nil)
    {
        TGMessage *innerMessage = [message copy];
        
        NSMutableArray *attachments = [[NSMutableArray alloc] init];
        for (TGMediaAttachment *attachment in message.mediaAttachments)
        {
            if ([attachment isKindOfClass:[TGForwardedMessageMediaAttachment class]])
            {
                TGForwardedMessageMediaAttachment *forwardedMessageAttachment = (TGForwardedMessageMediaAttachment *)attachment;
                innerMessage.fromUid = forwardedMessageAttachment.forwardUid;
                innerMessage.date = forwardedMessageAttachment.forwardDate;
                if (forwardedMessageAttachment.forwardMid != 0)
                    _forwardMid = forwardedMessageAttachment.forwardMid;
            }
            else
                [attachments addObject:attachment];
        }
        
        innerMessage.mediaAttachments = attachments;
        _innerMessage = innerMessage;
        if (_forwardMid == 0)
            _forwardMid = innerMessage.mid;
    }
    return self;
}

- (TGMessage *)message
{
    TGMessage *message = [_innerMessage copy];
    message.mid = self.mid;
    message.date = self.date;
    message.isBroadcast = self.isBroadcast;
    message.messageLifetime = self.messageLifetime;
    
    TGForwardedMessageMediaAttachment *forwardAttachment = [[TGForwardedMessageMediaAttachment alloc] init];
    forwardAttachment.forwardUid = (int32_t)_innerMessage.fromUid;
    forwardAttachment.forwardDate = (int32_t)_innerMessage.date;
    forwardAttachment.forwardMid = _forwardMid;
    
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    for (TGMediaAttachment *attachment in message.mediaAttachments)
    {
        if (![attachment isKindOfClass:[TGForwardedMessageMediaAttachment class]])
            [attachments addObject:attachment];
    }
    [attachments addObject:forwardAttachment];
    
    message.mediaAttachments = attachments;
    
    return message;
}

@end
