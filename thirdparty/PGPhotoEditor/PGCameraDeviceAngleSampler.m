#import "PGCameraDeviceAngleSampler.h"

#import <CoreMotion/CoreMotion.h>

#import "TGPhotoEditorUtils.h"

@interface PGCameraDeviceAngleSampler ()
{
    CMMotionManager *_motionManager;
    NSOperationQueue *_motionQueue;
}
@end

@implementation PGCameraDeviceAngleSampler

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _deviceOrientation = UIDeviceOrientationUnknown;
        
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.accelerometerUpdateInterval = 0.5f;
        _motionQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self stopMeasuring];
}

- (bool)isMeasuring
{
    return [_motionManager isDeviceMotionActive];
}

- (void)stopMeasuring
{
    [_motionManager stopDeviceMotionUpdates];
}

- (void)startMeasuring
{    
    if (![_motionManager isDeviceMotionAvailable])
        return;
    
    __weak PGCameraDeviceAngleSampler *weakSelf = self;
    [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical toQueue:_motionQueue withHandler:^(CMDeviceMotion *motion, __unused NSError *error)
    {
        __strong PGCameraDeviceAngleSampler *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_currentDeviceAngle = TGRadiansToDegrees((CGFloat)(atan2(motion.gravity.x, motion.gravity.y) - M_PI)) * -1;

        CGFloat angle = (CGFloat)M_PI / 2.0f - (CGFloat)atan2(motion.gravity.y, motion.gravity.x);
        if (angle > M_PI)
            angle -= 2 * M_PI;
        
        UIDeviceOrientation orientation = UIDeviceOrientationUnknown;
        
        if ((motion.gravity.z > -0.90f) && (motion.gravity.z < 0.90f))
        {
            if ((angle > -M_PI_4) && (angle < M_PI_4))
                orientation = UIDeviceOrientationPortraitUpsideDown;
            else if ((angle < -M_PI_4) && (angle > -3 * M_PI_4))
                orientation = UIDeviceOrientationLandscapeLeft;
            else if ((angle > M_PI_4) && (angle < 3 * M_PI_4))
                orientation = UIDeviceOrientationLandscapeRight;
            else
                orientation = UIDeviceOrientationPortrait;
        }
        
        if (orientation != UIDeviceOrientationUnknown && orientation != strongSelf.deviceOrientation)
        {
            TGDispatchOnMainThread(^
            {
                strongSelf->_deviceOrientation = orientation;

                if (strongSelf.deviceOrientationChanged != nil)
                    strongSelf.deviceOrientationChanged(orientation);
            });
        }
        
//        [_orientationQueue dispatch:^
//        {
//            PGCameraDeviceOrientationVector *gravityVector = strongSelf->_gravityVector;
//            if (gravityVector == nil)
//            {
//                gravityVector = [[PGCameraDeviceOrientationVector alloc] initWithDeviceOrientation:UIDeviceOrientationUnknown vector:(PGVector4)
//                {
//                    .x = 0.0f,
//                    .y = 0.0f,
//                    .z = 0.0f,
//                    .w = 1.0f
//                }];
//            }
//            CGFloat gravityX = (CGFloat)motion.gravity.x * PGCameraFilteringFactor + gravityVector.vector.x * (1.0f - PGCameraFilteringFactor);
//            CGFloat gravityY = (CGFloat)motion.gravity.y * PGCameraFilteringFactor + gravityVector.vector.y * (1.0f - PGCameraFilteringFactor);
//            CGFloat gravityZ = (CGFloat)motion.gravity.z * PGCameraFilteringFactor + gravityVector.vector.z * (1.0f - PGCameraFilteringFactor);
//            
//            gravityVector = [[PGCameraDeviceOrientationVector alloc] initWithDeviceOrientation:UIDeviceOrientationUnknown vector:(PGVector4)
//            {
//                .x = gravityX,
//                .y = gravityY,
//                .z = gravityZ,
//                .w = 1.0f
//            }];
//            strongSelf->_gravityVector = gravityVector;
//            
//            PGCameraDeviceOrientationVector *closestVector = nil;
//            CGFloat minDistance = CGFLOAT_MAX;
//            for (PGCameraDeviceOrientationVector *vector in strongSelf->_deviceOrientationVectors)
//            {
//                CGFloat distance = [vector distanceToVector:gravityVector];
//                if (distance < minDistance)
//                {
//                    minDistance = distance;
//                    closestVector = vector;
//                }
//            }
//            
//            if (closestVector.orientation != strongSelf.deviceOrientation)
//            {
//                TGDispatchOnMainThread(^
//                {
//                    strongSelf->_deviceOrientation = closestVector.orientation;
//                   
//                    if (strongSelf.deviceOrientationChanged != nil)
//                        strongSelf.deviceOrientationChanged(strongSelf->_deviceOrientation);
//                });
//            }
//        }];
        
//        CGFloat pitch = TGRadiansToDegrees((CGFloat)(atan2(motion.gravity.z, motion.gravity.y) - M_PI));
//
//        CMQuaternion quat = motion.attitude.quaternion;
//        CGFloat roll2 = TGRadiansToDegrees((CGFloat)asin(2 * (quat.x * quat.z - quat.w * quat.y)));
//        CGFloat pitch2 = TGRadiansToDegrees((CGFloat)atan2(2 * (quat.x * quat.w + quat.y * quat.z), 1 - 2 * quat.x * quat.x - 2 * quat.z * quat.z)) - 90.0f;
//        
//        CMRotationMatrix matrix = remap(motion.attitude.rotationMatrix, 1, 3);
//        CGFloat roll3 = TGRadiansToDegrees((CGFloat)atan2(-matrix.m31, matrix.m33));
//        CGFloat pitch3 = -TGRadiansToDegrees((CGFloat)-asin(matrix.m32));
    }];
}



//CMRotationMatrix remap(CMRotationMatrix rotationMatrix, NSInteger X, NSInteger Y)
//{
//    double inR[9] = { rotationMatrix.m11, rotationMatrix.m12, rotationMatrix.m13,
//                      rotationMatrix.m21, rotationMatrix.m22, rotationMatrix.m23,
//                      rotationMatrix.m31, rotationMatrix.m32, rotationMatrix.m33
//    };
//    double outR[9] = { 0, 0, 0, 0, 0, 0, 0, 0, 0 };
//    
//    NSInteger Z = X ^ Y;
//    
//    NSInteger x = (X & 0x3) - 1;
//    NSInteger y = (Y & 0x3) - 1;
//    NSInteger z = (Z & 0x3) - 1;
//    
//    NSInteger yAxis = (z + 1) % 3;
//    NSInteger zAxis = (z + 2) % 3;
//    
//    if (((x ^ yAxis) | (y ^ zAxis)) != 0)
//        Z ^= 0x80;
//    
//    bool sX = (X >= 0x80);
//    bool sY = (Y >= 0x80);
//    bool sZ = (Z >= 0x80);
//    
//    NSInteger rowLength = 3;
//    for (NSInteger j = 0; j < 3; j++)
//    {
//        NSInteger offset = j * rowLength;
//        for (NSInteger i = 0; i < 3; i++)
//        {
//            if (x == i)
//                outR[offset + i] = (sX * -2 + 1) * inR[offset + 0];
//            
//            if (y == i)
//                outR[offset + i] = (sY * -2 + 1) * inR[offset + 1];
//            
//            if (z == i)
//                outR[offset + i] = (sZ * -2 + 1) * inR[offset + 2];
//        }
//    }
//    
//    return (CMRotationMatrix) { .m11 = outR[0], .m12 = outR[1], .m13 = outR[2],
//                                .m21 = outR[3], .m22 = outR[4], .m23 = outR[5],
//                                .m31 = outR[6], .m32 = outR[7], .m33 = outR[8]
//    };
//};

@end
