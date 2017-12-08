#import "TGInlineVideoView.h"

#import "TGVTPlayer.h"
#import "TGVTPlayerView.h"

#import "TGAcceleratedVideoView.h"
#import "TGVTAcceleratedVideoView.h"
#import "TGGLVideoView.h"

#define USE_VT false

@interface TGInlineVideoView () {
#if USE_VT
    TGVTPlayerView *_playerView;
    TGVTPlayer *_player;
#else
    UIView<TGInlineVideoPlayerView> *_videoView;
#endif
    
    SMetaDisposable *_pathDisposable;
    
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGInlineVideoView

+ (SQueue *)playerQueue {
    static SQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[SQueue alloc] init];
    });
    return queue;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _pathDisposable = [[SMetaDisposable alloc] init];
        
#if USE_VT
        _playerView = [[TGVTPlayerView alloc] initWithFrame:self.bounds];
        [self addSubview:_playerView];
#else
        _videoView = [[[TGVTAcceleratedVideoView videoViewClass] alloc] initWithFrame:self.bounds];
        [self addSubview:_videoView];
#endif
        
        _cornerRadius = 13.0f;
        self.layer.cornerRadius = _cornerRadius;
        self.layer.masksToBounds = true;
        _insets = UIEdgeInsetsMake(-2.0f, -2.0f, -2.0f, -2.0f);
    }
    return self;
}

- (void)setVideoSize:(CGSize)videoSize {
    _videoSize = videoSize;
    _videoView.videoSize = videoSize;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
}

typedef enum {
    TGInlineVideoPositionNone = 0,
    TGInlineVideoPositionTop = 1 << 0,
    TGInlineVideoPositionBottom = 1 << 1,
    TGInlineVideoPositionLeft = 1 << 2,
    TGInlineVideoPositionRight = 1 << 3,
    TGInlineVideoPositionInside = 1 << 4
} TGInlineVideoPosition;

- (void)setPosition:(int)position {
    _position = position;
    
    if (position != 0)
    {
        self.layer.cornerRadius = 0;
        
        const CGFloat smallRadius = 3;
        const CGFloat bigRadius = _cornerRadius;
        
        CGFloat topLeftRadius = smallRadius;
        CGFloat topRightRadius = smallRadius;
        CGFloat bottomLeftRadius = smallRadius;
        CGFloat bottomRightRadius = smallRadius;
        
        if (position == TGInlineVideoPositionNone)
        {
            self.layer.cornerRadius = bigRadius;
            return;
        }
        else if (position == TGInlineVideoPositionInside)
            topLeftRadius = topRightRadius = bottomLeftRadius = bottomRightRadius = smallRadius;
        
        if (position & TGInlineVideoPositionTop && position & TGInlineVideoPositionLeft)
            topLeftRadius = bigRadius;
        if (position & TGInlineVideoPositionTop && position & TGInlineVideoPositionRight)
            topRightRadius = bigRadius;
        if (position & TGInlineVideoPositionBottom && position & TGInlineVideoPositionLeft)
            bottomLeftRadius = bigRadius;
        if (position & TGInlineVideoPositionBottom && position & TGInlineVideoPositionRight)
            bottomRightRadius = bigRadius;
        
        CGFloat minx = CGRectGetMinX(self.bounds);
        CGFloat miny = CGRectGetMinY(self.bounds);
        CGFloat maxx = CGRectGetMaxX(self.bounds);
        CGFloat maxy = CGRectGetMaxY(self.bounds);
        
        UIBezierPath *path = [[UIBezierPath alloc] init];
        [path moveToPoint:CGPointMake(minx + topLeftRadius, miny)];
        [path addLineToPoint:CGPointMake(maxx - topRightRadius, miny)];
        [path addArcWithCenter:CGPointMake(maxx - topRightRadius, miny + topRightRadius) radius: topRightRadius startAngle: 3 * M_PI_2 endAngle: 0 clockwise:true];
        [path addLineToPoint:CGPointMake(maxx, maxy - bottomRightRadius)];
        [path addArcWithCenter:CGPointMake(maxx - bottomRightRadius, maxy - bottomRightRadius) radius: bottomRightRadius startAngle: 0 endAngle: M_PI_2 clockwise:true];
        [path addLineToPoint:CGPointMake(minx + bottomLeftRadius, maxy)];
        [path addArcWithCenter:CGPointMake(minx + bottomLeftRadius, maxy - bottomLeftRadius) radius: bottomLeftRadius startAngle: M_PI_2 endAngle:M_PI clockwise:true];
        [path addLineToPoint:CGPointMake(minx, miny + topLeftRadius)];
        [path addArcWithCenter:CGPointMake(minx + topLeftRadius, miny + topLeftRadius) radius: topLeftRadius startAngle: M_PI endAngle:3 * M_PI_2 clockwise:true];
        [path closePath];
        
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.path = path.CGPath;
        self.layer.mask = maskLayer;
    }
    else
    {
        self.layer.cornerRadius = _cornerRadius;
    }
}

- (void)willBecomeRecycled {
#if USE_VT
    [_player stop];
    [_player _setOutput:nil];
#else
    TGDispatchOnMainThread(^
    {
        [_videoView setPath:nil];
        [_videoView prepareForRecycle];
    });
#endif
}

- (void)setVideoPathSignal:(SSignal *)signal {
    __weak TGInlineVideoView *weakSelf = self;
    
    if (signal == nil) {
        [self playVideoFromPath:nil];
    } else {
        [_pathDisposable setDisposable:[[signal deliverOn:[SQueue mainQueue]] startWithNext:^(NSString *path) {
            __strong TGInlineVideoView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf playVideoFromPath:path];
            }
        }]];
    }
}

- (void)playVideoFromPath:(NSString *)path {
//#if USE_VT
//    [_player stop];
//    [_player _setOutput:nil];
//    _player = nil;
//    
//    if (path != nil) {
//        _player = [[TGVTPlayer alloc] initWithUrl:[NSURL fileURLWithPath:path]];
//        [_player _setOutput:_playerView];
//        [_player play];
//    }
//#else
    [_videoView setPath:path];
    if (path != nil)
        _videoPath = path;
    
//#endif

}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    bounds.origin.x += _insets.left;
    bounds.origin.y += _insets.top;
    bounds.size.width -= _insets.left + _insets.right;
    bounds.size.height -= _insets.top + _insets.bottom;
    
#if USE_VT
    _playerView.frame = bounds;
#else
    _videoView.frame = bounds;
#endif
}

@end
