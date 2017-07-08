#import <UIKit/UIKit.h>

@protocol TGInlineVideoPlayerView <NSObject>

@property (nonatomic) CGSize videoSize;

- (void)setPath:(NSString *)path;
- (void)prepareForRecycle;

@end


@interface TGVTAcceleratedVideoView : UIView <TGInlineVideoPlayerView>

+ (Class)videoViewClass;

@end
