/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedMessage.h"

@interface TGPreparedForwardedMessage : TGPreparedMessage

@property (nonatomic, strong) TGMessage *innerMessage;

@property (nonatomic) int32_t forwardMid;
@property (nonatomic) int64_t forwardPeerId;

@property (nonatomic) int32_t forwardAuthorUserId;
@property (nonatomic) int32_t forwardPostId;

@property (nonatomic) int64_t forwardSourcePeerId;

@property (nonatomic, strong) NSString *forwardAuthorSignature;

- (instancetype)initWithInnerMessage:(TGMessage *)innerMessage;
- (instancetype)initWithInnerMessage:(TGMessage *)innerMessage keepForwarded:(bool)keepForwarded;

@end
