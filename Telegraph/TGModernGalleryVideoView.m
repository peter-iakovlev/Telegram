#import "TGModernGalleryVideoView.h"
#import <AVFoundation/AVFoundation.h>


@interface TGModernGalleryVideoView ()
{
    AVPlayerLayer *_playerLayer;
}
@end

@implementation TGModernGalleryVideoView

- (instancetype)initWithFrame:(CGRect)frame player:(AVPlayer *)player
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.playerLayer.player = player;
    }
    return self;
}

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer
{
    return (AVPlayerLayer *)self.layer;
}

@end
