#import <UIKit/UIKit.h>

@interface TGSecretPeerMediaProgressView : UIView

@property (nonatomic, assign) CGFloat progress;

@end

@interface TGSecretPeerMediaTimerView : UIView

@property (nonatomic, strong, readonly) UIImageView *infoBackgroundView;
@property (nonatomic, strong, readonly) TGSecretPeerMediaProgressView *progressView;

@end
