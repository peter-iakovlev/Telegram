#import <UIKit/UIKit.h>

@class AVPlayer;
@class AVPlayerLayer;

@interface TGModernGalleryVideoView : UIView

@property (nonatomic, readonly) AVPlayerLayer *playerLayer;

- (instancetype)initWithFrame:(CGRect)frame player:(AVPlayer *)player;

@end
