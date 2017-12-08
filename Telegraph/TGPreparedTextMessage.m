#import "TGPreparedTextMessage.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGLinkPreviewsContentProperty.h"

@interface TGPreparedTextMessage ()

@end

@implementation TGPreparedTextMessage

- (instancetype)initWithText:(NSString *)text replyMessage:(TGMessage *)replyMessage disableLinkPreviews:(bool)disableLinkPreviews parsedWebpage:(TGWebPageMediaAttachment *)parsedWebpage entities:(NSArray *)entities botContextResult:(TGBotContextResultAttachment *)botContextResult replyMarkup:(TGReplyMarkupAttachment *)replyMarkup
{
    self = [super init];
    if (self != nil)
    {
        _text = text;
        self.replyMessage = replyMessage;
        _disableLinkPreviews = disableLinkPreviews;
        _parsedWebpage = parsedWebpage;
        _entities = entities;
        self.botContextResult = botContextResult;
        self.replyMarkup = replyMarkup;
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
    
    if (self.replyMessage != nil)
    {
        TGReplyMessageMediaAttachment *replyMedia = [[TGReplyMessageMediaAttachment alloc] init];
        replyMedia.replyMessageId = self.replyMessage.mid;
        replyMedia.replyMessage = self.replyMessage;
        [attachments addObject:replyMedia];
    }
    
    if (_parsedWebpage != nil)
        [attachments addObject:_parsedWebpage];
    
    if (_disableLinkPreviews)
    {
        message.contentProperties = @{@"linkPreviews": [[TGLinkPreviewsContentProperty alloc] initWithDisableLinkPreviews:_disableLinkPreviews]};
    }
    
    if (_entities.count != 0) {
        TGMessageEntitiesAttachment *attachment = [[TGMessageEntitiesAttachment alloc] init];
        attachment.entities = _entities;
        [attachments addObject:attachment];
    }
    
    if (self.botContextResult != nil) {
        [attachments addObject:self.botContextResult];
        
        [attachments addObject:[[TGViaUserAttachment alloc] initWithUserId:self.botContextResult.userId username:nil]];
    }
    
    if (self.replyMarkup != nil) {
        [attachments addObject:self.replyMarkup];
    }
    
    message.mediaAttachments = attachments.count == 0 ? nil : attachments;
    
    return message;
}

@end
