#import <Foundation/Foundation.h>

@protocol TGModernGalleryTransitionView <NSObject>

@required

- (UIImage *)transitionImage;

@optional

- (CGRect)transitionContentRect;

@end
