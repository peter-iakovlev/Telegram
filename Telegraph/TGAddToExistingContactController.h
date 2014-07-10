/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGContactsController.h"

@class TGAddToExistingContactController;

@protocol TGAddToExistingContactControllerDelegate <NSObject>

@optional

- (void)addToExistingContactControllerDidFinish:(TGAddToExistingContactController *)addToExistingContactController;

@end

@interface TGAddToExistingContactController : TGContactsController

@property (nonatomic, weak) id<TGAddToExistingContactControllerDelegate> delegate;

- (id)initWithUid:(int32_t)uid phoneNumber:(NSString *)phoneNumber;

@end
