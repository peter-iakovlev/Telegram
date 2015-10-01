#import <UIKit/UIKit.h>

@interface TGLinkTargetView : UIView

@property (nonatomic, copy) void (^tap)(CGPoint);

@end
