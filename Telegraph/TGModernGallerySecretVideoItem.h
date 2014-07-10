/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernGalleryVideoItem.h"

@interface TGModernGallerySecretVideoItem : TGModernGalleryVideoItem

@property (nonatomic, readonly) int32_t messageId;
@property (nonatomic, readonly) NSTimeInterval messageCountdownTime;
@property (nonatomic, readonly) int messageLifetime;

- (instancetype)initWithMessageId:(int32_t)messageId videoMedia:(TGVideoMediaAttachment *)videoMedia messageCountdownTime:(NSTimeInterval)messageCountdownTime messageLifetime:(int)messageLifetime;

@end
