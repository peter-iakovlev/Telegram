#import <UIKit/UIKit.h>

@interface TGModernGalleryVideoFooterView : UIView

@property (nonatomic, copy) void (^playPressed)();
@property (nonatomic, copy) void (^pausePressed)();
@property (nonatomic, copy) void (^backwardPressed)();
@property (nonatomic, copy) void (^forwardPressed)();

@property (nonatomic) bool isPlaying;

@property (nonatomic, assign) NSTimeInterval duration;

@end
