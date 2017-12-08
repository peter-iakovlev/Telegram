#import "TGUserInfoEditingPhoneCollectionItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/TGModernButton.h>
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
        
        _fieldSeparator = [[UIImageView alloc] initWithImage:TGImageNamed(@"ModernUserInfoPhoneEditingSeparator.png")];
        _fieldSeparator.frame = CGRectMake(109.0f, 0.0f, TGScreenPixel, 44.0f);
        [self.editingContentView addSubview:_fieldSeparator];
        
        _labelButton = [[TGModernButton alloc] initWithFrame:CGRectMake(46.0f, TGRetinaPixel, 46.0f, 44.0f)];
        _labelButton.titleLabel.font = TGSystemFontOfSize(14.0f);
        _labelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_labelButton setTitleColor:TGAccentColor()];
        [_labelButton addTarget:self action:@selector(labelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.editingContentView addSubview:_labelButton];
        
        _arrowView = [[UIImageView alloc] initWithImage:TGImageNamed(@"ModernListsDisclosureIndicatorSmall.png")];
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
    CGFloat separatorInset = 15.0f + self.safeAreaInset.left;
    _separatorLayer.frame = CGRectMake(separatorInset, bounds.size.height - separatorHeight, bounds.size.width + 256.0f, separatorHeight);
    
    _labelButton.frame = CGRectMake(46.0f + self.safeAreaInset.left, TGRetinaPixel, 46.0f, 44.0f);
    _fieldSeparator.frame = CGRectMake(109.0f + self.safeAreaInset.left, 0.0f, TGScreenPixel, 44.0f);
    
    CGSize arrowSize = _arrowView.bounds.size;
    _arrowView.frame = CGRectMake(96.0f + self.safeAreaInset.left, 17.0f + TGRetinaPixel, arrowSize.width, arrowSize.height);
    
    _phoneField.frame = CGRectMake(122.0f + self.safeAreaInset.left, TGRetinaPixel, bounds.size.width - 122.0f - 8.0f - self.safeAreaInset.left - self.safeAreaInset.right, bounds.size.height);
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
