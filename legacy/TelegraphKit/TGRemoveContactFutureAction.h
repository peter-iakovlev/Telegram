/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGFutureAction.h"

#define TGRemoveContactFutureActionType ((int)0x64A04D67)

@interface TGRemoveContactFutureAction : TGFutureAction

- (id)initWithUid:(int)uid;

- (int)uid;

@end
