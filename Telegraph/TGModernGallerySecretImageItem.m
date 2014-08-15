/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernGallerySecretImageItem.h"

#import "TGModernGallerySecretImageItemView.h"

@interface TGModernGallerySecretImageItem ()

@end

@implementation TGModernGallerySecretImageItem

- (instancetype)initWithMessageId:(int32_t)messageId imageInfo:(TGImageInfo *)imageInfo messageCountdownTime:(NSTimeInterval)messageCountdownTime messageLifetime:(int)messageLifetime
{
    assert(false);
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
    return [TGModernGallerySecretImageItemView class];
}

@end
