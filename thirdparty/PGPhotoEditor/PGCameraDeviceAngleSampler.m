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
    }];
}

@end
