#import <UIKit/UIKit.h>

@interface TGModernGalleryZoomableScrollView : UIScrollView

@property (nonatomic, copy) void (^singleTapped)();
@property (nonatomic, copy) void (^doubleTapped)();

@end
