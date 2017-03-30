/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGUserInfoEditingPhoneCollectionItemView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGModernButton.h"
#import "TGPhoneTextField.h"

@interface TGUserInfoEditingPhoneCollectionItemView () <TGPhoneTextFieldDelegate>
{
    CALayer *_separatorLayer;
    UIImageView *_fieldSeparator;
    
    TGModernButton *_labelButton;
    UIImageView *_arrowView;
    TGPhoneTextField *_phoneField;
    
    bool _becomeFirstResponderOnLayout;
}

@end

@implementation TGUserInfoEditingPhoneCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _separatorLayer = [[CALayer alloc] init];
        _separatorLayer.backgroundColor = TGSeparatorColor().CGColor;
        [self.editingContentView.layer addSublayer:_separatorLayer];
        
        _fieldSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernUserInfoPhoneEditingSeparator.png"]];
        _fieldSeparator.frame = CGRectMake(109.0f, 0.0f, TGScreenPixel, 44.0f);
        [self.editingContentView addSubview:_fieldSeparator];
        
        _labelButton = [[TGModernButton alloc] initWithFrame:CGRectMake(46.0f, TGRetinaPixel, 46.0f, 44.0f)];
        _labelButton.titleLabel.font = TGSystemFontOfSize(14.0f);
        _labelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_labelButton setTitleColor:TGAccentColor()];
        [_labelButton addTarget:self action:@selector(labelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.editingContentView addSubview:_labelButton];
        
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernListsDisclosureIndicatorSmall.png"]];
        CGSize arrowSize = _arrowView.bounds.size;
        _arrowView.frame = CGRectMake(96.0f, 17.0f + TGRetinaPixel, arrowSize.width, arrowSize.height);
        [self.editingContentView addSubview:_arrowView];
        
        CGFloat separatorHeight = TGScreenPixel;
        self.optionsOffset = CGPointMake(0.0f, -separatorHeight);
        
        _phoneField = [[TGPhoneTextField alloc] init];
        _phoneField.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        _phoneField.textColor = [UIColor blackColor];
        _phoneField.font = TGSystemFontOfSize(17.0f);
        _phoneField.phoneDelegate = self;
        _phoneField.keyboardType = UIKeyboardTypePhonePad;
        _phoneField.returnKeyType = UIReturnKeyDone;
        [self.editingContentView addSubview:_phoneField];
    }
    return self;
}

- (void)setLabel:(NSString *)label
{
    [_labelButton setTitle:label forState:UIControlStateNormal];
}

- (void)setPhone:(NSString *)phone
{
    [_phoneField setPhoneNumber:phone];
}

- (void)makePhoneFieldFirstResponder
{
    [_phoneField becomeFirstResponder];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGFloat separatorHeight = TGScreenPixel;
    _separatorLayer.frame = CGRectMake(15.0f, bounds.size.height - separatorHeight, bounds.size.width + 256.0f, separatorHeight);
    
    _phoneField.frame = CGRectMake(122.0f, TGRetinaPixel, bounds.size.width - 122.0f - 8.0f, bounds.size.height);
}

- (void)deleteAction
{
    id<TGUserInfoEditingPhoneCollectionItemViewDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(editingPhoneItemViewRequestedDelete:)])
        [delegate editingPhoneItemViewRequestedDelete:self];
}

- (void)labelButtonPressed
{
    id<TGUserInfoEditingPhoneCollectionItemViewDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(editingPhoneItemViewLabelPressed:)])
        [delegate editingPhoneItemViewLabelPressed:self];
}

- (void)phoneTextField:(TGPhoneTextField *)__unused phoneTextField hasChangedPhone:(NSString *)phone
{
    id<TGUserInfoEditingPhoneCollectionItemViewDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(editingPhoneItemViewPhoneChanged:phone:)])
        [delegate editingPhoneItemViewPhoneChanged:self phone:phone];
}

@end
