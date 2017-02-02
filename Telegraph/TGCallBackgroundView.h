#import <UIKit/UIKit.h>

@class TGCallSessionState;

@interface TGCallBackgroundView : UIImageView

@property (nonatomic, copy) void (^imageChanged)(UIImage *image);

- (void)setState:(TGCallSessionState *)state;

@end
