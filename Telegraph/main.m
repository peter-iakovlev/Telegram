#import <UIKit/UIKit.h>

#import "TGAppDelegate.h"
#import "TGApplication.h"

int main(int argc, char *argv[])
{
    mainLaunchTimestamp = CFAbsoluteTimeGetCurrent();
    applicationStartupTimestamp = mainLaunchTimestamp;
    
    @autoreleasepool
    {
        [TGAppDelegate beginEarlyInitialization];
        
        return UIApplicationMain(argc, argv, @"TGApplication", @"TGAppDelegate");
    }
}
