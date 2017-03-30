//
//  STPWebViewController.h
//  Stripe
//
//  Created by Brian Dorfman on 9/12/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface STPWebViewController : UIViewController

- (instancetype)initWithURL:(NSURL *)url title:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
