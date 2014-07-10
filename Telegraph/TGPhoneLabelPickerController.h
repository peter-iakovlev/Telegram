/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCollectionMenuController.h"

@class TGPhoneLabelPickerController;

@protocol TGPhoneLabelPickerControllerDelegate <NSObject>

@optional

- (void)phoneLabelPickerController:(TGPhoneLabelPickerController *)phoneLabelPickerController didFinishWithLabel:(NSString *)label;

@end

@interface TGPhoneLabelPickerController : TGCollectionMenuController

@property (nonatomic, weak) id<TGPhoneLabelPickerControllerDelegate> delegate;

- (instancetype)initWithSelectedLabel:(NSString *)selectedLabel;

@end
