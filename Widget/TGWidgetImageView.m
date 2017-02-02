#import "TGWidgetImageView.h"

@interface TGWidgetImageView ()
{
    SMetaDisposable *_disposable;
}
@end

@implementation TGWidgetImageView

- (void)setSignal:(SSignal *)signal
{
    if (_disposable == nil)
        _disposable = [[SMetaDisposable alloc] init];
    
    self.image = nil;
    __weak TGWidgetImageView *weakSelf = self;
    [_disposable setDisposable:[[signal deliverOn:[SQueue mainQueue]] startWithNext:^(id next)
    {
        __strong TGWidgetImageView *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if ([next isKindOfClass:[UIImage class]])
                strongSelf.image = next;
        }
    }]];
}

@end
