/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedContactMessage.h"

#import "TGMessage.h"

@implementation TGPreparedContactMessage

- (instancetype)initWithUid:(int32_t)uid firstName:(NSString *)firstName lastName:(NSString *)lastName phoneNumber:(NSString *)phoneNumber
{
    self = [super init];
    if (self != nil)
    {
        _uid = uid;
        _firstName = firstName;
        _lastName = lastName;
        _phoneNumber = phoneNumber;
    }
    return self;
}

- (instancetype)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName phoneNumber:(NSString *)phoneNumber
{
    return [self initWithUid:0 firstName:firstName lastName:lastName phoneNumber:phoneNumber];
}

- (TGMessage *)message
{
    TGMessage *message = [[TGMessage alloc] init];
    message.mid = self.mid;
    message.date = self.date;
    message.isBroadcast = self.isBroadcast;
    message.messageLifetime = self.messageLifetime;
    
    TGContactMediaAttachment *contactAttachment = [[TGContactMediaAttachment alloc] init];
    contactAttachment.uid = _uid;
    contactAttachment.firstName = _firstName;
    contactAttachment.lastName = _lastName;
    contactAttachment.phoneNumber = _phoneNumber;
    
    message.mediaAttachments = @[contactAttachment];
    
    return message;
}

@end
