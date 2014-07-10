#import <UIKit/UIKit.h>

@interface TGVibrantActionSheetAction : NSObject

- (instancetype)initWithTitle:(NSString *)title action:(NSString *)action;

@end

@interface TGVibrantActionSheet : UIView

- (instancetype)initWithTitle:(NSString *)title actions:(NSArray *)actions actionActivated:(void (^)(NSString *action))actionActivated;

- (void)showInView:(UIView *)view;

@end
