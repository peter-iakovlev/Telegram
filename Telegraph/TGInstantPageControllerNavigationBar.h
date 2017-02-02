#import <UIKit/UIKit.h>

@interface TGInstantPageControllerNavigationBar : UIView

@property (nonatomic, copy) void (^backPressed)();
@property (nonatomic, copy) void (^sharePressed)();
@property (nonatomic, copy) void (^scrollToTop)();

@end
