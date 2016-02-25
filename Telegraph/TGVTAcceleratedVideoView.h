#import <UIKit/UIKit.h>

@interface TGVTAcceleratedVideoView : UIView

@property (nonatomic) CGSize videoSize;

- (void)setPath:(NSString *)path;
- (void)prepareForRecycle;

@end
