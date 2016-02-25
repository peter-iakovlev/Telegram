#import "TGStickerKeyboardTabSettingsCell.h"

#import "TGModernButton.h"

@interface TGStickerKeyboardTabSettingsCell () {
    TGModernButton *_button;
    UIImageView *_imageView;
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
    _imageView.image = mode == TGStickerKeyboardTabSettingsCellSettings ? [UIImage imageNamed:@"StickerKeyboardSettingsIcon.png"] : [UIImage imageNamed:@"StickerKeyboardGifIcon.png"];
    _button.hidden = mode != TGStickerKeyboardTabSettingsCellSettings;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _button.frame = self.bounds;
    _imageView.frame = self.bounds;
}

- (void)buttonPressed {
    if (_pressed) {
        _pressed();
    }
}

@end
