#import "TGPreparedDownloadImageMessage.h"

#import "TGMessage.h"

@implementation TGPreparedDownloadImageMessage

- (instancetype)initWithImageInfo:(TGImageInfo *)imageInfo caption:(NSString *)caption replyMessage:(TGMessage *)replyMessage
{
    self = [super init];
    if (self != nil)
    {
#ifdef DEBUG
        NSAssert(imageInfo != nil, @"imageInfo should not be nil");
#endif
        
        _imageInfo = imageInfo;
        _caption = caption;
        _replyMessage = replyMessage;
    }
    return self;
}

- (TGMessage *)message
{
    TGMessage *message = [[TGMessage alloc] init];
    message.mid = self.mid;
    message.date = self.date;
    message.isBroadcast = self.isBroadcast;
    message.messageLifetime = self.messageLifetime;
    
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    
    TGImageMediaAttachment *imageAttachment = [[TGImageMediaAttachment alloc] init];
    imageAttachment.imageInfo = _imageInfo;
    imageAttachment.caption = self.caption;
    [attachments addObject:imageAttachment];
    
    if (_replyMessage != nil)
    {
        TGReplyMessageMediaAttachment *replyMedia = [[TGReplyMessageMediaAttachment alloc] init];
        replyMedia.replyMessageId = _replyMessage.mid;
        replyMedia.replyMessage = _replyMessage;
        [attachments addObject:replyMedia];
    }
    
    message.mediaAttachments = attachments;
    
    return message;
}

@end
