#import <Foundation/Foundation.h>

@interface PGCameraShotMetadata : NSObject

@property (nonatomic, assign) CGFloat deviceAngle;
@property (nonatomic, assign) bool frontal;

+ (CGFloat)relativeDeviceAngleFromAngle:(CGFloat)angle orientation:(UIInterfaceOrientation)orientation;

@end
