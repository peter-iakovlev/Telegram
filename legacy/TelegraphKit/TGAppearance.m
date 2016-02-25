#import "TGAppearance.h"

#import "TGViewController.h"

#import <CoreMotion/CoreMotion.h>

bool TGBackdropEnabled()
{
    return false;
    
    static bool value = false;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        value = iosMajorVersion() >= 7 && [TGViewController isWidescreen] && [CMMotionActivityManager isActivityAvailable];
    });
#if TARGET_IPHONE_SIMULATOR
    //return false;
#endif
    return value;
}