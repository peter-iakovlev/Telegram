/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGContactsController.h"

@class TGForwardContactPickerController;

@protocol TGForwardContactPickerControllerDelegate <NSObject>

@optional

- (void)forwardContactPickerController:(TGForwardContactPickerController *)contactPicker didSelectContact:(TGUser *)contactUser;

@end

@interface TGForwardContactPickerController : TGContactsController

@property (nonatomic, weak) id<TGForwardContactPickerControllerDelegate> delegate;

@end
