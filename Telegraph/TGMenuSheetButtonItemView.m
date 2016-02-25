#import "TGMenuSheetButtonItemView.h"
#import "TGModernButton.h"
#import "TGFont.h"

const CGFloat TGMenuSheetButtonItemViewHeight = 57.0f;

@interface TGMenuSheetButtonItemView ()
{
    TGModernButton *_button;
}

@property (nonatomic, copy) void(^action)(void);

@end

@implementation TGMenuSheetButtonItemView


- (instancetype)initWithTitle:(NSString *)title type:(TGMenuSheetButtonType)type action:(void (^)(void))action
{
    self = [super initWithType:(type == TGMenuSheetButtonTypeCancel) ? TGMenuSheetItemTypeFooter : TGMenuSheetItemTypeDefault];
    if (self != nil)
    {
        self.action = action;
        
        _button = [[TGModernButton alloc] init];
        _button.exclusiveTouch = true;
        _button.highlightBackgroundColor = UIColorRGB(0xebebeb);
        _button.titleLabel.font = (type == TGMenuSheetButtonTypeCancel || type == TGMenuSheetButtonTypeSend) ? TGMediumSystemFontOfSize(20) : TGSystemFontOfSize(20);
        [_button setTitleColor:(type == TGMenuSheetButtonTypeDestructive) ? TGDestructiveAccentColor() : TGAccentColor()];
        [_button setTitle:title forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
        
        __weak TGMenuSheetButtonItemView *weakSelf = self;
        _button.highlitedChanged = ^(bool highlighted)
        {
            __strong TGMenuSheetButtonItemView *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf.highlightUpdateBlock != nil)
                strongSelf.highlightUpdateBlock(highlighted);
        };
    }
    return self;
}

- (void)buttonPressed
{
    if (self.action != nil)
        self.action();
}

- (NSString *)title
{
    return [_button titleForState:UIControlStateNormal];
}

- (void)setTitle:(NSString *)title
{
    [_button setTitle:title forState:UIControlStateNormal];
}

- (CGFloat)preferredHeightForWidth:(CGFloat)__unused width screenHeight:(CGFloat)__unused screenHeight
{
    return TGMenuSheetButtonItemViewHeight;
}

- (bool)requiresDivider
{
    return true;
}

- (void)layoutSubviews
{
    _button.frame = self.bounds;
}

@end
