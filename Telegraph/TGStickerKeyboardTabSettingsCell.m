#import "TGStickerKeyboardTabSettingsCell.h"

#import "TGModernButton.h"

#import "TGFont.h"
#import "TGImageUtils.h"

@interface TGStickerKeyboardTabSettingsCell () {
    TGModernButton *_button;
    UIImageView *_imageView;
    
    UILabel *_badgeLabel;
    UIImageView *_badgeView;
}

@end

@implementation TGStickerKeyboardTabSettingsCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _button = [[TGModernButton alloc] init];
        _button.modernHighlight = true;
        [_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_button];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.image = [UIImage imageNamed:@"StickerKeyboardSettingsIcon.png"];
        _imageView.userInteractionEnabled = false;
        _imageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:_imageView];
        
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = UIColorRGB(0xe6e6e6);
    }
    return self;
}

- (void)setMode:(TGStickerKeyboardTabSettingsCellMode)mode {
    _mode = mode;
    
    if (mode == TGStickerKeyboardTabSettingsCellSettings) {
        _imageView.image = [UIImage imageNamed:@"StickerKeyboardSettingsIcon.png"];
    } else if (mode == TGStickerKeyboardTabSettingsCellGifs) {
        _imageView.image = [UIImage imageNamed:@"StickerKeyboardGifIcon.png"];
    } else {
        _imageView.image = [UIImage imageNamed:@"StickerKeyboardTrendingIcon.png"];
    }
    _button.hidden = mode != TGStickerKeyboardTabSettingsCellSettings;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _button.frame = self.bounds;
    _imageView.frame = self.bounds;
    
    if (_badgeLabel != nil) {
        CGSize labelSize = _badgeLabel.frame.size;
        CGFloat badgeWidth = MAX(16.0f, labelSize.width + 6.0);
        _badgeView.frame = CGRectMake(self.frame.size.width - badgeWidth - 4.0, 6.0f, badgeWidth, 16.0f);
        _badgeLabel.frame = CGRectMake(CGRectGetMinX(_badgeView.frame) + TGRetinaFloor((badgeWidth - labelSize.width) / 2.0f), CGRectGetMinY(_badgeView.frame) + 1.0f, labelSize.width, labelSize.height);
    }
}

- (void)buttonPressed {
    if (_pressed) {
        _pressed();
    }
}

- (void)setBadge:(NSString *)badge {
    if (badge != nil) {
        if (_badgeLabel == nil) {
            _badgeLabel = [[UILabel alloc] init];
            _badgeLabel.font = TGSystemFontOfSize(12.0);
            _badgeLabel.backgroundColor = [UIColor clearColor];
            _badgeLabel.textColor = [UIColor whiteColor];
            [self addSubview:_badgeLabel];
            
            static UIImage *badgeImage = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(16.0f, 16.0f), false, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                CGContextSetFillColorWithColor(context, UIColorRGB(0xff3b30).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 16.0f, 16.0f));
                
                badgeImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:7.0f topCapHeight:0.0f];
                UIGraphicsEndImageContext();
            });
            _badgeView = [[UIImageView alloc] initWithImage:badgeImage];
            
            [self addSubview:_badgeView];
            [self addSubview:_badgeLabel];
        }
        _badgeLabel.text = badge;
        [_badgeLabel sizeToFit];
    } else {
        [_badgeView removeFromSuperview];
        _badgeView = nil;
        [_badgeLabel removeFromSuperview];
        _badgeLabel = nil;
    }
    
    [self setNeedsLayout];
}

@end
