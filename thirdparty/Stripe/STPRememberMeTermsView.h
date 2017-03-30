//
//  STPRememberMeTermsView.h
//  Stripe
//
//  Created by Jack Flintermann on 5/18/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPTheme.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^STPRememberMeTermsPushVCBlock)(UIViewController *vc);

@interface STPRememberMeTermsView : UIView

@property(nonatomic, weak, readonly)UITextView *textView;
@property(nonatomic)STPTheme *theme;
@property(nonatomic)UIEdgeInsets insets;
@property (nonatomic, copy)STPRememberMeTermsPushVCBlock pushViewControllerBlock;

- (CGFloat)heightForWidth:(CGFloat)maxWidth;

@end

NS_ASSUME_NONNULL_END
