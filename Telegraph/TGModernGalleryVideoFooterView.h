#import <UIKit/UIKit.h>

@interface TGModernGalleryVideoFooterView : UIView

@property (nonatomic, copy) void (^playPressed)();
@property (nonatomic, copy) void (^pausePressed)();

@property (nonatomic) bool isPlaying;

@end
