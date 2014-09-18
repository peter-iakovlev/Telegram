#import "TGAppearance.h"

#import "TGViewController.h"

#import <CoreMotion/CoreMotion.h>

UIColor *TGAccentColor()
{
    static UIColor *color = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        color = UIColorRGB(0x007ee5);
    });
    return color;
}

UIColor *TGDestructiveAccentColor()
{
    static UIColor *color = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        color = UIColorRGB(0xff3b30);
    });
    return color;
}

UIColor *TGSelectionColor()
{
    static UIColor *color = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            color = UIColorRGB(0xe4e4e4);
        else
            color = UIColorRGB(0xd9d9d9);
    });
    return color;
}

UIColor *TGSeparatorColor()
{
    static UIColor *color = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        color = UIColorRGB(0xc8c7cc);
    });
    return color;
}

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