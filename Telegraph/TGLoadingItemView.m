#import "TGLoadingItemView.h"
#import <LegacyComponents/TGMenuSheetController.h>

const CGFloat TGLoadingItemViewHeight = 57.0f;

@interface TGLoadingItemView ()
{
    TGMenuSheetPallete *_pallete;
    bool _started;
    
    UIActivityIndicatorView *_activityIndicator;
}
@end

@implementation TGLoadingItemView

- (instancetype)init
{
    self = [super initWithType:TGMenuSheetItemTypeDefault];
    if (self != nil)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_activityIndicator];
    }
    return self;
}

- (void)setPallete:(TGMenuSheetPallete *)pallete
{
    _pallete = pallete;
    _activityIndicator.color = pallete.spinnerColor;
}

- (void)start
{
    _started = true;
    [self _updateHeightAnimated:true];
    [_activityIndicator startAnimating];
}

- (CGFloat)preferredHeightForWidth:(CGFloat)__unused width screenHeight:(CGFloat)__unused screenHeight
{
    _activityIndicator.alpha = _started ? 1.0f : 0.0f;
    return _started ? TGLoadingItemViewHeight : 0.0f;
}

- (void)layoutSubviews
{
    _activityIndicator.center = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f);
}

@end
