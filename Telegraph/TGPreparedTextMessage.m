/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedTextMessage.h"

#import "TGMessage.h"

@interface TGPreparedTextMessage ()

@end

@implementation TGPreparedTextMessage

- (instancetype)initWithText:(NSString *)text
{
    self = [super init];
    if (self != nil)
    {
        _text = text;
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
    
    return message;
}

@end
