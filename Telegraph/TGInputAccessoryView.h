#import <UIKit/UIKit.h>

@interface TGInputAccessoryView : UIView

@property (nonatomic, assign) CGFloat initialPosition;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) bool ignore;
@property (nonatomic, copy) void (^didPan)(CGFloat offset);

@end
