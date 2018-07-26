#import "TGPreparedDownloadImageMessage.h"

#import <LegacyComponents/LegacyComponents.h>

@implementation TGPreparedDownloadImageMessage

- (instancetype)initWithImageInfo:(TGImageInfo *)imageInfo text:(NSString *)text entities:(NSArray *)entities replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup
{
    self = [super init];
    if (self != nil)
    {
#ifdef DEBUG
        NSAssert(imageInfo != nil, @"imageInfo should not be nil");
#endif
        
        _imageInfo = imageInfo;
        self.text = text;
        self.entities = entities;
        self.replyMessage = replyMessage;
        self.replyMarkup = replyMarkup;
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
    message.text = self.text;
    
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    
    TGImageMediaAttachment *imageAttachment = [[TGImageMediaAttachment alloc] init];
    imageAttachment.imageInfo = _imageInfo;
    [attachments addObject:imageAttachment];
    
    if (self.replyMessage != nil)
    {
        TGReplyMessageMediaAttachment *replyMedia = [[TGReplyMessageMediaAttachment alloc] init];
        replyMedia.replyMessageId = self.replyMessage.mid;
        replyMedia.replyMessage = self.replyMessage;
        [attachments addObject:replyMedia];
    }
    
    if (self.replyMarkup != nil) {
        [attachments addObject:self.replyMarkup];
    }
    
    message.mediaAttachments = attachments;
    message.entities = self.entities;
    
    return message;
}

@end
