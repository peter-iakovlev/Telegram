/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedTextMessage.h"

#import "TGMessage.h"

#import "TGLinkPreviewsContentProperty.h"

@interface TGPreparedTextMessage ()

@end

@implementation TGPreparedTextMessage

- (instancetype)initWithText:(NSString *)text replyMessage:(TGMessage *)replyMessage disableLinkPreviews:(bool)disableLinkPreviews parsedWebpage:(TGWebPageMediaAttachment *)parsedWebpage
{
    self = [super init];
    if (self != nil)
    {
        _text = text;
        _replyMessage = replyMessage;
        _disableLinkPreviews = disableLinkPreviews;
        _parsedWebpage = parsedWebpage;
    }
    return self;
}

- (TGMessage *)message
{
    TGMessage *message = [[TGMessage alloc] init];
    message.text = _text;
    message.mid = self.mid;
    message.date = self.date;
    message.isBroadcast = self.isBroadcast;
    message.messageLifetime = self.messageLifetime;
    
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    
    if (_replyMessage != nil)
    {
        TGReplyMessageMediaAttachment *replyMedia = [[TGReplyMessageMediaAttachment alloc] init];
        replyMedia.replyMessageId = _replyMessage.mid;
        replyMedia.replyMessage = _replyMessage;
        [attachments addObject:replyMedia];
    }
    
    if (_parsedWebpage != nil)
        [attachments addObject:_parsedWebpage];
    
    if (_disableLinkPreviews)
    {
        message.contentProperties = @{@"linkPreviews": [[TGLinkPreviewsContentProperty alloc] initWithDisableLinkPreviews:_disableLinkPreviews]};
    }
    
    message.mediaAttachments = attachments.count == 0 ? nil : attachments;
    
    return message;
}

@end
