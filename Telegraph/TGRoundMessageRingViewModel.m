#import "TGRoundMessageRingViewModel.h"

#import "TGRoundMessageRingView.h"

@interface TGRoundMessageRingViewModel ()
{
    TGMusicPlayerStatus *_status;
}
@end

@implementation TGRoundMessageRingViewModel

- (Class)viewClass
{
    return [TGRoundMessageRingView class];
}

- (void)setStatus:(TGMusicPlayerStatus *)status
{
    _status = status;
    [(TGRoundMessageRingView *)[self boundView] setStatus:_status];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    TGRoundMessageRingView *view = (TGRoundMessageRingView *)[self boundView];
    [view setStatus:_status];
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    [super unbindView:viewStorage];
}

@end
