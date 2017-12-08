#import "TGShareSheetItemView.h"

#import <LegacyComponents/LegacyComponents.h>

@interface TGShareSheetItemView ()
{
}

@end

@implementation TGShareSheetItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
    }
    return self;
}

- (CGFloat)preferredHeightForMaximumHeight:(CGFloat)__unused maximumHeight
{
    return [TGViewController hasLargeScreen] ? 57.0f : 45.0f;
}

- (bool)followsKeyboard
{
    return false;
}

- (void)setPreferredHeightNeedsUpdate
{
    if (_preferredHeightNeedsUpdate) {
        _preferredHeightNeedsUpdate(self);
    }
}

- (bool)wantsFullSeparator
{
    return false;
}

- (void)sheetDidAppear
{
    
}

- (void)sheetWillDisappear
{
    
}
- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setHighlightedImage:(UIImage *)__unused highlightedImage {
    
}

@end
