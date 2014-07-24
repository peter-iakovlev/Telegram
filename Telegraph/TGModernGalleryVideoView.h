#import <UIKit/UIKit.h>

@class AVPlayerLayer;

@interface TGModernGalleryVideoView : UIView

- (AVPlayerLayer *)playerLayer;

- (instancetype)initWithFrame:(CGRect)frame playerLayer:(AVPlayerLayer *)playerLayer;

@end
