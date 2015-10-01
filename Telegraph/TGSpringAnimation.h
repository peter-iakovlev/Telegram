#import <Foundation/Foundation.h>

@interface TGSpringAnimation : NSObject

+ (CAKeyframeAnimation *)animationWithKeypath:(NSString *)keypath duration:(CFTimeInterval)duration usingSpringWithDamping:(CGFloat)usingSpringWithDamping initialSpringVelocity:(CGFloat)initialSpringVelocity fromPosition:(CGPoint)fromPosition toPosition:(CGPoint)toPosition;

@end
