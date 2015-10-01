/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGFutureAction.h"

#define TGExportContactFutureActionType ((int)0xE573D945)

@interface TGExportContactFutureAction : TGFutureAction

- (id)initWithContactId:(int)contactId;

- (int)contactId;

@end
