/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGFutureAction.h"

#define TGDeleteProfilePhotoFutureActionType ((int)0x7C124D4C)

@interface TGDeleteProfilePhotoFutureAction : TGFutureAction

@property (nonatomic) int64_t imageId;
@property (nonatomic) int64_t accessHash;

- (id)initWithImageId:(int64_t)imageId accessHash:(int64_t)accessHash;

@end
