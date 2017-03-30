//
//  STPSMSCodeViewController.h
//  Stripe
//
//  Created by Jack Flintermann on 5/10/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STPSMSCodeViewController, STPCheckoutAccount, STPCheckoutAPIClient, STPAPIClient,STPCheckoutAPIVerification, STPTheme;

@protocol STPSMSCodeViewControllerDelegate <NSObject>

- (void)smsCodeViewControllerDidCancel:(STPSMSCodeViewController *)smsCodeViewController;
- (void)smsCodeViewController:(STPSMSCodeViewController *)smsCodeViewController
       didAuthenticateAccount:(STPCheckoutAccount *)account;

@end

@interface STPSMSCodeViewController : UIViewController

- (instancetype)initWithCheckoutAPIClient:(STPCheckoutAPIClient *)checkoutAPIClient
                             verification:(STPCheckoutAPIVerification *)verification
                            redactedPhone:(NSString *)redactedPhone;

@property(nonatomic)STPTheme *theme;
@property(nonatomic, weak)id<STPSMSCodeViewControllerDelegate>delegate;

@end
