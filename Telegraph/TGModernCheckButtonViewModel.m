#import "TGModernCheckButtonViewModel.h"

#import "TGModernCheckButtonView.h"

@implementation TGModernCheckButtonViewModel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self != nil)
    {
        self.frame = frame;
    }
    return self;
}

- (Class)viewClass
{
    return [TGModernCheckButtonView class];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    [(TGModernCheckButtonView *)[self boundView] setChecked:_isChecked animated:false];
}

- (void)setIsChecked:(bool)isChecked
{
    if (_isChecked != isChecked)
    {
        _isChecked = isChecked;
        
        if ([self boundView] != nil)
            [(TGModernCheckButtonView *)[self boundView] setChecked:_isChecked animated:true];
    }
}

@end
