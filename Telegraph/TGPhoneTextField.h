/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@class TGPhoneTextField;

@protocol TGPhoneTextFieldDelegate <NSObject>

@optional

- (void)phoneTextField:(TGPhoneTextField *)phoneTextField hasChangedPhone:(NSString *)phone;

@end

@interface TGPhoneTextField : UITextField

@property (nonatomic, weak) id<TGPhoneTextFieldDelegate> phoneDelegate;

- (void)setPhoneNumber:(NSString *)phoneNumber;

@end
