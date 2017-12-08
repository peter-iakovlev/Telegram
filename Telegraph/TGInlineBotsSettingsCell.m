#import "TGInlineBotsSettingsCell.h"

#import <LegacyComponents/LegacyComponentsGlobals.h>
#import <LegacyComponents/TGModernButton.h>

@interface TGInlineBotsSettingsCell () {
    TGModernButton *_button;
}

@end

@implementation TGInlineBotsSettingsCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _button = [[TGModernButton alloc] initWithFrame:self.bounds];
        [_button setImage:TGComponentsImageNamed(@"StickerKeyboardSettingsIcon.png") forState:UIControlStateNormal];
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
