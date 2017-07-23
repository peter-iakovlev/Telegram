#import <UIKit/UIKit.h>

@class TGCircularProgressView;

@interface TGSecretPeerMediaTimerView : UIView

@property (nonatomic, strong, readonly) UIImageView *infoBackgroundView;
@property (nonatomic, strong, readonly) UIImageView *timerFrameView;
@property (nonatomic, strong, readonly) TGCircularProgressView *progressView;
@property (nonatomic, strong, readonly) UILabel *progressLabel;

@end
