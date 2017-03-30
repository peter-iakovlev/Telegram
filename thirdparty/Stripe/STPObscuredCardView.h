//
//  STPObscuredCardView.h
//  Stripe
//
//  Created by Jack Flintermann on 5/11/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPCard.h"
#import "STPTheme.h"

NS_ASSUME_NONNULL_BEGIN

@class STPObscuredCardView;

@protocol STPObscuredCardViewDelegate <NSObject>

- (void)obscuredCardViewDidClear:(STPObscuredCardView *)cardView;

@end

@interface STPObscuredCardView : UIView

@property(nonatomic)STPTheme *theme;
@property(nonatomic, weak)id<STPObscuredCardViewDelegate>delegate;
@property(nonatomic, weak)UIView *inputAccessoryView;
- (void)configureWithCard:(STPCard *)card;
- (void)clear;
- (BOOL)isEmpty;

@end

NS_ASSUME_NONNULL_END
