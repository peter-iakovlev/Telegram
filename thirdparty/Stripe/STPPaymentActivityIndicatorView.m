//
//  STPPaymentActivityIndicatorView.m
//  Stripe
//
//  Created by Jack Flintermann on 5/12/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPPaymentActivityIndicatorView.h"

@interface STPPaymentActivityIndicatorView()

@property(nonatomic, weak)CAShapeLayer *indicatorLayer;

@end

@implementation STPPaymentActivityIndicatorView

- (instancetype)initWithFrame:(CGRect)frame {
    CGRect initialFrame = frame;
    if (CGRectIsEmpty(initialFrame)) {
        initialFrame = CGRectMake(frame.origin.x, frame.origin.y, 40, 40);
    }
    self = [super initWithFrame:initialFrame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        layer.backgroundColor = [UIColor clearColor].CGColor;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.strokeColor = self.tintColor.CGColor;
        layer.strokeStart = 0;
        layer.lineCap = @"round";
        layer.strokeEnd = 0.75f;
        layer.lineWidth = 2.0f;
        _indicatorLayer = layer;
        [self.layer addSublayer:layer];
        self.alpha = 0;
        _hidesWhenStopped = YES;
    }
    return self;
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    self.indicatorLayer.strokeColor = tintColor.CGColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    bounds.size.width = MIN(bounds.size.width, bounds.size.height);
    bounds.size.height = bounds.size.width;
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:bounds];
    self.indicatorLayer.path = path.CGPath;
}

- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped {
    _hidesWhenStopped = hidesWhenStopped;
    if (!self.animating && hidesWhenStopped) {
        self.alpha = 0;
    } else {
        self.alpha = 1;
    }
}

- (void)setAnimating:(BOOL)animating
            animated:(BOOL)animated {
    if (animating == _animating) {
        return;
    }
    _animating = animating;
    if (animating) {
        if (self.hidesWhenStopped) {
            [UIView animateWithDuration:(0.2f * animated) animations:^{
                self.alpha = 1.0f;
            }];
        }
        CALayer *currentLayer = [self.layer presentationLayer];
        CGFloat currentRotation = (CGFloat)[[currentLayer valueForKeyPath:@"transform.rotation.z"] floatValue];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = @(currentRotation);
        animation.toValue = @(currentRotation + 2*M_PI);
        animation.duration = 1.0f;
        animation.repeatCount = HUGE_VAL;
        [self.layer addAnimation:animation forKey:@"rotation"];
    } else {
        if (self.hidesWhenStopped) {
            [UIView animateWithDuration:(0.2f * animated) animations:^{
                self.alpha = 0.0f;
            }];
        }
    }
}

- (void)setAnimating:(BOOL)animating {
    [self setAnimating:animating animated:NO];
}

@end
