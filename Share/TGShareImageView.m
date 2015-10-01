#import "TGShareImageView.h"

@interface TGShareImageView ()
{
    SMetaDisposable *_disposable;
}

@end

@implementation TGShareImageView

- (void)setSignal:(SSignal *)signal
{
    if (_disposable == nil)
        _disposable = [[SMetaDisposable alloc] init];
    
    self.image = nil;
    __weak TGShareImageView *weakSelf = self;
    [_disposable setDisposable:[[signal deliverOn:[SQueue mainQueue]] startWithNext:^(id next)
    {
        __strong TGShareImageView *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if ([next isKindOfClass:[UIImage class]])
                strongSelf.image = next;
        }
    }]];
}

@end
