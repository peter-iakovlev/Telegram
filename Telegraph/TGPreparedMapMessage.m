/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedMapMessage.h"

#import "TGMessage.h"
#import "TGLocationMediaAttachment.h"

@implementation TGPreparedMapMessage

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude venue:(TGVenueAttachment *)venue replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup
{
    self = [super init];
    if (self != nil)
    {
        _latitude = latitude;
        _longitude = longitude;
        _venue = venue;
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
