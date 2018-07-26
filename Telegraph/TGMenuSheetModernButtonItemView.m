#import "TGMenuSheetModernButtonItemView.h"

#import <LegacyComponents/TGFont.h>
#import <LegacyComponents/TGImageUtils.h>
#import <LegacyComponents/TGModernButton.h>
#import <LegacyComponents/TGMenuSheetController.h>

#import "TGPresentation.h"

@interface TGMenuSheetModernButtonItemView ()
{
    bool _dark;
    bool _requiresDivider;
}
@end

const CGFloat TGMenuSheetModernButtonItemViewHeight = 88.0f;

@implementation TGMenuSheetModernButtonItemView

- (instancetype)initWithTitle:(NSString *)title type:(TGMenuSheetButtonType)type presentation:(TGPresentation *)presentation action:(void (^)(void))action
{
    self = [super initWithType:(type == TGMenuSheetButtonTypeCancel) ? TGMenuSheetItemTypeFooter : TGMenuSheetItemTypeDefault];
    if (self != nil)
    {
        _presentation = presentation;
        
        self.action = action;
        _buttonType = type;
        
        _button = [[TGModernButton alloc] init];
        _button.adjustsImageWhenHighlighted = false;
        _button.titleLabel.font = TGMediumSystemFontOfSize(17);
        _button.exclusiveTouch = true;
        [self _updateForType:type];
        [_button setTitle:title forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    _presentation = presentation;
    [self _updateForType:_buttonType];
}

- (void)setButtonType:(TGMenuSheetButtonType)buttonType
{
    [self setButtonType:buttonType animated:false];
}

- (void)setButtonType:(TGMenuSheetButtonType)buttonType animated:(bool)animated
{
    if (animated)
    {
        UIView *snapshotView = [_button snapshotViewAfterScreenUpdates:false];
        snapshotView.frame = _button.frame;
        [self addSubview:snapshotView];
        
        [self _updateForType:buttonType];
        _button.alpha = 0.0f;
        [UIView animateWithDuration:0.2 animations:^
        {
            snapshotView.alpha = 0.0f;
            _button.alpha = 1.0f;
        } completion:^(__unused BOOL finished)
        {
            [snapshotView removeFromSuperview];
        }];
    }
    else
    {
        [self _updateForType:buttonType];
    }
}

- (void)_updateForType:(TGMenuSheetButtonType)type
{
    UIImage *backgroundImage = nil;
    UIColor *textColor = nil;
    switch (type)
    {
        case TGMenuSheetButtonTypeSend:
            backgroundImage = _presentation.images.menuSendButtonImage;
            textColor = _presentation.pallete.accentContrastColor;
            break;
            
        case TGMenuSheetButtonTypeDestructive:
            backgroundImage = _presentation.images.menuDestructiveButtonImage;
            textColor = _presentation.pallete.menuDestructiveColor;
            break;
            
        default:
            backgroundImage = _presentation.images.menuDefaultButtonImage;
            textColor = _presentation.pallete.menuAccentColor;
            break;
    }
    
    [_button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [_button setTitleColor:textColor];
}

- (void)buttonPressed
{
    if (self.action != nil)
        self.action();
}

- (void)buttonLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        if (self.longPressAction != nil)
            self.longPressAction();
    }
}

- (void)setLongPressAction:(void (^)(void))longPressAction
{
    _longPressAction = [longPressAction copy];
    if (_longPressAction != nil)
    {
        UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(buttonLongPressed:)];
        gestureRecognizer.minimumPressDuration = 0.4;
        [_button addGestureRecognizer:gestureRecognizer];
    }
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
    return TGMenuSheetModernButtonItemViewHeight;
}

- (bool)requiresDivider
{
    return false;
}

- (void)layoutSubviews
{
    _button.frame = CGRectMake(16.0f, 20.0f, self.frame.size.width - 16.0f * 2, 50.0f);
}

@end
