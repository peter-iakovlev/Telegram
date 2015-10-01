#import <UIKit/UIKit.h>

@interface TGMusicPlayerScrubbingArea : UISlider

@property (nonatomic, copy) void (^didBeginDragging)(UITouch *);
@property (nonatomic, copy) void (^didFinishDragging)();
@property (nonatomic, copy) void (^didCancelDragging)();
@property (nonatomic, copy) void (^willMove)(UITouch *);

@end
