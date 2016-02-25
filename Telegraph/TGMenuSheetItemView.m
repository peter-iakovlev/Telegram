#import "TGMenuSheetItemView.h"

@implementation TGMenuSheetItemView

- (instancetype)initWithType:(TGMenuSheetItemType)type
{
    self = [super initWithFrame:CGRectZero];
    if (self != nil)
    {
        _type = type;
    }
    return self;
}

- (void)setHidden:(bool)hidden animated:(bool)animated
{
    void (^changeBlock)(void) = ^
    {
        self.alpha = hidden ? 0.0f : 1.0f;
    };
    
    void (^completionBlock)(BOOL) = ^(BOOL finished)
    {
        if (finished)
            self.userInteractionEnabled = !hidden;
    };
    
    if (animated)
    {
        [UIView animateWithDuration:0.18 animations:changeBlock completion:completionBlock];
    }
    else
    {
        changeBlock();
        completionBlock(true);
    }
}

- (CGFloat)contentHeightCorrection
{
    return 0;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)__unused width screenHeight:(CGFloat)__unused screenHeight
{
    return 0;
}

- (void)requestMenuLayoutUpdate
{
    if (self.layoutUpdateBlock != nil)
        self.layoutUpdateBlock();
}

- (void)menuView:(TGMenuSheetView *)__unused menuView willAppearAnimated:(bool)__unused animated
{
}

- (void)menuView:(TGMenuSheetView *)__unused menuView didAppearAnimated:(bool)__unused animated
{
}

- (void)menuView:(TGMenuSheetView *)__unused menuView willDisappearAnimated:(bool)__unused animated
{
}

- (void)menuView:(TGMenuSheetView *)__unused menuView didDisappearAnimated:(bool)__unused animated
{
}

@end
