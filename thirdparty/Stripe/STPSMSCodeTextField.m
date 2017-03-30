//
//  STPSMSCodeTextField.m
//  Stripe
//
//  Created by Jack Flintermann on 5/10/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPSMSCodeTextField.h"
#import "STPTheme.h"
#import "NSArray+Stripe_BoundSafe.h"
#import "NSString+Stripe.h"
#import "STPCardValidator.h"

@class STPCodeInternalTextField;

@protocol STPCodeInternalTextFieldDelegate <NSObject>
- (void)internalTextFieldDidBackspaceOnEmpty:(STPCodeInternalTextField *)textField;
@end

@interface STPCodeInternalTextField : UITextField
@property(nonatomic, weak)id<STPCodeInternalTextFieldDelegate>internalDelegate;
@end

@implementation STPCodeInternalTextField

- (void)deleteBackward {
    [super deleteBackward];
    if (self.text.length == 0) {
        [self.internalDelegate internalTextFieldDidBackspaceOnEmpty:self];
    }
}

@end

@interface STPSMSCodeTextField()<UITextFieldDelegate, STPCodeInternalTextFieldDelegate>

@property(nonatomic, weak)UIView *leftContainerView;
@property(nonatomic, weak)UILabel *centerLabel;
@property(nonatomic, weak)UIView *rightContainerView;
@property(nonatomic)NSArray *textFields;
@property(nonatomic)NSArray *separators;
@property(nonatomic, weak)UIView *coveringView;

@end

@implementation STPSMSCodeTextField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _theme = [STPTheme new];
        
        UIView *leftContainerView = [UIView new];
        [self addSubview:leftContainerView];
        _leftContainerView = leftContainerView;
        
        UILabel *centerLabel = [UILabel new];
        centerLabel.text = @"-";
        centerLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:centerLabel];
        _centerLabel = centerLabel;
        
        UIView *rightContainerView = [UIView new];
        [self addSubview:rightContainerView];
        _rightContainerView = rightContainerView;
        
        NSMutableArray *textFields = [NSMutableArray array];
        NSMutableArray *separators = [NSMutableArray array];
        for (UIView *containerView in @[leftContainerView, rightContainerView]) {
            for (NSInteger i=0; i < 3; i++) {
                STPCodeInternalTextField *textField = [STPCodeInternalTextField new];
                textField.delegate = self;
                textField.keyboardType = UIKeyboardTypePhonePad;
                textField.internalDelegate = self;
                textField.textAlignment = NSTextAlignmentCenter;
                [textFields addObject:textField];
                [containerView addSubview:textField];
                
                UIView *separator = [UIView new];
                [separators addObject:separator];
                [containerView addSubview:separator];
            }
        }
        _textFields = [textFields copy];
        _separators = [separators copy];
        
        UIView *coveringView = [UIView new];
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(becomeFirstResponder)];
        [coveringView addGestureRecognizer:gestureRecognizer];
        [self addSubview:coveringView];
        _coveringView = coveringView;
        
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.centerLabel sizeToFit];
    self.centerLabel.center = CGPointMake((CGFloat)round(self.bounds.size.width / 2), (CGFloat)round(self.bounds.size.height / 2));
    self.leftContainerView.frame = CGRectMake(0, 0, CGRectGetMinX(self.centerLabel.frame) - 8, self.bounds.size.height);
    CGFloat rightContainerX = CGRectGetMaxX(self.centerLabel.frame) + 8;
    self.rightContainerView.frame = CGRectMake(rightContainerX, 0, self.bounds.size.width - rightContainerX, self.bounds.size.height);
    CGFloat fieldWidth = (CGFloat)round(self.leftContainerView.bounds.size.width / 3.0f);
    CGFloat fieldHeight = self.leftContainerView.bounds.size.height;
    for (NSInteger i=0; i < 6; i++) {
        NSInteger j = i % 3;
        UITextField *textField = self.textFields[i];
        textField.frame = CGRectMake(j * fieldWidth, 0, fieldWidth, fieldHeight);
        
        UIView *separator = self.separators[i];
        separator.frame = CGRectMake(((j+1) * fieldWidth), 0, 0.5, fieldHeight);
        separator.hidden = j == 2;
    }
    self.coveringView.frame = self.bounds;
}

- (BOOL)becomeFirstResponder {
    UITextField *emptyField;
    for (UITextField *textField in self.textFields) {
        if (textField.text.length == 0) {
            emptyField = textField;
            break;
        }
    }
    if (!emptyField) {
        emptyField = self.textFields.lastObject;
    }
    return [emptyField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];
    for (UITextField *textField in self.textFields) {
        if ([textField isFirstResponder]) {
            return [textField resignFirstResponder];
        }
    }
    return NO;
}

- (void)shakeAndClear {
    for (UIView *containerView in @[self.leftContainerView, self.rightContainerView]) {
        CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
        colorAnimation.fromValue = (id)containerView.layer.borderColor;
        colorAnimation.toValue = (id)self.theme.errorColor.CGColor;
        containerView.layer.borderColor = self.theme.errorColor.CGColor;
        colorAnimation.duration = 0.1f;
        colorAnimation.timingFunction = [CATransaction animationTimingFunction];
        [containerView.layer addAnimation:colorAnimation forKey:nil];
        
        CABasicAnimation *widthAnimation = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
        widthAnimation.fromValue = @(containerView.layer.borderWidth);
        widthAnimation.toValue = @(1.0f);
        containerView.layer.borderWidth = 1.0f;
        widthAnimation.duration = 0.1f;
        widthAnimation.timingFunction = [CATransaction animationTimingFunction];
        [containerView.layer addAnimation:widthAnimation forKey:nil];
    }
    self.transform = CGAffineTransformMakeTranslation(20, 0);
    [UIView animateWithDuration:0.3f
                          delay:0.0f
         usingSpringWithDamping:0.3f
          initialSpringVelocity:1.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(__unused BOOL finished) {
        for (UITextField *textField in self.textFields) {
            textField.text = nil;
        }
        for (UIView *containerView in @[self.leftContainerView, self.rightContainerView]) {
            CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
            colorAnimation.fromValue = (id)containerView.layer.borderColor;
            colorAnimation.toValue = (id)self.theme.secondaryForegroundColor.CGColor;
            containerView.layer.borderColor = self.theme.secondaryForegroundColor.CGColor;
            colorAnimation.duration = 0.1f;
            colorAnimation.timingFunction = [CATransaction animationTimingFunction];
            [containerView.layer addAnimation:colorAnimation forKey:nil];
            
            CABasicAnimation *widthAnimation = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
            widthAnimation.fromValue = @(containerView.layer.borderWidth);
            widthAnimation.toValue = @(0.5f);
            containerView.layer.borderWidth = 0.5f;
            widthAnimation.duration = 0.15f;
            widthAnimation.timingFunction = [CATransaction animationTimingFunction];
            [containerView.layer addAnimation:widthAnimation forKey:nil];
        }
        [self becomeFirstResponder];
    }];
}

- (void)setTheme:(STPTheme *)theme {
    _theme = theme;
    [self updateAppearance];
}

- (void)updateAppearance {
    self.backgroundColor = [UIColor clearColor];
    self.coveringView.backgroundColor = [UIColor clearColor];
    for (UIView *containerView in @[self.leftContainerView, self.rightContainerView]) {
        containerView.layer.cornerRadius = 6;
        containerView.layer.borderWidth = 0.5f;
        containerView.layer.borderColor = self.theme.tertiaryBackgroundColor.CGColor;
        containerView.backgroundColor = self.theme.secondaryBackgroundColor;
    }
    self.centerLabel.textColor = self.theme.secondaryForegroundColor;
    self.centerLabel.font = self.theme.largeFont;
    for (UIView *separator in self.separators) {
        separator.backgroundColor = self.theme.quaternaryBackgroundColor;
    }
    for (UITextField *textField in self.textFields) {
        textField.textColor = self.theme.primaryForegroundColor;
        textField.tintColor = self.theme.accentColor;
        textField.font = self.theme.largeFont;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (![STPCardValidator stringIsNumeric:string]) {
        return NO;
    }
    NSString *destination = [[textField.text stringByReplacingCharactersInRange:range withString:string] stp_safeSubstringToIndex:1];
    textField.text = destination;
    UITextField *nextField = [self fieldAfter:textField];
    if (nextField) {
        [nextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self.delegate codeTextField:self didEnterCode:self.code];
    }
    return NO;
}

- (void)internalTextFieldDidBackspaceOnEmpty:(STPCodeInternalTextField *)textField {
    UITextField *previousField = [self fieldBefore:textField];
    previousField.text = @"";
    [previousField becomeFirstResponder];
}

- (UITextField *)fieldBefore:(UITextField *)field {
    NSInteger index = [self.textFields indexOfObject:field];
    return [self.textFields stp_boundSafeObjectAtIndex:index-1];
}

- (UITextField *)fieldAfter:(UITextField *)field {
    NSInteger index = [self.textFields indexOfObject:field];
    return [self.textFields stp_boundSafeObjectAtIndex:index+1];
}

- (NSString *)code {
    NSMutableString *code = [NSMutableString string];
    for (UITextField *aTextField in self.textFields) {
        [code appendString:aTextField.text];
    }
    return code.copy;
}

- (void)setCode:(NSString *)code {
    [self.textFields enumerateObjectsUsingBlock:^(UITextField *_Nonnull aTextField, NSUInteger idx, __unused BOOL * _Nonnull stop) {
        if (idx < code.length) {
            aTextField.text = [code substringWithRange:NSMakeRange(idx, 1)];
        }
        else {
            aTextField.text = @"";
        }
    }];
}

@end
