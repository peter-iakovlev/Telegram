/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernGallerySecretVideoItem.h"

#import "TGModernGallerySecretVideoItemView.h"

@implementation TGModernGallerySecretVideoItem

- (instancetype)initWithMessageId:(int32_t)messageId videoMedia:(TGVideoMediaAttachment *)videoMedia messageCountdownTime:(NSTimeInterval)messageCountdownTime messageLifetime:(int)messageLifetime
{
    //TODO:
    self = [super init];
    if (self != nil)
    {
        _messageId = messageId;
        _messageCountdownTime = messageCountdownTime;
        _messageLifetime = messageLifetime;
    }
    return self;
}

- (Class)viewClass
{
    return [TGModernGallerySecretVideoItemView class];
}

@end
