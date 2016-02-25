#import "TGInlineVideoModel.h"

#import "TGInlineVideoView.h"

@implementation TGInlineVideoModel

- (Class)viewClass {
    return [TGInlineVideoView class];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage {
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    TGInlineVideoView *view = (TGInlineVideoView *)[self boundView];
    [view setVideoPathSignal:_videoPathSignal];
}

- (void)unbindView:(TGModernViewStorage *)viewStorage {
    [(TGInlineVideoView *)[self boundView] setVideoPathSignal:nil];
    
    [super unbindView:viewStorage];
}

- (void)setVideoPathSignal:(SSignal *)videoPathSignal {
    _videoPathSignal = videoPathSignal;
    
    [(TGInlineVideoView *)[self boundView] setVideoPathSignal:videoPathSignal];
}

@end
