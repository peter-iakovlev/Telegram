#import <UIKit/UIKit.h>

@interface TGForceTouchGestureRecognizer : UILongPressGestureRecognizer

@property (nonatomic, readonly, getter=isTriggered) bool triggered;

- (bool)forceTouchAvailable;

@end
