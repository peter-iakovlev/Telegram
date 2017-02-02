#import "TGModernConversationGenericContextResultsAssociatedPanelSwitchPm.h"

#import "TGModernButton.h"
#import "TGImageUtils.h"
#import "TGFont.h"

@interface TGModernConversationGenericContextResultsAssociatedPanelSwitchPm () {
    TGModernButton *_button;
}

@end

@implementation TGModernConversationGenericContextResultsAssociatedPanelSwitchPm

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.backgroundColor = [UIColor whiteColor];
        _button = [[TGModernButton alloc] initWithFrame:self.bounds];
        _button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_button setTitleColor:TGAccentColor()];
        _button.modernHighlight = true;
        [_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        _button.titleLabel.font = TGSystemFontOfSize(15.0f);
        [self addSubview:_button];
        
        CGFloat separatorHeight = 1.0f / TGScreenScaling();
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - separatorHeight, frame.size.width, separatorHeight)];
        separatorView.backgroundColor = UIColorRGB(0xc5c7d0);
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:separatorView];
    }
    return self;
}

- (void)buttonPressed {
    if (_pressed) {
        _pressed();
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [_button setTitle:title forState:UIControlStateNormal];
}

@end
