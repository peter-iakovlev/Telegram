#import "TGMenuSheetCheckItemView.h"

#import "TGPresentation.h"

@interface TGMenuSheetCheckItemView ()
{
    TGModernButton *_button;
    UIImageView *_checkView;
}
@end

@implementation TGMenuSheetCheckItemView

- (instancetype)initWithTitle:(NSString *)title action:(void (^)(void))action checked:(bool)checked
{
    self = [super initWithType:TGMenuSheetItemTypeDefault];
    if (self != nil)
    {
        self.action = action;
        
        _button = [[TGModernButton alloc] init];
        _button.exclusiveTouch = true;
        _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _button.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 16.0f, 0.0f, 0.0f);
        _button.highlightBackgroundColor = UIColorRGB(0xebebeb);
        _button.titleLabel.font = TGSystemFontOfSize(20);
        [_button setTitle:title forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
        
        __weak TGMenuSheetCheckItemView *weakSelf = self;
        _button.highlitedChanged = ^(bool highlighted)
        {
            __strong TGMenuSheetCheckItemView *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf.highlightUpdateBlock != nil)
                strongSelf.highlightUpdateBlock(highlighted);
        };
        
        if (checked)
        {
            _checkView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 14.0f, 11.0f)];
            [self addSubview:_checkView];
        }
    }
    return self;
}

- (void)setPallete:(TGMenuSheetPallete *)pallete
{
    _button.highlightBackgroundColor = pallete.selectionColor;
    [_button setTitleColor:pallete.textColor];
}

- (void)setPresentation:(TGPresentation *)presentation
{
    if (_checkView != nil)
        _checkView.image = presentation.images.collectionMenuCheckImage;
}

- (void)buttonPressed
{
    if (self.action != nil)
        self.action();
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
    _checkView.frame = CGRectMake(self.frame.size.width - _checkView.frame.size.width - 13.0f, 23.0f, _checkView.frame.size.width, _checkView.frame.size.height);
}

@end
