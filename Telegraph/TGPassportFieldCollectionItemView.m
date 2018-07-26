#import "TGPassportFieldCollectionItemView.h"

#import <LegacyComponents/TGFont.h>

#import "TGPresentation.h"

#import "TGSimpleImageView.h"

@interface TGPassportFieldCollectionItemView ()
{
    NSArray *_errors;
    NSString *_subtitle;
    CGSize _calculatedSize;
    
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    TGSimpleImageView *_disclosureView;
    TGSimpleImageView *_checkView;
    
    bool _isRequired;
}
@end

@implementation TGPassportFieldCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TGSystemFontOfSize(17);
        [self addSubview:_titleLabel];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.textAlignment = NSTextAlignmentLeft;
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.font = TGSystemFontOfSize(14);
        _subtitleLabel.numberOfLines = 0;
        _subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_subtitleLabel];
        
        _disclosureView = [[TGSimpleImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 8.0f, 14.0f)];
        [self addSubview:_disclosureView];
        
        _checkView = [[TGSimpleImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 14.0f, 11.0f)];
        [self addSubview:_checkView];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    _titleLabel.textColor = presentation.pallete.collectionMenuTextColor;
    _subtitleLabel.textColor = _isRequired ? presentation.pallete.collectionMenuDestructiveColor : presentation.pallete.collectionMenuVariantColor;
    _disclosureView.image = presentation.images.collectionMenuDisclosureIcon;
    _checkView.image = presentation.images.collectionMenuCheckImage;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle
{
    _subtitle = subtitle;
    if (_errors.count > 0)
        return;
    
    [self _setSubtext:_subtitle];
}

- (void)setErrors:(NSArray *)errors
{
    _errors = errors;
    
    if (_errors.count == 0) {
        [self _setSubtext:_subtitle];
    }
    else {
        NSString *subtext = nil;
        NSString *text = TGLocalized(@"Passport.CorrectErrors");
        if (text.length > 0)
            subtext = text;
        else
            subtext = [errors componentsJoinedByString:@"\n"];
        
        [self _setSubtext:subtext];
    }
}

- (void)_setSubtext:(NSString *)text
{
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text ?: @""];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.lineSpacing = 2.0f;
    style.paragraphSpacing = 0.0f;
    [attributedText addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributedText.length)];
    [attributedText addAttribute:NSFontAttributeName value:_subtitleLabel.font range:NSMakeRange(0, attributedText.length)];
    
    _subtitleLabel.attributedText = attributedText;
}

- (void)setIsChecked:(bool)isChecked
{
    _checkView.hidden = !isChecked;
    _disclosureView.hidden = isChecked;
}

- (void)setIsRequired:(bool)isRequired
{
    _isRequired = isRequired;
    _subtitleLabel.textColor = isRequired ? self.presentation.pallete.collectionMenuDestructiveColor : self.presentation.pallete.collectionMenuVariantColor;
}

- (void)setCalculatedSize:(CGSize)calculatedSize
{
    _calculatedSize = calculatedSize;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    [UIView performWithoutAnimation:^
    {
        _titleLabel.frame = CGRectMake(15.0f + self.safeAreaInset.left, 9.0f, bounds.size.width - 15 - 40, 26);
        _subtitleLabel.frame = CGRectMake(15.0f + self.safeAreaInset.left, CGRectGetMaxY(_titleLabel.frame) + 3.0f, _calculatedSize.width, _calculatedSize.height);
    }];
    
    _checkView.frame = CGRectMake(bounds.size.width - _checkView.frame.size.width - 15.0f - self.safeAreaInset.right, CGFloor((bounds.size.height - _checkView.frame.size.height) / 2), _checkView.frame.size.width, _checkView.frame.size.height);
    _disclosureView.frame = CGRectMake(bounds.size.width - _disclosureView.frame.size.width - 15.0f - self.safeAreaInset.right, CGFloor((bounds.size.height - _disclosureView.frame.size.height) / 2), _disclosureView.frame.size.width, _disclosureView.frame.size.height);
}

@end
