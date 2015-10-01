#import "TGTooltipWindow.h"

@interface TGTooltipWindow ()
{
    __weak UIView *_anchorView;
}

@end

@implementation TGTooltipWindow

- (instancetype)initWithAnchorView:(UIView *)anchorView
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self != nil)
    {
        _anchorView = anchorView;
    }
    return self;
}



@end
