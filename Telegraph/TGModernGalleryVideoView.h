#import <UIKit/UIKit.h>

@class AVPlayer;
@class AVPlayerLayer;

@interface TGModernGalleryVideoView : UIView

@property (nonatomic, readonly) AVPlayerLayer *playerLayer;
@property (nonatomic, copy) void (^deallocBlock)(void);

- (instancetype)initWithFrame:(CGRect)frame player:(AVPlayer *)player;
- (void)cleanupPlayer;

@end
