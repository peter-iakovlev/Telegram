#import "TGModernGalleryVideoView.h"

#import <AVFoundation/AVFoundation.h>

#import <objc/runtime.h>

#import "Freedom.h"
#import "TGStringUtils.h"

@interface TGModernGalleryVideoView ()
{
    AVPlayerLayer *_playerLayer;
}

@end

@implementation TGModernGalleryVideoView

- (instancetype)initWithFrame:(CGRect)frame playerLayer:(AVPlayerLayer *)playerLayer
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        ptrdiff_t layerOffset = freedomIvarOffset([UIView class], murMurHash32(@"_layer"));
        if (layerOffset >= 0)
        {
            __strong CALayer **viewLayer = (__strong CALayer **)(void *)(((uint8_t *)(__bridge void *)self) + layerOffset);
            *viewLayer = playerLayer;
        }
        
        _playerLayer.frame = frame;
        _playerLayer = playerLayer;
        _playerLayer.delegate = self;
    }
    return self;
}

- (AVPlayerLayer *)playerLayer
{
    return _playerLayer;
}

@end
