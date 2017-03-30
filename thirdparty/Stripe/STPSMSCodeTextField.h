//
//  STPSMSCodeTextField.h
//  Stripe
//
//  Created by Jack Flintermann on 5/10/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class STPSMSCodeTextField, STPTheme;

@protocol STPSMSCodeTextFieldDelegate <NSObject>

- (void)codeTextField:(STPSMSCodeTextField *)codeField didEnterCode:(NSString *)code;

@end

@interface STPSMSCodeTextField : UIView

@property(nonatomic, weak)id<STPSMSCodeTextFieldDelegate>delegate;
@property(nonatomic)STPTheme *theme;
@property(nonatomic, copy)NSString *code;

- (void)shakeAndClear;

@end

NS_ASSUME_NONNULL_END
