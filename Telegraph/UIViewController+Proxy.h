#import <UIKit/UIKit.h>

@interface UIViewController (Proxy)

- (void)setProxyDismissBlock:(void (^)(bool))block;

@end
