#import "TGAttachmentSheetCheckmarkVariantItemView.h"

#import "TGFont.h"

#import "TGModernButton.h"
#import "TGImageUtils.h"

@interface TGAttachmentSheetCheckmarkVariantItemView () {
    TGModernButton *_button;
    UIImageView *_checkmarkView;
    UIImageView *_iconView;
    UILabel *_titleLabel;
    UILabel *_variantLabel;
    bool _checked;
}

@end

@implementation TGAttachmentSheetCheckmarkVariantItemView

- (instancetype)initWithTitle:(NSString *)title variant:(NSString *)variant checked:(bool)checked {
    return [self initWithTitle:title variant:variant checked:checked image:nil];
}

- (instancetype)initWithTitle:(NSString *)title variant:(NSString *)variant checked:(bool)checked image:(UIImage *)image {
    self = [super init];
    if (self != nil) {
        _button = [[TGModernButton alloc] init];
        _button.exclusiveTouch = true;
        _button.titleLabel.font = TGSystemFontOfSize(20.0f + TGRetinaPixel);
        [_button addTarget:self action:@selector(_buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        _button.stretchHighlightImage = true;
        _button.highlighted = false;
        [self addSubview:_button];
        
        if (image != nil) {
            _iconView = [[UIImageView alloc] initWithImage:image];
            [self addSubview:_iconView];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGSystemFontOfSize(20.0f);
        _titleLabel.text = title;
        _titleLabel.userInteractionEnabled = false;
        [self addSubview:_titleLabel];
        
        _variantLabel = [[UILabel alloc] init];
        _variantLabel.backgroundColor = [UIColor clearColor];
        _variantLabel.textColor = UIColorRGB(0x8e8e93);
        _variantLabel.font = TGSystemFontOfSize(20.0f);
        _variantLabel.text = variant;
        _variantLabel.userInteractionEnabled = false;
        [self addSubview:_variantLabel];
        
        _checked = checked;
        _checkmarkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernMenuCheck.png"]];
        _checkmarkView.hidden = !_checked;
        _checkmarkView.userInteractionEnabled = false;
        [self addSubview:_checkmarkView];
    }
    return self;
}

- (void)setHighlightedImage:(UIImage *)highlightedImage {
    [_button setHighlightImage:highlightedImage];
}

- (CGFloat)preferredHeight {
    return 57.0f;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _button.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
    
    _checkmarkView.frame = CGRectMake(22.0f, CGFloor((self.bounds.size.height - _checkmarkView.bounds.size.height) / 2.0f), _checkmarkView.bounds.size.width, _checkmarkView.bounds.size.height);
    
    CGSize variantSize = [_variantLabel.text sizeWithFont:_variantLabel.font];
    variantSize.width = CGCeil(variantSize.width);
    variantSize.height = CGCeil(variantSize.height);
    _variantLabel.frame = CGRectMake(self.bounds.size.width - variantSize.width - 10.0f, CGFloor((self.bounds.size.height - variantSize.height) / 2.0f), variantSize.width, variantSize.height);
    
    CGFloat titleOffset = 52.0f;
    if (_disableInsetIfNotChecked && !_checked) {
        titleOffset = 12.0f;
    }
    
    CGFloat imageWidth = 0.0f;
    if (_iconView != nil) {
        imageWidth = _iconView.frame.size.width + 8.0f;
        _iconView.frame = CGRectMake(titleOffset, CGFloor((self.bounds.size.height - _iconView.frame.size.height) / 2.0f), _iconView.frame.size.width, _iconView.frame.size.height);
        titleOffset += imageWidth;
    }
    
    CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
    titleSize.width = MIN(CGRectGetMinX(_variantLabel.frame) - 10.0f - titleOffset, CGCeil(titleSize.width));
    titleSize.height = CGCeil(titleSize.height);
    _titleLabel.frame = CGRectMake(titleOffset, CGFloor((self.bounds.size.height - titleSize.height) / 2.0f), titleSize.width, titleSize.height);
}

- (void)_buttonPressed {
    if (!_disableAutoCheck) {
        _checked = !_checked;
        _checkmarkView.hidden = !_checked;
    
        if (_onCheckedChanged) {
            _onCheckedChanged(_checked);
        }
    } else {
        if (!_checked) {
            if (_onCheckedChanged) {
                _onCheckedChanged(!_checked);
            }
        }
    }
}

@end
