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

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude
{
    self = [super init];
    if (self != nil)
    {
        _latitude = latitude;
        _longitude = longitude;
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
    
    TGLocationMediaAttachment *locationAttachment = [[TGLocationMediaAttachment alloc] init];
    locationAttachment.latitude = _latitude;
    locationAttachment.longitude = _longitude;
    message.mediaAttachments = @[locationAttachment];
    
    return message;
}

@end
