#import "TGInlineBotsSettingsCell.h"

#import "TGModernButton.h"

@interface TGInlineBotsSettingsCell () {
    TGModernButton *_button;
}

@end

@implementation TGInlineBotsSettingsCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _button = [[TGModernButton alloc] initWithFrame:self.bounds];
        [_button setImage:[UIImage imageNamed:@"StickerKeyboardSettingsIcon.png"] forState:UIControlStateNormal];
        _button.modernHighlight = true;
        [_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_button];
    }
    return self;
}

- (void)buttonPressed {
    if (_pressed) {
        _pressed();
    }
}

@end
