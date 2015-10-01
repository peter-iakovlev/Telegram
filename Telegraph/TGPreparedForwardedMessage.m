/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedForwardedMessage.h"

#import "TGMessage.h"

@interface TGPreparedForwardedMessage ()
{
    bool _keepForwarded;
}

@end

@implementation TGPreparedForwardedMessage

- (instancetype)initWithInnerMessage:(TGMessage *)message
{
    return [self initWithInnerMessage:message keepForwarded:true];
}

- (instancetype)initWithInnerMessage:(TGMessage *)message keepForwarded:(bool)keepForwarded
{
    self = [super init];
    if (self != nil)
    {
        _keepForwarded = keepForwarded;
        TGMessage *innerMessage = [message copy];
        
        NSMutableArray *attachments = [[NSMutableArray alloc] init];
        for (TGMediaAttachment *attachment in message.mediaAttachments)
        {
            if ([attachment isKindOfClass:[TGForwardedMessageMediaAttachment class]])
            {
                TGForwardedMessageMediaAttachment *forwardedMessageAttachment = (TGForwardedMessageMediaAttachment *)attachment;
                innerMessage.fromUid = forwardedMessageAttachment.forwardPeerId;
                innerMessage.date = forwardedMessageAttachment.forwardDate;
                if (forwardedMessageAttachment.forwardMid != 0) {
                    _forwardMid = forwardedMessageAttachment.forwardMid;
                    _forwardPeerId = forwardedMessageAttachment.forwardPeerId;
                }
            }
            else if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]])
            {
            }
            else
                [attachments addObject:attachment];
        }
        
        innerMessage.mediaAttachments = attachments;
        _innerMessage = innerMessage;
        if (_forwardMid == 0) {
            _forwardMid = innerMessage.mid;
            _forwardPeerId = innerMessage.toUid;
        }
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
    
    TGForwardedMessageMediaAttachment *forwardAttachment = nil;
    if (_keepForwarded)
    {
        forwardAttachment = [[TGForwardedMessageMediaAttachment alloc] init];
        forwardAttachment.forwardPeerId = _innerMessage.fromUid;
        forwardAttachment.forwardDate = (int32_t)_innerMessage.date;
        forwardAttachment.forwardMid = _forwardMid;
    }
    
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    for (TGMediaAttachment *attachment in message.mediaAttachments)
    {
        if (![attachment isKindOfClass:[TGForwardedMessageMediaAttachment class]])
            [attachments addObject:attachment];
    }
    if (forwardAttachment != nil)
        [attachments addObject:forwardAttachment];
    
    message.mediaAttachments = attachments;
    
    return message;
}

@end
