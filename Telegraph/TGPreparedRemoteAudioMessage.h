/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedMessage.h"

@class TGAudioMediaAttachment;

@interface TGPreparedRemoteAudioMessage : TGPreparedMessage

@property (nonatomic) int64_t audioId;
@property (nonatomic) int64_t accessHash;
@property (nonatomic) int32_t datacenterId;
@property (nonatomic) int32_t duration;
@property (nonatomic) int32_t fileSize;

- (instancetype)initWithAudioMedia:(TGAudioMediaAttachment *)audioMedia;

@end
