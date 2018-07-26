#import "TGUserInfoUsernameCollectionItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGPresentation.h"

#import <LegacyComponents/TGCheckButtonView.h>

@interface TGUserInfoUsernameCollectionItemView ()
{
    CALayer *_separatorLayer;
    
    UILabel *_labelView;
    UILabel *_usernameLabel;
    
    TGCheckButtonView *_checkView;
}
@end

@implementation TGUserInfoUsernameCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.selectionInsets = UIEdgeInsetsMake(TGScreenPixel, 0.0f, 0.0f, 0.0f);
        
        _separatorLayer = [[CALayer alloc] init];
        _separatorLayer.backgroundColor = TGSeparatorColor().CGColor;
        [self.backgroundView.layer addSublayer:_separatorLayer];
        
        _labelView = [[UILabel alloc] init];
        _labelView.backgroundColor = [UIColor clearColor];
        _labelView.textColor = TGAccentColor();
        _labelView.font = TGSystemFontOfSize(14.0f);
        [self addSubview:_labelView];
        
        _usernameLabel = [[UILabel alloc] init];
        _usernameLabel.backgroundColor = [UIColor clearColor];
        _usernameLabel.textColor = [UIColor blackColor];
        _usernameLabel.font = TGSystemFontOfSize(17.0f);
        [self addSubview:_usernameLabel];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    _labelView.textColor = presentation.pallete.collectionMenuTextColor;
    _usernameLabel.textColor = presentation.pallete.collectionMenuAccentColor;
    _separatorLayer.backgroundColor = presentation.pallete.collectionMenuSeparatorColor.CGColor;
}

- (void)setChecking:(bool)checking
{
    if (_checkView == nil)
    {
        _checkView = [[TGCheckButtonView alloc] initWithStyle:TGCheckButtonStyleDefaultBlue pallete:self.presentation.checkButtonPallete];
        _checkView.userInteractionEnabled = false;
        [self addSubview:_checkView];
    }
    _checkView.hidden = !checking;
    [self setNeedsLayout];
}

- (void)setIsChecked:(bool)checked animated:(bool)animated
{
    [_checkView setSelected:checked animated:animated];
}

- (void)setLabel:(NSString *)label
{
    _labelView.text = label;
    [self setNeedsLayout];
}

- (void)setUsername:(NSString *)username
{
    _usernameLabel.text = username;
    [self setNeedsLayout];
}

- (void)setLastInList:(bool)lastInList
{
    _separatorLayer.hidden = !lastInList;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    bool hasCheck = _checkView != nil && !_checkView.hidden;
    
    _checkView.frame = CGRectMake(14.0f + self.safeAreaInset.left, TGScreenPixelFloor((self.frame.size.height - _checkView.frame.size.height) / 2.0f), _checkView.frame.size.width, _checkView.frame.size.height);
    
    CGFloat separatorHeight = TGScreenPixel;
    CGFloat separatorInset = (hasCheck ? 60.0f : 15.0f) + self.safeAreaInset.left;
    _separatorLayer.frame = CGRectMake(separatorInset, bounds.size.height - separatorHeight, bounds.size.width - separatorInset, separatorHeight);
    
    CGFloat leftPadding = (hasCheck ? 60.0f : 15.0f) + TGScreenPixel + self.safeAreaInset.left;
    
    CGSize labelSize = [_labelView sizeThatFits:CGSizeMake(bounds.size.width - leftPadding - self.safeAreaInset.right - 10.0f, CGFLOAT_MAX)];
    _labelView.frame = CGRectMake(leftPadding, 11.0f, labelSize.width, labelSize.height);
    
    CGSize usernameSize = [_usernameLabel sizeThatFits:CGSizeMake(bounds.size.width - leftPadding - self.safeAreaInset.right - 10.0f, CGFLOAT_MAX)];
    usernameSize.width = MIN(CGCeil(usernameSize.width), bounds.size.width - leftPadding - self.safeAreaInset.right - 10.0f);
    usernameSize.height = CGCeil(usernameSize.height);
    _usernameLabel.frame = CGRectMake(leftPadding, 30.0f, usernameSize.width, usernameSize.height);
}

@end
