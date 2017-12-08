#import "TGPreparedMapMessage.h"

#import <LegacyComponents/LegacyComponents.h>

@implementation TGPreparedMapMessage

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude venue:(TGVenueAttachment *)venue period:(int32_t)period replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup
{
    self = [super init];
    if (self != nil)
    {
        _latitude = latitude;
        _longitude = longitude;
        _venue = venue;
        _period = period;
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
    
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    
    TGLocationMediaAttachment *locationAttachment = [[TGLocationMediaAttachment alloc] init];
    locationAttachment.latitude = _latitude;
    locationAttachment.longitude = _longitude;
    locationAttachment.venue = _venue;
    locationAttachment.period = _period;
    [attachments addObject:locationAttachment];
    
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
    
    if (self.botContextResult != nil) {
        [attachments addObject:self.botContextResult];
        
        [attachments addObject:[[TGViaUserAttachment alloc] initWithUserId:self.botContextResult.userId username:nil]];
    }
    
    message.mediaAttachments = attachments;
    
    return message;
}

@end
