#import <UIKit/UIKit.h>

@class TGCallSessionState;
@class TGCallCommState;

@interface TGCallAvatarView : UIView

- (void)setState:(TGCallSessionState *)state;
- (void)setLevel:(CGFloat)level;

@end

extern const CGSize TGCallAvatarLargeSize;
