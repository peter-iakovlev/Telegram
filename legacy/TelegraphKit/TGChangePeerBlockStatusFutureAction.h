/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGFutureAction.h"

#define TGChangePeerBlockStatusFutureActionType ((int)0x07776F6C)

@interface TGChangePeerBlockStatusFutureAction : TGFutureAction

@property (nonatomic) bool block;

- (id)initWithPeerId:(int64_t)peerId block:(bool)block;

@end
